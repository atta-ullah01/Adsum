
import 'package:adsum/data/sources/remote/base_remote_source.dart';
import 'package:adsum/domain/models/syllabus.dart';

class SyllabusRemoteSource extends SupabaseDataSource<SyllabusUnit> {
  SyllabusRemoteSource(super.client) : super(tableName: 'syllabus_units');

  @override
  SyllabusUnit fromJson(Map<String, dynamic> json) {
    // Model likely expects nested topics?
    // Or we fetch units and topics separately?
    // SCHEMA.md has syllabus_units and syllabus_topics
    // Domain model 'SyllabusUnit' likely contains list<Topic>?
    
    // Simple mapping for now
    final safeJson = Map<String, dynamic>.from(json);
    if (!safeJson.containsKey('id') && safeJson.containsKey('unit_id')) {
      safeJson['id'] = safeJson['unit_id'];
    }
    return SyllabusUnit.fromJson(safeJson);
  }

  /// Fetch full syllabus structure for a course
  Future<List<SyllabusUnit>> fetchSyllabusForCourse(String courseCode) async {
    // Fetch units
    final unitsResponse = await client
        .from('syllabus_units')
        .select()
        .eq('course_code', courseCode)
        .order('unit_order');
        
    final unitsData = unitsResponse as List;
    
    // Fetch all topics for this course (or per unit)
    // Optimization: Fetch all topics for course_code via join if possible, or separate query
    // Supabase supports joins if foreign keys exist.
    // 'syllabus_topics' has 'unit_id'. 
    
    // Using deep select:
    final response = await client
        .from('syllabus_units')
        .select('*, syllabus_topics(*)')
        .eq('course_code', courseCode)
        .order('unit_order');
        
    final data = response as List;
    
    // The JSON will now have 'syllabus_topics' list inside each unit.
    // Ensure SyllabusUnit.fromJson handles this or we map it.
    
    return data.map((json) {
       final safeJson = Map<String, dynamic>.from(json as Map);
       if (!safeJson.containsKey('id') && safeJson.containsKey('unit_id')) {
         safeJson['id'] = safeJson['unit_id'];
       }
       // Map nested topics: 'syllabus_topics' -> 'topics' based on model expectation
       if (safeJson['syllabus_topics'] != null) {
         safeJson['topics'] = safeJson['syllabus_topics'];
       }
       return SyllabusUnit.fromJson(safeJson);
    }).toList();
  }
}
