import 'package:adsum/domain/models/university.dart';
import 'package:adsum/domain/models/models.dart';

/// Repository for shared app data (Universities, Hostels, Global Config)
/// In production, this would fetch from Supabase.
class SharedDataRepository {
  
  // Mock Data
  final List<University> _universities = [
    University(id: 'iit_delhi', name: 'IIT Delhi', domain: 'iitd.ac.in', semesterStart: DateTime(2026, 1, 6), semesterEnd: DateTime(2026, 5, 15)),
    University(id: 'iit_bombay', name: 'IIT Bombay', domain: 'iitb.ac.in', semesterStart: DateTime(2026, 1, 5), semesterEnd: DateTime(2026, 5, 10)),
    University(id: 'iit_kanpur', name: 'IIT Kanpur', domain: 'iitk.ac.in', semesterStart: DateTime(2026, 1, 4), semesterEnd: DateTime(2026, 5, 12)),
    University(id: 'bits_pilani', name: 'BITS Pilani', domain: 'bits-pilani.ac.in', semesterStart: DateTime(2026, 1, 10), semesterEnd: DateTime(2026, 5, 20)),
    University(id: 'iiit_una', name: 'IIIT Una', domain: 'iiitu.ac.in', semesterStart: DateTime(2026, 2, 1), semesterEnd: DateTime(2026, 6, 15)),
  ];

  final Map<String, List<Hostel>> _hostels = {
    'iit_delhi': [
      const Hostel(id: 'h_udaigiri', name: 'Udaigiri', universityId: 'iit_delhi'),
      const Hostel(id: 'h_aravali', name: 'Aravali', universityId: 'iit_delhi'),
      const Hostel(id: 'h_kumaon', name: 'Kumaon', universityId: 'iit_delhi'),
      const Hostel(id: 'h_shivalik', name: 'Shivalik', universityId: 'iit_delhi'),
      const Hostel(id: 'h_zanskar', name: 'Zanskar', universityId: 'iit_delhi'),
    ],
    // ... other hostels ...
  };

  final Map<String, List<Course>> _mockCourses = {
    'iit_delhi': [
      // CS Department
      const Course(courseCode: 'COL100', universityId: 'iit_delhi', name: 'Intro to Computer Science', instructor: 'Prof. Subhashis Banerjee'),
      const Course(courseCode: 'COL106', universityId: 'iit_delhi', name: 'Data Structures & Algorithms', instructor: 'Prof. Amitabha Bagchi'),
      const Course(courseCode: 'COL202', universityId: 'iit_delhi', name: 'Discrete Mathematical Structures', instructor: 'Prof. Naveen Garg'),
      const Course(courseCode: 'COL216', universityId: 'iit_delhi', name: 'Computer Architecture', instructor: 'Prof. Anshul Kumar'),
      const Course(courseCode: 'COL331', universityId: 'iit_delhi', name: 'Operating Systems', instructor: 'Prof. Sorav Bansal'),
      const Course(courseCode: 'COL334', universityId: 'iit_delhi', name: 'Computer Networks', instructor: 'Prof. Vinay Ribeiro'),
      const Course(courseCode: 'COL362', universityId: 'iit_delhi', name: 'Intro to Database Systems', instructor: 'Prof. Maya Ramanath'),
      const Course(courseCode: 'COL774', universityId: 'iit_delhi', name: 'Machine Learning', instructor: 'Prof. Parag Singla'),
      // EE Department
      const Course(courseCode: 'ELL101', universityId: 'iit_delhi', name: 'Intro to Electrical Engineering', instructor: 'Prof. Jayadeva'),
      const Course(courseCode: 'ELL201', universityId: 'iit_delhi', name: 'Digital Electronics', instructor: 'Prof. M. Jagadesh Kumar'),
      const Course(courseCode: 'ELL302', universityId: 'iit_delhi', name: 'Power Electronics', instructor: 'Prof. Anandrup Mukherjee'),
      // Math & others
      const Course(courseCode: 'MTL100', universityId: 'iit_delhi', name: 'Calculus', instructor: 'Prof. S. Kundu'),
      const Course(courseCode: 'MTL101', universityId: 'iit_delhi', name: 'Linear Algebra', instructor: 'Prof. R. Sarma'),
      const Course(courseCode: 'HUL261', universityId: 'iit_delhi', name: 'Intro to Psychology', instructor: 'Prof. Purnima Singh'),
    ],
    'iit_bombay': [
       const Course(courseCode: 'CS101', universityId: 'iit_bombay', name: 'Computer Programming', instructor: 'Prof. Phatak'),
    ],
    'iiit_una': [
       const Course(courseCode: 'CS201', universityId: 'iiit_una', name: 'Data Structures', instructor: 'Dr. Naman'),
    ],
    'default': [
      const Course(courseCode: 'CS101', universityId: 'default', name: 'Intro to Programming', instructor: 'Dr. Smith'),
    ],
  };

  /// Get list of supported universities
  Future<List<University>> getUniversities() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500)); 
    return _universities;
  }

  /// Get hostels for a specific university
  Future<List<Hostel>> getHostels(String universityId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _hostels[universityId] ?? [];
  }

  /// Search catalog courses
  Future<List<Course>> searchCourses(String universityId, String query) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Sim network
    final allCourses = _mockCourses[universityId] ?? [];
    
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return allCourses.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) || 
             c.courseCode.toLowerCase().contains(lowerQuery) ||
             c.instructor.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
