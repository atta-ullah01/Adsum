import 'package:equatable/equatable.dart';

/// Type of schedule modification action
enum ModificationAction {
  cancel,
  reschedule,
  extraClass,
  swapRoom;

  String toJson() => name.toUpperCase();

  static ModificationAction fromJson(String json) {
    // Handle legacy or mapped values if needed
    if (json == 'CANCELLED') return ModificationAction.cancel;
    if (json == 'RESCHEDULED') return ModificationAction.reschedule;
    
    return ModificationAction.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => ModificationAction.cancel,
    );
  }
}

/// Represents a modification to the standard schedule (Layer 2)
/// Maps to `schedule_modifications` table in SCHEMA.md
class ScheduleModification extends Equatable {
  final String patchId;
  final String? targetRuleId; // Null for extra class
  final String courseCode;
  final String? section;
  final DateTime affectedDate;
  final ModificationAction action;
  final DateTime? newDate;
  final String? newStartTime;
  final String? newEndTime;
  final String? newLocation;
  final String? note;
  final String crUserId;
  final DateTime createdAt;

  const ScheduleModification({
    required this.patchId,
    this.targetRuleId,
    required this.courseCode,
    this.section,
    required this.affectedDate,
    required this.action,
    this.newDate,
    this.newStartTime,
    this.newEndTime,
    this.newLocation,
    this.note,
    required this.crUserId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        patchId,
        targetRuleId,
        courseCode,
        section,
        affectedDate,
        action,
        newDate,
        newStartTime,
        newEndTime,
        newLocation,
        note,
        crUserId,
        createdAt,
      ];

  factory ScheduleModification.fromJson(Map<String, dynamic> json) {
    return ScheduleModification(
      patchId: json['patch_id'] as String,
      targetRuleId: json['target_rule_id'] as String?,
      courseCode: json['course_code'] as String,
      section: json['section'] as String?,
      affectedDate: DateTime.parse(json['affected_date'] as String),
      action: ModificationAction.fromJson(json['action'] as String),
      newDate: json['new_date'] != null ? DateTime.parse(json['new_date'] as String) : null,
      newStartTime: json['new_start_time'] as String?,
      newEndTime: json['new_end_time'] as String?,
      newLocation: json['new_location'] as String?,
      note: json['note'] as String?,
      crUserId: json['cr_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patch_id': patchId,
      'target_rule_id': targetRuleId,
      'course_code': courseCode,
      'section': section,
      'affected_date': affectedDate.toIso8601String().split('T').first,
      'action': action.toJson(),
      'new_date': newDate?.toIso8601String().split('T').first,
      'new_start_time': newStartTime,
      'new_end_time': newEndTime,
      'new_location': newLocation,
      'note': note,
      'cr_user_id': crUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
