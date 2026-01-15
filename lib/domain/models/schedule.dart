/// Schedule domain models - matches `/data/custom_schedules.json`
/// and `/data/schedule_bindings.json`

import 'package:flutter/foundation.dart';

/// Day of week enum
enum DayOfWeek {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun;

  static DayOfWeek fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'MON':
        return DayOfWeek.mon;
      case 'TUE':
        return DayOfWeek.tue;
      case 'WED':
        return DayOfWeek.wed;
      case 'THU':
        return DayOfWeek.thu;
      case 'FRI':
        return DayOfWeek.fri;
      case 'SAT':
        return DayOfWeek.sat;
      case 'SUN':
        return DayOfWeek.sun;
      default:
        return DayOfWeek.mon;
    }
  }

  String toJson() => name.toUpperCase();

  String get displayName {
    switch (this) {
      case DayOfWeek.mon:
        return 'Monday';
      case DayOfWeek.tue:
        return 'Tuesday';
      case DayOfWeek.wed:
        return 'Wednesday';
      case DayOfWeek.thu:
        return 'Thursday';
      case DayOfWeek.fri:
        return 'Friday';
      case DayOfWeek.sat:
        return 'Saturday';
      case DayOfWeek.sun:
        return 'Sunday';
    }
  }

  String get shortName => name.substring(0, 1).toUpperCase() + name.substring(1);
}

/// Schedule type for bindings
enum ScheduleType {
  global,
  custom;

  static ScheduleType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'GLOBAL':
        return ScheduleType.global;
      case 'CUSTOM':
        return ScheduleType.custom;
      default:
        return ScheduleType.custom;
    }
  }

  String toJson() => name.toUpperCase();
}

/// Custom schedule slot - matches `/data/custom_schedules.json`
@immutable
class CustomScheduleSlot {
  final String ruleId;
  final String enrollmentId;
  final DayOfWeek dayOfWeek;
  final String startTime; // "HH:mm" format
  final String endTime;

  const CustomScheduleSlot({
    required this.ruleId,
    required this.enrollmentId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory CustomScheduleSlot.fromJson(Map<String, dynamic> json) {
    return CustomScheduleSlot(
      ruleId: json['rule_id'] as String,
      enrollmentId: json['enrollment_id'] as String,
      dayOfWeek: DayOfWeek.fromString(json['day_of_week'] as String?),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'rule_id': ruleId,
        'enrollment_id': enrollmentId,
        'day_of_week': dayOfWeek.toJson(),
        'start_time': startTime,
        'end_time': endTime,
      };

  CustomScheduleSlot copyWith({
    String? ruleId,
    String? enrollmentId,
    DayOfWeek? dayOfWeek,
    String? startTime,
    String? endTime,
  }) {
    return CustomScheduleSlot(
      ruleId: ruleId ?? this.ruleId,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Schedule binding for GPS/WiFi - matches `/data/schedule_bindings.json`
@immutable
class ScheduleBinding {
  final String bindingId;
  final String userId;
  final String ruleId;
  final ScheduleType scheduleType;
  final String? locationName;
  final double? locationLat;
  final double? locationLong;
  final String? wifiSsid;

  const ScheduleBinding({
    required this.bindingId,
    required this.userId,
    required this.ruleId,
    required this.scheduleType,
    this.locationName,
    this.locationLat,
    this.locationLong,
    this.wifiSsid,
  });

  bool get hasGpsBinding => locationLat != null && locationLong != null;
  bool get hasWifiBinding => wifiSsid != null && wifiSsid!.isNotEmpty;

  factory ScheduleBinding.fromJson(Map<String, dynamic> json) {
    return ScheduleBinding(
      bindingId: json['binding_id'] as String,
      userId: json['user_id'] as String,
      ruleId: json['rule_id'] as String,
      scheduleType: ScheduleType.fromString(json['schedule_type'] as String?),
      locationName: json['location_name'] as String?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLong: (json['location_long'] as num?)?.toDouble(),
      wifiSsid: json['wifi_ssid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'binding_id': bindingId,
        'user_id': userId,
        'rule_id': ruleId,
        'schedule_type': scheduleType.toJson(),
        if (locationName != null) 'location_name': locationName,
        if (locationLat != null) 'location_lat': locationLat,
        if (locationLong != null) 'location_long': locationLong,
        if (wifiSsid != null) 'wifi_ssid': wifiSsid,
      };

  ScheduleBinding copyWith({
    String? bindingId,
    String? userId,
    String? ruleId,
    ScheduleType? scheduleType,
    String? locationName,
    double? locationLat,
    double? locationLong,
    String? wifiSsid,
  }) {
    return ScheduleBinding(
      bindingId: bindingId ?? this.bindingId,
      userId: userId ?? this.userId,
      ruleId: ruleId ?? this.ruleId,
      scheduleType: scheduleType ?? this.scheduleType,
      locationName: locationName ?? this.locationName,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      wifiSsid: wifiSsid ?? this.wifiSsid,
    );
  }
}

/// Event type for merged schedule
/// Event type for merged schedule
enum ScheduleEventType {
  classSession,
  lab,
  exam,
  event,
  personal,
  conflict,
  holiday; 

  bool get isAcademic => this == ScheduleEventType.classSession || this == ScheduleEventType.lab || this == ScheduleEventType.exam;
}

/// A merged schedule event ready for UI display
@immutable
class ScheduleEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleEventType type;
  final String? location;
  final String color; // Hex string e.g., "#FF5733"
  final bool isCancelled;
  final String? enrollmentId;
  final Map<String, dynamic> metadata;
  final List<ScheduleEvent>? conflictingEvents; // List of events involved in this conflict

  const ScheduleEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.location,
    this.color = '#6366F1',
    this.isCancelled = false,
    this.enrollmentId,
    this.metadata = const {},
    this.conflictingEvents,
  });
  
  Duration get duration => endTime.difference(startTime);
  bool get isCurrent => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isPast => DateTime.now().isAfter(endTime);
  bool get isFuture => DateTime.now().isBefore(startTime);
}
