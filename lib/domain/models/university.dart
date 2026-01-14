
import 'package:equatable/equatable.dart';

class University extends Equatable {
  final String id;
  final String name;
  final String domain; // e.g., 'iitd.ac.in', for email validation
  final String? logoUrl;

  const University({
    required this.id,
    required this.name,
    required this.domain,
    this.logoUrl,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'logo_url': logoUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, domain, logoUrl];
}

class Hostel extends Equatable {
  final String id;
  final String name;
  final String universityId;

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
