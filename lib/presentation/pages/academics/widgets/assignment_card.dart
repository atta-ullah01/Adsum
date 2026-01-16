import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/work.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class AssignmentCard extends StatelessWidget {

  const AssignmentCard({
    required this.task, super.key,
    this.isCompleted = false,
  });
  final Work task;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    // Determine urgency: Due within 24 hours
    final isUrgent = task.dueAt != null && 
                     task.dueAt!.difference(DateTime.now()).inHours < 24 &&
                     task.dueAt!.isAfter(DateTime.now());

    // Color based on course (hashing logic for consistency)
    final colors = [Colors.indigo, Colors.purple, Colors.teal, Colors.orange, Colors.blueGrey];
    final subjectColor = colors[task.courseCode.hashCode % colors.length];

    // Format deadline
    var deadlineText = 'No Deadline';
    if (task.dueAt != null) {
      final now = DateTime.now();
      final diff = task.dueAt!.difference(now);
      if (diff.inDays == 0) {
        deadlineText = 'Today, ${DateFormat.jm().format(task.dueAt!)}';
      } else if (diff.inDays == 1) {
        deadlineText = 'Tomorrow, ${DateFormat.jm().format(task.dueAt!)}';
      } else {
        deadlineText = DateFormat('EEE, d MMM').format(task.dueAt!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/academics/detail', extra: task.toJson()),
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 1. Color Strip
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  ),
                ),
                // 2. Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Subject + Type
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: subjectColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(task.workType.name.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: subjectColor, letterSpacing: 0.5)),
                            ),
                            const Spacer(),
                            if (isUrgent && !isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Ionicons.flame, size: 12, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text('URGENT', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          task.title, 
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.courseCode, 
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)
                        ),
                        const SizedBox(height: 16),
                        // Footer: Due Date
                        Row(
                          children: [
                            Icon(Ionicons.time_outline, size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Due $deadlineText', 
                                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Circular Checkbox (Custom)
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[300]!, width: 2),
                              ),
                              child: Center(
                                child: Icon(
                                  Ionicons.checkmark, 
                                  size: 16, 
                                  color: isCompleted ? Colors.green : Colors.grey[300]
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
