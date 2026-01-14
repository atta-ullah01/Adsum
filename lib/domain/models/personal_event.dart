/// Personal events domain model - matches `/data/events.json`

import 'package:flutter/foundation.dart';

/// Personal calendar event
@immutable
class PersonalEvent {
  final String eventId;
  final String title;
  final DateTime date;
  final String startTime; // "HH:mm"
  final String endTime;

  const PersonalEvent({
    required this.eventId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory PersonalEvent.fromJson(Map<String, dynamic> json) {
    return PersonalEvent(
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'title': title,
        'date': date.toIso8601String().split('T')[0],
        'start_time': startTime,
        'end_time': endTime,
      };

  PersonalEvent copyWith({
    String? eventId,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
  }) {
    return PersonalEvent(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Calendar override - matches `/data/calendar_overrides.json`
@immutable
class CalendarOverride {
  final String calendarId;
  final bool isHidden;

  const CalendarOverride({
    required this.calendarId,
    this.isHidden = true,
  });

  factory CalendarOverride.fromJson(Map<String, dynamic> json) {
    return CalendarOverride(
      calendarId: json['calendar_id'] as String,
      isHidden: json['is_hidden'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'calendar_id': calendarId,
        'is_hidden': isHidden,
      };
}
