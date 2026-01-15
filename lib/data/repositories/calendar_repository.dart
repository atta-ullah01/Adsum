import 'package:uuid/uuid.dart';

import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/calendar_event.dart';

/// Repository for personal calendar events
/// 
/// Manages two JSON files:
/// - `events.json` - Personal calendar events
/// - `calendar_overrides.json` - Hidden events
class CalendarRepository {
  static const String _eventsFile = 'events.json';
  static const String _overridesFile = 'calendar_overrides.json';
  static const _uuid = Uuid();

  final JsonFileService _jsonService;

  CalendarRepository(this._jsonService);

  // ============ Events CRUD ============

  /// Get all events
  Future<List<CalendarEvent>> getAll() async {
    final data = await _jsonService.readJsonArray(_eventsFile);
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map((json) => CalendarEvent.fromJson(json))
        .toList();
  }

  /// Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final allEvents = await getAll();
    return allEvents.where((e) => 
      e.date.year == date.year && 
      e.date.month == date.month && 
      e.date.day == date.day
    ).toList();
  }

  /// Save a calendar event (create or update)
  Future<void> saveEvent(CalendarEvent event) async {
    final exists = await getAll();
    final index = exists.indexWhere((e) => e.eventId == event.eventId);
    
    if (index >= 0) {
      await _jsonService.updateInJsonArray(
        _eventsFile,
        keyField: 'event_id',
        keyValue: event.eventId,
        updates: event.toJson(),
      );
    } else {
      await _jsonService.appendToJsonArray(_eventsFile, event.toJson());
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _jsonService.removeFromJsonArray(
      _eventsFile,
      keyField: 'event_id',
      keyValue: eventId,
    );
  }

  // ============ Overrides ============

  /// Get all overrides
  Future<List<CalendarOverride>> getAllOverrides() async {
    final data = await _jsonService.readJsonArray(_overridesFile);
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map((json) => CalendarOverride.fromJson(json))
        .toList();
  }

  /// Add or update an override
  Future<void> saveOverride(CalendarOverride override) async {
    final overrides = await getAllOverrides();
    final index = overrides.indexWhere((o) => o.calendarId == override.calendarId);
    
    if (index >= 0) {
      await _jsonService.updateInJsonArray(
        _overridesFile,
        keyField: 'calendar_id',
        keyValue: override.calendarId,
        updates: override.toJson(),
      );
    } else {
      await _jsonService.appendToJsonArray(_overridesFile, override.toJson());
    }
  }

  /// Delete an override
  Future<void> deleteOverride(String calendarId) async {
    await _jsonService.removeFromJsonArray(
      _overridesFile,
      keyField: 'calendar_id',
      keyValue: calendarId,
    );
  }
}
