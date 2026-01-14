import 'package:flutter_test/flutter_test.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final helper = TestHelper();

  setUp(() async {
    await helper.setUp();
  });

  tearDown(() async {
    await helper.tearDown();
  });

  group('AttendanceRepository', () {
    test('logAttendance creates attendance record', () async {
      final repo = helper.container.read(attendanceRepositoryProvider);

      final log = await repo.logAttendance(
        enrollmentId: 'enroll_1',
        date: DateTime(2026, 1, 14),
        status: AttendanceStatus.present,
        confidenceScore: 85,
        evidence: const AttendanceEvidence(
          gpsLat: 28.6139,
          gpsLong: 77.2090,
        ),
      );

      expect(log.logId, isNotEmpty);
      expect(log.status, AttendanceStatus.present);
      expect(log.confidenceScore, 85);
    });

    test('getLogsForEnrollment filters by enrollment', () async {
      final repo = helper.container.read(attendanceRepositoryProvider);

      await repo.logAttendance(enrollmentId: 'E1', date: DateTime(2026, 1, 14), status: AttendanceStatus.present);
      await repo.logAttendance(enrollmentId: 'E2', date: DateTime(2026, 1, 14), status: AttendanceStatus.absent);
      await repo.logAttendance(enrollmentId: 'E1', date: DateTime(2026, 1, 15), status: AttendanceStatus.present);

      final logs = await repo.getLogsForEnrollment('E1');
      expect(logs.length, 2);
    });

    test('getLogsForDate filters by date', () async {
      final repo = helper.container.read(attendanceRepositoryProvider);

      final today = DateTime(2026, 1, 14);
      await repo.logAttendance(enrollmentId: 'E1', date: today, status: AttendanceStatus.present);
      await repo.logAttendance(enrollmentId: 'E2', date: DateTime(2026, 1, 15), status: AttendanceStatus.present);

      final logs = await repo.getLogsForDate(today);
      expect(logs.length, 1);
    });
  });
}
