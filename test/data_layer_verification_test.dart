import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late JsonFileService jsonService;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('adsum_test_');
    jsonService = JsonFileService();
    await jsonService.initialize(overrideBasePath: tempDir.path);
    container = ProviderContainer(
      overrides: [
        jsonFileServiceProvider.overrideWithValue(jsonService),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await tempDir.delete(recursive: true);
  });

  // ============================================================
  // USER REPOSITORY TESTS
  // ============================================================
  group('UserRepository', () {
    test('saveUser and getUser work correctly', () async {
      final repo = container.read(userRepositoryProvider);

      final user = UserProfile(
        userId: 'user_001',
        fullName: 'Alice Student',
        email: 'alice@university.edu',
        universityId: 'UNI001',
        defaultSection: 'B',
        settings: const UserSettings(themeMode: 'DARK', notificationsEnabled: false),
      );

      await repo.saveUser(user);
      final fetched = await repo.getUser();

      expect(fetched, isNotNull);
      expect(fetched!.userId, 'user_001');
      expect(fetched.fullName, 'Alice Student');
      expect(fetched.defaultSection, 'B');
      expect(fetched.settings.themeMode, 'DARK');
      expect(fetched.settings.notificationsEnabled, false);
    });

    test('updateSettings modifies nested settings object', () async {
      final repo = container.read(userRepositoryProvider);

      await repo.saveUser(UserProfile(
        userId: 'user_002',
        fullName: 'Bob',
        email: 'bob@example.com',
        settings: const UserSettings(notificationsEnabled: true),
      ));

      await repo.updateSettings(const UserSettings(
        notificationsEnabled: false,
        googleSyncEnabled: false,
      ));

      final fetched = await repo.getUser();
      expect(fetched!.settings.notificationsEnabled, false);
      expect(fetched.settings.googleSyncEnabled, false);
    });

    test('getUser returns null when no user exists', () async {
      final repo = container.read(userRepositoryProvider);
      final user = await repo.getUser();
      expect(user, isNull);
    });
  });

  // ============================================================
  // ENROLLMENT REPOSITORY TESTS
  // ============================================================
  group('EnrollmentRepository', () {
    test('addEnrollment with global course code', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final enrollment = await repo.addEnrollment(
        courseCode: 'CS101',
        section: 'A',
        targetAttendance: 80.0,
        colorTheme: '#FF5733',
      );

      expect(enrollment.enrollmentId, isNotEmpty);
      expect(enrollment.courseCode, 'CS101');
      expect(enrollment.isCustom, false);
      expect(enrollment.section, 'A');
      expect(enrollment.targetAttendance, 80.0);
    });

    test('addEnrollment with custom course', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final customCourse = CustomCourse(
        code: 'ELEC01',
        name: 'Guitar Practice',
        instructor: 'Self',
      );

      final enrollment = await repo.addEnrollment(customCourse: customCourse);

      expect(enrollment.isCustom, true);
      expect(enrollment.customCourse!.name, 'Guitar Practice');
    });

    test('getEnrollments returns all enrollments', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      await repo.addEnrollment(courseCode: 'MATH101');
      await repo.addEnrollment(courseCode: 'PHYS101');
      await repo.addEnrollment(
        customCourse: CustomCourse(code: 'C1', name: 'Custom', instructor: 'Me'),
      );

      final enrollments = await repo.getEnrollments();
      expect(enrollments.length, 3);
    });

    test('getEnrollment by ID returns correct enrollment', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'ENG101');
      final fetched = await repo.getEnrollment(created.enrollmentId);

      expect(fetched, isNotNull);
      expect(fetched!.courseCode, 'ENG101');
    });

    test('getEnrollment returns null for non-existent ID', () async {
      final repo = container.read(enrollmentRepositoryProvider);
      final fetched = await repo.getEnrollment('non_existent_id');
      expect(fetched, isNull);
    });

    test('updateEnrollment modifies existing enrollment', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(
        courseCode: 'BIO101',
        targetAttendance: 75.0,
      );

      final updated = created.copyWith(targetAttendance: 85.0);
      await repo.updateEnrollment(updated);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched!.targetAttendance, 85.0);
    });

    test('markAttended increments stats correctly', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'CHEM101');
      await repo.markAttended(created.enrollmentId);
      await repo.markAttended(created.enrollmentId);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched!.stats.attended, 2);
      expect(fetched.stats.totalClasses, 2);
    });

    test('markAbsent increments total only', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'HIST101');
      await repo.markAttended(created.enrollmentId);
      await repo.markAbsent(created.enrollmentId);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched!.stats.attended, 1);
      expect(fetched.stats.totalClasses, 2);
    });

    test('deleteEnrollment removes enrollment', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'DEL101');
      await repo.deleteEnrollment(created.enrollmentId);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched, isNull);
    });

    test('getCount returns correct count', () async {
      final repo = container.read(enrollmentRepositoryProvider);

      await repo.addEnrollment(courseCode: 'A');
      await repo.addEnrollment(courseCode: 'B');

      expect(await repo.getCount(), 2);
    });
  });

  // ============================================================
  // SCHEDULE REPOSITORY TESTS
  // ============================================================
  group('ScheduleRepository', () {
    test('addCustomSlot creates slot with generated ID', () async {
      final repo = container.read(scheduleRepositoryProvider);

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
      final repo = container.read(scheduleRepositoryProvider);

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
      final repo = container.read(scheduleRepositoryProvider);

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
      final repo = container.read(scheduleRepositoryProvider);

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
      final repo = container.read(scheduleRepositoryProvider);

      await repo.addBinding(userId: 'u1', ruleId: 'R1', scheduleType: ScheduleType.global);
      await repo.addBinding(userId: 'u1', ruleId: 'R2', scheduleType: ScheduleType.custom);
      await repo.addBinding(userId: 'u1', ruleId: 'R1', scheduleType: ScheduleType.global, wifiSsid: 'WiFi');

      final bindings = await repo.getBindingsForRule('R1');
      expect(bindings.length, 2);
    });
  });

  // ============================================================
  // ACTION ITEM REPOSITORY TESTS
  // ============================================================
  group('ActionItemRepository', () {
    test('add creates pending action item', () async {
      final repo = container.read(actionItemRepositoryProvider);

      final item = await repo.add(
        type: ActionItemType.conflict,
        title: 'Schedule Conflict',
        body: 'CS101 and MATH101 overlap on Monday',
        payload: {'slot_ids': ['s1', 's2']},
      );

      expect(item.itemId, isNotEmpty);
      expect(item.isPending, true);
      expect(item.type, ActionItemType.conflict);
    });

    test('getPending filters resolved items', () async {
      final repo = container.read(actionItemRepositoryProvider);

      final item1 = await repo.add(
        type: ActionItemType.verify,
        title: 'Verify Attendance',
        body: 'Were you in CS101?',
      );
      await repo.add(
        type: ActionItemType.attendanceRisk,
        title: 'Low Attendance',
        body: 'You are at 60%',
      );

      // Resolve item1
      await repo.resolve(item1.itemId, Resolution.yesPresent);

      final pending = await repo.getPending();
      expect(pending.length, 1);
      expect(pending.first.type, ActionItemType.attendanceRisk);
    });

    test('getByType filters by action type', () async {
      final repo = container.read(actionItemRepositoryProvider);

      await repo.add(type: ActionItemType.assignmentDue, title: 'HW1', body: 'Due tomorrow');
      await repo.add(type: ActionItemType.assignmentDue, title: 'HW2', body: 'Due next week');
      await repo.add(type: ActionItemType.scheduleChange, title: 'Room Change', body: 'New room');

      final assignments = await repo.getByType(ActionItemType.assignmentDue);
      expect(assignments.length, 2);
    });

    test('resolve marks item as resolved with resolution type', () async {
      final repo = container.read(actionItemRepositoryProvider);

      final item = await repo.add(
        type: ActionItemType.conflict,
        title: 'Pick One',
        body: 'Choose source A or B',
      );

      await repo.resolve(item.itemId, Resolution.keepMine);

      final fetched = await repo.getById(item.itemId);
      expect(fetched!.isPending, false);
      expect(fetched.resolution, Resolution.keepMine);
      expect(fetched.resolvedAt, isNotNull);
    });

    test('delete removes action item', () async {
      final repo = container.read(actionItemRepositoryProvider);

      final item = await repo.add(type: ActionItemType.verify, title: 'Test', body: 'Body');
      await repo.delete(item.itemId);

      final fetched = await repo.getById(item.itemId);
      expect(fetched, isNull);
    });

    test('clearResolved keeps only pending items', () async {
      final repo = container.read(actionItemRepositoryProvider);

      final item1 = await repo.add(type: ActionItemType.verify, title: 'A', body: 'a');
      await repo.add(type: ActionItemType.verify, title: 'B', body: 'b');
      await repo.resolve(item1.itemId, Resolution.acknowledged);

      await repo.clearResolved();

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.title, 'B');
    });
  });

  // ============================================================
  // ATTENDANCE REPOSITORY TESTS
  // ============================================================
  group('AttendanceRepository', () {
    test('logAttendance creates attendance record', () async {
      final repo = container.read(attendanceRepositoryProvider);

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
      final repo = container.read(attendanceRepositoryProvider);

      await repo.logAttendance(enrollmentId: 'E1', date: DateTime(2026, 1, 14), status: AttendanceStatus.present);
      await repo.logAttendance(enrollmentId: 'E2', date: DateTime(2026, 1, 14), status: AttendanceStatus.absent);
      await repo.logAttendance(enrollmentId: 'E1', date: DateTime(2026, 1, 15), status: AttendanceStatus.present);

      final logs = await repo.getLogsForEnrollment('E1');
      expect(logs.length, 2);
    });

    test('getLogsForDate filters by date', () async {
      final repo = container.read(attendanceRepositoryProvider);

      final today = DateTime(2026, 1, 14);
      await repo.logAttendance(enrollmentId: 'E1', date: today, status: AttendanceStatus.present);
      await repo.logAttendance(enrollmentId: 'E2', date: DateTime(2026, 1, 15), status: AttendanceStatus.present);

      final logs = await repo.getLogsForDate(today);
      expect(logs.length, 1);
    });
  });

  // ============================================================
  // SCHEDULE SERVICE INTEGRATION TESTS
  // ============================================================
  group('ScheduleService Integration', () {
    test('getEventsForDate returns merged events for custom slots', () async {
      final enrollmentRepo = container.read(enrollmentRepositoryProvider);
      final scheduleRepo = container.read(scheduleRepositoryProvider);
      final scheduleService = container.read(scheduleServiceProvider);

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
      final enrollmentRepo = container.read(enrollmentRepositoryProvider);
      final scheduleRepo = container.read(scheduleRepositoryProvider);
      final scheduleService = container.read(scheduleServiceProvider);

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
      final enrollmentRepo = container.read(enrollmentRepositoryProvider);
      final scheduleRepo = container.read(scheduleRepositoryProvider);
      final scheduleService = container.read(scheduleServiceProvider);

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

  // ============================================================
  // JSON FILE SERVICE EDGE CASES
  // ============================================================
  group('JsonFileService Edge Cases', () {
    test('readJsonArray returns null for non-existent file', () async {
      final data = await jsonService.readJsonArray('does_not_exist.json');
      expect(data, isNull);
    });

    test('exists returns false for non-existent file', () async {
      final exists = await jsonService.exists('phantom.json');
      expect(exists, false);
    });

    test('listFiles returns all JSON files', () async {
      await jsonService.writeJson('file1.json', {'a': 1});
      await jsonService.writeJson('file2.json', [1, 2, 3]);

      final files = await jsonService.listFiles();
      expect(files.length, 2);
      expect(files.contains('file1.json'), true);
      expect(files.contains('file2.json'), true);
    });

    test('exportAll aggregates all data', () async {
      await jsonService.writeJson('users.json', {'name': 'Test'});
      await jsonService.writeJson('items.json', [1, 2, 3]);

      final export = await jsonService.exportAll();

      expect(export['users'], {'name': 'Test'});
      expect(export['items'], [1, 2, 3]);
      expect(export['exported_at'], isNotNull);
    });
  });

  // ============================================================
  // EDGE CASES & ROBUSTNESS TESTS
  // ============================================================
  group('Edge Cases & Robustness', () {
    test('ActionItemRepository: delete non-existent item should not throw', () async {
      final repo = container.read(actionItemRepositoryProvider);
      // Should complete without error
      await repo.delete('non_existent_id');
      final items = await repo.getAll();
      expect(items.isEmpty, true);
    });

    test('EnrollmentRepository: update non-existent enrollment does nothing', () async {
      final repo = container.read(enrollmentRepositoryProvider);
      
      final ghostEnrollment = Enrollment(
        enrollmentId: 'ghost', 
        courseCode: 'GHOST', 
        stats: const EnrollmentStats()
      );
      
      // Should not throw and not add the item
      await repo.updateEnrollment(ghostEnrollment);
      
      final fetched = await repo.getEnrollment('ghost');
      expect(fetched, isNull);
    });

    test('ScheduleRepository: overlapping slots allowed in persistence', () async {
       // Persistence layer should strictly store what is given, conflict resolution logic is higher up
       final repo = container.read(scheduleRepositoryProvider);
       
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
