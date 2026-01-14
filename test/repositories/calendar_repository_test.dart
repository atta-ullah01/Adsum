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

  group('CalendarRepository', () {
    test('getAll returns empty list initially', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      final events = await repo.getAll();
      expect(events, isEmpty);
    });

    test('saveEvent creates new event', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      
      final event = CalendarEvent(
        eventId: 'E1',
        title: 'Team Meeting',
        date: DateTime(2026, 1, 15),
        type: CalendarEventType.personal,
      );

      await repo.saveEvent(event);
      
      final events = await repo.getAll();
      expect(events.length, 1);
      expect(events.first.title, 'Team Meeting');
    });

    test('saveEvent updates existing event', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      
      await repo.saveEvent(CalendarEvent(
        eventId: 'E1',
        title: 'Original',
        date: DateTime(2026, 1, 15),
      ));

      await repo.saveEvent(CalendarEvent(
        eventId: 'E1',
        title: 'Updated',
        date: DateTime(2026, 1, 15),
      ));

      final events = await repo.getAll();
      expect(events.length, 1);
      expect(events.first.title, 'Updated');
    });

    test('deleteEvent removes event', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      
      await repo.saveEvent(CalendarEvent(
        eventId: 'E1',
        title: 'To Delete',
        date: DateTime(2026, 1, 15),
      ));

      await repo.deleteEvent('E1');
      
      final events = await repo.getAll();
      expect(events, isEmpty);
    });

    test('getAllOverrides returns empty list initially', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      final overrides = await repo.getAllOverrides();
      expect(overrides, isEmpty);
    });

    test('saveOverride creates new override', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      
      await repo.saveOverride(CalendarOverride(calendarId: 'E1', isHidden: true));
      
      final overrides = await repo.getAllOverrides();
      expect(overrides.length, 1);
      expect(overrides.first.isHidden, true);
    });

    test('saveOverride updates existing override', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      
      await repo.saveOverride(CalendarOverride(calendarId: 'E1', isHidden: true));
      await repo.saveOverride(CalendarOverride(calendarId: 'E1', isHidden: false));

      final overrides = await repo.getAllOverrides();
      expect(overrides.length, 1);
      expect(overrides.first.isHidden, false);
    });

    test('deleteOverride removes override', () async {
      final repo = helper.container.read(calendarRepositoryProvider);
      
      await repo.saveOverride(CalendarOverride(calendarId: 'E1', isHidden: true));
      await repo.deleteOverride('E1');
      
      final overrides = await repo.getAllOverrides();
      expect(overrides, isEmpty);
    });
  });
}
