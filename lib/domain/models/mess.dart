import 'package:equatable/equatable.dart';

/// Meal type enumeration
enum MealType {
  breakfast,
  lunch,
  snacks,
  dinner;

  String toJson() => name.toUpperCase();

  static MealType fromJson(String json) {
    return MealType.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => MealType.lunch,
    );
  }

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.snacks:
        return 'Snacks';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}

/// Day of week for mess schedule
enum MessDayOfWeek {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun;

  String toJson() => name.toUpperCase();

  static MessDayOfWeek fromJson(String json) {
    return MessDayOfWeek.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => MessDayOfWeek.mon,
    );
  }

  static MessDayOfWeek fromDateTime(DateTime date) {
    return MessDayOfWeek.values[date.weekday - 1];
  }
}

/// Represents a mess menu entry
/// Maps to `mess_menus` and `/data/menu_cache.json` in SCHEMA.md
class MessMenu extends Equatable {
  final String menuId;
  final String hostelId;
  final MessDayOfWeek dayOfWeek;
  final MealType mealType;
  final String startTime;
  final String endTime;
  final String items;
  final bool isModified; // Local edit flag

  const MessMenu({
    required this.menuId,
    required this.hostelId,
    required this.dayOfWeek,
    required this.mealType,
    required this.startTime,
    required this.endTime,
    required this.items,
    this.isModified = false,
  });

  @override
  List<Object?> get props => [
        menuId,
        hostelId,
        dayOfWeek,
        mealType,
        startTime,
        endTime,
        items,
        isModified,
      ];

  factory MessMenu.fromJson(Map<String, dynamic> json) {
    return MessMenu(
      menuId: json['menu_id'] as String,
      hostelId: json['hostel_id'] as String,
      dayOfWeek: MessDayOfWeek.fromJson(json['day_of_week'] as String),
      mealType: MealType.fromJson(json['meal_type'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      items: json['items'] as String,
      isModified: json['is_modified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'hostel_id': hostelId,
      'day_of_week': dayOfWeek.toJson(),
      'meal_type': mealType.toJson(),
      'start_time': startTime,
      'end_time': endTime,
      'items': items,
      'is_modified': isModified,
    };
  }

  MessMenu copyWith({
    String? menuId,
    String? hostelId,
    MessDayOfWeek? dayOfWeek,
    MealType? mealType,
    String? startTime,
    String? endTime,
    String? items,
    bool? isModified,
  }) {
    return MessMenu(
      menuId: menuId ?? this.menuId,
      hostelId: hostelId ?? this.hostelId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      items: items ?? this.items,
      isModified: isModified ?? this.isModified,
    );
  }

  /// Parse items string into list
  List<String> get itemsList {
    return items.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}

/// Menu cache metadata
class MenuCache extends Equatable {
  final DateTime? lastSyncedAt;
  final String? currentHostelId;
  final List<MessMenu> menus;

  const MenuCache({
    this.lastSyncedAt,
    this.currentHostelId,
    this.menus = const [],
  });

  @override
  List<Object?> get props => [lastSyncedAt, currentHostelId, menus];

  factory MenuCache.fromJson(Map<String, dynamic> json) {
    return MenuCache(
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      currentHostelId: json['current_hostel_id'] as String?,
      menus: (json['menus'] as List<dynamic>?)
              ?.map((m) => MessMenu.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'current_hostel_id': currentHostelId,
      'menus': menus.map((m) => m.toJson()).toList(),
    };
  }

  MenuCache copyWith({
    DateTime? lastSyncedAt,
    String? currentHostelId,
    List<MessMenu>? menus,
  }) {
    return MenuCache(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      currentHostelId: currentHostelId ?? this.currentHostelId,
      menus: menus ?? this.menus,
    );
  }
}
