import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for the Subject Detail Page
class SubjectDetailState {

  SubjectDetailState({
    required this.enrollment,
    this.selectedTab = 0,
  });
  final AsyncValue<Enrollment> enrollment;
  final int selectedTab;

  SubjectDetailState copyWith({
    AsyncValue<Enrollment>? enrollment,
    int? selectedTab,
  }) {
    return SubjectDetailState(
      enrollment: enrollment ?? this.enrollment,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class SubjectDetailViewModel extends StateNotifier<SubjectDetailState> {

  SubjectDetailViewModel(this.ref, this.courseCode, this.enrollmentId)
      : super(SubjectDetailState(enrollment: const AsyncValue.loading())) {
    _loadEnrollment();
  }
  final Ref ref;
  final String courseCode;
  final String? enrollmentId;

  Future<void> _loadEnrollment() async {
    try {
      final enrollments = await ref.read(enrollmentsProvider.future);
      
      Enrollment? found;
      if (enrollmentId != null) {
        found = enrollments.firstWhere(
          (e) => e.enrollmentId == enrollmentId,
          orElse: () => enrollments.firstWhere((e) => e.courseCode == courseCode, orElse: _mockEnrollment),
        );
      } else {
        found = enrollments.firstWhere(
          (e) => e.courseCode == courseCode, 
          orElse: _mockEnrollment
        );
      }
      
      state = state.copyWith(enrollment: AsyncValue.data(found));
    } catch (e, st) {
      // If we can't load enrollments (e.g. offline and not cached), try mock if explicitly requested or just error
      state = state.copyWith(enrollment: AsyncValue.error(e, st));
    }
  }

  Enrollment _mockEnrollment() {
      // Fallback/Mock logic from original file
      return Enrollment(
         enrollmentId: 'mock',
         courseCode: courseCode,
         startDate: DateTime.now(),
         // Add minimal mock data to prevent null crashes
         stats: EnrollmentStats(totalClasses: 0, attended: 0), 
       );
  }

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
  }
}

final AutoDisposeStateNotifierProviderFamily<SubjectDetailViewModel, SubjectDetailState, String> subjectDetailViewModelProvider = StateNotifierProvider.family.autoDispose<
    SubjectDetailViewModel, SubjectDetailState, String>((ref, idKey) {
  // We parse the ID key which might be "code|enrollmentId" or just "code"
  final parts = idKey.split('|');
  final code = parts[0];
  final enrollmentId = parts.length > 1 ? parts[1] : null;
  
  return SubjectDetailViewModel(ref, code, enrollmentId);
});
