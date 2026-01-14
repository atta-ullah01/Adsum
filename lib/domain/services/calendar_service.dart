import 'package:adsum/data/repositories/calendar_repository.dart';
import 'package:adsum/domain/models/calendar_event.dart';

import 'package:uuid/uuid.dart';

/// Service for calendar management
class CalendarService {
  final CalendarRepository _repository;
  static const _uuid = Uuid();

  CalendarService(this._repository);

  // ============ Event Queries ============

  /// Get all events (excluding hidden)
  Future<List<CalendarEvent>> getAllEvents() async {
    final all = await _repository.getAll();
    final overrides = await _repository.getAllOverrides();
    final hiddenIds = overrides.where((o) => o.isHidden).map((o) => o.calendarId).toSet();
    
    return all.where((e) => e.isActive && !hiddenIds.contains(e.eventId)).toList();
  }

  /// Get events for a specific date (excluding hidden)
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final all = await _repository.getAll();
    final eventsOnDate = all.where((e) => e.isOnDate(date) && e.isActive).toList();
    
    final overrides = await _repository.getAllOverrides();
    final hiddenIds = overrides.where((o) => o.isHidden).map((o) => o.calendarId).toSet();
    
    return eventsOnDate.where((e) => !hiddenIds.contains(e.eventId)).toList();
  }

  /// Get upcoming events (next N days)
  Future<List<CalendarEvent>> getUpcoming({int days = 7}) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    
    final all = await _repository.getAll();
    final overrides = await _repository.getAllOverrides();
    final hiddenIds = overrides.where((o) => o.isHidden).map((o) => o.calendarId).toSet();
    
    final events = all.where((e) {
      if (!e.isActive || hiddenIds.contains(e.eventId)) return false;
      return !e.date.isBefore(now) && !e.date.isAfter(end);
    }).toList();
    
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  /// Get event count for a date
  Future<int> getEventCount(DateTime date) async {
    final events = await getEventsForDate(date);
    return events.length;
  }

  // ============ Event Actions ============

  /// Add a new event
  Future<CalendarEvent> addEvent({
    required String title,
    required DateTime date,
    String? startTime,
    String? endTime,
    CalendarEventType type = CalendarEventType.personal,
    String? description,
  }) async {
    final event = CalendarEvent(
      eventId: _uuid.v4(),
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      type: type,
      description: description,
    );
    
    await _repository.saveEvent(event);
    return event;
  }

  // ============ Visibility ============

  /// Toggle event visibility
  Future<bool> toggleVisibility(String eventId) async {
    final overrides = await _repository.getAllOverrides();
    final index = overrides.indexWhere((o) => o.calendarId == eventId);
    
    if (index >= 0) {
      final override = overrides[index];
      if (override.isHidden) {
        await _repository.deleteOverride(eventId);
        return true; // Now visible
      }
    }
    
    await _repository.saveOverride(CalendarOverride(calendarId: eventId, isHidden: true));
    return false; // Now hidden
  }

  /// Check if hidden
  Future<bool> isHidden(String eventId) async {
    final overrides = await _repository.getAllOverrides();
    return overrides.any((o) => o.calendarId == eventId && o.isHidden);
  }
}
