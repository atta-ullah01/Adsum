import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/work.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:adsum/presentation/pages/academics/widgets/create_assignment_sheet.dart';
import 'package:intl/intl.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({super.key});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Watch real data
    final pendingAsync = ref.watch(pendingWorkProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: Text("Academics", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Completed"), // TODO: Add completedWorkProvider or filter
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Tab
          pendingAsync.when(
            data: (workItems) {
              if (workItems.isEmpty) return _buildEmptyState("No pending tasks! 🎉");
              return _buildAssignmentList(workItems);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
          
          // Completed Tab (Placeholder for now)
          _buildEmptyState("No completed tasks yet!"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
           final result = await showModalBottomSheet(
             context: context,
             isScrollControlled: true,
             backgroundColor: Colors.transparent,
             builder: (context) => const CreateAssignmentSheet(),
           );
           
           if (result != null) {
              // Refresh provider after adding (if CreateAssignmentSheet saves it)
              ref.invalidate(pendingWorkProvider);
              
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Signing & Broadcasting to Class..."),
                backgroundColor: AppColors.accent,
                duration: Duration(seconds: 2),
              ));
           }
        },
        backgroundColor: AppColors.textMain,
        icon: const Icon(Ionicons.add, color: Colors.white),
        label: Text("Add Task", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildAssignmentList(List<Work> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return FadeSlideTransition(
          index: index,
          child: _buildTaskCard(context, task),
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Work task) {
    // Determine urgency: Due within 24 hours
    final isUrgent = task.dueAt != null && 
                     task.dueAt!.difference(DateTime.now()).inHours < 24 &&
                     task.dueAt!.isAfter(DateTime.now());

    // Color based on course (hashing logic for consistency)
    final colors = [Colors.indigo, Colors.purple, Colors.teal, Colors.orange, Colors.blueGrey];
    final subjectColor = colors[task.courseCode.hashCode % colors.length];

    // Format deadline
    String deadlineText = "No Deadline";
    if (task.dueAt != null) {
      final now = DateTime.now();
      final diff = task.dueAt!.difference(now);
      if (diff.inDays == 0) {
        deadlineText = "Today, ${DateFormat.jm().format(task.dueAt!)}";
      } else if (diff.inDays == 1) {
        deadlineText = "Tomorrow, ${DateFormat.jm().format(task.dueAt!)}";
      } else {
        deadlineText = DateFormat('EEE, d MMM').format(task.dueAt!);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Pass Work object to detail page
          onTap: () => context.push('/academics/detail', extra: task.toJson()), // Temporary: passing JSON map to maintain generic route arg for now
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
                              decoration: BoxDecoration(color: subjectColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(task.workType.name.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: subjectColor, letterSpacing: 0.5)),
                            ),
                            const Spacer(),
                            if (isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Ionicons.flame, size: 12, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text("URGENT", style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          task.title, 
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
                            Text(
                              "Due $deadlineText", 
                              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)
                            ),
                            const Spacer(),
                            // Circular Checkbox (Custom)
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[300]!, width: 2),
                              ),
                              child: Center(
                                child: Icon(Ionicons.checkmark, size: 16, color: Colors.grey[300]),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.checkmark_done_circle_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.dmSans(color: Colors.grey)),
        ],
      ),
    );
  }
}
