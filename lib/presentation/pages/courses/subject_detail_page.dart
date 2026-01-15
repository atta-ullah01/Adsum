import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:adsum/presentation/widgets/navigation/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/presentation/pages/attendance/history_log_page.dart' as history;

import 'package:adsum/presentation/widgets/charts/weekly_trend_chart.dart';
import 'package:adsum/presentation/pages/academics/widgets/create_assignment_sheet.dart';


class SubjectDetailPage extends ConsumerStatefulWidget {
  final String courseTitle;
  final String courseCode;
  
  // Optional: If provided, fetches real data. If null, might fallback to legacy/mock or error.
  final String? enrollmentId;
  final bool isCustomCourse; 

  const SubjectDetailPage({
    super.key,
    required this.courseTitle,
    required this.courseCode,
    this.enrollmentId,
    this.isCustomCourse = false, // Default to Global for demo
  });

  @override
  ConsumerState<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends ConsumerState<SubjectDetailPage> {
  late PageController _pageController;
  int _selectedIndex = 0;
  late bool _isCustom;
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _instructorController;
  late TextEditingController _expectedClassesController;
  late TextEditingController _sectionController;
  
  final List<String> _tabs = ["Stats", "Syllabus", "Work", "Info"];


  
  // Helper to find enrollment
  Enrollment? get _enrollment {
    final enrollments = ref.watch(enrollmentsProvider).asData?.value;
    if (enrollments == null) return null;
    
    // Try finding by ID first
    if (widget.enrollmentId != null) {
      return enrollments.firstWhere(
        (e) => e.enrollmentId == widget.enrollmentId,
        orElse: () => enrollments.firstWhere((e) => e.courseCode == widget.courseCode, orElse: () => _createMockEnrollment())
      );
    }
    
    // Fallback by code
    return enrollments.firstWhere((e) => e.courseCode == widget.courseCode, orElse: () => _createMockEnrollment());
  }

  // Temporary fix to avoid crashing if data missing during dev
  Enrollment _createMockEnrollment() {
     if (widget.isCustomCourse) {
       return Enrollment(
         enrollmentId: 'mock',
         customCourse: CustomCourse(
           code: widget.courseCode,
           name: widget.courseTitle,
         ),
         startDate: DateTime.now(),
       );
     } else {
       return Enrollment(
         enrollmentId: 'mock',
         courseCode: widget.courseCode,
         startDate: DateTime.now(),
       );
     }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _isCustom = widget.isCustomCourse || widget.courseCode.toUpperCase().startsWith('CUSTOM');

    // Initialize Controllers with widget data (updated later if enrollment loads)
    _nameController = TextEditingController(text: widget.courseTitle);
    _codeController = TextEditingController(text: widget.courseCode);
    _instructorController = TextEditingController(text: _isCustom ? "Self" : "Dr. Smith");
    _expectedClassesController = TextEditingController(text: "0");
    _sectionController = TextEditingController(text: "A");
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _expectedClassesController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOutCubic
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  // Placeholder for assignments
  final List<Map<String, dynamic>> _assignments = [];

  @override
  Widget build(BuildContext context) {
    // Watch enrollment (trigger rebuild on change)
    final asyncEnrollments = ref.watch(enrollmentsProvider);
    final enrollment = _enrollment;

    // Use derived data if available, else defaults
    final attendancePct = enrollment?.stats.attendancePercent ?? 0.0;
    final totalClasses = enrollment?.stats.totalClasses ?? 0;
    final attendedClasses = enrollment?.stats.attended ?? 0;
    final bunks = enrollment?.stats.safeBunks ?? 0;

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
                selectedIndex: _selectedIndex,
                onIndexChanged: _onTabChanged,
              ),
            ),
            
            const SizedBox(height: 1), 
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildStatsView(attendancePct, totalClasses, attendedClasses, bunks),
                  _buildSyllabusView(),
                  _buildAssignmentsView(),
                  _buildInfoView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () async {
                 // Assignment creation logic...
              },
              backgroundColor: AppColors.textMain,
              icon: const Icon(Ionicons.add, color: Colors.white),
              label: Text("Create Work", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
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

  // --- STATS VIEW (Pastel Bento) ---
  Widget _buildStatsView(double attendancePct, int total, int attended, int bunks) {
    return ListView(
      padding: const EdgeInsets.all(24), 
      children: [
        FadeSlideTransition(
          index: 0,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildPastelCard(
                      color: AppColors.pastelGreen,
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
                          Text("Attendance", style: GoogleFonts.dmSans(color: Colors.green[900], fontSize: 14)),
                          Text("${attendancePct.toInt()}%", style: GoogleFonts.outfit(color: Colors.green[900], fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildPastelCard(
                      color: AppColors.pastelOrange,
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
                          Text("Safe Bunks", style: GoogleFonts.dmSans(color: Colors.orange[900], fontSize: 14)),
                          Text("$bunks", style: GoogleFonts.outfit(color: Colors.orange[900], fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               Row(
                children: [
                  Expanded(
                    child: _buildPastelCard(
                      color: AppColors.pastelBlue,
                      height: 100, 
                      onTap: () {},
                      child: Row(
                        children: [
                           Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text("Total Classes", style: GoogleFonts.dmSans(color: Colors.blue[900], fontSize: 12)),
                               Text("$total", style: GoogleFonts.outfit(color: Colors.blue[900], fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                           ),
                           const Spacer(),
                           Icon(Ionicons.school, color: Colors.blue[300], size: 32),
                        ],
                      )
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPastelCard(
                      color: AppColors.pastelPurple,
                      height: 100,
                      onTap: () {},
                      child: Row(
                        children: [
                           Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text("Attended", style: GoogleFonts.dmSans(color: Colors.deepPurple[900], fontSize: 12)),
                               Text("$attended", style: GoogleFonts.outfit(color: Colors.deepPurple[900], fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                           ),
                           const Spacer(),
                           Icon(Ionicons.people, color: Colors.deepPurple[300], size: 32),
                        ],
                      )
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
                   Text("Past 7 Days", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                   TextButton(
                     onPressed: () => context.push('/history-log', extra: {'title': widget.courseTitle, 'courseCode': widget.courseCode}),
                     child: const Text("View All"),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               
               // TODO: Fetch real history from AttendanceRepository
               Container(
                 padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                 decoration: BoxDecoration(
                   color: AppColors.bgApp, 
                   borderRadius: BorderRadius.circular(24),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      // Placeholder for now
                      _buildDayStatusIcon("M", AttendanceStatus.present),
                      _buildDayStatusIcon("T", AttendanceStatus.present),
                      _buildDayStatusIcon("W", AttendanceStatus.absent), 
                      _buildDayStatusIcon("T", AttendanceStatus.present),
                      _buildDayStatusIcon("F", AttendanceStatus.present),
                      _buildDayStatusIcon("S", null), // No class
                      _buildDayStatusIcon("S", null),
                   ],
                 ),
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
  
  Widget _buildPastelCard({required Color color, required Widget child, VoidCallback? onTap, double height = 160}) {
     return GestureDetector(
       onTap: onTap,
       child: Container(
         height: height,
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
           color: color,
           borderRadius: BorderRadius.circular(30), 
         ),
         child: child,
       ),
     );
  }


  // --- SYLLABUS VIEW ---
  Widget _buildSyllabusView() {
    final syllabusAsync = ref.watch(customSyllabusProvider(widget.courseCode));
    final progressAsync = ref.watch(syllabusProgressProvider(widget.courseCode));

    return syllabusAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading syllabus: $err')),
      data: (syllabus) {
        final units = syllabus?.units ?? [];
        if (units.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Ionicons.book_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text("No syllabus found", style: GoogleFonts.dmSans(color: Colors.grey)),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    context.push('/syllabus-editor', extra: {'courseCode': widget.courseCode});
                  },
                  icon: const Icon(Ionicons.add),
                  label: const Text("Create Syllabus"),
                ),
              ],
            ),
          );
        }

        final completedTopicIds = progressAsync.asData?.value ?? [];

        int totalTopics = 0;
        int completedTopics = 0;
        for (var unit in units) {
          for (var topic in unit.topics) {
            totalTopics++;
            if (completedTopicIds.contains(topic.topicId)) completedTopics++;;
          }
        }

        double progress = totalTopics == 0 ? 0 : completedTopics / totalTopics;
        String percentage = "${(progress * 100).toInt()}%";

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 1. Progress Card
            FadeSlideTransition(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreen,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Overall Progress", style: GoogleFonts.dmSans(color: Colors.green[900], fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("$completedTopics / $totalTopics Topics", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900])),
                          ],
                        ),
                        Text(percentage, style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.green[900])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white,
                        color: Colors.green,
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Modules", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                TextButton.icon(
                  onPressed: () {
                    context.push('/syllabus-editor', extra: {'courseCode': widget.courseCode});
                  },
                  icon: const Icon(Ionicons.create_outline, size: 18),
                  label: const Text("Edit / Import"),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 16),

            // 2. Units Accordion List
            ...List.generate(units.length, (index) {
              final unit = units[index];
              return FadeSlideTransition(
                index: index + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgApp,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(unit.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 16)),
                        subtitle: Text("${unit.topics.length} Topics", style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13)),
                        childrenPadding: const EdgeInsets.only(bottom: 16),
                        iconColor: AppColors.textMain,
                        children: unit.topics.map<Widget>((topic) {
                          final bool isDone = completedTopicIds.contains(topic.topicId);
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            title: Text(
                              topic.title,
                              style: GoogleFonts.dmSans(
                                color: isDone ? Colors.grey[400] : AppColors.textMain,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            leading: _buildCustomCheckbox(isDone, () async {
                              // Optimistic update handled by provider invalidation in service
                              await ref.read(syllabusServiceProvider).toggleComplete(widget.courseCode, topic.topicId);
                              ref.invalidate(syllabusProgressProvider(widget.courseCode));
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCustomCheckbox(bool isChecked, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isChecked ? AppColors.primary : Colors.grey.shade400, width: 2),
        ),
        child: isChecked ? const Icon(Ionicons.checkmark, size: 16, color: Colors.white) : null,
      ),
    );
  }


  // --- INFO VIEW (Read-Only) ---
  Widget _buildInfoView() {
    final enrollment = _enrollment;
    // Default values if loading/null
    final instructor = enrollment?.customCourse?.instructor ?? "Dr. Smith (Global)";
    final total = enrollment?.stats.totalClasses ?? 24;
    final section = enrollment?.section ?? "A";
    final targetAtt = enrollment?.targetAttendance ?? 75.0;
    final colorHex = enrollment?.colorTheme ?? "#6366F1";
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
               Text("Course Details", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(24)),
                 child: Column(
                   children: [
                      // Course Name, Code, Instructor (Read-Only)
                        _buildDetailRow("Course Name", widget.courseTitle),
                        const SizedBox(height: 12),
                        _buildDetailRow("Course Code", widget.courseCode),
                        const SizedBox(height: 12),
                        _buildDetailRow("Instructor", instructor),
                        const SizedBox(height: 12),
                        _buildDetailRow("Total Classes", "$total (Expected)"),
                         const SizedBox(height: 12),
                         // Tag
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                               child: Text(enrollment?.isCustom == true ? "Custom Course" : "University Catalog", style: GoogleFonts.dmSans(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                             ),
                           ],
                         ),
                         const SizedBox(height: 24),
                         
                         // Schedule (Placeholder)
                         Text("Class Schedule", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                         const SizedBox(height: 8),
                         Text("View your full schedule on the Dashboard tab.", style: GoogleFonts.dmSans(color: Colors.grey)),
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
               Text("My Enrollment", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(24)),
                 child: Column(
                   children: [
                      _buildDetailRow("Class Section", section), 
                      const Divider(height: 24),
                      _buildDetailRow("Target Attendance", "${targetAtt.toInt()}%"),
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
               Text("Settings", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
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
                          Text("Card Color", style: GoogleFonts.dmSans(color: AppColors.textMuted)),
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
                          Expanded(child: Text("To edit these settings, go to Manage Courses.", style: TextStyle(fontSize: 11, color: Colors.grey))),
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
       if (hex.length == 6) hex = 'FF' + hex;
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
  
  Widget _buildDropdownRow(String label, String currentValue, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
         const SizedBox(height: 4),
         DropdownButtonFormField<String>(
           value: currentValue,
           items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
           onChanged: onChanged,
           style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 16),
           decoration: const InputDecoration(
             isDense: true,
             contentPadding: EdgeInsets.symmetric(vertical: 8),
             enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
             focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
           ),
           icon: const Icon(Icons.keyboard_arrow_down, size: 18),
         ),
      ],
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
         const SizedBox(height: 4),
         TextFormField(
           controller: controller,
           style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain),
           decoration: InputDecoration(
             isDense: true,
             contentPadding: const EdgeInsets.symmetric(vertical: 8),
             enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
             focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
             hintText: "Enter $label",
             hintStyle: GoogleFonts.dmSans(color: Colors.black12),
           ),
         ),
      ],
    );
  }
  
  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.textMain, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const Spacer(),
            Icon(Ionicons.chevron_forward, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  
  // --- ASSIGNMENTS VIEW (New Tab) ---
  Widget _buildAssignmentsView() {
    if (_assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.checkmark_done_circle_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No pending tasks!", style: GoogleFonts.dmSans(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final task = _assignments[index];
        final String workType = (task['work_type'] as String?) ?? 'ASSIGNMENT';
        
        // Color Logic based on work_type
        Color accentColor;
        IconData typeIcon;
        if (workType == 'EXAM') {
          accentColor = Colors.red;
          typeIcon = Ionicons.alert_circle;
        } else if (workType == 'QUIZ') {
          accentColor = Colors.purple;
          typeIcon = Ionicons.timer;
        } else if (workType == 'PROJECT') {
          accentColor = Colors.green; // Distinct for Projects
          typeIcon = Ionicons.cube;
        } else {
          accentColor = Colors.blue; // Default for Assignment/Homework
          typeIcon = Ionicons.document_text;
        }
        
        return FadeSlideTransition(
          index: index,
          child: Container(
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
                onTap: () {
                   context.push('/academics/detail', extra: task);
                },
                borderRadius: BorderRadius.circular(20),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // 1. Color Strip
                      Container(
                         width: 6,
                         decoration: BoxDecoration(
                           color: accentColor,
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
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Icon(typeIcon, size: 12, color: accentColor),
                                        const SizedBox(width: 4),
                                        Text(workType, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 0.5)),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Title
                              Text((task['title'] as String?) ?? 'Untitled', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              const SizedBox(height: 12),
                              
                              // Footer: Unique Elements based on work_type
                              if (workType == 'ASSIGNMENT')
                                _buildIconText(Ionicons.time_outline, "Due ${(task['due_at'] as String?) ?? 'TBD'}"),
                                
                              if (workType == 'QUIZ')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconText(Ionicons.calendar_outline, "${(task['start_at'] as String?) ?? 'TBD'} - ${(task['due_at'] as String?) ?? 'TBD'}"),
                                    const SizedBox(height: 4),
                                    _buildIconText(Ionicons.hourglass_outline, "Duration: ${task['duration_minutes']} mins"),
                                  ],
                                ),
                                
                              if (workType == 'EXAM')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconText(Ionicons.calendar, (task['start_at'] as String?) ?? 'TBD'),
                                    const SizedBox(height: 4),
                                    _buildIconText(Ionicons.location_outline, "Venue: ${(task['venue'] as String?) ?? 'TBD'}"),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text, 
        style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: color)
      ),
    );
  }

  // End of widget
}
