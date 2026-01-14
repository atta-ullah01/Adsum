import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:adsum/presentation/pages/academics/widgets/create_assignment_sheet.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _pendingAssignments = [
    {
      "title": "Math Problem Set 3",
      "subject": "CS-302 • Linear Algebra",
      "deadline": "Tomorrow, 10:00 AM",
      "isUrgent": true,
      "type": "Homework"
    },
    {
      "title": "Physics Lab Report",
      "subject": "PH-401 • Quantum Physics",
      "deadline": "Fri, 14 Nov",
      "isUrgent": false,
      "type": "Project"
    },
    {
      "title": "Read Chapter 4",
      "subject": "HS-101 • Psychology",
      "deadline": "Mon, 17 Nov",
      "isUrgent": false,
      "type": "Reading"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignmentList(_pendingAssignments),
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
              // CR-Only: All work is broadcast
              setState(() {
                _pendingAssignments.insert(0, result);
              });
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

  Widget _buildAssignmentList(List<Map<String, dynamic>> tasks) {
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

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    final bool isUrgent = task['isUrgent'] ?? false;
    // Mock subject color based on text
    final Color subjectColor = task['subject'].toString().contains("Math") ? Colors.indigo : 
                             task['subject'].toString().contains("Physics") ? Colors.purple : Colors.teal;

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
          onTap: () => context.push('/academics/detail', extra: task),
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
                              child: Text(task['type'].toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: subjectColor, letterSpacing: 0.5)),
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
                          task['title'], 
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task['subject'], 
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)
                        ),
                        const SizedBox(height: 16),
                        // Footer: Due Date
                        Row(
                          children: [
                            Icon(Ionicons.time_outline, size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text(
                              "Due ${task['deadline']}", 
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
