import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adsum/data/sources/local/app_database.dart' hide Enrollment;
import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/data/repositories/repositories.dart';
import 'package:adsum/data/validation/data_validation.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/domain/services/schedule_service.dart';

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

// ============ Service Providers ============

/// Schedule service
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    ref.watch(enrollmentRepositoryProvider),
    ref.watch(scheduleRepositoryProvider),
  );
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
