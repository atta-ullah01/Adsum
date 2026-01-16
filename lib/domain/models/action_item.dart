/// Action Item domain models - matches `/data/action_items.json`
library;

import 'package:flutter/material.dart';

/// Action item type
enum ActionItemType {
  conflict,
  verify,
  scheduleChange,
  assignmentDue,
  attendanceRisk;

  static ActionItemType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CONFLICT':
        return ActionItemType.conflict;
      case 'VERIFY':
        return ActionItemType.verify;
      case 'SCHEDULE_CHANGE':
        return ActionItemType.scheduleChange;
      case 'ASSIGNMENT_DUE':
        return ActionItemType.assignmentDue;
      case 'ATTENDANCE_RISK':
        return ActionItemType.attendanceRisk;
      default:
        return ActionItemType.verify;
    }
  }

  String toJson() {
    switch (this) {
      case ActionItemType.conflict:
        return 'CONFLICT';
      case ActionItemType.verify:
        return 'VERIFY';
      case ActionItemType.scheduleChange:
        return 'SCHEDULE_CHANGE';
      case ActionItemType.assignmentDue:
        return 'ASSIGNMENT_DUE';
      case ActionItemType.attendanceRisk:
        return 'ATTENDANCE_RISK';
    }
  }
}

/// Action item status
enum ActionItemStatus {
  pending,
  resolved;

  static ActionItemStatus fromString(String? value) {
    return value?.toUpperCase() == 'RESOLVED'
        ? ActionItemStatus.resolved
        : ActionItemStatus.pending;
  }

  String toJson() => name.toUpperCase();
}

/// Resolution type
enum Resolution {
  acceptUpdate,
  keepMine,
  yesPresent,
  noAbsent,
  acknowledged,
  markDone,
  snooze,
  details;

  static Resolution? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'ACCEPT_UPDATE':
        return Resolution.acceptUpdate;
      case 'KEEP_MINE':
        return Resolution.keepMine;
      case 'YES_PRESENT':
        return Resolution.yesPresent;
      case 'NO_ABSENT':
        return Resolution.noAbsent;
      case 'ACKNOWLEDGED':
        return Resolution.acknowledged;
      case 'MARK_DONE':
        return Resolution.markDone;
      case 'SNOOZE':
        return Resolution.snooze;
      case 'DETAILS':
        return Resolution.details;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case Resolution.acceptUpdate:
        return 'ACCEPT_UPDATE';
      case Resolution.keepMine:
        return 'KEEP_MINE';
      case Resolution.yesPresent:
        return 'YES_PRESENT';
      case Resolution.noAbsent:
        return 'NO_ABSENT';
      case Resolution.acknowledged:
        return 'ACKNOWLEDGED';
      case Resolution.markDone:
        return 'MARK_DONE';
      case Resolution.snooze:
        return 'SNOOZE';
      case Resolution.details:
        return 'DETAILS';
    }
  }
}

/// Action item - matches `/data/action_items.json`
@immutable
class ActionItem {

  const ActionItem({
    required this.itemId,
    required this.type,
    required this.title, required this.body, required this.createdAt, this.status = ActionItemStatus.pending,
    this.resolvedAt,
    this.resolution,
    this.bgColor = const Color(0xFFF3F4F6),
    this.accentColor = const Color(0xFF6366F1),
    this.payload = const {},
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      itemId: json['item_id'] as String,
      type: ActionItemType.fromString(json['type'] as String?),
      status: ActionItemStatus.fromString(json['status'] as String?),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolution: Resolution.fromString(json['resolution'] as String?),
      bgColor: _parseColor(json['bg_color'] as String?),
      accentColor: _parseColor(json['accent_color'] as String?),
      payload: json['payload'] != null
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : const {},
    );
  }
  final String itemId;
  final ActionItemType type;
  final ActionItemStatus status;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final Resolution? resolution;
  final Color bgColor;
  final Color accentColor;
  final Map<String, dynamic> payload;

  bool get isPending => status == ActionItemStatus.pending;

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFF3F4F6);
    try {
      return Color(int.parse(hex));
    } catch (_) {
      return const Color(0xFFF3F4F6);
    }
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'type': type.toJson(),
        'status': status.toJson(),
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
        if (resolution != null) 'resolution': resolution!.toJson(),
        'bg_color': '0x${bgColor.value.toRadixString(16).toUpperCase()}',
        'accent_color': '0x${accentColor.value.toRadixString(16).toUpperCase()}',
        'payload': payload,
      };

  ActionItem copyWith({
    String? itemId,
    ActionItemType? type,
    ActionItemStatus? status,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? resolvedAt,
    Resolution? resolution,
    Color? bgColor,
    Color? accentColor,
    Map<String, dynamic>? payload,
  }) {
    return ActionItem(
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      bgColor: bgColor ?? this.bgColor,
      accentColor: accentColor ?? this.accentColor,
      payload: payload ?? this.payload,
    );
  }

  /// Resolve this action item
  ActionItem resolve(Resolution res) {
    return copyWith(
      status: ActionItemStatus.resolved,
      resolvedAt: DateTime.now(),
      resolution: res,
    );
  }
}

/// Conflict payload details
@immutable
class ConflictPayload {

  const ConflictPayload({
    required this.conflictCategory,
    required this.sourceA,
    required this.sourceB,
  });

  factory ConflictPayload.fromJson(Map<String, dynamic> json) {
    return ConflictPayload(
      conflictCategory: json['conflict_category'] as String,
      sourceA: ConflictSource.fromJson(json['sourceA'] as Map<String, dynamic>),
      sourceB: ConflictSource.fromJson(json['sourceB'] as Map<String, dynamic>),
    );
  }
  final String conflictCategory;
  final ConflictSource sourceA;
  final ConflictSource sourceB;
}

@immutable
class ConflictSource {

  const ConflictSource({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.layer,
  });

  factory ConflictSource.fromJson(Map<String, dynamic> json) {
    return ConflictSource(
      label: json['label'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      layer: json['layer'] as String,
    );
  }
  final String label;
  final String title;
  final String subtitle;
  final String layer;
}
