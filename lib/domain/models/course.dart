import 'package:flutter/foundation.dart';

@immutable
class Course {

  const Course({
    required this.courseCode,
    required this.universityId,
    required this.name,
    required this.instructor,
    this.description = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseCode: json['course_code'] as String,
      universityId: json['university_id'] as String,
      name: json['name'] as String,
      instructor: json['instructor'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
    );
  }
  final String courseCode;
  final String universityId;
  final String name;
  final String instructor;
  final String description;

  Map<String, dynamic> toJson() => {
        'course_code': courseCode,
        'university_id': universityId,
        'name': name,
        'instructor': instructor,
        'description': description,
      };
}
