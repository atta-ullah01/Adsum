import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/syllabus.dart';

/// Repository for syllabus progress and custom syllabus management
/// 
/// Manages two JSON files:
/// - `syllabus_progress.json` - Maps course_code to list of completed topic IDs
/// - `custom_syllabus.json` - User-defined syllabus for custom courses
class SyllabusRepository {
  static const String _progressFile = 'syllabus_progress.json';
  static const String _customFile = 'custom_syllabus.json';

  final JsonFileService _jsonService;

  SyllabusRepository(this._jsonService);

  // ============ Progress Tracking ============

  /// Get completed topic IDs for a course
  Future<List<String>> getProgress(String courseCode) async {
    final data = await _jsonService.readJsonObject(_progressFile);
    if (data == null) return [];
    final topics = data[courseCode] as List<dynamic>?;
    return topics?.cast<String>() ?? [];
  }

  /// Save progress for a course
  Future<void> saveProgress(String courseCode, List<String> topicIds) async {
    await _jsonService.updateJsonObject(
      _progressFile,
      {courseCode: topicIds},
    );
  }

  /// Clear all progress for a course
  Future<void> clearProgress(String courseCode) async {
    final data = await _jsonService.readJsonObject(_progressFile) ?? {};
    data.remove(courseCode);
    await _jsonService.writeJson(_progressFile, data);
  }

  // ============ Custom Syllabus ============

  /// Get all custom syllabi
  Future<List<CustomSyllabus>> getAllCustom() async {
    final data = await _jsonService.readJsonArray(_customFile);
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map((json) => CustomSyllabus.fromJson(json))
        .toList();
  }

  /// Get custom syllabus for a specific course
  Future<CustomSyllabus?> getCustomSyllabus(String courseCode) async {
    final all = await getAllCustom();
    try {
      return all.firstWhere((s) => s.courseCode == courseCode);
    } catch (_) {
      return null;
    }
  }

  /// Save custom syllabus (creates or updates)
  Future<void> saveCustomSyllabus(CustomSyllabus syllabus) async {
    final exists = await getCustomSyllabus(syllabus.courseCode);
    if (exists != null) {
      await _jsonService.updateInJsonArray(
        _customFile,
        keyField: 'course_code',
        keyValue: syllabus.courseCode,
        updates: syllabus.toJson(),
      );
    } else {
      await _jsonService.appendToJsonArray(_customFile, syllabus.toJson());
    }
  }

  /// Delete custom syllabus for a course
  Future<void> deleteCustomSyllabus(String courseCode) async {
    await _jsonService.removeFromJsonArray(
      _customFile,
      keyField: 'course_code',
      keyValue: courseCode,
    );
    // Also clear progress (logic to clear progress remains here as it's data cleanup?)
    // Actually, strictly service should handle this correlation, but cascade delete 
    // is often handled in repo or DB. I'll leave atomic cleanup here for now but exposed properly.
    await clearProgress(courseCode);
  }
}
