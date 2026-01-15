import 'package:adsum/data/repositories/work_repository.dart';
import 'package:adsum/domain/models/work.dart';

/// Service for academic work management
/// Handles filtering, sorting, and state transitions
class WorkService {
  final WorkRepository _repository;

  WorkService(this._repository);

  // ============ Queries ============

  /// Get all work items for a course
  Future<List<Work>> getForCourse(String courseCode) async {
    return _repository.getForCourse(courseCode);
  }

  /// Get pending/upcoming work (due in future, not submitted)
  Future<List<Work>> getPending() async {
    final all = await _repository.getAll();
    final states = await _repository.getAllStates();
    final stateMap = {for (var s in states) s.workId: s};

    return all.where((w) {
      final state = stateMap[w.workId];
      if (state != null && state.status != WorkStatus.pending) return false;
      if (w.dueAt != null && w.dueAt!.isBefore(DateTime.now())) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        if (a.dueAt == null && b.dueAt == null) return 0;
        if (a.dueAt == null) return 1;
        if (b.dueAt == null) return -1;
        return a.dueAt!.compareTo(b.dueAt!);
      });
  }

  /// Get completed work items (submitted or graded)
  Future<List<Work>> getCompleted() async {
    final all = await _repository.getAll();
    final states = await _repository.getAllStates();
    final stateMap = {for (var s in states) s.workId: s};

    return all.where((w) {
      final state = stateMap[w.workId];
      if (state != null && (state.status == WorkStatus.submitted || state.status == WorkStatus.graded)) {
        return true;
      }
      return false;
    }).toList()
      ..sort((a, b) => b.dueAt?.compareTo(a.dueAt ?? DateTime.now()) ?? 0); // Newest completed first
  }

  /// Get count of pending work items
  Future<int> getPendingCount() async {
    final pending = await getPending();
    return pending.length;
  }

  // ============ Actions ============

  /// Mark work as submitted
  Future<void> markSubmitted(String workId) async {
    final existing = await _repository.getState(workId);
    await _repository.updateState(
      (existing ?? WorkState(workId: workId)).copyWith(
        status: WorkStatus.submitted,
      ),
    );
  }

  /// Mark work as graded
  Future<void> markGraded(String workId, String grade) async {
    final existing = await _repository.getState(workId);
    await _repository.updateState(
      (existing ?? WorkState(workId: workId)).copyWith(
        status: WorkStatus.graded,
        grade: grade,
      ),
    );
  }


  /// Toggle visibility in calendar
  Future<void> setHidden(String workId, bool hidden) async {
    final existing = await _repository.getState(workId);
    await _repository.updateState(
      (existing ?? WorkState(workId: workId)).copyWith(
        isHiddenFromCalendar: hidden,
      ),
    );
  }

  // ============ Comments ============

  /// Get comments for a work item
  Future<List<WorkComment>> getComments(String workId) async {
    return _repository.getComments(workId);
  }

  /// Add a comment
  Future<void> addComment(String workId, String text, String userId) async {
    final comment = WorkComment(
      commentId: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
      workId: workId,
      userId: userId,
      text: text,
      createdAt: DateTime.now(),
    );
    await _repository.addComment(comment);
  }
}
