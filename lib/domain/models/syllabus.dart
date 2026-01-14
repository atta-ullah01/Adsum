import 'package:equatable/equatable.dart';

/// Represents a syllabus unit with topics
/// Maps to `syllabus_units` and `syllabus_topics` in SCHEMA.md
class SyllabusUnit extends Equatable {
  final String unitId;
  final String title;
  final int unitOrder;
  final List<SyllabusTopic> topics;

  const SyllabusUnit({
    required this.unitId,
    required this.title,
    required this.unitOrder,
    this.topics = const [],
  });

  @override
  List<Object?> get props => [unitId, title, unitOrder, topics];

  factory SyllabusUnit.fromJson(Map<String, dynamic> json) {
    return SyllabusUnit(
      unitId: json['unit_id'] as String,
      title: json['title'] as String,
      unitOrder: json['unit_order'] as int? ?? 0,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((t) => SyllabusTopic.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'title': title,
      'unit_order': unitOrder,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }

  SyllabusUnit copyWith({
    String? unitId,
    String? title,
    int? unitOrder,
    List<SyllabusTopic>? topics,
  }) {
    return SyllabusUnit(
      unitId: unitId ?? this.unitId,
      title: title ?? this.title,
      unitOrder: unitOrder ?? this.unitOrder,
      topics: topics ?? this.topics,
    );
  }

  /// Calculate completion percentage for this unit
  double completionPercentage(List<String> completedTopicIds) {
    if (topics.isEmpty) return 0;
    final completed = topics.where((t) => completedTopicIds.contains(t.topicId)).length;
    return (completed / topics.length) * 100;
  }
}

/// Represents a single topic within a syllabus unit
class SyllabusTopic extends Equatable {
  final String topicId;
  final String title;

  const SyllabusTopic({
    required this.topicId,
    required this.title,
  });

  @override
  List<Object?> get props => [topicId, title];

  factory SyllabusTopic.fromJson(Map<String, dynamic> json) {
    return SyllabusTopic(
      topicId: json['topic_id'] as String,
      title: json['name'] as String? ?? json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic_id': topicId,
      'name': title,
    };
  }

  SyllabusTopic copyWith({
    String? topicId,
    String? title,
  }) {
    return SyllabusTopic(
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
    );
  }
}

/// Wrapper for a course's custom syllabus
class CustomSyllabus extends Equatable {
  final String courseCode;
  final List<SyllabusUnit> units;

  const CustomSyllabus({
    required this.courseCode,
    this.units = const [],
  });

  @override
  List<Object?> get props => [courseCode, units];

  factory CustomSyllabus.fromJson(Map<String, dynamic> json) {
    return CustomSyllabus(
      courseCode: json['course_code'] as String,
      units: (json['units'] as List<dynamic>?)
              ?.map((u) => SyllabusUnit.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_code': courseCode,
      'units': units.map((u) => u.toJson()).toList(),
    };
  }

  /// Get all topic IDs in this syllabus
  List<String> get allTopicIds {
    return units.expand((u) => u.topics.map((t) => t.topicId)).toList();
  }

  /// Calculate total completion percentage
  double completionPercentage(List<String> completedTopicIds) {
    final allTopics = allTopicIds;
    if (allTopics.isEmpty) return 0;
    final completed = allTopics.where((id) => completedTopicIds.contains(id)).length;
    return (completed / allTopics.length) * 100;
  }
}
