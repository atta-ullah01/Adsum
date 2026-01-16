import 'package:equatable/equatable.dart';

/// Calendar event type enumeration
/// Calendar event type enumeration
enum CalendarEventType {
  personal,
  holiday,
  exam,
  daySwap,
  quiz,
  assignment;

  String toJson() => name.toUpperCase();

  static CalendarEventType fromJson(String json) {
    return CalendarEventType.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => CalendarEventType.personal,
    );
  }

  String get displayName {
    switch (this) {
      case CalendarEventType.personal:
        return 'Personal';
      case CalendarEventType.holiday:
        return 'Holiday';
      case CalendarEventType.exam:
        return 'Exam';
      case CalendarEventType.daySwap:
        return 'Day Swap';
      case CalendarEventType.quiz:
        return 'Quiz';
      case CalendarEventType.assignment:
        return 'Assignment';
    }
  }
}

/// Represents a calendar event
/// Maps to `/data/events.json` in SCHEMA.md
class CalendarEvent extends Equatable {

  const CalendarEvent({
    required this.eventId,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    this.type = CalendarEventType.personal,
    this.description,
    this.isActive = true,
    this.dayOrderOverride,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      type: CalendarEventType.fromJson(json['type'] as String? ?? 'PERSONAL'),
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      dayOrderOverride: json['day_order_override'] as String?,
    );
  }
  final String eventId;
  final String title;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final CalendarEventType type;
  final String? description;
  final bool isActive;
  /// For DAY_SWAP events only: which day's schedule to follow (e.g., "MON", "TUE")
  final String? dayOrderOverride;

  @override
  List<Object?> get props => [
        eventId,
        title,
        date,
        startTime,
        endTime,
        type,
        description,
        isActive,
        dayOrderOverride,
      ];

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'date': date.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'type': type.toJson(),
      'description': description,
      'is_active': isActive,
      if (dayOrderOverride != null) 'day_order_override': dayOrderOverride,
    };
  }

  CalendarEvent copyWith({
    String? eventId,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    CalendarEventType? type,
    String? description,
    bool? isActive,
    String? dayOrderOverride,
  }) {
    return CalendarEvent(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      dayOrderOverride: dayOrderOverride ?? this.dayOrderOverride,
    );
  }

  /// Check if event is on a specific date
  bool isOnDate(DateTime targetDate) {
    return date.year == targetDate.year &&
        date.month == targetDate.month &&
        date.day == targetDate.day;
  }

  /// Check if event is in the future
  bool get isFuture => date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
}

/// Calendar override - hides specific events locally
/// Maps to `/data/calendar_overrides.json` in SCHEMA.md
class CalendarOverride extends Equatable {

  const CalendarOverride({
    required this.calendarId,
    this.isHidden = false,
  });

  factory CalendarOverride.fromJson(Map<String, dynamic> json) {
    return CalendarOverride(
      calendarId: json['calendar_id'] as String,
      isHidden: json['is_hidden'] as bool? ?? false,
    );
  }
  final String calendarId;
  final bool isHidden;

  @override
  List<Object?> get props => [calendarId, isHidden];

  Map<String, dynamic> toJson() {
    return {
      'calendar_id': calendarId,
      'is_hidden': isHidden,
    };
  }
}
