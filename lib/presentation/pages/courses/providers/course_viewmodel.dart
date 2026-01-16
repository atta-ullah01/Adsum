
import 'dart:async';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- State Class ---
class CourseSearchState {

  const CourseSearchState({
    this.isSearching = false,
    this.results = const [],
    this.query = '',
  });
  final bool isSearching;
  final List<Course> results;
  final String query;

  CourseSearchState copyWith({
    bool? isSearching,
    List<Course>? results,
    String? query,
  }) {
    return CourseSearchState(
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      query: query ?? this.query,
    );
  }
}

// --- ViewModel ---
class CourseViewModel extends AutoDisposeNotifier<CourseSearchState> {
  Timer? _debounce;

  @override
  CourseSearchState build() {
    return const CourseSearchState();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(results: [], query: '', isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true, query: query);

    try {
      // Get user's university ID
      final userAsync = ref.read(userProfileProvider);
      final universityId = userAsync.value?.universityId ?? 'iit_delhi'; // Fallback

      final results = await ref.read(sharedDataRepositoryProvider).searchCourses(universityId, query);
      
      state = state.copyWith(results: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(results: [], isSearching: false);
      // Ideally handle error state
    }
  }

  void clearSearch() {
    state = const CourseSearchState();
  }

  // Enrollment Logic
  Future<bool> enrollInCourse(Course course, String section, double targetAttendance, String colorHex) async {
    final result = await ref.read(enrollmentRepositoryProvider).addEnrollment(
      courseCode: course.courseCode,
      catalogInstructor: course.instructor,
      section: section,
      targetAttendance: targetAttendance,
      colorTheme: colorHex,
    );
    
    if (result != null) {
      ref.invalidate(enrollmentsProvider);
      clearSearch(); // Reset search on success
      return true;
    }
    return false; // Duplicate or failed
  }

  // Custom Course Logic
  Future<String?> saveCustomCourse({
    required String? editingEnrollmentId,
    required String name,
    required String code,
    required String instructor,
    required String section,
    required double targetAttendance,
    required int totalExpected,
    required Color color,
    required DateTime startDate,
    required List<Map<String, dynamic>> slots,
  }) async {
    final customCourse = CustomCourse(
      code: code,
      name: name,
      instructor: instructor,
      totalExpected: totalExpected,
    );
    final colorHex = '#${color.value.toRadixString(16).substring(2)}';
    final enrollRepo = ref.read(enrollmentRepositoryProvider);
    final scheduleRepo = ref.read(scheduleRepositoryProvider);

    try {
      if (editingEnrollmentId != null) {
        // UPDATE
        final existing = await enrollRepo.getEnrollment(editingEnrollmentId);
        if (existing != null) {
          final updated = existing.copyWith(
            customCourse: customCourse,
            colorTheme: colorHex,
            section: section,
            targetAttendance: targetAttendance,
            startDate: startDate,
          );
          await enrollRepo.updateEnrollment(updated);
          ref.invalidate(enrollmentsProvider);
          return null; // Success
        }
        return 'Course not found';
      } else {
        // CREATE
        final enrollment = await enrollRepo.addEnrollment(
          customCourse: customCourse,
          colorTheme: colorHex,
          section: section,
          targetAttendance: targetAttendance,
          startDate: startDate,
        );

        if (enrollment == null) {
          return "Course '$code' already exists in Section $section";
        }

        // Add Slots
        for (final slotMap in slots) {
          final dayStr = slotMap['day'] as String;
          final timeStr = slotMap['time'] as String;
          
          DayOfWeek? day;
          switch (dayStr) {
            case 'Mon': case 'Monday': day = DayOfWeek.mon;
            case 'Tue': case 'Tuesday': day = DayOfWeek.tue;
            case 'Wed': case 'Wednesday': day = DayOfWeek.wed;
            case 'Thu': case 'Thursday': day = DayOfWeek.thu;
            case 'Fri': case 'Friday': day = DayOfWeek.fri;
            case 'Sat': case 'Saturday': day = DayOfWeek.sat;
            case 'Sun': case 'Sunday': day = DayOfWeek.sun;
          }
           
          if (day != null) {
             final parts = timeStr.split(' - ');
             if (parts.length == 2) {
               final savedSlot = await scheduleRepo.addCustomSlot(
                 enrollmentId: enrollment.enrollmentId,
                 dayOfWeek: day,
                 startTime: parts[0],
                 endTime: parts[1],
               );

               // Save Bindings
               if (slotMap['gps_lat'] != null) {
                  await scheduleRepo.addBinding(
                    userId: 'current_user',
                    ruleId: savedSlot.ruleId,
                    scheduleType: ScheduleType.custom,
                    locationName: slotMap['loc'] as String?,
                    locationLat: slotMap['gps_lat'] as double?,
                    locationLong: slotMap['gps_long'] as double?,
                  );
               }
               if (slotMap['wifi'] != null) {
                  await scheduleRepo.addBinding(
                    userId: 'current_user', 
                    ruleId: savedSlot.ruleId,
                    scheduleType: ScheduleType.custom,
                    wifiSsid: slotMap['wifi'] as String?,
                  );
               }
             }
          }
        }
        ref.invalidate(enrollmentsProvider);
        return null; // Success
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> deleteCourse(String enrollmentId) async {
    await ref.read(enrollmentRepositoryProvider).deleteEnrollment(enrollmentId);
    ref.invalidate(enrollmentsProvider);
  }
}

final courseViewModelProvider = NotifierProvider.autoDispose<CourseViewModel, CourseSearchState>(() {
  return CourseViewModel();
});
