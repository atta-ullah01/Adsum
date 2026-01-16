import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:adsum/presentation/widgets/pastel_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class SubjectAssignmentsTab extends ConsumerWidget {

  const SubjectAssignmentsTab({
    required this.enrollment, required this.courseTitle, required this.courseCode, super.key,
  });
  final Enrollment enrollment;
  final String courseTitle;
  final String courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch assignments for this course
    final assignmentsAsync = ref.watch(courseWorkProvider(courseCode));

    return assignmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading work: $err')),
      data: (assignments) {
         if (assignments.isEmpty) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Ionicons.document_text_outline, size: 48, color: Colors.grey),
                 const SizedBox(height: 16),
                 Text('No upcoming work', style: GoogleFonts.dmSans(color: Colors.grey)),
                 const SizedBox(height: 16),
                 TextButton.icon(
                   onPressed: () {
                      // context.push('/add-work', extra: {'courseCode': courseCode}); 
                      // Or open sheet
                   },
                   icon: const Icon(Ionicons.add),
                   label: const Text('Add Assignment'),
                 ),
               ],
             ),
           );
         }

         // TODO: Implement status check (completed/pending) correctly using WorkState
         // For now, assuming not completed
         final upcoming = assignments.where((a) => (a.dueAt?.isAfter(DateTime.now()) ?? true)).toList();
         final past = assignments.where((a) => (a.dueAt?.isBefore(DateTime.now()) ?? false)).toList();

         return ListView(
           padding: const EdgeInsets.all(24),
           children: [
              // Summary Cards
              FadeSlideTransition(
                index: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 110,
                        child: PastelCard(
                          backgroundColor: AppColors.pastelOrange,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${upcoming.length}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                              Text('Pending', style: GoogleFonts.dmSans(color: Colors.orange[900])),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 110,
                        child: PastelCard(
                          backgroundColor: AppColors.pastelBlue,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('0', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                              Text('Completed', style: GoogleFonts.dmSans(color: Colors.blue[900])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              if (upcoming.isNotEmpty) ...[
                 Text('Upcoming Deadlines', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                 const SizedBox(height: 16),
                 ...upcoming.map((a) => Padding(
                   padding: const EdgeInsets.only(bottom: 12),
                   child: _buildAssignmentCard(context, a),
                 )),
                 const SizedBox(height: 24),
              ],

              if (past.isNotEmpty) ...[
                 Text('Past / Completed', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                 const SizedBox(height: 16),
                 ...past.map((a) => Padding(
                   padding: const EdgeInsets.only(bottom: 12),
                   child: Opacity(
                     opacity: 0.6,
                     child: _buildAssignmentCard(context, a),
                   ),
                 )),
              ],
           ],
         );
      },
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Work work) {
    final isOverdue = work.isOverdue; // Use Work's helper
    final dateStr = work.dueAt != null 
        ? DateFormat('MMM d, h:mm a').format(work.dueAt!) 
        : 'No Deadline';
    
    return GestureDetector(
      onTap: () => context.push('/work/${work.workId}'), // Assuming route exists
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: work.workType == WorkType.exam ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                work.workType == WorkType.exam ? Ionicons.alert_circle : Ionicons.document_text,
                color: work.workType == WorkType.exam ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isOverdue) 
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('OVERDUE', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                        ),
                      Text(dateStr, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            // if (work.isCompleted) // No isCompleted field on Work
            //   const Icon(Ionicons.checkmark_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
