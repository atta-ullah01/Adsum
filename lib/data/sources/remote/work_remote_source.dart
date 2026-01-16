
import 'package:adsum/data/sources/remote/base_remote_source.dart';
import 'package:adsum/domain/models/work.dart';

class WorkRemoteSource extends SupabaseDataSource<Work> {
  WorkRemoteSource(super.client) : super(tableName: 'course_work');

  @override
  Work fromJson(Map<String, dynamic> json) {
    final safeJson = Map<String, dynamic>.from(json);
    if (!safeJson.containsKey('id') && safeJson.containsKey('work_id')) {
      safeJson['id'] = safeJson['work_id'];
    }
    return Work.fromJson(safeJson);
  }

  /// Watch work for enrolled courses
  Stream<List<Work>> watchWorkForCourses(List<String> courseCodes) {
    if (courseCodes.isEmpty) return Stream.value([]);
    
    return client
        .from(tableName)
        .stream(primaryKey: ['work_id'])
        .inFilter('course_code', courseCodes)
        .map((data) => data.map(fromJson).toList());
  }
}
