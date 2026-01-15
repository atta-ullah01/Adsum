import 'package:adsum/data/repositories/enrollment_repository.dart';
import 'package:adsum/data/repositories/schedule_repository.dart';
import 'package:adsum/data/repositories/work_repository.dart';
import 'package:adsum/data/repositories/calendar_repository.dart';
import 'package:adsum/data/repositories/schedule_modification_repository.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/domain/models/schedule_modification.dart';
import 'package:flutter/material.dart';

/// Service to calculate the effective schedule by merging L1, L2, and L3 layers
class ScheduleService {
  ScheduleService(
    this._enrollmentRepo,
    this._scheduleRepo,
    this._workRepo,
    this._calendarRepo,
    this._modificationRepo,
  );

  final EnrollmentRepository _enrollmentRepo;
  final ScheduleRepository _scheduleRepo;
  final WorkRepository _workRepo;
  final CalendarRepository _calendarRepo;
  final ScheduleModificationRepository _modificationRepo;

  /// Get events for a specific date
  Future<List<ScheduleEvent>> getEventsForDate(DateTime date) async {
    // parallel fetch
    final results = await Future.wait<Object>([
      _enrollmentRepo.getEnrollments(),
      _scheduleRepo.getCustomSlots(),
      _workRepo.getAll(), // TODO: Filter by date efficiently in repo
      _calendarRepo.getEventsForDate(date),
      _modificationRepo.getForDate(date),
    ]);

    final enrollments = results[0] as List<Enrollment>;
    final customSlots = results[1] as List<CustomScheduleSlot>;
    final allWork = results[2] as List<Work>;
    final calendarEvents = results[3] as List<CalendarEvent>;
    final modifications = results[4] as List<ScheduleModification>;

    final events = <ScheduleEvent>[];

    // --- 0. Check for Day Swap ---
    // If there's a DAY_SWAP event on this date, use that day's schedule instead.
    DayOfWeek effectiveDayOfWeek = _getDayOfWeek(date);
    CalendarEvent? daySwapEvent;
    
    for (final calEvent in calendarEvents) {
      if (calEvent.type == CalendarEventType.daySwap && 
          calEvent.dayOrderOverride != null &&
          calEvent.isActive) {
        daySwapEvent = calEvent;
        effectiveDayOfWeek = DayOfWeek.fromString(calEvent.dayOrderOverride);
        break; // Only one Day Swap per day
      }
    }

    // --- 1. Course Schedule (L3: Custom & L1: Global) ---
    // Use effectiveDayOfWeek instead of actual day
    final courseEvents = _generateCourseEvents(date, enrollments, customSlots, effectiveDayOfWeek);
    
    // --- 2. Apply L2: Modifications (Cancel, Reschedule, Swap) ---
    final effectiveCourseEvents = _applyModifications(courseEvents, modifications);
    events.addAll(effectiveCourseEvents);

    // --- 3. Work Events (Assignments, Exams) ---
    for (final work in allWork) {
      if (work.dueAt != null && _isSameDay(work.dueAt!, date)) {
        // If it's a super event (e.g. Exam), it blocks time
        if (work.isSuperEvent && work.startAt != null) {
          final endTime = work.startAt!.add(Duration(minutes: work.durationMinutes ?? 60));
          events.add(ScheduleEvent(
            id: work.workId,
            title: work.title,
            subtitle: '${work.courseCode} • ${work.venue ?? "TBD"}',
            startTime: work.startAt!,
            endTime: endTime,
            type: ScheduleEventType.exam,
            color: '#EC4899', // Pink for exams
            location: work.venue,
            metadata: {'type': 'EXAM', 'work_type': work.workType.name},
          ));
        } else {
           // Assignment due date - represented as an event or handled separately?
           // For now, let's treat it as a task/deadline, maybe 1hr slot at due time if not startAt
            events.add(ScheduleEvent(
            id: work.workId,
            title: work.title,
            subtitle: '${work.courseCode} • Due ${work.dueAt!.hour}:${work.dueAt!.minute}',
            startTime: work.dueAt!.subtract(const Duration(minutes: 30)), // Mock slot
            endTime: work.dueAt!,
            type: ScheduleEventType.event,
            color: '#F59E0B', // Orange for assignments
            metadata: {'type': 'ASSIGNMENT', 'work_type': work.workType.name},
          ));
        }
      }
    }

    // --- 4. Personal Calendar Events ---
    for (final calEvent in calendarEvents) {
      if (!calEvent.isActive) continue;
      
      // Parse times if available, else all day
      DateTime start = date;
      DateTime end = date.add(const Duration(hours: 1)); 

      if (calEvent.startTime != null) {
         start = _parseTime(date, calEvent.startTime!);
         if (calEvent.endTime != null) {
           end = _parseTime(date, calEvent.endTime!);
         } else {
           end = start.add(const Duration(hours: 1));
         }
      }

      events.add(ScheduleEvent(
        id: calEvent.eventId,
        title: calEvent.title,
        subtitle: calEvent.type.displayName,
        startTime: start,
        endTime: end,
        type: _mapCalendarTypeToScheduleType(calEvent.type),
        color: _getColorForCalendarType(calEvent.type),
        metadata: {'type': 'PERSONAL', 'calendar_type': calEvent.type.name},
      ));
    }

    // Sort by start time before processing conflicts
    events.sort((a, b) => a.startTime.compareTo(b.startTime));

    // --- 5. Resolve Conflicts ---
    final resolvedEvents = _resolveConflicts(events);



    return resolvedEvents;
  }

