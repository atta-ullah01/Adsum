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

  group('MessRepository', () {
    test('getCache returns empty cache initially', () async {
      final repo = helper.container.read(messRepositoryProvider);
      final cache = await repo.getCache();
      expect(cache.menus, isEmpty);
      expect(cache.currentHostelId, isNull);
    });

    test('saveCache persists menu cache', () async {
      final repo = helper.container.read(messRepositoryProvider);
      
      final cache = MenuCache(
        menus: [
          MessMenu(
            menuId: 'M1',
            hostelId: 'H1',
            dayOfWeek: MessDayOfWeek.mon,
            mealType: MealType.breakfast,
            startTime: '08:00',
            endTime: '09:00',
            items: 'Bread, Eggs',
          ),
          MessMenu(
            menuId: 'M2',
            hostelId: 'H1',
            dayOfWeek: MessDayOfWeek.mon,
            mealType: MealType.lunch,
            startTime: '12:00',
            endTime: '13:00',
            items: 'Rice, Dal',
          ),
        ],
        currentHostelId: 'H1',
        lastSyncedAt: DateTime(2026, 1, 14),
      );

      await repo.saveCache(cache);
      
      final fetched = await repo.getCache();
      expect(fetched.menus.length, 2);
      expect(fetched.currentHostelId, 'H1');
      expect(fetched.lastSyncedAt, isNotNull);
    });

    test('saveCache overwrites existing cache', () async {
      final repo = helper.container.read(messRepositoryProvider);
      
      await repo.saveCache(MenuCache(
        menus: [MessMenu(
          menuId: 'M1',
          hostelId: 'H1',
          dayOfWeek: MessDayOfWeek.mon,
          mealType: MealType.breakfast,
          startTime: '08:00',
          endTime: '09:00',
          items: 'Old Menu',
        )],
      ));

      await repo.saveCache(MenuCache(
        menus: [MessMenu(
          menuId: 'M2',
          hostelId: 'H2',
          dayOfWeek: MessDayOfWeek.tue,
          mealType: MealType.dinner,
          startTime: '19:00',
          endTime: '20:00',
          items: 'New Menu',
        )],
        currentHostelId: 'H2',
      ));

      final fetched = await repo.getCache();
      expect(fetched.menus.length, 1);
      expect(fetched.menus.first.menuId, 'M2');
      expect(fetched.currentHostelId, 'H2');
    });
  });
}
