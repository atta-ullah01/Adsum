import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/enrollment.dart';
import 'package:uuid/uuid.dart';

/// Repository for enrollment data (enrollments.json)
class EnrollmentRepository {
  static const String _filename = 'enrollments.json';

  final JsonFileService _jsonService;

  EnrollmentRepository(this._jsonService);

  /// Get all enrollments
  Future<List<Enrollment>> getEnrollments() async {
    final data = await _jsonService.readJsonArray(_filename);
    if (data == null) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Enrollment.fromJson)
        .toList();
  }

  /// Get enrollment by ID
  Future<Enrollment?> getEnrollment(String enrollmentId) async {
    final enrollments = await getEnrollments();
    try {
      return enrollments.firstWhere((e) => e.enrollmentId == enrollmentId);
    } catch (_) {
      return null;
    }
  }

  /// Add new enrollment
  Future<Enrollment> addEnrollment({
    String? courseCode,
    CustomCourse? customCourse,
    String section = 'A',
    double targetAttendance = 75.0,
    String colorTheme = '#6366F1',
  }) async {
    final enrollment = Enrollment(
      enrollmentId: const Uuid().v4(),
      courseCode: courseCode,
      customCourse: customCourse,
      section: section,
      targetAttendance: targetAttendance,
      colorTheme: colorTheme,
    );

    await _jsonService.appendToJsonArray(_filename, enrollment.toJson());
    return enrollment;
  }

  /// Update enrollment
  Future<bool> updateEnrollment(Enrollment enrollment) async {
    return _jsonService.updateInJsonArray(
      _filename,
      keyField: 'enrollment_id',
      keyValue: enrollment.enrollmentId,
      updates: enrollment.toJson(),
    );
  }

  /// Update enrollment stats
  Future<void> updateStats(String enrollmentId, EnrollmentStats stats) async {
    final enrollment = await getEnrollment(enrollmentId);
    if (enrollment == null) return;
    await updateEnrollment(enrollment.copyWith(stats: stats));
  }

  /// Increment attendance
  Future<void> markAttended(String enrollmentId) async {
    final enrollment = await getEnrollment(enrollmentId);
    if (enrollment == null) return;

    await updateEnrollment(
      enrollment.copyWith(
        stats: enrollment.stats.copyWith(
          attended: enrollment.stats.attended + 1,
          totalClasses: enrollment.stats.totalClasses + 1,
        ),
      ),
    );
  }

  /// Mark absent (increment total only)
  Future<void> markAbsent(String enrollmentId) async {
    final enrollment = await getEnrollment(enrollmentId);
    if (enrollment == null) return;

    await updateEnrollment(
      enrollment.copyWith(
        stats: enrollment.stats.copyWith(
          totalClasses: enrollment.stats.totalClasses + 1,
        ),
      ),
    );
  }

  /// Delete enrollment
  Future<bool> deleteEnrollment(String enrollmentId) async {
    return _jsonService.removeFromJsonArray(
      _filename,
      keyField: 'enrollment_id',
      keyValue: enrollmentId,
    );
  }

  /// Get enrollment count
  Future<int> getCount() async {
    final enrollments = await getEnrollments();
    return enrollments.length;
  }
}
