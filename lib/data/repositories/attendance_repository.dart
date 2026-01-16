import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/attendance_log.dart';
import 'package:uuid/uuid.dart';

/// Repository for attendance data (attendance.json)
class AttendanceRepository {

  AttendanceRepository(this._jsonService);
  static const String _filename = 'attendance.json';

  final JsonFileService _jsonService;

  /// Get all attendance logs
  Future<List<AttendanceLog>> getAllLogs() async {
    final data = await _jsonService.readJsonArray(_filename);
    if (data == null) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AttendanceLog.fromJson)
        .toList();
  }

  /// Get logs for a specific enrollment
  Future<List<AttendanceLog>> getLogsForEnrollment(String enrollmentId) async {
    final logs = await getAllLogs();
    return logs.where((l) => l.enrollmentId == enrollmentId).toList();
  }

  /// Get logs for a specific date
  Future<List<AttendanceLog>> getLogsForDate(DateTime date) async {
    final logs = await getAllLogs();
    return logs
        .where((l) =>
            l.date.year == date.year &&
            l.date.month == date.month &&
            l.date.day == date.day)
        .toList();
  }

  /// Get unsynced logs
  Future<List<AttendanceLog>> getUnsyncedLogs() async {
    final logs = await getAllLogs();
    return logs.where((l) => !l.synced).toList();
  }

  /// Log attendance
  Future<AttendanceLog> logAttendance({
    required String enrollmentId,
    required DateTime date,
    required AttendanceStatus status,
    String? slotId,
    String? startTime,
    AttendanceSource source = AttendanceSource.manual,
    int confidenceScore = 100,
    AttendanceEvidence? evidence,
  }) async {
    final log = AttendanceLog(
      logId: const Uuid().v4(),
      enrollmentId: enrollmentId,
      date: date,
      slotId: slotId,
      startTime: startTime,
      status: status,
      source: source,
      confidenceScore: confidenceScore,
      verificationState: source == AttendanceSource.manual
          ? VerificationState.manualOverride
          : VerificationState.autoConfirmed,
      evidence: evidence,
    );

    await _jsonService.appendToJsonArray(_filename, log.toJson());
    return log;
  }

  /// Update log (e.g., mark as synced)
  Future<bool> updateLog(AttendanceLog log) async {
    return _jsonService.updateInJsonArray(
      _filename,
      keyField: 'log_id',
      keyValue: log.logId,
      updates: log.toJson(),
    );
  }

  /// Mark log as synced
  Future<void> markSynced(String logId) async {
    await _jsonService.updateInJsonArray(
      _filename,
      keyField: 'log_id',
      keyValue: logId,
      updates: {'synced': true},
    );
  }

  /// Delete log
  Future<bool> deleteLog(String logId) async {
    return _jsonService.removeFromJsonArray(
      _filename,
      keyField: 'log_id',
      keyValue: logId,
    );
  }

  /// Get log by ID
  Future<AttendanceLog?> getLog(String logId) async {
    final logs = await getAllLogs();
    try {
      return logs.firstWhere((l) => l.logId == logId);
    } catch (_) {
      return null;
    }
  }
}
