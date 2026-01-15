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
    University(id: 'iit_madras', name: 'IIT Madras', domain: 'iitm.ac.in', semesterStart: DateTime(2026, 1, 12), semesterEnd: DateTime(2026, 5, 18)),
    University(id: 'iit_kharagpur', name: 'IIT Kharagpur', domain: 'iitkgp.ac.in', semesterStart: DateTime(2026, 1, 8), semesterEnd: DateTime(2026, 5, 14)),
    University(id: 'bits_pilani', name: 'BITS Pilani', domain: 'bits-pilani.ac.in', semesterStart: DateTime(2026, 1, 10), semesterEnd: DateTime(2026, 5, 20)),
    University(id: 'iiit_una', name: 'IIIT Una', domain: 'iiitu.ac.in', semesterStart: DateTime(2026, 2, 1), semesterEnd: DateTime(2026, 6, 15)),
    University(id: 'srm_univ', name: 'SRM University', domain: 'srmist.edu.in', semesterStart: DateTime(2026, 1, 20), semesterEnd: DateTime(2026, 5, 25)),
  ];

  final Map<String, List<Hostel>> _hostels = {
    'iit_delhi': [
      const Hostel(id: 'h_udaigiri', name: 'Udaigiri', universityId: 'iit_delhi'),
      const Hostel(id: 'h_aravali', name: 'Aravali', universityId: 'iit_delhi'),
      const Hostel(id: 'h_kumaon', name: 'Kumaon', universityId: 'iit_delhi'),
      const Hostel(id: 'h_shivalik', name: 'Shivalik', universityId: 'iit_delhi'),
      const Hostel(id: 'h_zanskar', name: 'Zanskar', universityId: 'iit_delhi'),
      const Hostel(id: 'h_girnar', name: 'Girnar', universityId: 'iit_delhi'),
      const Hostel(id: 'h_satpura', name: 'Satpura', universityId: 'iit_delhi'),
      const Hostel(id: 'h_himadri', name: 'Himadri', universityId: 'iit_delhi'),
    ],
    'iit_bombay': [
        const Hostel(id: 'h_1', name: 'Hostel 1', universityId: 'iit_bombay'),
        const Hostel(id: 'h_2', name: 'Hostel 2', universityId: 'iit_bombay'),
        const Hostel(id: 'h_3', name: 'Hostel 3', universityId: 'iit_bombay'),
        const Hostel(id: 'h_4', name: 'Hostel 4', universityId: 'iit_bombay'),
        const Hostel(id: 'h_12', name: 'Hostel 12', universityId: 'iit_bombay'),
        const Hostel(id: 'h_18', name: 'Hostel 18', universityId: 'iit_bombay'),
    ],
    'iit_kanpur': [
        const Hostel(id: 'h_hall1', name: 'Hall 1', universityId: 'iit_kanpur'),
        const Hostel(id: 'h_hall2', name: 'Hall 2', universityId: 'iit_kanpur'),
        const Hostel(id: 'h_hall3', name: 'Hall 3', universityId: 'iit_kanpur'),
        const Hostel(id: 'h_hall5', name: 'Hall 5', universityId: 'iit_kanpur'),
        const Hostel(id: 'h_gh', name: 'Girls Hostel 1', universityId: 'iit_kanpur'),
    ],
    'iit_madras': [
        const Hostel(id: 'h_ganga', name: 'Ganga', universityId: 'iit_madras'),
        const Hostel(id: 'h_jamuna', name: 'Jamuna', universityId: 'iit_madras'),
        const Hostel(id: 'h_godavari', name: 'Godavari', universityId: 'iit_madras'),
        const Hostel(id: 'h_saraswathi', name: 'Saraswathi', universityId: 'iit_madras'),
    ],
    'iit_kharagpur': [
        const Hostel(id: 'h_rp', name: 'Rajendra Prasad Hall', universityId: 'iit_kharagpur'),
        const Hostel(id: 'h_rk', name: 'Radhakrishnan Hall', universityId: 'iit_kharagpur'),
        const Hostel(id: 'h_llr', name: 'Lala Lajpat Rai Hall', universityId: 'iit_kharagpur'),
        const Hostel(id: 'h_mmm', name: 'Madan Mohan Malviya Hall', universityId: 'iit_kharagpur'),
    ],
     'bits_pilani': [
        const Hostel(id: 'h_shankar', name: 'Shankar Bhawan', universityId: 'bits_pilani'),
        const Hostel(id: 'h_vyas', name: 'Vyas Bhawan', universityId: 'bits_pilani'),
        const Hostel(id: 'h_ram', name: 'Ram Bhawan', universityId: 'bits_pilani'),
        const Hostel(id: 'h_budh', name: 'Budh Bhawan', universityId: 'bits_pilani'),
    ],
    'iiit_una': [
        const Hostel(id: 'h_b1', name: 'Bhadrakali (Boys)', universityId: 'iiit_una'),
        const Hostel(id: 'h_g1', name: 'Saraswati (Girls)', universityId: 'iiit_una'),
    ],
    'srm_univ': [
        const Hostel(id: 'h_srm_b1', name: 'Adhiyaman', universityId: 'srm_univ'),
        const Hostel(id: 'h_srm_b2', name: 'Kaari', universityId: 'srm_univ'),
        const Hostel(id: 'h_srm_g1', name: 'Kalpana Chawla', universityId: 'srm_univ'),
    ]
  };

  final Map<String, List<Course>> _mockCourses = {
    'iit_delhi': [
      // CS Department
      const Course(courseCode: 'COL100', universityId: 'iit_delhi', name: 'Intro to Computer Science', instructor: 'Prof. Subhashis Banerjee'),
      const Course(courseCode: 'COL106', universityId: 'iit_delhi', name: 'Data Structures & Algorithms', instructor: 'Prof. Amitabha Bagchi'),
      const Course(courseCode: 'COL202', universityId: 'iit_delhi', name: 'Discrete Mathematical Structures', instructor: 'Prof. Naveen Garg'),
      const Course(courseCode: 'COL215', universityId: 'iit_delhi', name: 'Digital Logic & System Design', instructor: 'Prof. M. Balakrishnan'),
      const Course(courseCode: 'COL216', universityId: 'iit_delhi', name: 'Computer Architecture', instructor: 'Prof. Anshul Kumar'),
      const Course(courseCode: 'COL226', universityId: 'iit_delhi', name: 'Programming Languages', instructor: 'Prof. S. Arun-Kumar'),
      const Course(courseCode: 'COL331', universityId: 'iit_delhi', name: 'Operating Systems', instructor: 'Prof. Sorav Bansal'),
      const Course(courseCode: 'COL333', universityId: 'iit_delhi', name: 'Artificial Intelligence', instructor: 'Prof. Mausam'),
      const Course(courseCode: 'COL334', universityId: 'iit_delhi', name: 'Computer Networks', instructor: 'Prof. Vinay Ribeiro'),
      const Course(courseCode: 'COL351', universityId: 'iit_delhi', name: 'Analysis and Design of Algorithms', instructor: 'Prof. Sandeep Sen'),
      const Course(courseCode: 'COL352', universityId: 'iit_delhi', name: 'Intro to Automata & Theory of Computation', instructor: 'Prof. Raghunath Tewari'),
      const Course(courseCode: 'COL362', universityId: 'iit_delhi', name: 'Intro to Database Systems', instructor: 'Prof. Maya Ramanath'),
      const Course(courseCode: 'COL380', universityId: 'iit_delhi', name: 'Intro to Parallel & Distributed Programming', instructor: 'Prof. Subodh Kumar'),
      const Course(courseCode: 'COL774', universityId: 'iit_delhi', name: 'Machine Learning', instructor: 'Prof. Parag Singla'),
      const Course(courseCode: 'COP290', universityId: 'iit_delhi', name: 'Design Practices', instructor: 'Prof. Rijurekha Sen'),
      // EE Department
      const Course(courseCode: 'ELL101', universityId: 'iit_delhi', name: 'Intro to Electrical Engineering', instructor: 'Prof. Jayadeva'),
      const Course(courseCode: 'ELL201', universityId: 'iit_delhi', name: 'Digital Electronics', instructor: 'Prof. M. Jagadesh Kumar'),
      const Course(courseCode: 'ELL202', universityId: 'iit_delhi', name: 'Circuit Theory', instructor: 'Prof. B.K. Panigrahi'),
      const Course(courseCode: 'ELL203', universityId: 'iit_delhi', name: 'Electromechanics', instructor: 'Prof. Bhim Singh'),
      const Course(courseCode: 'ELL302', universityId: 'iit_delhi', name: 'Power Electronics', instructor: 'Prof. Anandrup Mukherjee'),
      const Course(courseCode: 'ELP101', universityId: 'iit_delhi', name: 'Electronics Lab I', instructor: 'Prof. Shouri Chatterjee'),
      // Math & others
      const Course(courseCode: 'MTL100', universityId: 'iit_delhi', name: 'Calculus', instructor: 'Prof. S. Kundu'),
      const Course(courseCode: 'MTL101', universityId: 'iit_delhi', name: 'Linear Algebra', instructor: 'Prof. R. Sarma'),
      const Course(courseCode: 'MTL106', universityId: 'iit_delhi', name: 'Probability and Stochastic Processes', instructor: 'Prof. S. Dharmaraja'),
      const Course(courseCode: 'HUL261', universityId: 'iit_delhi', name: 'Intro to Psychology', instructor: 'Prof. Purnima Singh'),
      const Course(courseCode: 'HUL211', universityId: 'iit_delhi', name: 'Intro to Economics', instructor: 'Prof. V. Upadhyay'),
    ],
    'iit_bombay': [
        const Course(courseCode: 'CS101', universityId: 'iit_bombay', name: 'Computer Programming and Utilization', instructor: 'Prof. D.B. Phatak'),
        const Course(courseCode: 'CS152', universityId: 'iit_bombay', name: 'Abstractions and Paradigms in Programming', instructor: 'Prof. Amitabha Sanyal'),
        const Course(courseCode: 'CS154', universityId: 'iit_bombay', name: 'Programming Paradigms Lab', instructor: 'Prof. Amitabha Sanyal'),
        const Course(courseCode: 'EE101', universityId: 'iit_bombay', name: 'Introduction to Electrical and Electronic Circuits', instructor: 'Prof. M.B. Patil'),
        const Course(courseCode: 'PH107', universityId: 'iit_bombay', name: 'Quantum Physics and Application', instructor: 'Prof. S.P. Mahajan'),
        const Course(courseCode: 'MA105', universityId: 'iit_bombay', name: 'Calculus', instructor: 'Prof. I.K. Rana'),
    ],
    'iit_kanpur': [
        const Course(courseCode: 'ESC101', universityId: 'iit_kanpur', name: 'Fundamentals of Computing', instructor: 'Prof. Sumit Ganguly'),
        const Course(courseCode: 'MTH101', universityId: 'iit_kanpur', name: 'Mathematics I', instructor: 'Prof. P. Shunmugaraj'),
        const Course(courseCode: 'PHY102', universityId: 'iit_kanpur', name: 'Physics I', instructor: 'Prof. H.C. Verma'), // Classic
        const Course(courseCode: 'CHM101', universityId: 'iit_kanpur', name: 'Chemistry I', instructor: 'Prof. J.N. Moorthy'),
        const Course(courseCode: 'ENG112', universityId: 'iit_kanpur', name: 'English', instructor: 'Prof. T. Ravichandran'),
    ],
    'iit_madras': [
         const Course(courseCode: 'CS1100', universityId: 'iit_madras', name: 'Computational Engineering', instructor: 'Prof. S. Das'),
         const Course(courseCode: 'AM1100', universityId: 'iit_madras', name: 'Engineering Mechanics', instructor: 'Prof. M.S. Sivakumar'),
         const Course(courseCode: 'CY1010', universityId: 'iit_madras', name: 'Chemistry I', instructor: 'Prof. S. Sankararaman'),
         const Course(courseCode: 'MA1010', universityId: 'iit_madras', name: 'Calculus I', instructor: 'Prof. S. Ponnusamy'),
    ],
    'iit_kharagpur': [
         const Course(courseCode: 'CS10001', universityId: 'iit_kharagpur', name: 'Programming and Data Structures', instructor: 'Prof. P.P. Das'),
         const Course(courseCode: 'MA10001', universityId: 'iit_kharagpur', name: 'Mathematics I', instructor: 'Prof. G.P. Raja Sekhar'),
         const Course(courseCode: 'EE10001', universityId: 'iit_kharagpur', name: 'Electrical Technology', instructor: 'Prof. N.K. Kishore'),
    ],
    'bits_pilani': [
        const Course(courseCode: 'CS F111', universityId: 'bits_pilani', name: 'Computer Programming', instructor: 'Dr. Jagat Sesh Challa'),
        const Course(courseCode: 'MATH F111', universityId: 'bits_pilani', name: 'Mathematics I', instructor: 'Dr. Krishnendra Shekhawat'),
        const Course(courseCode: 'EEE F111', universityId: 'bits_pilani', name: 'Electrical Sciences', instructor: 'Dr. Navneet Gupta'),
        const Course(courseCode: 'BITS F110', universityId: 'bits_pilani', name: 'Engineering Graphics', instructor: 'Dr. P. Srinivasan'),
    ],
    'iiit_una': [
       const Course(courseCode: 'CS201', universityId: 'iiit_una', name: 'Data Structures', instructor: 'Dr. Naman'),
       const Course(courseCode: 'MA201', universityId: 'iiit_una', name: 'Discrete Mathematics', instructor: 'Dr. S. Kumar'),
       const Course(courseCode: 'EC201', universityId: 'iiit_una', name: 'Analog Electronics', instructor: 'Dr. A. Gupta'),
    ],
    'srm_univ': [
        const Course(courseCode: '18CS101J', universityId: 'srm_univ', name: 'Programming for Problem Solving', instructor: 'Dr. Annie Uthra'),
        const Course(courseCode: '18MA101B', universityId: 'srm_univ', name: 'Calculus and Linear Algebra', instructor: 'Dr. B. Vennila'),
    ],
    'default': [
      const Course(courseCode: 'CS101', universityId: 'default', name: 'Intro to Programming', instructor: 'Dr. Smith'),
      const Course(courseCode: 'MATH101', universityId: 'default', name: 'Calculus I', instructor: 'Dr. Johnson'),
      const Course(courseCode: 'ENG101', universityId: 'default', name: 'English Composition', instructor: 'Dr. Williams'),
      const Course(courseCode: 'PHY101', universityId: 'default', name: 'Physics I', instructor: 'Dr. Brown'),
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

  // ============ Global Schedules (Layer 1) ============
  // Simulates data from Supabase `global_schedules` table
  
  /// Global schedule entries for catalog courses
  /// Key: courseCode, Value: List of schedule slots
  final Map<String, List<GlobalScheduleSlot>> _globalSchedules = {
    'COL106': [
      GlobalScheduleSlot(ruleId: 'r_col106_1', courseCode: 'COL106', section: 'A', dayOfWeek: 'MON', startTime: '09:00', endTime: '10:00', locationName: 'LH-101', locationLat: 28.5455, locationLong: 77.1938),
      GlobalScheduleSlot(ruleId: 'r_col106_2', courseCode: 'COL106', section: 'A', dayOfWeek: 'WED', startTime: '09:00', endTime: '10:00', locationName: 'LH-101', locationLat: 28.5455, locationLong: 77.1938),
      GlobalScheduleSlot(ruleId: 'r_col106_3', courseCode: 'COL106', section: 'A', dayOfWeek: 'FRI', startTime: '09:00', endTime: '10:00', locationName: 'LH-101', locationLat: 28.5455, locationLong: 77.1938),
      GlobalScheduleSlot(ruleId: 'r_col106_tut', courseCode: 'COL106', section: 'A', dayOfWeek: 'THU', startTime: '14:00', endTime: '15:00', locationName: 'TB-2', locationLat: 28.5458, locationLong: 77.1935),
    ],
    'COL774': [
      GlobalScheduleSlot(ruleId: 'r_col774_1', courseCode: 'COL774', section: 'A', dayOfWeek: 'TUE', startTime: '14:00', endTime: '15:30', locationName: 'LH-310', locationLat: 28.5452, locationLong: 77.1930),
      GlobalScheduleSlot(ruleId: 'r_col774_2', courseCode: 'COL774', section: 'A', dayOfWeek: 'THU', startTime: '14:00', endTime: '15:30', locationName: 'LH-310', locationLat: 28.5452, locationLong: 77.1930),
    ],
    'COL331': [
      GlobalScheduleSlot(ruleId: 'r_col331_1', courseCode: 'COL331', section: 'B', dayOfWeek: 'MON', startTime: '11:00', endTime: '12:00', locationName: 'LH-221', locationLat: 28.5453, locationLong: 77.1932),
      GlobalScheduleSlot(ruleId: 'r_col331_2', courseCode: 'COL331', section: 'B', dayOfWeek: 'WED', startTime: '11:00', endTime: '12:00', locationName: 'LH-221', locationLat: 28.5453, locationLong: 77.1932),
      GlobalScheduleSlot(ruleId: 'r_col331_lab', courseCode: 'COL331', section: 'B', dayOfWeek: 'FRI', startTime: '14:00', endTime: '17:00', locationName: 'SIT-LAB-1', locationLat: 28.5460, locationLong: 77.1940),
    ],
    'COL362': [
      GlobalScheduleSlot(ruleId: 'r_col362_1', courseCode: 'COL362', section: 'A', dayOfWeek: 'TUE', startTime: '09:00', endTime: '10:00', locationName: 'LH-108', locationLat: 28.5454, locationLong: 77.1936),
      GlobalScheduleSlot(ruleId: 'r_col362_2', courseCode: 'COL362', section: 'A', dayOfWeek: 'THU', startTime: '09:00', endTime: '10:00', locationName: 'LH-108', locationLat: 28.5454, locationLong: 77.1936),
      GlobalScheduleSlot(ruleId: 'r_col362_3', courseCode: 'COL362', section: 'A', dayOfWeek: 'FRI', startTime: '11:00', endTime: '12:00', locationName: 'LH-108', locationLat: 28.5454, locationLong: 77.1936),
    ],
    'COL334': [
      GlobalScheduleSlot(ruleId: 'r_col334_1', courseCode: 'COL334', section: 'A', dayOfWeek: 'MON', startTime: '14:00', endTime: '15:00', locationName: 'LH-120', locationLat: 28.5456, locationLong: 77.1934),
      GlobalScheduleSlot(ruleId: 'r_col334_2', courseCode: 'COL334', section: 'A', dayOfWeek: 'WED', startTime: '14:00', endTime: '15:00', locationName: 'LH-120', locationLat: 28.5456, locationLong: 77.1934),
    ],
  };

  /// Get global schedule for a course
  Future<List<GlobalScheduleSlot>> getGlobalSchedule(String courseCode, {String? section}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final slots = _globalSchedules[courseCode] ?? [];
    if (section != null) {
      return slots.where((s) => s.section == section || s.section == null).toList();
    }
    return slots;
  }

  /// Get all global schedules for today (for dashboard timeline)
  Future<List<GlobalScheduleSlot>> getSchedulesForDay(String dayOfWeek, {List<String>? courseCodes}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final result = <GlobalScheduleSlot>[];
    
    for (final entry in _globalSchedules.entries) {
      if (courseCodes != null && !courseCodes.contains(entry.key)) continue;
      result.addAll(entry.value.where((s) => s.dayOfWeek == dayOfWeek.toUpperCase()));
    }
    
    // Sort by start time
    result.sort((a, b) => a.startTime.compareTo(b.startTime));
    return result;
  }
}

/// Global schedule slot model (Layer 1 - from Supabase)
class GlobalScheduleSlot {
  final String ruleId;
  final String courseCode;
  final String? section;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String locationName;
  final double? locationLat;
  final double? locationLong;
  final String? wifiSsid;

  const GlobalScheduleSlot({
    required this.ruleId,
    required this.courseCode,
    this.section,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    this.locationLat,
    this.locationLong,
    this.wifiSsid,
  });
}

