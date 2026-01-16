import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('ScheduleRepository', () {
    test('addCustomSlot creates slot with generated ID', () async {
      final repo = helper.container.read(scheduleRepositoryProvider);

      final slot = await repo.addCustomSlot(
        enrollmentId: 'enroll_123',
        dayOfWeek: DayOfWeek.tue,
        startTime: '09:00',
        endTime: '10:30',
      );

      expect(slot.ruleId, isNotEmpty);
      expect(slot.dayOfWeek, DayOfWeek.tue);
    });

    test('getSlotsForEnrollment filters correctly', () async {
      final repo = helper.container.read(scheduleRepositoryProvider);

      await repo.addCustomSlot(
        enrollmentId: 'A',
        dayOfWeek: DayOfWeek.mon,
        startTime: '08:00',
        endTime: '09:00',
      );
      await repo.addCustomSlot(
        enrollmentId: 'B',
        dayOfWeek: DayOfWeek.wed,
        startTime: '10:00',
        endTime: '11:00',
      );
      await repo.addCustomSlot(
        enrollmentId: 'A',
        dayOfWeek: DayOfWeek.fri,
        startTime: '14:00',
        endTime: '15:00',
      );

      final slotsA = await repo.getSlotsForEnrollment('A');
      final slotsB = await repo.getSlotsForEnrollment('B');

      expect(slotsA.length, 2);
      expect(slotsB.length, 1);
    });

    test('deleteCustomSlot removes specific slot', () async {
      final repo = helper.container.read(scheduleRepositoryProvider);

      final slot = await repo.addCustomSlot(
        enrollmentId: 'X',
        dayOfWeek: DayOfWeek.thu,
        startTime: '13:00',
        endTime: '14:00',
      );

      await repo.deleteCustomSlot(slot.ruleId);

      final slots = await repo.getCustomSlots();
      expect(slots.isEmpty, true);
    });

    test('addBinding creates GPS/WiFi binding', () async {
      final repo = helper.container.read(scheduleRepositoryProvider);

      final binding = await repo.addBinding(
        userId: 'user_1',
        ruleId: 'rule_1',
        scheduleType: ScheduleType.custom,
        locationName: 'Library',
        locationLat: 28.6139,
        locationLong: 77.2090,
        wifiSsid: 'Campus_WiFi',
      );

      expect(binding.bindingId, isNotEmpty);
      expect(binding.hasGpsBinding, true);
      expect(binding.hasWifiBinding, true);
    });

    test('getBindingsForRule filters by rule ID', () async {
      final repo = helper.container.read(scheduleRepositoryProvider);

      await repo.addBinding(userId: 'u1', ruleId: 'R1', scheduleType: ScheduleType.global);
      await repo.addBinding(userId: 'u1', ruleId: 'R2', scheduleType: ScheduleType.custom);
      await repo.addBinding(userId: 'u1', ruleId: 'R1', scheduleType: ScheduleType.global, wifiSsid: 'WiFi');

      final bindings = await repo.getBindingsForRule('R1');
      expect(bindings.length, 2);
    });

    test('overlapping slots allowed in persistence', () async {
       // Persistence layer should strictly store what is given, conflict resolution logic is higher up
       final repo = helper.container.read(scheduleRepositoryProvider);
       
       await repo.addCustomSlot(
         enrollmentId: 'E1',
         dayOfWeek: DayOfWeek.mon,
         startTime: '10:00', 
         endTime: '11:00'
       );
       
       // Add overlapping slot
       await repo.addCustomSlot(
         enrollmentId: 'E1', 
         dayOfWeek: DayOfWeek.mon,
         startTime: '10:30', 
         endTime: '11:30'
       );
       
       final slots = await repo.getSlotsForEnrollment('E1');
       expect(slots.length, 2, reason: 'Persistence layer should allow overlaps');
    });
  });
}
