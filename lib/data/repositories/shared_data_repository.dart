import 'package:adsum/domain/models/university.dart';

/// Repository for shared app data (Universities, Hostels, Global Config)
/// In production, this would fetch from Supabase.
class SharedDataRepository {
  
  // Mock Data
  final List<University> _universities = [
    const University(id: 'iit_delhi', name: 'IIT Delhi', domain: 'iitd.ac.in'),
    const University(id: 'iit_bombay', name: 'IIT Bombay', domain: 'iitb.ac.in'),
    const University(id: 'iit_madras', name: 'IIT Madras', domain: 'iitm.ac.in'),
    const University(id: 'bits_pilani', name: 'BITS Pilani', domain: 'bits-pilani.ac.in'),
    const University(id: 'iiit_una', name: 'IIIT Una', domain: 'iiitu.ac.in'),
  ];

  final Map<String, List<Hostel>> _hostels = {
    'iit_delhi': [
      const Hostel(id: 'h_udaigiri', name: 'Hostel Udaigiri', universityId: 'iit_delhi'),
      const Hostel(id: 'h_aravali', name: 'Hostel Aravali', universityId: 'iit_delhi'),
      const Hostel(id: 'h_nilgiri', name: 'Hostel Nilgiri', universityId: 'iit_delhi'),
      const Hostel(id: 'h_kumaon', name: 'Hostel Kumaon', universityId: 'iit_delhi'),
    ],
    'iiit_una': [
      const Hostel(id: 'h_f1', name: 'Hostel F1', universityId: 'iiit_una'),
      const Hostel(id: 'h_f2', name: 'Hostel F2', universityId: 'iiit_una'),
      const Hostel(id: 'h_f3', name: 'Hostel F3', universityId: 'iiit_una'),
    ],
    // Default/Fallback
    'default': [
      const Hostel(id: 'h_1', name: 'Hostel A', universityId: 'default'),
      const Hostel(id: 'h_2', name: 'Hostel B', universityId: 'default'),
    ]
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
    return _hostels[universityId] ?? _hostels['default']!;
  }
}
