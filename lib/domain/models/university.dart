
import 'package:equatable/equatable.dart';

class University extends Equatable {

  const University({
    required this.id,
    required this.name,
    required this.domain,
    this.logoUrl,
    this.semesterStart,
    this.semesterEnd,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
      logoUrl: json['logo_url'] as String?,
      semesterStart: json['semester_start'] != null 
          ? DateTime.parse(json['semester_start'] as String) 
          : null,
      semesterEnd: json['semester_end'] != null 
          ? DateTime.parse(json['semester_end'] as String) 
          : null,
    );
  }
  final String id;
  final String name;
  final String domain; // e.g., 'iitd.ac.in', for email validation
  final String? logoUrl;
  final DateTime? semesterStart;
  final DateTime? semesterEnd;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'logo_url': logoUrl,
      if (semesterStart != null) 'semester_start': semesterStart!.toIso8601String(),
      if (semesterEnd != null) 'semester_end': semesterEnd!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, domain, logoUrl, semesterStart, semesterEnd];
}

class Hostel extends Equatable {

  const Hostel({
    required this.id,
    required this.name,
    required this.universityId,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      id: json['id'] as String,
      name: json['name'] as String,
      universityId: json['university_id'] as String,
    );
  }
  final String id;
  final String name;
  final String universityId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'university_id': universityId,
    };
  }

  @override
  List<Object?> get props => [id, name, universityId];
}
