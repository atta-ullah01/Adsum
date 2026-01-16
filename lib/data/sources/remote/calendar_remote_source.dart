
import 'package:adsum/data/sources/remote/base_remote_source.dart';
import 'package:adsum/domain/models/calendar_event.dart';

class CalendarRemoteSource extends SupabaseDataSource<CalendarEvent> {
  CalendarRemoteSource(super.client) : super(tableName: 'academic_calendar');

  @override
  CalendarEvent fromJson(Map<String, dynamic> json) {
    // The DB has 'calendar_id', model expects 'event_id' or similar?
    // Let's check CalendarEvent model.
    // Assuming mapping exists or needs DTO.
    // Ideally update model to match schema or map here.
    
    // Mapping DB 'calendar_id' to model 'id' if needed
    final safeJson = Map<String, dynamic>.from(json);
    if (!safeJson.containsKey('id') && safeJson.containsKey('calendar_id')) {
      safeJson['id'] = safeJson['calendar_id'];
    }
    // DB: type (HOLIDAY, EXAM, etc), Model: type
    return CalendarEvent.fromJson(safeJson);
  }

  /// Fetch calendar for university
  Future<List<CalendarEvent>> fetchCalendar(String universityId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('university_id', universityId);
      
      final data = response as List;
      return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch calendar: $e');
    }
  }
}
