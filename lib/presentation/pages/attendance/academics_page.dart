import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/courses/courses_page.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class AcademicsPage extends ConsumerWidget {
  const AcademicsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch Enrollments
    final enrollmentsAsync = ref.watch(enrollmentsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Ionicons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Academics', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                           Text('Your Session Progress', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    // Assignments Link
                    GestureDetector(
                      onTap: () => context.push('/assignments'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                         child: const Icon(Ionicons.list, color: Colors.blue, size: 22),
                      ),
                    ),

                  ],
                ),
              ),
              
              enrollmentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error loading courses: $err')),
                data: (enrollments) {
                  if (enrollments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Smart Stats Card (Premium)
                      FadeSlideTransition(
                        index: 0,
                        child: _buildSummaryCard(enrollments),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 2. Course List Header
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('Enrolled Courses', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                           Text('${enrollments.length} Active', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       const SizedBox(height: 16),
                       
                       // 3. Vertical List of Horizontal Pastel Cards
                       ListView.separated(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: enrollments.length,
                         separatorBuilder: (c, i) => const SizedBox(height: 16),
                         itemBuilder: (context, index) {
                            final enrollment = enrollments[index];
                            return FadeSlideTransition(
                              index: index + 1,
                              child: _buildCourseCard(context, enrollment),
                            );
                         },
                       ),
                       
                       const SizedBox(height: 48), // Bottom Padding
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Go to Course Management (Standalone)
           Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesPage(showWizard: false)));
        }, 
        backgroundColor: Colors.black,
        child: const Icon(Ionicons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const SizedBox(height: 50),
           const Icon(Ionicons.school_outline, size: 64, color: AppColors.textMuted),
           const SizedBox(height: 16),
           Text('No courses enrolled yet.', style: GoogleFonts.outfit(fontSize: 18, color: AppColors.textMuted)),
           const SizedBox(height: 8),
           Text('Tap + to add your courses.', style: GoogleFonts.dmSans(color: Colors.grey)),
         ],
       ),
     );
  }

  Widget _buildSummaryCard(List<Enrollment> enrollments) {
    final riskCount = enrollments.where((e) => e.stats.attendancePercent < e.targetAttendance).length;
    final isSafe = riskCount == 0;
    
    // Calculate Total Safe Bunks
    var totalBunks = 0;
    for (final e in enrollments) {
      totalBunks += e.stats.safeBunks;
    }
    
    // Colors
    final bg = isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE); // Custom lighter shades
    final accent = isSafe ? Colors.green[800]! : Colors.red[800]!;
    final IconData icon = isSafe ? Ionicons.shield_checkmark : Ionicons.warning;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Decorative Background Icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 140, color: accent.withOpacity(0.1)),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                       child: Icon(icon, size: 16, color: accent),
                     ),
                     const SizedBox(width: 8),
                     Text(
                       isSafe ? 'All Good!' : 'Action Required',
                       style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: accent, fontSize: 13),
                     ),
                   ],
                 ),
                 const Spacer(),
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Text(
                       isSafe ? '$totalBunks' : '$riskCount',
                       style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: accent, height: 1),
                     ),
                     const SizedBox(width: 12),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: Text(
                         isSafe ? 'Safe Bunks\nAvailable' : 'Subjects\nat Risk',
                         style: GoogleFonts.dmSans(fontSize: 14, color: accent, fontWeight: FontWeight.w500, height: 1.2),
                       ),
                     )
                   ],
                 )
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Enrollment enrollment) {
    final bg = _parseColor(enrollment.colorTheme);
    const textDark = Colors.black; // Adjust based on contrast if needed
    var percent = enrollment.stats.attendancePercent / 100;
    if (percent.isNaN) percent = 0.0;
    
    final isRisky = enrollment.stats.attendancePercent < enrollment.targetAttendance;

    return GestureDetector(
      onTap: () {
        context.push('/subject-detail', extra: {
          'title': enrollment.courseName,
          'code': enrollment.effectiveCourseCode,
          'enrollmentId': enrollment.enrollmentId,
          'isCustomCourse': enrollment.isCustom,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    enrollment.courseName, 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Ionicons.arrow_forward_circle, color: textDark.withOpacity(0.3), size: 24),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Stats Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${enrollment.stats.attendancePercent.toInt()}%',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.textMain),
                ),
                const SizedBox(width: 12),
                Flexible( 
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: !isRisky
                       ? Text('${enrollment.stats.safeBunks} Safe Bunks', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
                       : Text('Risk: below ${enrollment.targetAttendance.toInt()}%', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.danger, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.white.withOpacity(0.5),
                color: AppColors.textMain,
                minHeight: 8,
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
     if (hex.startsWith('#')) hex = hex.substring(1);
     if (hex.length == 6) hex = 'FF$hex';
     return Color(int.parse('0x$hex'));
  }
}
