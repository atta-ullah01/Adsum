import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class SubjectInfoTab extends StatelessWidget {

  const SubjectInfoTab({
    required this.enrollment, required this.courseTitle, required this.courseCode, super.key,
  });
  final Enrollment enrollment;
  final String courseTitle;
  final String courseCode;

  @override
  Widget build(BuildContext context) {
    // Default values if loading/null
    final instructor = enrollment.customCourse?.instructor ?? 'Dr. Smith (Global)';
    final total = enrollment.stats.totalClasses;
    final section = enrollment.section;
    final targetAtt = enrollment.targetAttendance;
    final colorHex = enrollment.colorTheme;
    final color = _parseColor(colorHex);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 1. Course Details (Metadata)
        FadeSlideTransition(
           index: 0,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Course Details', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(24)),
                 child: Column(
                   children: [
                      // Course Name, Code, Instructor (Read-Only)
                        _buildDetailRow('Course Name', courseTitle),
                        const SizedBox(height: 12),
                        _buildDetailRow('Course Code', courseCode),
                        const SizedBox(height: 12),
                        _buildDetailRow('Instructor', instructor),
                        const SizedBox(height: 12),
                        _buildDetailRow('Total Classes', '$total (Expected)'),
                         const SizedBox(height: 12),
                         // Tag
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                               child: Text(enrollment.isCustom ? 'Custom Course' : 'University Catalog', style: GoogleFonts.dmSans(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                             ),
                           ],
                         ),
                         const SizedBox(height: 24),
                         
                         // Schedule (Placeholder)
                         Text('Class Schedule', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                         const SizedBox(height: 8),
                         InkWell(
                            onTap: () => context.go('/dashboard'), // Or specific index if using indexed stack logic
                            child: Text('View your full schedule on the Dashboard tab.', style: GoogleFonts.dmSans(color: Colors.blue, decoration: TextDecoration.underline)),
                         ),
                   ],
                 ),
               )
             ],
           ),
        ),
        
        const SizedBox(height: 24),
        
        // 2. My Enrollment (Read-Only)
        FadeSlideTransition(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('My Enrollment', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(24)),
                 child: Column(
                   children: [
                      _buildDetailRow('Class Section', section), 
                      const Divider(height: 24),
                      _buildDetailRow('Target Attendance', '${targetAtt.toInt()}%'),
                   ],
                 ),
               ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        
        // 3. Settings (Read-Only / Info)
        FadeSlideTransition(
           index: 2,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Settings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
               const SizedBox(height: 8),
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(24)),
                 child: Column(
                   children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Card Color', style: GoogleFonts.dmSans(color: AppColors.textMuted)),
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Ionicons.information_circle, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(child: Text('To edit these settings, go to Manage Courses.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                        ],
                      )
                   ],
                 ),
               ),
             ],
           ),
        ),
      ],
    );
  }

  Color _parseColor(String? hex) {
     if (hex == null) return Colors.blue; 
     try {
       if (hex.startsWith('#')) hex = hex.substring(1);
       if (hex.length == 6) hex = 'FF$hex';
       return Color(int.parse('0x$hex'));
     } catch (_) {
       return Colors.blue;
     }
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted)),
        Text(value, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain)),
      ],
    );
  }
}
