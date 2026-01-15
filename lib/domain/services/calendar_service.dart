import 'package:adsum/data/repositories/calendar_repository.dart';
import 'package:adsum/data/repositories/work_repository.dart';
import 'package:adsum/domain/models/calendar_event.dart';
import 'package:adsum/domain/models/work.dart';

import 'package:uuid/uuid.dart';

/// Service for calendar management
class CalendarService {
  final CalendarRepository _repository;
  final WorkRepository _workRepository;
  static const _uuid = Uuid();

  CalendarService(this._repository, this._workRepository);

  // ============ Event Queries ============

  /// Get all events (excluding hidden)
  Future<List<CalendarEvent>> getAllEvents() async {
    // 1. Fetch persistent events (Personal, Holiday, DaySwap)
    final persistentEvents = await _repository.getAll();
    
    // 2. Fetch course work (Assignments, Exams, Quizzes)
    final allWork = await _workRepository.getAll();
    final derivedEvents = <CalendarEvent>[];
    
    for (final work in allWork) {
      // Determine date and times
      final date = work.workType == WorkType.assignment || work.workType == WorkType.project
          ? work.dueAt // Deadline
          : work.startAt; // Exam/Quiz start
          
      if (date == null) continue;
      
      // Determine type
      CalendarEventType type;
      switch (work.workType) {
        case WorkType.exam:
          type = CalendarEventType.exam;
          break;
        case WorkType.quiz:
          type = CalendarEventType.quiz;
          break;
        case WorkType.assignment:
        case WorkType.project:
          type = CalendarEventType.assignment;
          break;
      }
      
      // Create derived event (read-only in calendar)
      derivedEvents.add(CalendarEvent(
        eventId: "derived_${work.workId}", // Prevent ID collision
        title: work.title,
        date: date,
        startTime: work.startAt != null 
            ? "${work.startAt!.hour.toString().padLeft(2, '0')}:${work.startAt!.minute.toString().padLeft(2, '0')}"
            : null,
        endTime: work.workType == WorkType.quiz && work.durationMinutes != null && work.startAt != null
            ? _formatEndTime(work.startAt!, work.durationMinutes!)
            : null,
        type: type,
        description: work.description ?? "${work.courseCode} ${work.workType.name}",
        isActive: true, // Always active unless specifically hidden in overrides
      ));
    }

    // 3. Merge and Filter
    final allEvents = [...persistentEvents, ...derivedEvents];
    final overrides = await _repository.getAllOverrides();
    final hiddenIds = overrides.where((o) => o.isHidden).map((o) => o.calendarId).toSet();
    
    return allEvents.where((e) => e.isActive && !hiddenIds.contains(e.eventId)).toList();
  }

  /// Get events for a specific date (excluding hidden)
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final all = await getAllEvents(); // Re-use merge logic (slightly inefficient but safe)
    return all.where((e) => e.isOnDate(date)).toList();
  }

  /// Get upcoming events (next N days)
  Future<List<CalendarEvent>> getUpcoming({int days = 7}) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    
    final all = await getAllEvents(); // Re-use merge logic
    
    final events = all.where((e) {
      if (!e.isActive) return false;
      // Compare dates (ignore time)
      final eDate = DateTime(e.date.year, e.date.month, e.date.day);
      final nowDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return !eDate.isBefore(nowDate) && !eDate.isAfter(endDate);
    }).toList();
    
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  /// Get event count for a date
  Future<int> getEventCount(DateTime date) async {
    final events = await getEventsForDate(date);
    return events.length;
  }

  // ============ Event Actions ============

  /// Add a new event
  Future<CalendarEvent> addEvent({
    required String title,
    required DateTime date,
    String? startTime,
    String? endTime,
    CalendarEventType type = CalendarEventType.personal,
    String? description,
  }) async {
    final event = CalendarEvent(
      eventId: _uuid.v4(),
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      type: type,
      description: description,
    );
    
    await _repository.saveEvent(event);
    return event;
  }

  /// Update an existing event
  Future<void> updateEvent(CalendarEvent event) async {
    // Prevent updating derived events
    if (event.eventId.startsWith("derived_")) {
      throw Exception("Cannot edit official academic events from the calendar.");
    }
    await _repository.saveEvent(event);
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    // Prevent deleting derived events
    if (eventId.startsWith("derived_")) {
      throw Exception("Cannot delete official academic events from the calendar. Use 'Hide' instead.");
    }
    await _repository.deleteEvent(eventId);
  }

  // ============ Visibility ============

  /// Toggle event visibility
  Future<bool> toggleVisibility(String eventId) async {
    final overrides = await _repository.getAllOverrides();
    final index = overrides.indexWhere((o) => o.calendarId == eventId);
    
    if (index >= 0) {
      final override = overrides[index];
      if (override.isHidden) {
        await _repository.deleteOverride(eventId);
        return true; // Now visible
      }
    }
    
    await _repository.saveOverride(CalendarOverride(calendarId: eventId, isHidden: true));
    return false; // Now hidden
  }

  /// Check if hidden
  Future<bool> isHidden(String eventId) async {
    final overrides = await _repository.getAllOverrides();
    return overrides.any((o) => o.calendarId == eventId && o.isHidden);
  }
  
  String _formatEndTime(DateTime start, int minutes) {
    final end = start.add(Duration(minutes: minutes));
    return "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
  }
}
