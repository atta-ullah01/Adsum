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

  group('ScheduleService Integration', () {
    test('getEventsForDate returns merged events for custom slots', () async {
      final enrollmentRepo = helper.container.read(enrollmentRepositoryProvider);
      final scheduleRepo = helper.container.read(scheduleRepositoryProvider);
      final scheduleService = helper.container.read(scheduleServiceProvider);

      // Create enrollment
      final enrollment = await enrollmentRepo.addEnrollment(
        customCourse: CustomCourse(code: 'YOGA', name: 'Morning Yoga', instructor: 'Guru'),
        colorTheme: '#00FF00',
      );

      // Add schedule slot for Wednesday
      await scheduleRepo.addCustomSlot(
        enrollmentId: enrollment.enrollmentId,
        dayOfWeek: DayOfWeek.wed,
        startTime: '06:00',
        endTime: '07:00',
      );

      // January 14, 2026 is a Wednesday
      final wednesday = DateTime(2026, 1, 14);
      final events = await scheduleService.getEventsForDate(wednesday);

      expect(events.length, 1);
      expect(events.first.title, 'Morning Yoga');
      expect(events.first.color, '#00FF00');
      expect(events.first.startTime.hour, 6);
      expect(events.first.endTime.hour, 7);
    });

    test('getEventsForDate returns empty list for days with no classes', () async {
      final enrollmentRepo = helper.container.read(enrollmentRepositoryProvider);
      final scheduleRepo = helper.container.read(scheduleRepositoryProvider);
      final scheduleService = helper.container.read(scheduleServiceProvider);

      final enrollment = await enrollmentRepo.addEnrollment(courseCode: 'TEST');
      await scheduleRepo.addCustomSlot(
        enrollmentId: enrollment.enrollmentId,
        dayOfWeek: DayOfWeek.mon,
        startTime: '10:00',
        endTime: '11:00',
      );

      // January 17, 2026 is a Saturday (no classes scheduled)
      final saturday = DateTime(2026, 1, 17);
      final events = await scheduleService.getEventsForDate(saturday);

      expect(events.isEmpty, true);
    });

    test('multiple slots for same day appear as separate events', () async {
      final enrollmentRepo = helper.container.read(enrollmentRepositoryProvider);
      final scheduleRepo = helper.container.read(scheduleRepositoryProvider);
      final scheduleService = helper.container.read(scheduleServiceProvider);

      final e1 = await enrollmentRepo.addEnrollment(
        customCourse: CustomCourse(code: 'A', name: 'Course A', instructor: 'X'),
      );
      final e2 = await enrollmentRepo.addEnrollment(
        customCourse: CustomCourse(code: 'B', name: 'Course B', instructor: 'Y'),
      );

      await scheduleRepo.addCustomSlot(
        enrollmentId: e1.enrollmentId,
        dayOfWeek: DayOfWeek.fri,
        startTime: '09:00',
        endTime: '10:00',
      );
      await scheduleRepo.addCustomSlot(
        enrollmentId: e2.enrollmentId,
        dayOfWeek: DayOfWeek.fri,
        startTime: '10:00',
        endTime: '11:00',
      );

      // January 16, 2026 is a Friday
      final friday = DateTime(2026, 1, 16);
      final events = await scheduleService.getEventsForDate(friday);

      expect(events.length, 2);
      expect(events.map((e) => e.title).toSet(), {'Course A', 'Course B'});
    });
  });
}
