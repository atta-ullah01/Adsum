
import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/courses/providers/course_viewmodel.dart';
import 'package:flutter/material.dart';
// Ensure animate is imported if used
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CourseSearchOverlay extends ConsumerWidget {

  const CourseSearchOverlay({
    required this.currentEnrollments, required this.onEnroll, required this.onCreateCustom, super.key,
  });
  final List<Enrollment> currentEnrollments;
  final Function(Course) onEnroll;
  final VoidCallback onCreateCustom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(courseViewModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for overlay
        children: [
          // Always show option to create custom course
          GestureDetector(
            onTap: onCreateCustom,
            child: _searchItemProminent(),
          ),

          if (searchState.results.isEmpty && !searchState.isSearching)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No other courses found.', style: GoogleFonts.dmSans(color: Colors.grey)),
            ),

          if (searchState.isSearching)
             const Padding(
               padding: EdgeInsets.all(20),
               child: Center(child: CircularProgressIndicator()),
             ),

          ...searchState.results.map((course) => GestureDetector(
            key: ValueKey(course.courseCode),
            onTap: () => onEnroll(course),
            child: _searchItem(
              course.name, 
              '${course.courseCode} • ${course.instructor}',
              isEnrolled: currentEnrollments.any((e) => e.effectiveCourseCode == course.courseCode)
            ),
          )),
        ],
      ),
    );
  }

  Widget _searchItem(String title, String subtitle, {bool isEnrolled = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEnrolled ? Colors.green[50] : AppColors.pastelBlue, 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              isEnrolled ? 'ENROLLED' : 'GLOBAL', 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: isEnrolled ? Colors.green : Colors.blue
              )
            ),
          ),
        ],
      )
    );
  }

  Widget _searchItemProminent() {
     return Container(
       margin: const EdgeInsets.all(8),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: AppColors.pastelYellow,
         borderRadius: BorderRadius.circular(12),
       ),
       child: Row(
         children: [
           Container(
             width: 32, height: 32,
             decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
             child: const Icon(Ionicons.add, size: 20),
           ),
           const SizedBox(width: 12),
           const Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Create Custom Course', style: TextStyle(fontWeight: FontWeight.bold)),
               Text("Can't find it? Add your own.", style: TextStyle(fontSize: 12, color: Colors.black54)),
             ],
           )
         ],
       ),
     );
  }
}
