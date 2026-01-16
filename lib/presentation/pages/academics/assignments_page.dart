import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/work.dart';
import 'package:adsum/presentation/pages/academics/providers/assignments_viewmodel.dart';
import 'package:adsum/presentation/pages/academics/widgets/assignment_card.dart';
import 'package:adsum/presentation/pages/academics/widgets/create_assignment_sheet.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch real data
    final pendingAsync = ref.watch(pendingWorkProvider);
    final completedAsync = ref.watch(completedWorkProvider);
    final vmNotifier = ref.read(assignmentsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: Text('Academics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
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
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Tab
          pendingAsync.when(
            data: (workItems) {
              if (workItems.isEmpty) return _buildEmptyState('No pending tasks! 🎉');
              return _buildAssignmentList(workItems);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          
          // Completed Tab
          completedAsync.when(
            data: (workItems) {
              if (workItems.isEmpty) return _buildEmptyState('No completed tasks yet!');
              return _buildAssignmentList(workItems, isCompleted: true);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
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
              vmNotifier.refresh();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Signing & Broadcasting to Class...'),
                  backgroundColor: AppColors.accent,
                  duration: Duration(seconds: 2),
                ));
              }
           }
        },
        backgroundColor: AppColors.textMain,
        icon: const Icon(Ionicons.add, color: Colors.white),
        label: Text('Add Task', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildAssignmentList(List<Work> tasks, {bool isCompleted = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return FadeSlideTransition(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AssignmentCard(task: task, isCompleted: isCompleted),
          ),
        );
      },
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
