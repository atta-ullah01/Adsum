import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/schedule_modification.dart';

/// Repository for schedule modifications (CR updates)
/// 
/// Manages `schedule_modifications.json` which contains:
/// - Cancellations
/// - Rescheduling
/// - Room Swaps
/// - Extra Classes
class ScheduleModificationRepository {

  ScheduleModificationRepository(this._jsonService);
  static const String _file = 'schedule_modifications.json';

  final JsonFileService _jsonService;

  /// Get all modifications
  Future<List<ScheduleModification>> getAll() async {
    final data = await _jsonService.readJsonArray(_file);
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map(ScheduleModification.fromJson)
        .toList();
  }

  /// Get modifications for a specific course
  Future<List<ScheduleModification>> getForCourse(String courseCode) async {
    final all = await getAll();
    return all.where((m) => m.courseCode == courseCode).toList();
  }

  /// Get modifications effective on a specific date
  Future<List<ScheduleModification>> getForDate(DateTime date) async {
    final all = await getAll();
    return all.where((m) => 
      m.affectedDate.year == date.year &&
      m.affectedDate.month == date.month &&
      m.affectedDate.day == date.day
    ).toList();
  }
}
