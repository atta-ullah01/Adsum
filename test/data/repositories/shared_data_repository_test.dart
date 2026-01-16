import 'package:adsum/data/repositories/shared_data_repository.dart';
import 'package:adsum/data/sources/local/app_database.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SharedDataRepository repository;

  setUp(() {
    // Use in-memory database for testing
    db = AppDatabase(NativeDatabase.memory());
    repository = SharedDataRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SharedDataRepository (Global Schedules)', () {
    test('Offline Strategy: Fetches from Remote and caches to DB on first call', () async {
      // 1. Verify DB is empty
      var hasCache = await db.hasSchedulesForCourse('COL106');
      expect(hasCache, false);

      // 2. Call Repo (should hit "Remote" mock)
      final schedules = await repository.getGlobalSchedule('COL106');
      
      // 3. Verify data returned
      expect(schedules, isNotEmpty);
      expect(schedules.first.courseCode, 'COL106');

      // 4. Verify data was cached in DB
      hasCache = await db.hasSchedulesForCourse('COL106');
      expect(hasCache, true);
      
      final dbEntries = await db.getSchedulesForCourse('COL106');
      expect(dbEntries.length, schedules.length);
    });

    test('Offline Strategy: Returns cached data if available', () async {
      // 1. Seed DB with fake data
      await db.into(db.globalSchedules).insert(
        GlobalSchedulesCompanion.insert(
          ruleId: 'test_rule_1',
          courseCode: 'TEST101',
          dayOfWeek: 'MON',
          startTime: '10:00',
          endTime: '11:00',
          locationName: 'Test Hall',
        ),
      );

      // 2. Call Repo
      final schedules = await repository.getGlobalSchedule('TEST101');

      // 3. Verify it returned the cached item
      expect(schedules.length, 1);
      expect(schedules.first.courseCode, 'TEST101');
      expect(schedules.first.locationName, 'Test Hall');
      expect(schedules.first.dayOfWeek, DayOfWeek.mon);
      
      // Verify "Remote" wasn't used (Remote mock wouldn't have TEST101)
    });
  });
}
