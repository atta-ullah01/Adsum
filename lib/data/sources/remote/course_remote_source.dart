
import 'package:adsum/data/sources/remote/base_remote_source.dart';
import 'package:adsum/domain/models/course.dart';
import 'package:adsum/domain/models/schedule.dart';

class CourseRemoteSource extends SupabaseDataSource<Course> {
  CourseRemoteSource(super.client) : super(tableName: 'courses');

  @override
  Course fromJson(Map<String, dynamic> json) {
    return Course.fromJson(json);
  }
  
  /// Fetch all courses (catalog)
  /// Can be filtered by university if RLS allows
  Future<List<Course>> fetchCoursesForUniversity(String universityId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('university_id', universityId);
      
      final data = response as List;
      return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      throw handleError(e, stack, 'fetchCoursesForUniversity');
    }
  }

  /// Fetch global schedule for a course
  Future<List<GlobalSchedule>> fetchGlobalSchedule(String courseCode) async {
    try {
      final response = await client
          .from('global_schedules')
          .select()
          .eq('course_code', courseCode);
          
      final data = response as List;
      return data.map((json) => GlobalSchedule.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      // Log error but maybe return empty list?
      // Better to throw so UI/Repo knows sync failed
      throw handleError(e, stack, 'fetchGlobalSchedule');
    }
  }
  
  // Helper to re-use base error handling logic if exposed, 
  // but since _handleError is private, we'll duplicate or make it protected.
  // Actually, I can't access private _handleError.
  // I will make a local helper.
  Exception handleError(dynamic e, StackTrace s, String context) {
    // Re-use logic or just throw
    return Exception('Error in $context: $e');
  }
}
