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

  group('MessService Integration', () {
    test('local modifications work', () async {
      final repo = helper.container.read(messRepositoryProvider);
      final service = helper.container.read(messServiceProvider);

      const menu = MessMenu(
        menuId: 'M1',
        hostelId: 'H1',
        dayOfWeek: MessDayOfWeek.mon,
        mealType: MealType.breakfast,
        startTime: '08:00',
        endTime: '09:00',
        items: 'Bread',
      );

      await repo.saveCache(const MenuCache(menus: [menu]));
      
      // Verify initial
      var menus = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H1');
      expect(menus.first.items, 'Bread');
      expect(menus.first.isModified, false);

      // Modify locally
      final modified = menu.copyWith(items: 'Toast');
      await service.updateLocalMenu(modified);

      // Verify modification
      menus = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H1');
      expect(menus.first.items, 'Toast');
      expect(menus.first.isModified, true);

      // Reset
      await service.resetToGlobal('M1');
      menus = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H1');
      expect(menus.first.isModified, false);
    });

    test('getMenusForDay filters by day and hostel', () async {
      final repo = helper.container.read(messRepositoryProvider);
      final service = helper.container.read(messServiceProvider);

      await repo.saveCache(const MenuCache(menus: [
        MessMenu(menuId: 'M1', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'A'),
        MessMenu(menuId: 'M2', hostelId: 'H1', dayOfWeek: MessDayOfWeek.tue, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'B'),
        MessMenu(menuId: 'M3', hostelId: 'H2', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'C'),
      ]));

      final mondayH1 = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H1');
      expect(mondayH1.length, 1);
      expect(mondayH1.first.items, 'A');
    });

    test('getMenusForDay sorts by meal type', () async {
      final repo = helper.container.read(messRepositoryProvider);
      final service = helper.container.read(messServiceProvider);

      await repo.saveCache(const MenuCache(menus: [
        MessMenu(menuId: 'M1', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.dinner, startTime: '19:00', endTime: '20:00', items: 'Dinner'),
        MessMenu(menuId: 'M2', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'Breakfast'),
        MessMenu(menuId: 'M3', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.lunch, startTime: '12:00', endTime: '13:00', items: 'Lunch'),
      ]));

      final menus = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H1');
      expect(menus[0].mealType, MealType.breakfast);
      expect(menus[1].mealType, MealType.lunch);
      expect(menus[2].mealType, MealType.dinner);
    });

    test('getModifiedCount returns correct count', () async {
      final repo = helper.container.read(messRepositoryProvider);
      final service = helper.container.read(messServiceProvider);

      await repo.saveCache(const MenuCache(menus: [
        MessMenu(menuId: 'M1', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'A', isModified: true),
        MessMenu(menuId: 'M2', hostelId: 'H1', dayOfWeek: MessDayOfWeek.tue, mealType: MealType.lunch, startTime: '12:00', endTime: '13:00', items: 'B'),
        MessMenu(menuId: 'M3', hostelId: 'H1', dayOfWeek: MessDayOfWeek.wed, mealType: MealType.dinner, startTime: '19:00', endTime: '20:00', items: 'C', isModified: true),
      ]));

      final count = await service.getModifiedCount();
      expect(count, 2);
    });

    test('setCurrentHostelId and getCurrentHostelId work', () async {
      final service = helper.container.read(messServiceProvider);

      // Initially null
      var hostelId = await service.getCurrentHostelId();
      expect(hostelId, isNull);

      // Set hostel
      await service.setCurrentHostelId('H1');
      hostelId = await service.getCurrentHostelId();
      expect(hostelId, 'H1');

      // Change hostel
      await service.setCurrentHostelId('H2');
      hostelId = await service.getCurrentHostelId();
      expect(hostelId, 'H2');
    });

    test('setMenusForHostel replaces hostel menus', () async {
      final repo = helper.container.read(messRepositoryProvider);
      final service = helper.container.read(messServiceProvider);

      // Initial menus
      await repo.saveCache(const MenuCache(menus: [
        MessMenu(menuId: 'M1', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'Old'),
        MessMenu(menuId: 'M2', hostelId: 'H2', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'Keep'),
      ]));

      // Replace H1 menus
      await service.setMenusForHostel('H1', [
        const MessMenu(menuId: 'M3', hostelId: 'H1', dayOfWeek: MessDayOfWeek.mon, mealType: MealType.breakfast, startTime: '08:00', endTime: '09:00', items: 'New'),
      ]);

      final h1Menus = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H1');
      final h2Menus = await service.getMenusForDay(MessDayOfWeek.mon, hostelId: 'H2');

      expect(h1Menus.length, 1);
      expect(h1Menus.first.items, 'New');
      expect(h2Menus.length, 1);
      expect(h2Menus.first.items, 'Keep');
    });
  });
}
