/// Domain models for local JSON storage.
///
/// These models match SCHEMA.md Part 2: Local JSON Files exactly.
/// Uses immutable classes with copyWith for safety.
library;

import 'package:flutter/foundation.dart';

/// User profile and settings - matches `/data/user.json`
@immutable
class UserProfile {

  const UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    this.universityId,
    this.homeHostelId,
    this.defaultSection = 'A',
    this.settings = const UserSettings(),
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      universityId: json['university_id'] as String?,
      homeHostelId: json['home_hostel_id'] as String?,
      defaultSection: json['default_section'] as String? ?? 'A',
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : const UserSettings(),
    );
  }
  final String userId;
  final String email;
  final String fullName;
  final String? universityId;
  final String? homeHostelId;
  final String defaultSection;
  final UserSettings settings;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        if (universityId != null) 'university_id': universityId,
        if (homeHostelId != null) 'home_hostel_id': homeHostelId,
        'default_section': defaultSection,
        'settings': settings.toJson(),
      };

  UserProfile copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? universityId,
    String? homeHostelId,
    String? defaultSection,
    UserSettings? settings,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      universityId: universityId ?? this.universityId,
      homeHostelId: homeHostelId ?? this.homeHostelId,
      defaultSection: defaultSection ?? this.defaultSection,
      settings: settings ?? this.settings,
    );
  }
}

@immutable
class UserSettings {

  const UserSettings({
    this.themeMode = 'SYSTEM',
    this.notificationsEnabled = true,
    this.isPrivateMode = false,
    this.googleSyncEnabled = true,
    this.lastSyncAt,
    this.sensorGeofenceEnabled = false,
    this.sensorMotionEnabled = false,
    this.sensorBatteryOptimizationDisabled = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      themeMode: json['theme_mode'] as String? ?? 'SYSTEM',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      isPrivateMode: json['is_private_mode'] as bool? ?? false,
      googleSyncEnabled: json['google_sync_enabled'] as bool? ?? true,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      sensorGeofenceEnabled: json['sensor_geofence_enabled'] as bool? ?? false,
      sensorMotionEnabled: json['sensor_motion_enabled'] as bool? ?? false,
      sensorBatteryOptimizationDisabled: json['sensor_battery_optimization_disabled'] as bool? ?? false,
    );
  }
  final String themeMode;
  final bool notificationsEnabled;
  final bool isPrivateMode;
  final bool googleSyncEnabled;
  final DateTime? lastSyncAt;
  
  // Sensor Hub Settings
  final bool sensorGeofenceEnabled;
  final bool sensorMotionEnabled;
  final bool sensorBatteryOptimizationDisabled;

  Map<String, dynamic> toJson() => {
        'theme_mode': themeMode,
        'notifications_enabled': notificationsEnabled,
        'is_private_mode': isPrivateMode,
        'google_sync_enabled': googleSyncEnabled,
        if (lastSyncAt != null) 'last_sync_at': lastSyncAt!.toIso8601String(),
        'sensor_geofence_enabled': sensorGeofenceEnabled,
        'sensor_motion_enabled': sensorMotionEnabled,
        'sensor_battery_optimization_disabled': sensorBatteryOptimizationDisabled,
      };

  UserSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    bool? isPrivateMode,
    bool? googleSyncEnabled,
    DateTime? lastSyncAt,
    bool? sensorGeofenceEnabled,
    bool? sensorMotionEnabled,
    bool? sensorBatteryOptimizationDisabled,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isPrivateMode: isPrivateMode ?? this.isPrivateMode,
      googleSyncEnabled: googleSyncEnabled ?? this.googleSyncEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      sensorGeofenceEnabled: sensorGeofenceEnabled ?? this.sensorGeofenceEnabled,
      sensorMotionEnabled: sensorMotionEnabled ?? this.sensorMotionEnabled,
      sensorBatteryOptimizationDisabled: sensorBatteryOptimizationDisabled ?? this.sensorBatteryOptimizationDisabled,
    );
  }
}
