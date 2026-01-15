import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adsum/data/sources/local/app_database.dart' hide Enrollment;
import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/data/repositories/repositories.dart';
import 'package:adsum/data/repositories/shared_data_repository.dart';
import 'package:adsum/data/validation/data_validation.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/domain/services/services.dart';
import 'package:adsum/core/services/permission_service.dart';

// ============ Core Services ============

/// Main database instance (singleton)
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// JSON file service (singleton)
final jsonFileServiceProvider = Provider<JsonFileService>((ref) {
  return JsonFileService();
});

/// Data validation service
final dataValidationProvider = Provider<DataValidationService>((ref) {
  return DataValidationService();
});

// ============ Repositories ============

/// User repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(jsonFileServiceProvider));
});

/// Enrollment repository
final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepository(ref.watch(jsonFileServiceProvider));
});

/// Attendance repository
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(jsonFileServiceProvider));
});

/// Action item repository
final actionItemRepositoryProvider = Provider<ActionItemRepository>((ref) {
  return ActionItemRepository(ref.watch(jsonFileServiceProvider));
});

/// Schedule repository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(jsonFileServiceProvider));
});

/// Work repository (assignments, quizzes, exams)
final workRepositoryProvider = Provider<WorkRepository>((ref) {
  return WorkRepository(ref.watch(jsonFileServiceProvider));
});

/// Syllabus repository
final syllabusRepositoryProvider = Provider<SyllabusRepository>((ref) {
  return SyllabusRepository(ref.watch(jsonFileServiceProvider));
});

/// Mess repository
final messRepositoryProvider = Provider<MessRepository>((ref) {
  return MessRepository(ref.watch(jsonFileServiceProvider));
});

/// Calendar repository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.watch(jsonFileServiceProvider));
});

/// Shared Data repository (Universities, Hostels)
final sharedDataRepositoryProvider = Provider<SharedDataRepository>((ref) {
  return SharedDataRepository();
});

/// Permission service (for Sensor Hub)
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// ============ Service Providers ============

/// Schedule service
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    ref.watch(enrollmentRepositoryProvider),
    ref.watch(scheduleRepositoryProvider),
  );
});

/// Work service
final workServiceProvider = Provider<WorkService>((ref) {
  return WorkService(ref.watch(workRepositoryProvider));
});

/// Syllabus service
final syllabusServiceProvider = Provider<SyllabusService>((ref) {
  return SyllabusService(ref.watch(syllabusRepositoryProvider));
});

/// Mess service
final messServiceProvider = Provider<MessService>((ref) {
  return MessService(ref.watch(messRepositoryProvider));
});

/// Calendar service
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService(ref.watch(calendarRepositoryProvider));
});

// ============ Data Providers ============

/// Current user profile
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUser();
});

/// Schedule events for today
final todayScheduleProvider = FutureProvider<List<ScheduleEvent>>((ref) async {
  final service = ref.watch(scheduleServiceProvider);
  return service.getEventsForDate(DateTime.now());
});

/// Schedule events for selected date
final scheduleForDateProvider = FutureProvider.family<List<ScheduleEvent>, DateTime>(
  (ref, date) async {
    final service = ref.watch(scheduleServiceProvider);
    return service.getEventsForDate(date);
  },
);

/// All enrollments
final enrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  final repo = ref.watch(enrollmentRepositoryProvider);
  return repo.getEnrollments();
});

/// Pending action items
final pendingActionItemsProvider = FutureProvider<List<ActionItem>>((ref) async {
  final repo = ref.watch(actionItemRepositoryProvider);
  return repo.getPending();
});

/// Pending action count (for badges)
final pendingActionCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(actionItemRepositoryProvider);
  return repo.getPendingCount();
});

/// Attendance logs for a specific enrollment
final attendanceLogsProvider = FutureProvider.family<List<AttendanceLog>, String>(
  (ref, enrollmentId) async {
    final repo = ref.watch(attendanceRepositoryProvider);
    return repo.getLogsForEnrollment(enrollmentId);
  },
);

/// Today's attendance logs
final todayAttendanceProvider = FutureProvider<List<AttendanceLog>>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getLogsForDate(DateTime.now());
});

// ============ Phase 2A: Feature Providers ============

/// Pending work items (assignments, quizzes, etc.)
final pendingWorkProvider = FutureProvider<List<Work>>((ref) async {
  final service = ref.watch(workServiceProvider);
  return service.getPending();
});

/// Work items for a specific course
final courseWorkProvider = FutureProvider.family<List<Work>, String>(
  (ref, courseCode) async {
    final service = ref.watch(workServiceProvider);
    return service.getForCourse(courseCode);
  },
);

/// Syllabus progress for a course (list of completed topic IDs)
final syllabusProgressProvider = FutureProvider.family<List<String>, String>(
  (ref, courseCode) async {
    final service = ref.watch(syllabusServiceProvider);
    return service.getProgress(courseCode);
  },
);

/// Custom syllabus for a course
final customSyllabusProvider = FutureProvider.family<CustomSyllabus?, String>(
  (ref, courseCode) async {
    final service = ref.watch(syllabusServiceProvider);
    return service.getCustomSyllabus(courseCode);
  },
);

/// Today's mess menu
final todayMessMenuProvider = FutureProvider<List<MessMenu>>((ref) async {
  final service = ref.watch(messServiceProvider);
  return service.getCurrentHostelTodayMenus();
});

/// Mess menus for a specific day
final messMenuForDayProvider = FutureProvider.family<List<MessMenu>, MessDayOfWeek>(
  (ref, day) async {
    final service = ref.watch(messServiceProvider);
    return service.getMenusForDay(day);
  },
);

/// Personal calendar events
final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final service = ref.watch(calendarServiceProvider);
  return service.getAllEvents();
});

/// Calendar events for a specific date
final calendarEventsForDateProvider = FutureProvider.family<List<CalendarEvent>, DateTime>(
  (ref, date) async {
    final service = ref.watch(calendarServiceProvider);
    return service.getEventsForDate(date);
  },
);

/// Upcoming calendar events (next 7 days)
final upcomingEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final service = ref.watch(calendarServiceProvider);
  return service.getUpcoming();
});

// ============ Sync Providers ============

/// Pending sync count
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final items = await db.getPendingQueueItems();
  return items.length;
});

/// Dead letter queue items
final deadLetterItemsProvider = FutureProvider<List<OfflineQueueItem>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getDeadLetterItems();
});

// ============ Shared Data Providers ============

/// All Universities
final universitiesProvider = FutureProvider<List<University>>((ref) async {
  final repo = ref.watch(sharedDataRepositoryProvider);
  return repo.getUniversities();
});

/// Hostels for a University
final hostelsProvider = FutureProvider.family<List<Hostel>, String>((ref, universityId) async {
  final repo = ref.watch(sharedDataRepositoryProvider);
  return repo.getHostels(universityId);
});

