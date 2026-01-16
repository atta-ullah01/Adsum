import 'package:adsum/data/repositories/syllabus_repository.dart';
import 'package:adsum/domain/models/syllabus.dart';

/// Service for syllabus management
class SyllabusService {

  SyllabusService(this._repository);
  final SyllabusRepository _repository;

  // ============ Progress Tracking ============

  /// Get completed topic IDs
  Future<List<String>> getProgress(String courseCode) async {
    return _repository.getProgress(courseCode);
  }

  /// Mark topic as complete
  Future<void> markComplete(String courseCode, String topicId) async {
    final progress = await _repository.getProgress(courseCode);
    if (!progress.contains(topicId)) {
      progress.add(topicId);
      await _repository.saveProgress(courseCode, progress);
    }
  }

  /// Mark topic as incomplete
  Future<void> markIncomplete(String courseCode, String topicId) async {
    final progress = await _repository.getProgress(courseCode);
    if (progress.contains(topicId)) {
      progress.remove(topicId);
      await _repository.saveProgress(courseCode, progress);
    }
  }

  /// Toggle topic completion
  Future<bool> toggleComplete(String courseCode, String topicId) async {
    final progress = await _repository.getProgress(courseCode);
    final isComplete = progress.contains(topicId);
    
    if (isComplete) {
      progress.remove(topicId);
    } else {
      progress.add(topicId);
    }
    
    await _repository.saveProgress(courseCode, progress);
    return !isComplete;
  }

  /// Calculate completion percentage
  Future<double> getCompletionPercentage(String courseCode) async {
    final syllabus = await getCustomSyllabus(courseCode);
    if (syllabus == null) return 0;
    final progress = await getProgress(courseCode);
    return syllabus.completionPercentage(progress);
  }

  // ============ Custom Syllabus ============

  /// Get custom syllabus
  Future<CustomSyllabus?> getCustomSyllabus(String courseCode) async {
    return _repository.getCustomSyllabus(courseCode);
  }

  /// Save custom syllabus
  Future<void> saveCustomSyllabus(CustomSyllabus syllabus) async {
    await _repository.saveCustomSyllabus(syllabus);
  }

  /// Delete custom syllabus and clear progress
  Future<void> deleteCustomSyllabus(String courseCode) async {
    await _repository.deleteCustomSyllabus(courseCode);
  }
}
