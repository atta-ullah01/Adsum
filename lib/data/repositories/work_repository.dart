import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/work.dart';
import 'package:uuid/uuid.dart';

/// Repository for course work (assignments, quizzes, exams, projects)
/// 
/// Manages two JSON files:
/// - `work.json` - The actual work items
/// - `work_states.json` - Local state tracking (submitted, grade, hidden)
class WorkRepository {

  WorkRepository(this._jsonService);
  static const String _workFile = 'course_work.json';
  static const String _statesFile = 'work_states.json';
  static const _uuid = Uuid();

  final JsonFileService _jsonService;

  // ============ Work CRUD ============

  /// Get all work items
  Future<List<Work>> getAll() async {
    final data = await _jsonService.readJsonArray(_workFile);
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map(Work.fromJson)
        .toList();
  }

  /// Get work items for a specific course
  Future<List<Work>> getForCourse(String courseCode) async {
    final all = await getAll();
    return all.where((w) => w.courseCode == courseCode).toList();
  }

  /// Get a single work item by ID
  Future<Work?> getById(String workId) async {
    final all = await getAll();
    try {
      return all.firstWhere((w) => w.workId == workId);
    } catch (_) {
      return null;
    }
  }

  /// Get pending/upcoming work - MOVED TO SERVICE
  // Future<List<Work>> getPending() async { ... }

  /// Add a new work item
  Future<Work> add({
    required String courseCode,
    required WorkType workType,
    required String title,
    DateTime? dueAt,
    DateTime? startAt,
    int? durationMinutes,
    String? venue,
    String? description,
    bool isSuperEvent = false,
  }) async {
    final work = Work(
      workId: _uuid.v4(),
      courseCode: courseCode,
      workType: workType,
      title: title,
      dueAt: dueAt,
      startAt: startAt,
      durationMinutes: durationMinutes,
      venue: venue,
      description: description,
      isSuperEvent: isSuperEvent,
      createdAt: DateTime.now(),
    );

    await _jsonService.appendToJsonArray(_workFile, work.toJson());
    return work;
  }

  /// Update an existing work item
  Future<void> update(Work work) async {
    await _jsonService.updateInJsonArray(
      _workFile,
      keyField: 'work_id',
      keyValue: work.workId,
      updates: work.toJson(),
    );
  }

  /// Delete a work item
  Future<void> delete(String workId) async {
    await _jsonService.removeFromJsonArray(
      _workFile,
      keyField: 'work_id',
      keyValue: workId,
    );
    // Also remove state if exists
    await _jsonService.removeFromJsonArray(
      _statesFile,
      keyField: 'work_id',
      keyValue: workId,
    );
  }

  // ============ Work States ============

  /// Get all work states
  Future<List<WorkState>> getAllStates() async {
    final data = await _jsonService.readJsonArray(_statesFile);
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map(WorkState.fromJson)
        .toList();
  }

  /// Get state for a specific work item
  Future<WorkState?> getState(String workId) async {
    final states = await getAllStates();
    try {
      return states.firstWhere((s) => s.workId == workId);
    } catch (_) {
      return null;
    }
  }

  /// Update or create state for a work item
  Future<void> updateState(WorkState state) async {
    final exists = await getState(state.workId);
    if (exists != null) {
      await _jsonService.updateInJsonArray(
        _statesFile,
        keyField: 'work_id',
        keyValue: state.workId,
        updates: state.toJson(),
      );
    } else {
      await _jsonService.appendToJsonArray(_statesFile, state.toJson());
    }
  }
  // ============ Comments ============

  /// Get comments for a work item
  Future<List<WorkComment>> getComments(String workId) async {
    final data = await _jsonService.readJsonArray('work_comments.json');
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map(WorkComment.fromJson)
        .where((c) => c.workId == workId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  /// Add a comment
  Future<void> addComment(WorkComment comment) async {
    await _jsonService.appendToJsonArray('work_comments.json', comment.toJson());
  }
}