  /// Merges overlapping events into a single Conflict card
  List<ScheduleEvent> _resolveConflicts(List<ScheduleEvent> inputEvents) {
    if (inputEvents.isEmpty) return [];
    
    final resolved = <ScheduleEvent>[];
    List<ScheduleEvent> currentCluster = [];
    DateTime? clusterEnd;

    for (final event in inputEvents) {
       if (event.isCancelled) {
         resolved.add(event);
         continue;
       }

       if (currentCluster.isEmpty) {
         currentCluster.add(event);
         clusterEnd = event.endTime;
       } else {
         // Check overlap: if event starts before cluster ends
         // Allow 1 minute buffer or strict overlap? Strict for now.
         if (event.startTime.isBefore(clusterEnd!)) {
            currentCluster.add(event);
            if (event.endTime.isAfter(clusterEnd)) {
              clusterEnd = event.endTime;
            }
         } else {
           _flushCluster(resolved, currentCluster);
           currentCluster = [event];
           clusterEnd = event.endTime;
         }
       }
    }
    _flushCluster(resolved, currentCluster);
    return resolved;
  }

  void _flushCluster(List<ScheduleEvent> out, List<ScheduleEvent> cluster) {
    if (cluster.isEmpty) return;
    if (cluster.length == 1) {
      out.add(cluster.first);
    } else {
      // Merge into conflict card
      final start = cluster.map((e) => e.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
      final end = cluster.map((e) => e.endTime).reduce((a, b) => a.isAfter(b) ? a : b);
      
      out.add(ScheduleEvent(
        id: 'conflict_${start.millisecondsSinceEpoch}',
        title: '${cluster.length} Events Conflict',
        subtitle: 'Tap to resolve',
        startTime: start,
        endTime: end,
        type: ScheduleEventType.conflict,
        color: '#EF4444', // Red
        conflictingEvents: List.from(cluster),
        metadata: {'conflict_count': cluster.length}
      ));
    }
  }

  List<ScheduleEvent> _generateCourseEvents(
    DateTime date, 
    List<Enrollment> enrollments, 
    List<CustomScheduleSlot> customSlots,
    DayOfWeek effectiveDayOfWeek, // For Day Swap support
  ) {
    final events = <ScheduleEvent>[];
    final todayDayOfWeek = effectiveDayOfWeek; // Use effective day, not actual

    for (final enrollment in enrollments) {
      if (enrollment.isCustom) {
         // Custom Slots
         final relevantSlots = customSlots.where((s) => 
            s.enrollmentId == enrollment.enrollmentId && 
            s.dayOfWeek == todayDayOfWeek
        );

        for (final slot in relevantSlots) {
          final start = _parseTime(date, slot.startTime);
          final end = _parseTime(date, slot.endTime);
          
          events.add(ScheduleEvent(
            id: slot.ruleId,
            title: enrollment.courseName,
            subtitle: enrollment.customCourse?.instructor ?? 'Custom Course',
            startTime: start,
            endTime: end,
            type: ScheduleEventType.classSession,
            color: enrollment.colorTheme,
            enrollmentId: enrollment.enrollmentId,
            location: 'TBD', // TODO: Bindings
            metadata: {'course_code': enrollment.courseCode, 'section': 'A'},
          ));
        }
      } else {
        // Global Courses (Mock/L1) - Now explicitly supporting all weekdays for demo
        if (date.weekday <= 5) {
           bool shouldAdd = false;
           // Simple hash logic to distribute courses across days
           // Monday (1): Odd hash
           // Tuesday (2): Even hash
           // ...
           // Forcing classes for demo:
           shouldAdd = true; 

           if (shouldAdd) {
             final hash = enrollment.courseCode.hashCode;
             int startHour = 9 + (hash % 6); // 9am - 3pm
             
             // FORCE CONFLICT FOR DEMO on Jan 15 (Thursday)
             // "Project Discussion" is 16:00-17:00.
             // Let's make one course land at 16:00 on this day.
             if (date.year == 2026 && date.month == 1 && date.day == 15 && enrollment.courseCode == 'COL106') {
                startHour = 16;
             }

             final start = DateTime(date.year, date.month, date.day, startHour, 0);
             final end = start.add(const Duration(hours: 1));
             
             events.add(ScheduleEvent(
              id: 'mock_${enrollment.enrollmentId}_${date.weekday}',
              title: enrollment.courseName, // Use course name or code
              subtitle: 'Lecture • LH-${(hash % 5) + 1}',
              startTime: start,
              endTime: end,
              type: ScheduleEventType.classSession,
              color: enrollment.colorTheme,
              enrollmentId: enrollment.enrollmentId,
              location: 'LH-${(hash % 5) + 1}',
              metadata: {'course_code': enrollment.courseCode, 'section': 'A'},
            ));
           }
        }
      }
    }
    return events;
  }

  /// Apply L2 modifications (Cancel, Reschedule, SwapRoom)
  List<ScheduleEvent> _applyModifications(
    List<ScheduleEvent> baseEvents, 
    List<ScheduleModification> modifications
  ) {
    if (modifications.isEmpty) return baseEvents;

    final processedEvents = <ScheduleEvent>[];
    
    // Create a map for quick lookup of modifications by course code?
    // Actually modifications might target specific rules, but here we mock rules.
    // Let's match by course code for now since we don't have stable rule IDs in this mock L1.

    for (var event in baseEvents) {
      final courseCode = event.metadata['course_code'];
      if (courseCode == null) {
        processedEvents.add(event);
        continue;
      }
      
      // Find relevant modification
      // In real scenario, match by ruleId. Here match by courseCode + action type
      try {
        final mod = modifications.firstWhere((m) => m.courseCode == courseCode);
        
        // Check if this specific instance is affected? 
        // Mock simplification: usage of mod on the day applies to any class of that course on that day.
        
        switch (mod.action) {
          case ModificationAction.cancel:
            // Add as cancelled event
             processedEvents.add(ScheduleEvent(
              id: event.id,
              title: event.title,
              subtitle: 'Cancelled: ${mod.note ?? "No reason provided"}',
              startTime: event.startTime,
              endTime: event.endTime,
              type: event.type,
              color: '#9CA3AF', // Gray for cancelled
              isCancelled: true,
              enrollmentId: event.enrollmentId,
              location: event.location,
              metadata: {...event.metadata, 'status': 'CANCELLED'},
            ));
            break;
            
          case ModificationAction.swapRoom:
             processedEvents.add(ScheduleEvent(
              id: event.id,
              title: event.title,
              subtitle: 'Room Changed to ${mod.newLocation}',
              startTime: event.startTime,
              endTime: event.endTime,
              type: event.type,
              color: event.color,
              enrollmentId: event.enrollmentId,
              location: mod.newLocation, // Update location
              metadata: {...event.metadata, 'status': 'ROOM_SWAP', 'new_location': mod.newLocation},
            ));
            break;
            
          case ModificationAction.reschedule:
             // Remove original, add new slot
             if (mod.newDate != null && mod.newStartTime != null && mod.newEndTime != null) {
                // Determine new start/end
                final newStart = _parseTime(mod.newDate!, mod.newStartTime!);
                final newEnd = _parseTime(mod.newDate!, mod.newEndTime!);
                
                processedEvents.add(ScheduleEvent(
                  id: '${event.id}_rescheduled',
                  title: event.title,
                  subtitle: 'Rescheduled: ${mod.newLocation ?? event.location}',
                  startTime: newStart,
                  endTime: newEnd,
                  type: event.type,
                  color: event.color,
                  enrollmentId: event.enrollmentId,
                  location: mod.newLocation ?? event.location,
                  metadata: {...event.metadata, 'status': 'RESCHEDULED'},
                ));
             }
            break;
            
          default:
            processedEvents.add(event);
        }
      } catch (_) {
        // No modification for this event
        processedEvents.add(event);
      }
    }
    
    // Handle "Extra Class" - additions not modifying existing
    // We would need to loop modifications again to find extra classes not bound to existing events
    // Skipping for brevity unless requested.

    return processedEvents;
  }

  DayOfWeek _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return DayOfWeek.mon;
      case DateTime.tuesday: return DayOfWeek.tue;
      case DateTime.wednesday: return DayOfWeek.wed;
      case DateTime.thursday: return DayOfWeek.thu;
      case DateTime.friday: return DayOfWeek.fri;
      case DateTime.saturday: return DayOfWeek.sat;
      case DateTime.sunday: return DayOfWeek.sun;
      default: return DayOfWeek.mon;
    }
  }

  DateTime _parseTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool _isSameDay(DateTime a, DateTime b) => 
      a.year == b.year && a.month == b.month && a.day == b.day;
      
  String _getColorForCalendarType(CalendarEventType type) {
     switch (type) {
       case CalendarEventType.personal: return '#8B5CF6';
       case CalendarEventType.holiday: return '#EF4444';
       case CalendarEventType.exam: return '#EC4899';
       // Day swap handled as global modification usually, but if event:
       case CalendarEventType.daySwap: return '#3B82F6';
       case CalendarEventType.quiz: return '#EAB308';
       case CalendarEventType.assignment: return '#F59E0B'; // Orange
       default: return '#9CA3AF';
     }
  }

  ScheduleEventType _mapCalendarTypeToScheduleType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.exam:
      case CalendarEventType.quiz:
        return ScheduleEventType.exam; // Treat quizzes as exams for schedule priority
      case CalendarEventType.assignment:
        return ScheduleEventType.event;
      case CalendarEventType.holiday:
        return ScheduleEventType.holiday;
      case CalendarEventType.personal:
      case CalendarEventType.daySwap:
      default:
        return ScheduleEventType.personal;
    }
  }
}
