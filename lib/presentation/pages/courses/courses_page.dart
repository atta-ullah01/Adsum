import 'dart:async';
import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/courses/providers/course_viewmodel.dart';
import 'package:adsum/presentation/pages/courses/widgets/course_search_overlay.dart';
import 'package:adsum/presentation/pages/courses/widgets/custom_course_form.dart';
import 'package:adsum/presentation/widgets/course_card.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key, this.showWizard = true});
  final bool showWizard;

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  // UI State (View-Specific)
  bool _showSearchResults = false;
  String? _editingEnrollmentId;
  bool _isEditingCustomCourse = false;

  // Track search text focus to show/hide overlay
  late TextEditingController _searchController;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_searchFocus.hasFocus) {
      setState(() => _showSearchResults = true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _enrollInCourse(Course course, List<Enrollment> existing) async {
    final isEnrolled = existing.any((e) => e.effectiveCourseCode == course.courseCode);
    
    if (isEnrolled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Already enrolled in ${course.name}')));
      return;
    }

    // Show enrollment modal
    _showEnrollmentModal(course);
  }

  void _showEnrollmentModal(Course course) {
    var section = 'A';
    var targetAttendance = 75.0;
    var selectedColor = AppColors.pastelPurple;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enroll in ${course.name}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(course.courseCode, style: GoogleFonts.dmSans(color: Colors.grey)),
                const SizedBox(height: 20),
                
                // Section
                const Text('SECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgApp,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: section,
                      isExpanded: true,
                      items: ['A', 'B', 'C', 'D', 'E'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setModalState(() => section = val ?? 'A'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Target Attendance
                const Text('TARGET ATTENDANCE %', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Slider(
                  value: targetAttendance,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  label: '${targetAttendance.round()}%',
                  onChanged: (val) => setModalState(() => targetAttendance = val),
                ),
                Center(child: Text('${targetAttendance.round()}%', style: const TextStyle(fontWeight: FontWeight.bold))),
                
                const SizedBox(height: 16),
                
                // Semester Start (Read-Only for Global)
                _buildReadOnlyField('Semester Start', 'Jan 6, 2026 (University Calendar)'),
                
                const SizedBox(height: 16),
                
                // Color
                const Text('CARD COLOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _modalColorOption(AppColors.pastelGreen, selectedColor, (c) => setModalState(() => selectedColor = c)),
                    const SizedBox(width: 8),
                    _modalColorOption(AppColors.pastelPurple, selectedColor, (c) => setModalState(() => selectedColor = c)),
                    const SizedBox(width: 8),
                    _modalColorOption(AppColors.pastelOrange, selectedColor, (c) => setModalState(() => selectedColor = c)),
                    const SizedBox(width: 8),
                    _modalColorOption(AppColors.pastelBlue, selectedColor, (c) => setModalState(() => selectedColor = c)),
                    const SizedBox(width: 8),
                    _modalColorOption(const Color(0xFFFCE7F3), selectedColor, (c) => setModalState(() => selectedColor = c)),
                  ],
                ),

                const SizedBox(height: 24),
                
                PrimaryButton(
                  text: 'Confirm Enrollment',
                  onPressed: () async {
                    final colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';
                    
                    final success = await ref.read(courseViewModelProvider.notifier).enrollInCourse(
                      course, section, targetAttendance, colorHex
                    );
                    
                    if (!success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Already enrolled in ${course.name} (Section $section)'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enrolled in ${course.name} 🎉')));
                      setState(() {
                         _showSearchResults = false;
                         _searchController.clear();
                         _searchFocus.unfocus();
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
         const SizedBox(height: 4),
         Container(
           width: double.infinity,
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
           decoration: BoxDecoration(
             color: Colors.grey[100],
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: Colors.transparent),
           ),
           child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
         ),
       ],
     );
  }

  Widget _modalColorOption(Color color, Color selected, Function(Color) onTap) {
    final isSelected = color.value == selected.value;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(width: 2) : null,
        ),
        child: isSelected ? const Icon(Icons.check, size: 16) : null,
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.pastelPurple;
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return AppColors.pastelPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentsAsync = ref.watch(enrollmentsProvider);
    final vmState = ref.watch(courseViewModelProvider);
    final vm = ref.read(courseViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      floatingActionButton: widget.showWizard
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/sensors'),
              backgroundColor: Colors.black,
              label: Text('Continue', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
              icon: const Icon(Ionicons.arrow_forward, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss search on background tap
            if (_showSearchResults) {
              setState(() => _showSearchResults = false);
              _searchFocus.unfocus();
            }
          },
          child: Stack(
          children: [
            Column(
              children: [
                // Header (Wizard Only)
                if (widget.showWizard)
                   Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 44, height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                            ),
                            child: const Icon(Ionicons.chevron_back, size: 20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(),
                          ),
                          child: const Text(
                            'Step 2 / 3',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                   // Standalone Header
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                     child: Row(
                       children: [
                         GestureDetector(
                            onTap: () => context.pop(),
                            child: const Icon(Ionicons.arrow_back, size: 24),
                         ),
                         const SizedBox(width: 16),
                         Text('Manage Courses', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),

                Expanded(
                  child: enrollmentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (enrollments) {
                      final globalEnrollments = enrollments.where((e) => !e.isCustom).toList();
                      final customEnrollments = enrollments.where((e) => e.isCustom).toList();

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        children: [
                          // Title
                          Text(
                            'My Courses',
                            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${enrollments.length} courses enrolled',
                            style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 30),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              onChanged: vm.onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search by Course Code (e.g. CS101)...',
                                hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                                prefixIcon: const Icon(Ionicons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                suffixIcon: vmState.isSearching 
                                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) 
                                    : null,
                              ),
                            ),
                          ),
                          
                          // Search Results Overlay
                          if (_showSearchResults) ...[
                            const SizedBox(height: 10),
                             CourseSearchOverlay(
                               currentEnrollments: enrollments,
                               onEnroll: (course) => _enrollInCourse(course, enrollments),
                               onCreateCustom: () {
                                 setState(() {
                                    // Close search, reset form, show creation mode
                                    _showSearchResults = false;
                                    _editingEnrollmentId = null; // null = creating new
                                    _isEditingCustomCourse = true;
                                    _searchController.clear();
                                    _searchFocus.unfocus();
                                    // Logic to reset form would go here or in widget
                                 });
                               },
                             ).animate().fadeIn().moveY(begin: 10, end: 0),
                          ],

                          const SizedBox(height: 30),

                          if (enrollments.isEmpty)
                            const Center(child: Text('No courses added yet. Search above!')),

                          // Timeline - Global Courses
                          ...globalEnrollments.map((course) {
                             final isEditing = _editingEnrollmentId == course.enrollmentId;
                             
                             return Column(
                               children: [
                                  CourseCard(
                                   startTime: course.courseCode ?? 'UNK',
                                   endTime: 'Global', // Tag
                                   title: course.courseName,
                                   location: course.section, // Show Section
                                   instructor: course.instructor ?? 'TBD',
                                   color: _parseColor(course.colorTheme),
                                   isGlobal: true,
                                   onTap: () {
                                       setState(() {
                                         if (_editingEnrollmentId == course.enrollmentId) {
                                           _editingEnrollmentId = null;
                                         } else {
                                           _editingEnrollmentId = course.enrollmentId;
                                           _isEditingCustomCourse = false;
                                         }
                                       });
                                   },
                                 ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                                 
                                 // Global Course Edit Panel
                                 if (isEditing)
                                   _buildGlobalEditPanel(course),
                               ],
                             );
                          }),

                          // Custom Courses
                          ...customEnrollments.map((course) {
                            // Map custom data
                            return Column(
                              children: [
                                CourseCard(
                                  startTime: course.customCourse?.code ?? 'Custom',
                                  endTime: '',
                                  title: course.customCourse?.name ?? 'Custom Course',
                                  location: course.section, // Show Section for consistency
                                  instructor: course.customCourse?.instructor ?? 'Self',
                                  color: _parseColor(course.colorTheme),
                                  isCustom: true,
                                  onTap: () {
                                    setState(() {
                                      if (_editingEnrollmentId == course.enrollmentId) {
                                         // Toggle off
                                         _editingEnrollmentId = null;
                                         _isEditingCustomCourse = false;
                                      } else {
                                        // Toggle on
                                        _editingEnrollmentId = course.enrollmentId;
                                        _isEditingCustomCourse = true;
                                        // Populate logic handled in widget now
                                      }
                                    });
                                  },
                                ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),
                            
                                if (_isEditingCustomCourse && _editingEnrollmentId == course.enrollmentId)
                                  CustomCourseForm(
                                    initialData: {
                                      'name': course.customCourse?.name,
                                      'code': course.customCourse?.code,
                                      'instructor': course.customCourse?.instructor,
                                      'section': course.section,
                                      'targetAttendance': course.targetAttendance,
                                      'totalExpected': course.customCourse?.totalExpected,
                                      'color': _parseColor(course.colorTheme),
                                      'startDate': course.startDate,
                                    },
                                    onCancel: () => setState(() => _editingEnrollmentId = null),
                                    onSave: (data) async {
                                       final err = await vm.saveCustomCourse(
                                         editingEnrollmentId: course.enrollmentId,
                                         name: data['name'], code: data['code'], instructor: data['instructor'],
                                         section: data['section'], targetAttendance: data['targetAttendance'],
                                         totalExpected: data['totalExpected'], color: data['color'], startDate: data['startDate'],
                                         slots: data['slots']
                                       );
                                       if (err == null) {
                                         setState(() => _editingEnrollmentId = null);
                                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course Updated!')));
                                       } else {
                                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
                                       }
                                    },
                                  )
                               ],
                            );
                          }),
                          
                          // Show inline form for CREATING new custom course (when _editingEnrollmentId is null)
                          if (_isEditingCustomCourse && _editingEnrollmentId == null)
                            CustomCourseForm(
                              onCancel: () => setState(() => _isEditingCustomCourse = false),
                              onSave: (data) async {
                                 final err = await vm.saveCustomCourse(
                                   editingEnrollmentId: null,
                                   name: data['name'], code: data['code'], instructor: data['instructor'],
                                   section: data['section'], targetAttendance: data['targetAttendance'],
                                   totalExpected: data['totalExpected'], color: data['color'], startDate: data['startDate'],
                                   slots: data['slots']
                                 );
                                 if (err == null) {
                                   setState(() => _isEditingCustomCourse = false);
                                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course Created!')));
                                 } else {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
                                 }
                              },
                            ),

                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    if (widget.showWizard) {
      return Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: const Icon(Ionicons.chevron_back, size: 20),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: const Text('Step 2 / 3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(children: [
           GestureDetector(onTap: () => context.pop(), child: const Icon(Ionicons.arrow_back, size: 24)),
           const SizedBox(width: 16),
           Text('Manage Courses', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
      );
    }
  }

  Widget _buildGlobalEditPanel(Enrollment enrollment) {
     return Container(
       margin: const EdgeInsets.only(left: 90, bottom: 20), padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!)),
       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildReadOnlyField('Course Name', enrollment.courseName), const SizedBox(height: 12),
          _buildReadOnlyField('Course Code', enrollment.courseCode ?? 'N/A'), const SizedBox(height: 12),
          // Simple Delete for Global
          Center(child: TextButton.icon(
             icon: const Icon(Ionicons.trash, color: Colors.red, size: 16),
             label: const Text('Remove from my list', style: TextStyle(color: Colors.red)),
             onPressed: () {
                ref.read(enrollmentRepositoryProvider).deleteEnrollment(enrollment.enrollmentId);
                ref.invalidate(enrollmentsProvider);
             },
          )),
       ]),
     );
  }


}
