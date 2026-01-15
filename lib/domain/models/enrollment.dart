/// Enrollment domain models - matches `/data/enrollments.json`

import 'package:flutter/foundation.dart';

/// A course enrollment with stats
@immutable
class Enrollment {
  final String enrollmentId;
  final String? courseCode; // For catalog courses
  final String? catalogInstructor; // Snapshot of instructor name for catalog courses
  final CustomCourse? customCourse; // For custom courses
  final String section;
  final double targetAttendance;
  final String colorTheme;
  final DateTime startDate;
  final EnrollmentStats stats;

  const Enrollment({
    required this.enrollmentId,
    this.courseCode,
    this.catalogInstructor,
    this.customCourse,
    this.section = 'A',
    this.targetAttendance = 75.0,
    this.colorTheme = '#6366F1',
    required this.startDate,
    this.stats = const EnrollmentStats(),
  });

  /// Whether this is a custom course (not from catalog)
  bool get isCustom => customCourse != null;

  /// Get course code (custom or catalog)
  String get effectiveCourseCode =>
      courseCode ?? customCourse?.code ?? 'UNKNOWN';

  /// Get course name
  String get courseName =>
      customCourse?.name ?? courseCode ?? 'Unknown Course';

  /// Get instructor name (custom or catalog)
  String? get instructor => customCourse?.instructor ?? catalogInstructor;

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollmentId: json['enrollment_id'] as String,
      courseCode: json['course_code'] as String?,
      catalogInstructor: json['catalog_instructor'] as String?,
      customCourse: json['custom_course'] != null
          ? CustomCourse.fromJson(json['custom_course'] as Map<String, dynamic>)
          : null,
      section: json['section'] as String? ?? 'A',
      targetAttendance: (json['target_attendance'] as num?)?.toDouble() ?? 75.0,
      colorTheme: json['color_theme'] as String? ?? '#6366F1',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'] as String) 
          : DateTime.now(), // Fallback for old data
      stats: json['stats'] != null
          ? EnrollmentStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const EnrollmentStats(),
    );
  }

  Map<String, dynamic> toJson() => {
        'enrollment_id': enrollmentId,
        if (courseCode != null) 'course_code': courseCode,
        if (catalogInstructor != null) 'catalog_instructor': catalogInstructor,
        if (customCourse != null) 'custom_course': customCourse!.toJson(),
        'section': section,
        'target_attendance': targetAttendance,
        'color_theme': colorTheme,
        'start_date': startDate.toIso8601String(),
        'stats': stats.toJson(),
      };

  Enrollment copyWith({
    String? enrollmentId,
    String? courseCode,
    String? catalogInstructor,
    CustomCourse? customCourse,
    String? section,
    double? targetAttendance,
    String? colorTheme,
    DateTime? startDate,
    EnrollmentStats? stats,
  }) {
    return Enrollment(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      courseCode: courseCode ?? this.courseCode,
      catalogInstructor: catalogInstructor ?? this.catalogInstructor,
      customCourse: customCourse ?? this.customCourse,
      section: section ?? this.section,
      targetAttendance: targetAttendance ?? this.targetAttendance,
      colorTheme: colorTheme ?? this.colorTheme,
      startDate: startDate ?? this.startDate,
      stats: stats ?? this.stats,
    );
  }
}

/// Custom course definition (embedded in enrollment)
@immutable
class CustomCourse {
  final String code;
  final String name;
  final String instructor;
  final int totalExpected;

  const CustomCourse({
    required this.code,
    required this.name,
    this.instructor = 'Self',
    this.totalExpected = 30,
  });

  factory CustomCourse.fromJson(Map<String, dynamic> json) {
    return CustomCourse(
      code: json['code'] as String,
      name: json['name'] as String,
      instructor: json['instructor'] as String? ?? 'Self',
      totalExpected: json['total_expected'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'instructor': instructor,
        'total_expected': totalExpected,
      };

  CustomCourse copyWith({
    String? code,
    String? name,
    String? instructor,
    int? totalExpected,
  }) {
    return CustomCourse(
      code: code ?? this.code,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      totalExpected: totalExpected ?? this.totalExpected,
    );
  }
}

/// Enrollment statistics
@immutable
class EnrollmentStats {
  final int totalClasses;
  final int attended;
  final int safeBunks;

  const EnrollmentStats({
    this.totalClasses = 0,
    this.attended = 0,
    this.safeBunks = 0,
  });

  /// Current attendance percentage
  double get attendancePercent =>
      totalClasses > 0 ? (attended / totalClasses) * 100 : 0;

  factory EnrollmentStats.fromJson(Map<String, dynamic> json) {
    return EnrollmentStats(
      totalClasses: json['total_classes'] as int? ?? 0,
      attended: json['attended'] as int? ?? 0,
      safeBunks: json['safe_bunks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_classes': totalClasses,
        'attended': attended,
        'safe_bunks': safeBunks,
      };

  EnrollmentStats copyWith({
    int? totalClasses,
    int? attended,
    int? safeBunks,
  }) {
    return EnrollmentStats(
      totalClasses: totalClasses ?? this.totalClasses,
      attended: attended ?? this.attended,
      safeBunks: safeBunks ?? this.safeBunks,
    );
  }
}
