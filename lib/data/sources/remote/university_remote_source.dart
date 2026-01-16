
import 'package:adsum/data/sources/remote/base_remote_source.dart';
import 'package:adsum/domain/models/university.dart';

class UniversityRemoteSource extends SupabaseDataSource<University> {
  UniversityRemoteSource(super.client) : super(tableName: 'universities');

  @override
  University fromJson(Map<String, dynamic> json) {
    // Map 'university_id' to 'id' for the model
    final safeJson = Map<String, dynamic>.from(json);
    if (!safeJson.containsKey('id') && safeJson.containsKey('university_id')) {
      safeJson['id'] = safeJson['university_id'];
    }
    return University.fromJson(safeJson);
  }
  
  /// Fetch hostels for a specific university
  Future<List<Hostel>> fetchHostels(String universityId) async {
    try {
      final response = await client
          .from('hostels')
          .select()
          .eq('university_id', universityId)
          .eq('is_active', true);
          
      final data = response as List;
      return data.map((json) {
         final h = Map<String, dynamic>.from(json as Map);
         if (!h.containsKey('id') && h.containsKey('hostel_id')) {
           h['id'] = h['hostel_id'];
         }
         return Hostel.fromJson(h);
      }).toList();
    } catch (e) {
      // Allow empty list if no hostels found or error, but logging is good
      // AppLogger handled by caller or we should log here?
      // Base class logs, but this is a custom method.
      return [];
    }
  }
}
