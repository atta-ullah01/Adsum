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

class SubjectStatsTab extends ConsumerWidget {

  const SubjectStatsTab({
    required this.enrollment, required this.courseTitle, required this.courseCode, super.key,
  });
  final Enrollment enrollment;
  final String courseTitle;
  final String courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real logs
    final logsAsync = ref.watch(attendanceLogsProvider(enrollment.enrollmentId));
    
    final attendancePct = enrollment.stats.attendancePercent;
    final total = enrollment.stats.totalClasses;
    final attended = enrollment.stats.attended;
    final bunks = enrollment.stats.safeBunks;

    return ListView(
      padding: const EdgeInsets.all(24), 
      children: [
        FadeSlideTransition(
          index: 0,
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PastelCard(
                        backgroundColor: AppColors.pastelGreen,
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Ionicons.checkmark_circle, color: Colors.green, size: 20),
                            ),
                            const Spacer(),
                            Text('Attendance', style: GoogleFonts.dmSans(color: Colors.green[900], fontSize: 14)),
                            Text('${attendancePct.toInt()}%', style: GoogleFonts.outfit(color: Colors.green[900], fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: PastelCard(
                        backgroundColor: AppColors.pastelOrange,
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Ionicons.bed, color: Colors.orange, size: 20),
                            ),
                            const Spacer(),
                            Text('Safe Bunks', style: GoogleFonts.dmSans(color: Colors.orange[900], fontSize: 14)),
                            Text('$bunks', style: GoogleFonts.outfit(color: Colors.orange[900], fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
               Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 115,
                      child: PastelCard(
                        backgroundColor: AppColors.pastelBlue,
                        onTap: () {},
                        child: Row(
                          children: [
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text('Total Classes', style: GoogleFonts.dmSans(color: Colors.blue[900], fontSize: 12)),
                                 Text('$total', style: GoogleFonts.outfit(color: Colors.blue[900], fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                             ),
                             const Spacer(),
                             Icon(Ionicons.school, color: Colors.blue[300], size: 32),
                          ],
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 115,
                      child: PastelCard(
                        backgroundColor: AppColors.pastelPurple,
                        onTap: () {},
                        child: Row(
                          children: [
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text('Attended', style: GoogleFonts.dmSans(color: Colors.deepPurple[900], fontSize: 12)),
                                 Text('$attended', style: GoogleFonts.outfit(color: Colors.deepPurple[900], fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                             ),
                             const Spacer(),
                             Icon(Ionicons.people, color: Colors.deepPurple[300], size: 32),
                          ],
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        
        FadeSlideTransition(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text('Past 7 Days', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                   TextButton(
                     onPressed: () => context.push('/history-log', extra: {'title': courseTitle, 'courseCode': courseCode}),
                     child: const Text('View All'),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               
               logsAsync.when(
                 loading: () => Container(
                   height: 100,
                   alignment: Alignment.center,
                   child: const CircularProgressIndicator(),
                 ),
                 error: (err, _) => Text('Could not load history: $err'),
                 data: (logs) {
                   final recentLogs = logs.take(7).toList();
                   
                   if (recentLogs.isEmpty) {
                     return Container(
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                       child: const Text('No recent attendance data.'),
                     );
                   }

                   return Container(
                     padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                     decoration: BoxDecoration(
                       color: AppColors.bgApp, 
                       borderRadius: BorderRadius.circular(24),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: recentLogs.map((log) {
                         final date = log.date;
                         final dayLetter = DateFormat('E').format(date).substring(0, 1);
                         return _buildDayStatusIcon(dayLetter, log.status);
                       }).toList(),
                     ),
                   );
                 }
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayStatusIcon(String day, AttendanceStatus? status) {
    Color color;
    IconData icon;
    
    if (status == AttendanceStatus.present) {
      color = Colors.green;
      icon = Ionicons.checkmark;
    } else if (status == AttendanceStatus.absent) {
      color = AppColors.danger;
      icon = Ionicons.close;
    } else if (status == AttendanceStatus.pending) {
      color = Colors.orange;
      icon = Ionicons.help;
    } else {
      // No class
      color = Colors.grey.shade400;
      icon = Ionicons.remove;
    }
    
    return Column(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
             color: status == null ? Colors.transparent : color.withOpacity(0.15),
             shape: BoxShape.circle,
             border: status == null ? Border.all(color: Colors.grey.shade300) : null,
          ),
          child: Icon(icon, color: status == null ? Colors.grey.shade400 : color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(day, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
