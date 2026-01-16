import 'package:adsum/data/providers/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Currently AssignmentsPage relies on specific providers. 
// This VM can be expanded for filtering or complex actions.
class AssignmentsState {
  // Placeholder for any page-level state (filters, sort order)
  const AssignmentsState();
}

class AssignmentsViewModel extends AutoDisposeNotifier<AssignmentsState> {
  @override
  AssignmentsState build() {
    return const AssignmentsState();
  }

  void refresh() {
    ref.invalidate(pendingWorkProvider);
    ref.invalidate(completedWorkProvider);
  }
}

final assignmentsViewModelProvider = NotifierProvider.autoDispose<AssignmentsViewModel, AssignmentsState>(AssignmentsViewModel.new);
