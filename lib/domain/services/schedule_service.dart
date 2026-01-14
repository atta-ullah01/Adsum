import 'package:adsum/data/repositories/enrollment_repository.dart';
import 'package:adsum/data/repositories/schedule_repository.dart';
import 'package:adsum/domain/models/models.dart';

/// Service to calculate the effective schedule by merging L1, L2, and L3 layers
class ScheduleService {
  ScheduleService(this._enrollmentRepo, this._scheduleRepo);

  final EnrollmentRepository _enrollmentRepo;
  final ScheduleRepository _scheduleRepo;

  /// Get events for a specific date
  Future<List<ScheduleEvent>> getEventsForDate(DateTime date) async {
    final enrollments = await _enrollmentRepo.getEnrollments();
    final customSlots = await _scheduleRepo.getCustomSlots();
    // In future: final l1Rules = await _globalScheduleRepo.getRules();
    // In future: final l2Patches = await _patchRepo.getPatches(date);

    final events = <ScheduleEvent>[];

    // 1. Process Custom Course Slots (L3)
    // Filter slots for this day of week
    final todayDayOfWeek = _getDayOfWeek(date);
    
    for (final enrollment in enrollments) {
      if (!enrollment.isCustom) continue;
      
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
          // TODO: Fetch binding location
          location: 'TBD',
        ));
      }
    }

    // 2. Process Global Courses (L1) - MOCK for now
    // This logic handles catalog courses which we don't have real data for yet
    for (final enrollment in enrollments) {
      if (enrollment.isCustom) continue;
      
      // MOCK: Generate fixed slots for demo purposes if it's a weekday
      if (date.weekday <= 5) {
        // Mock schedule based on simple hash of course code
        final hash = enrollment.courseCode.hashCode;
        final startHour = 9 + (hash % 6); // 9am to 3pm
        final start = DateTime(date.year, date.month, date.day, startHour, 0);
        final end = start.add(const Duration(hours: 1));
        
        events.add(ScheduleEvent(
          id: 'mock_${enrollment.enrollmentId}',
          title: enrollment.courseName,
          subtitle: 'Global Course (Mock)',
          startTime: start,
          endTime: end,
          type: ScheduleEventType.classSession,
          color: enrollment.colorTheme,
          enrollmentId: enrollment.enrollmentId,
          location: 'L${(hash % 5) + 1}',
        ));
      }
    }

    // Sort by start time
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
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
}
