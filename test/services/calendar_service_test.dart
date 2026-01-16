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

  group('CalendarService Integration', () {
    test('Event hiding works', () async {
      final service = helper.container.read(calendarServiceProvider);

      final event = await service.addEvent(
        title: 'Boring Event', 
        date: DateTime.now()
      );

      // Should be visible initially
      var visible = await service.getEventsForDate(DateTime.now());
      expect(visible.map((e) => e.eventId), contains(event.eventId));
      
      // Hide
      await service.toggleVisibility(event.eventId);
      
      // Should be hidden
      visible = await service.getEventsForDate(DateTime.now());
      expect(visible.map((e) => e.eventId), isNot(contains(event.eventId)));
      
      // Unhide
      await service.toggleVisibility(event.eventId);
      
      // Visible again
      visible = await service.getEventsForDate(DateTime.now());
      expect(visible.map((e) => e.eventId), contains(event.eventId));
    });

    test('addEvent creates event with generated ID', () async {
      final service = helper.container.read(calendarServiceProvider);

      final event = await service.addEvent(
        title: 'Test Event',
        date: DateTime(2026, 1, 20),
        startTime: '10:00',
        endTime: '11:00',
        type: CalendarEventType.exam,
        description: 'A test event',
      );

      expect(event.eventId, isNotEmpty);
      expect(event.title, 'Test Event');
      expect(event.type, CalendarEventType.exam);
    });

    test('getAllEvents excludes hidden events', () async {
      final service = helper.container.read(calendarServiceProvider);

      final e1 = await service.addEvent(title: 'Event 1', date: DateTime(2026, 1, 15));
      final e2 = await service.addEvent(title: 'Event 2', date: DateTime(2026, 1, 16));

      await service.toggleVisibility(e1.eventId);

      final events = await service.getAllEvents();
      expect(events.length, 1);
      expect(events.first.eventId, e2.eventId);
    });

    test('getEventsForDate returns events on specific date', () async {
      final service = helper.container.read(calendarServiceProvider);

      await service.addEvent(title: 'Jan 15', date: DateTime(2026, 1, 15));
      await service.addEvent(title: 'Jan 16', date: DateTime(2026, 1, 16));
      await service.addEvent(title: 'Jan 15 Again', date: DateTime(2026, 1, 15));

      final events = await service.getEventsForDate(DateTime(2026, 1, 15));
      expect(events.length, 2);
      expect(events.every((e) => e.title.contains('Jan 15')), true);
    });

    test('getUpcoming returns events in next N days', () async {
      final service = helper.container.read(calendarServiceProvider);
      final now = DateTime.now();

      await service.addEvent(title: 'Tomorrow', date: now.add(const Duration(days: 1)));
      await service.addEvent(title: 'Next Week', date: now.add(const Duration(days: 8)));
      await service.addEvent(title: 'In 3 Days', date: now.add(const Duration(days: 3)));

      final upcoming = await service.getUpcoming(days: 5);
      expect(upcoming.length, 2);
      expect(upcoming[0].title, 'Tomorrow');
      expect(upcoming[1].title, 'In 3 Days');
    });

    test('getEventCount returns count for specific date', () async {
      final service = helper.container.read(calendarServiceProvider);

      await service.addEvent(title: 'E1', date: DateTime(2026, 1, 15));
      await service.addEvent(title: 'E2', date: DateTime(2026, 1, 15));
      await service.addEvent(title: 'E3', date: DateTime(2026, 1, 16));

      final count = await service.getEventCount(DateTime(2026, 1, 15));
      expect(count, 2);
    });

    test('isHidden returns correct hidden state', () async {
      final service = helper.container.read(calendarServiceProvider);

      final event = await service.addEvent(title: 'Test', date: DateTime.now());

      // Initially visible
      expect(await service.isHidden(event.eventId), false);

      // Hide it
      await service.toggleVisibility(event.eventId);
      expect(await service.isHidden(event.eventId), true);

      // Unhide it
      await service.toggleVisibility(event.eventId);
      expect(await service.isHidden(event.eventId), false);
    });
  });
}
