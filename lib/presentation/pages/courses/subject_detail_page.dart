import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/pages/courses/providers/subject_detail_viewmodel.dart';
import 'package:adsum/presentation/pages/courses/widgets/tabs/subject_assignments_tab.dart';
import 'package:adsum/presentation/pages/courses/widgets/tabs/subject_info_tab.dart';
import 'package:adsum/presentation/pages/courses/widgets/tabs/subject_stats_tab.dart';
import 'package:adsum/presentation/pages/courses/widgets/tabs/subject_syllabus_tab.dart';
import 'package:adsum/presentation/widgets/navigation/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class SubjectDetailPage extends ConsumerStatefulWidget { 
  const SubjectDetailPage({
    required this.courseTitle, required this.courseCode, super.key,
    this.enrollmentId,
    this.isCustomCourse = false,
  });
  final String courseTitle;
  final String courseCode;
  
  final String? enrollmentId;
  final bool isCustomCourse;

  @override
  ConsumerState<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends ConsumerState<SubjectDetailPage> {
  late PageController _pageController;
  final List<String> _tabs = ['Stats', 'Syllabus', 'Work', 'Info'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate unique key for family provider
    final providerKey = "${widget.courseCode}|${widget.enrollmentId ?? ''}";
    final viewState = ref.watch(subjectDetailViewModelProvider(providerKey));
    final viewModel = ref.read(subjectDetailViewModelProvider(providerKey).notifier);

    // Sync PageController with Riverpod state
    // Sync PageController with Riverpod state
    ref.listen(subjectDetailViewModelProvider(providerKey), (previous, next) {
      if (previous?.selectedTab != next.selectedTab) {
        if (_pageController.hasClients && (_pageController.page?.round() != next.selectedTab)) {
           _pageController.animateToPage(
            next.selectedTab, 
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeOutCubic
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Column(
          children: [
             // Custom App Bar
            _buildAppBar(context),
            
            const SizedBox(height: 8),
            
            // Segmented Control (Top Nav)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomSegmentedControl(
                tabs: _tabs,
                selectedIndex: viewState.selectedTab,
                onIndexChanged: viewModel.setTab,
              ),
            ),
            
            const SizedBox(height: 1), 
            
            // Content
            Expanded(
              child: viewState.enrollment.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (enrollment) {
                   return PageView(
                    controller: _pageController,
                    onPageChanged: viewModel.setTab,
                    children: [
                      SubjectStatsTab(enrollment: enrollment, courseTitle: widget.courseTitle, courseCode: widget.courseCode),
                      SubjectSyllabusTab(courseCode: widget.courseCode),
                      SubjectAssignmentsTab(enrollment: enrollment, courseTitle: widget.courseTitle, courseCode: widget.courseCode),
                      SubjectInfoTab(enrollment: enrollment, courseTitle: widget.courseTitle, courseCode: widget.courseCode),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: viewState.selectedTab == 2
          ? FloatingActionButton.extended(
              onPressed: () async {
                 // Open bottom sheet or navigate to add assignment page
                 // For now, we'll just log or show a snackbar as placeholder is fine
                 // Or navigate to a create page if exists
                 // context.push('/create-assignment', extra: {'courseCode': widget.courseCode});
              },
              backgroundColor: AppColors.textMain,
              icon: const Icon(Ionicons.add, color: Colors.white),
              label: Text('Create Work', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
             onTap: () => context.pop(),
             child: const Icon(Ionicons.arrow_back, size: 24),
          ),
          
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.courseTitle,
                  style: GoogleFonts.outfit(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                 Text(
                  widget.courseCode,
                  style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
           const SizedBox(width: 24), 
        ],
      ),
    );
  }
}
