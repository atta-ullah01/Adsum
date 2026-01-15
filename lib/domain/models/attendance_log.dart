/// Attendance log domain models - matches `/data/attendance.json`

import 'package:flutter/foundation.dart';

/// Attendance status enum
enum AttendanceStatus {
  present,
  absent,
  pending;

  static AttendanceStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'ABSENT':
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.pending;
    }
  }

  String toJson() => name.toUpperCase();
}

/// Source of attendance detection
enum AttendanceSource {
  geofence,
  wifi,
  manual,
  crowdVerified;

  static AttendanceSource fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'GEOFENCE':
        return AttendanceSource.geofence;
      case 'WIFI':
        return AttendanceSource.wifi;
      case 'MANUAL':
        return AttendanceSource.manual;
      case 'CROWD_VERIFIED':
        return AttendanceSource.crowdVerified;
      default:
        return AttendanceSource.manual;
    }
  }

  String toJson() => name.toUpperCase();
}

/// Verification state
enum VerificationState {
  autoConfirmed,
  manualOverride,
  pending;

  static VerificationState fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'AUTO_CONFIRMED':
        return VerificationState.autoConfirmed;
      case 'MANUAL_OVERRIDE':
        return VerificationState.manualOverride;
      default:
        return VerificationState.pending;
    }
  }

  String toJson() {
    switch (this) {
      case VerificationState.autoConfirmed:
        return 'AUTO_CONFIRMED';
      case VerificationState.manualOverride:
        return 'MANUAL_OVERRIDE';
      case VerificationState.pending:
        return 'PENDING';
    }
  }
}

/// Attendance log entry
@immutable
class AttendanceLog {
  final String logId;
  final String enrollmentId;
  final DateTime date;
  final String? slotId; // References base_timetable_rules or custom_schedule_slots
  final String? startTime; // For display: "10:00"
  final AttendanceStatus status;
  final AttendanceSource source;
  final int confidenceScore;
  final VerificationState verificationState;
  final AttendanceEvidence? evidence;
  final bool synced;

  const AttendanceLog({
    required this.logId,
    required this.enrollmentId,
    required this.date,
    this.slotId,
    this.startTime,
    this.status = AttendanceStatus.pending,
    this.source = AttendanceSource.manual,
    this.confidenceScore = 0,
    this.verificationState = VerificationState.pending,
    this.evidence,
    this.synced = false,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      logId: json['log_id'] as String,
      enrollmentId: json['enrollment_id'] as String,
      date: DateTime.parse(json['date'] as String),
      slotId: json['slot_id'] as String?,
      startTime: json['start_time'] as String?,
      status: AttendanceStatus.fromString(json['status'] as String?),
      source: AttendanceSource.fromString(json['source'] as String?),
      confidenceScore: json['confidence_score'] as int? ?? 0,
      verificationState:
          VerificationState.fromString(json['verification_state'] as String?),
      evidence: json['evidence'] != null
          ? AttendanceEvidence.fromJson(json['evidence'] as Map<String, dynamic>)
          : null,
      synced: json['synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'log_id': logId,
        'enrollment_id': enrollmentId,
        'date': date.toIso8601String().split('T')[0], // Date only
        if (slotId != null) 'slot_id': slotId,
        if (startTime != null) 'start_time': startTime,
        'status': status.toJson(),
        'source': source.toJson(),
        'confidence_score': confidenceScore,
        'verification_state': verificationState.toJson(),
        if (evidence != null) 'evidence': evidence!.toJson(),
        'synced': synced,
      };

  AttendanceLog copyWith({
    String? logId,
    String? enrollmentId,
    DateTime? date,
    String? slotId,
    String? startTime,
    AttendanceStatus? status,
    AttendanceSource? source,
    int? confidenceScore,
    VerificationState? verificationState,
    AttendanceEvidence? evidence,
    bool? synced,
  }) {
    return AttendanceLog(
      logId: logId ?? this.logId,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      date: date ?? this.date,
      slotId: slotId ?? this.slotId,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      source: source ?? this.source,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      verificationState: verificationState ?? this.verificationState,
      evidence: evidence ?? this.evidence,
      synced: synced ?? this.synced,
    );
  }
}

/// Evidence supporting attendance detection
@immutable
class AttendanceEvidence {
  final double? gpsLat;
  final double? gpsLong;
  final String? wifiBssid;
  final String? activity;

  const AttendanceEvidence({
    this.gpsLat,
    this.gpsLong,
    this.wifiBssid,
    this.activity,
  });

  factory AttendanceEvidence.fromJson(Map<String, dynamic> json) {
    return AttendanceEvidence(
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLong: (json['gps_long'] as num?)?.toDouble(),
      wifiBssid: json['wifi_bssid'] as String?,
      activity: json['activity'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (gpsLat != null) 'gps_lat': gpsLat,
        if (gpsLong != null) 'gps_long': gpsLong,
        if (wifiBssid != null) 'wifi_bssid': wifiBssid,
        if (activity != null) 'activity': activity,
      };
}
