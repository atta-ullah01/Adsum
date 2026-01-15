import 'package:equatable/equatable.dart';

/// Work type enumeration matching SCHEMA.md `course_work.work_type`
enum WorkType {
  assignment,
  quiz,
  exam,
  project;

  String toJson() => name.toUpperCase();

  static WorkType fromJson(String json) {
    return WorkType.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => WorkType.assignment,
    );
  }
}

/// Work status for local tracking
enum WorkStatus {
  pending,
  submitted,
  graded;

  String toJson() => name.toUpperCase();

  static WorkStatus fromJson(String json) {
    return WorkStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => WorkStatus.pending,
    );
  }
}

/// Represents course work (assignment, quiz, exam, project)
/// Maps to `course_work` table in SCHEMA.md
class Work extends Equatable {
  final String workId;
  final String courseCode;
  final WorkType workType;
  final String title;
  final DateTime? dueAt;
  final DateTime? startAt;
  final int? durationMinutes;
  final String? venue;
  final String? description;
  final bool isSuperEvent;
  final DateTime createdAt;

  const Work({
    required this.workId,
    required this.courseCode,
    required this.workType,
    required this.title,
    this.dueAt,
    this.startAt,
    this.durationMinutes,
    this.venue,
    this.description,
    this.isSuperEvent = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        workId,
        courseCode,
        workType,
        title,
        dueAt,
        startAt,
        durationMinutes,
        venue,
        description,
        isSuperEvent,
        createdAt,
      ];

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      workId: json['work_id'] as String,
      courseCode: json['course_code'] as String,
      workType: WorkType.fromJson(json['work_type'] as String),
      title: json['title'] as String,
      dueAt: json['due_at'] != null ? DateTime.parse(json['due_at'] as String) : null,
      startAt: json['start_at'] != null ? DateTime.parse(json['start_at'] as String) : null,
      durationMinutes: json['duration_minutes'] as int?,
      venue: json['venue'] as String?,
      description: json['description'] as String?,
      isSuperEvent: json['is_super_event'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work_id': workId,
      'course_code': courseCode,
      'work_type': workType.toJson(),
      'title': title,
      'due_at': dueAt?.toIso8601String(),
      'start_at': startAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'venue': venue,
      'description': description,
      'is_super_event': isSuperEvent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Work copyWith({
    String? workId,
    String? courseCode,
    WorkType? workType,
    String? title,
    DateTime? dueAt,
    DateTime? startAt,
    int? durationMinutes,
    String? venue,
    String? description,
    bool? isSuperEvent,
    DateTime? createdAt,
  }) {
    return Work(
      workId: workId ?? this.workId,
      courseCode: courseCode ?? this.courseCode,
      workType: workType ?? this.workType,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      startAt: startAt ?? this.startAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      isSuperEvent: isSuperEvent ?? this.isSuperEvent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if work is due soon (within 48 hours)
  bool get isDueSoon {
    if (dueAt == null) return false;
    final now = DateTime.now();
    final diff = dueAt!.difference(now);
    return diff.inHours >= 0 && diff.inHours <= 48;
  }

  /// Check if work is overdue
  bool get isOverdue {
    if (dueAt == null) return false;
    return DateTime.now().isAfter(dueAt!);
  }
}

/// Tracks local state of course work
/// Maps to `/data/work_states.json` in SCHEMA.md
class WorkState extends Equatable {
  final String workId;
  final WorkStatus status;
  final String? grade;
  final bool isHiddenFromCalendar;

  const WorkState({
    required this.workId,
    this.status = WorkStatus.pending,
    this.grade,
    this.isHiddenFromCalendar = false,
  });

  @override
  List<Object?> get props => [workId, status, grade, isHiddenFromCalendar];

  factory WorkState.fromJson(Map<String, dynamic> json) {
    return WorkState(
      workId: json['work_id'] as String,
      status: WorkStatus.fromJson(json['status'] as String? ?? 'PENDING'),
      grade: json['grade'] as String?,
      isHiddenFromCalendar: json['is_hidden_from_calendar'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work_id': workId,
      'status': status.toJson(),
      'grade': grade,
      'is_hidden_from_calendar': isHiddenFromCalendar,
    };
  }

  WorkState copyWith({
    String? workId,
    WorkStatus? status,
    String? grade,
    bool? isHiddenFromCalendar,
  }) {
    return WorkState(
      workId: workId ?? this.workId,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      isHiddenFromCalendar: isHiddenFromCalendar ?? this.isHiddenFromCalendar,
    );
  }
}

/// Represents a comment on a work item
/// Maps to `work_comments` table in SCHEMA.md
class WorkComment extends Equatable {
  final String commentId;
  final String workId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const WorkComment({
    required this.commentId,
    required this.workId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [commentId, workId, userId, text, createdAt];

  factory WorkComment.fromJson(Map<String, dynamic> json) {
    return WorkComment(
      commentId: json['comment_id'] as String,
      workId: json['work_id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'work_id': workId,
      'user_id': userId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
