import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:adsum/presentation/widgets/navigation/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/presentation/pages/attendance/history_log_page.dart';

import 'package:adsum/presentation/widgets/charts/weekly_trend_chart.dart';
import 'package:adsum/presentation/pages/academics/widgets/create_assignment_sheet.dart';


class SubjectDetailPage extends StatefulWidget {
  final String courseTitle;
  final String courseCode;
  
  // In a real app, pass the full Course/Enrollment object to know if it's custom
  final bool isCustomCourse; 

  const SubjectDetailPage({
    super.key,
    required this.courseTitle,
    required this.courseCode,
    this.isCustomCourse = false, // Default to Global for demo
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late PageController _pageController;
  int _selectedIndex = 0;
  late bool _isCustom;
  
  // Mock Data
  final double currentAttendance = 85.0;


  final int totalClasses = 24;
  final int attendedClasses = 20;
  final int bunksAvailable = 3; 
  
  // Settings Mock Data
  double _targetAttendance = 75.0;
  String _selectedColor = "Blue";
  String _currentSection = "A"; // Mock Section

  final List<String> _tabs = ["Stats", "Syllabus", "Work", "Info"];

  // Mock Syllabus Data
  final List<Map<String, dynamic>> _syllabusUnits = [
    {
      "title": "Unit 1: Introduction to Flutter",
      "topics": [
        {"name": "Dart Basics", "done": true},
        {"name": "Widget Tree & Element Tree", "done": true},
        {"name": "Stateless vs Stateful", "done": false},
      ]
    },
    {
      "title": "Unit 2: Layouts & UI",
      "topics": [
        {"name": "Rows, Columns, Stack", "done": false},
        {"name": "Constraint Layout System", "done": false},
        {"name": "Material Design 3", "done": false},
      ]
    },
    {
      "title": "Unit 3: State Management",
      "topics": [
        {"name": "InheritedWidget", "done": false},
        {"name": "Riverpod Basics", "done": false},
      ]
    }
  ];

  // Mock Work Data (Aligned with course_work schema)
  final List<Map<String, dynamic>> _assignments = [
    {
      "title": "Math Problem Set 3",
      "course_code": "CS-302",
      "due_at": "Tomorrow, 10:00 AM",
      "work_type": "ASSIGNMENT",
      "status": "PENDING"
    },
    {
      "title": "Module 2 Quiz",
      "course_code": "CS-302",
      "start_at": "Fri, 24 Nov, 2:00 PM",
      "due_at": "Fri, 24 Nov, 3:00 PM",  // Window end uses due_at
      "duration_minutes": 45,
      "work_type": "QUIZ",
      "status": "PENDING"
    },
    {
      "title": "Mid-Sem Exam",
      "course_code": "CS-302",
      "start_at": "Mon, 10 Dec, 9:00 AM",
      "venue": "LH-101 • Seat A4",
      "work_type": "EXAM",
      "status": "PENDING"
    },
  ];

  // Controllers for Editing
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _instructorController;
  late TextEditingController _expectedClassesController;
  late TextEditingController _sectionController;
  
  // Mock Schedule Slots with Per-Slot Bindings (matches schedule_bindings.json design)
  // Each slot can have its own location/wifi binding, stored in schedule_bindings.json
  final List<Map<String, String?>> _scheduleSlots = [
    {'day': 'Mon', 'time': '10:00 - 11:00', 'location': null, 'wifi': null},  // No binding yet
    {'day': 'Wed', 'time': '14:00 - 15:00', 'location': 'Lab 2 (GPS)', 'wifi': 'IIITU_5G'},  // Has bindings
  ];
  
  // Mock Global Schedule (for catalog courses - shared, but bindings are user-specific)
  final List<Map<String, String?>> _globalScheduleSlots = [
    {'day': 'Mon', 'time': '09:00 - 10:00', 'defaultLoc': 'LH-101', 'location': null, 'wifi': null},
    {'day': 'Tue', 'time': '11:00 - 12:00', 'defaultLoc': 'LH-101', 'location': 'My Seat Row 3', 'wifi': 'IIITU_WIFI'},
    {'day': 'Thu', 'time': '14:00 - 15:00', 'defaultLoc': 'Lab 3', 'location': null, 'wifi': null},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    // Robust fallback: If code starts with 'CUSTOM', force custom mode
    _isCustom = widget.isCustomCourse || widget.courseCode.toUpperCase().startsWith('CUSTOM');

    // Initialize Controllers
    _nameController = TextEditingController(text: widget.courseTitle);
    _codeController = TextEditingController(text: widget.courseCode);
    _instructorController = TextEditingController(text: _isCustom ? "Self" : "Dr. Smith");
    _expectedClassesController = TextEditingController(text: "$totalClasses");
    _sectionController = TextEditingController(text: _currentSection);
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

  @override
  Widget build(BuildContext context) {
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
                  _buildStatsView(),
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
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CreateAssignmentSheet(initialSubject: widget.courseCode),
                );
                
                if (result != null) {
                   // CR-Only: Always broadcast
                   setState(() {
                       _assignments.insert(0, {
                         "title": result['title'],
                         "course_code": result['subject'],
                         "due_at": result['deadline'],
                         "start_at": result['start_at'],
                         "venue": result['venue'],
                         "duration_minutes": result['duration_minutes'],
                         "work_type": result['type'].toString().toUpperCase(),
                         "status": "PENDING"
                       });
                   });
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                     content: Text("Signing & Broadcasting to Class..."),
                     backgroundColor: AppColors.accent,
                   ));
                }
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
  Widget _buildStatsView() {
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
                          Text("85%", style: GoogleFonts.outfit(color: Colors.green[900], fontSize: 32, fontWeight: FontWeight.bold)),
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
                          Text("$bunksAvailable", style: GoogleFonts.outfit(color: Colors.orange[900], fontSize: 32, fontWeight: FontWeight.bold)),
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
                               Text("$totalClasses", style: GoogleFonts.outfit(color: Colors.blue[900], fontSize: 24, fontWeight: FontWeight.bold)),
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
                               Text("$attendedClasses", style: GoogleFonts.outfit(color: Colors.deepPurple[900], fontSize: 24, fontWeight: FontWeight.bold)),
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
                     onPressed: () => context.push('/history-log', extra: {'title': widget.courseTitle}),
                     child: Text("View Calendar", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
                   )
                 ],
               ),
               const SizedBox(height: 16),
               
               Container(
                 padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                 decoration: BoxDecoration(
                   color: AppColors.bgApp, 
                   borderRadius: BorderRadius.circular(24),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      _buildDayStatusIcon("M", AttendanceStatus.presentAuto),
                      _buildDayStatusIcon("T", AttendanceStatus.presentAuto),
                      _buildDayStatusIcon("W", AttendanceStatus.absent), 
                      _buildDayStatusIcon("T", AttendanceStatus.presentAuto),
                      _buildDayStatusIcon("F", AttendanceStatus.presentAuto),
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
    
    if (status == AttendanceStatus.presentAuto || status == AttendanceStatus.presentManual) {
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


  // --- SYLLABUS VIEW (Restored Card + Linear Content) ---
  Widget _buildSyllabusView() {
    int totalTopics = 0;
    int completedTopics = 0;
    for (var unit in _syllabusUnits) {
       for (var topic in unit["topics"]) {
         totalTopics++;
         if (topic["done"] == true) completedTopics++;
       }
    }
    double progress = totalTopics == 0 ? 0 : completedTopics / totalTopics;
    String percentage = "${(progress * 100).toInt()}%";

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 1. Progress Card Restored (Container) but with Linear Content
        FadeSlideTransition(
          index: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pastelGreen, // Green for tab
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
                    Text(percentage, style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.green[900])), // All Green
                  ],
                ),
                const SizedBox(height: 20),
                // Linear Progress on Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Colors.white,
                    color: Colors.green, // All Green
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
            if (_isCustom)
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Edit/Import Syllabus — Coming Soon!")),
                  );
                },
                icon: const Icon(Ionicons.create_outline, size: 18),
                label: const Text("Edit / Import"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              )
          ],
        ),
        const SizedBox(height: 16),
        
        // 2. Units Accordion List
        ...List.generate(_syllabusUnits.length, (index) {
          final unit = _syllabusUnits[index];
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
                    title: Text(unit["title"], style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 16)),
                    subtitle: Text("${unit['topics'].length} Topics", style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13)),
                    childrenPadding: const EdgeInsets.only(bottom: 16),
                    iconColor: AppColors.textMain,
                    children: (unit["topics"] as List).map<Widget>((topic) {
                      final bool isDone = topic["done"];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        title: Text(
                          topic["name"], 
                          style: GoogleFonts.dmSans(
                            color: isDone ? Colors.grey[400] : AppColors.textMain,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: _buildCustomCheckbox(isDone, () {
                             setState(() {
                               topic["done"] = !isDone; 
                             });
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
                        _buildDetailRow("Instructor", "Dr. Smith"),
                        const SizedBox(height: 12),
                        _buildDetailRow("Total Classes", "$totalClasses (Fixed)"),
                         const SizedBox(height: 12),
                         // Tag
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                               child: Text("University Catalog", style: GoogleFonts.dmSans(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                             ),
                           ],
                         ),
                         const SizedBox(height: 24),
                         
                         // Schedule (Read-Only Logic)
                         Text("Class Schedule", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                         const SizedBox(height: 12),
                         ..._globalScheduleSlots.asMap().entries.map((entry) {
                           Map<String, String?> slot = entry.value;
                           return Container(
                             margin: const EdgeInsets.only(bottom: 8),
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: Colors.grey[200]!)
                             ),
                             child: Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                   decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                                   child: Text(slot['day']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                        Text("${slot['time']} @ ${slot['defaultLoc']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        // Display current binding if any, but no edit button
                                        if (slot['location'] != null || slot['wifi'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "Bound: ${slot['location'] ?? ''} ${slot['wifi'] ?? ''}".trim(), 
                                              style: GoogleFonts.dmSans(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.bold)
                                            ),
                                          )
                                        else 
                                           Text("No custom binding", style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey)),
                                     ],
                                   )
                                 ),
                               ],
                             ),
                           );
                         }).toList(),
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
                      _buildDetailRow("Class Section", _currentSection), 
                      const Divider(height: 24),
                      _buildDetailRow("Target Attendance", "${_targetAttendance.toInt()}%"),
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
                      _buildDetailRow("Card Color", _selectedColor),
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
  
  Widget _buildColorOption(Color color, String label) {
    bool isSelected = _selectedColor == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = label),
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Center(
           child: Container(
             width: 24, height: 24,
             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
             child: isSelected ? const Icon(Ionicons.checkmark, size: 16, color: Colors.white) : null,
           ),
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
        final String workType = task['work_type'];
        
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
                              Text(task['title'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              const SizedBox(height: 12),
                              
                              // Footer: Unique Elements based on work_type
                              if (workType == 'ASSIGNMENT')
                                _buildIconText(Ionicons.time_outline, "Due ${task['due_at']}"),
                                
                              if (workType == 'QUIZ')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconText(Ionicons.calendar_outline, "${task['start_at']} - ${task['due_at']}"),
                                    const SizedBox(height: 4),
                                    _buildIconText(Ionicons.hourglass_outline, "Duration: ${task['duration_minutes']} mins"),
                                  ],
                                ),
                                
                              if (workType == 'EXAM')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconText(Ionicons.calendar, task['start_at']),
                                    const SizedBox(height: 4),
                                    _buildIconText(Ionicons.location_outline, "Venue: ${task['venue']}"),
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

  // --- Slot Editing Logic ---
  void _editSlot(int index) {
    Map<String, String?> slot = _scheduleSlots[index];
    String? tempLocation = slot['location'];
    String? tempWifi = slot['wifi']; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Edit Slot Binding", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("${slot['day']} ${slot['time']}", style: GoogleFonts.dmSans(color: Colors.grey)),
                
                const SizedBox(height: 20),
                const Text("BINDINGS (stored in schedule_bindings.json)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                

                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                           _pickLocationForModal(context, (val) {
                             setModalState(() => tempLocation = val);
                           });
                        },
                        icon: Icon(Ionicons.navigate, size: 16, color: tempLocation != null ? Colors.blue : Colors.black),
                        label: Text(tempLocation ?? "Bind GPS", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tempLocation != null ? Colors.blue : Colors.black,
                          side: BorderSide(color: tempLocation != null ? Colors.blue : Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12)
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pickWifiForModal(context, (val) {
                             setModalState(() => tempWifi = val);
                           });
                        },
                        icon: Icon(Ionicons.wifi, size: 16, color: tempWifi != null ? Colors.green : Colors.black),
                        label: Text(tempWifi ?? "Bind Wi-Fi", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tempWifi != null ? Colors.green : Colors.black,
                          side: BorderSide(color: tempWifi != null ? Colors.green : Colors.grey[300]!),
                           padding: const EdgeInsets.symmetric(vertical: 12)
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       setState(() {
                         _scheduleSlots[index]['location'] = tempLocation;
                         _scheduleSlots[index]['wifi'] = tempWifi;
                       });
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("Slot updated${tempLocation != null ? ' (GPS)' : ''}${tempWifi != null ? ' (WiFi)' : ''}"))
                       );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text("Save Slot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        }
      ),
    );
  }

  // Edit bindings for global (catalog) schedule slots
  void _editGlobalSlot(int index) {
    Map<String, String?> slot = _globalScheduleSlots[index];
    String? tempLocation = slot['location'];
    String? tempWifi = slot['wifi']; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Edit Slot Binding", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("${slot['day']} ${slot['time']} @ ${slot['defaultLoc']}", style: GoogleFonts.dmSans(color: Colors.grey)),
                
                const SizedBox(height: 20),
                const Text("BINDINGS (stored in schedule_bindings.json)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                           _pickLocationForModal(context, (val) {
                             setModalState(() => tempLocation = val);
                           });
                        },
                        icon: Icon(Ionicons.navigate, size: 16, color: tempLocation != null ? Colors.blue : Colors.black),
                        label: Text(tempLocation ?? "Bind GPS", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tempLocation != null ? Colors.blue : Colors.black,
                          side: BorderSide(color: tempLocation != null ? Colors.blue : Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12)
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pickWifiForModal(context, (val) {
                             setModalState(() => tempWifi = val);
                           });
                        },
                        icon: Icon(Ionicons.wifi, size: 16, color: tempWifi != null ? Colors.green : Colors.black),
                        label: Text(tempWifi ?? "Bind Wi-Fi", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tempWifi != null ? Colors.green : Colors.black,
                          side: BorderSide(color: tempWifi != null ? Colors.green : Colors.grey[300]!),
                           padding: const EdgeInsets.symmetric(vertical: 12)
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       setState(() {
                         _globalScheduleSlots[index]['location'] = tempLocation;
                         _globalScheduleSlots[index]['wifi'] = tempWifi;
                       });
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("Binding updated${tempLocation != null ? ' (GPS)' : ''}${tempWifi != null ? ' (WiFi)' : ''}"))
                       );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text("Save Binding", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        }
      ),
    );
  }

  void _pickLocationForModal(BuildContext modalContext, Function(String) onPick) {
    showModalBottomSheet(
      context: modalContext, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Set Location Binding", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                 leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: const Icon(Ionicons.location, color: Colors.blue)),
                 title: Text("Use Current Location", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                 subtitle: const Text("Detected: LH-102 (12.934, 77.534)"),
                 onTap: () {
                   onPick("LH-102 (GPS)");
                   Navigator.pop(context);
                 },
              ),
              const Divider(),
              ListTile(
                 leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Ionicons.map, color: Colors.black)),
                 title: Text("Pick on Map", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                 onTap: () {
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Map Picker Mock")));
                 },
              ),
            ],
          ),
        );
      }
    );
  }

  void _pickWifiForModal(BuildContext modalContext, Function(String) onPick) {
    showModalBottomSheet(
      context: modalContext,
      backgroundColor: Colors.white,
       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Select WiFi Binding", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               ListTile(
                  leading: const Icon(Ionicons.wifi, color: Colors.green),
                  title: Text("IIITU_WIFI", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  onTap: () { onPick("IIITU_WIFI"); Navigator.pop(context); },
               ),
               ListTile(
                  leading: const Icon(Ionicons.wifi, color: Colors.orange),
                  title: Text("IIITU_GUEST", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                   onTap: () { onPick("IIITU_GUEST"); Navigator.pop(context); },
               ),
               ListTile(
                  leading: const Icon(Ionicons.wifi, color: Colors.orange),
                  title: Text("ED_ROOM_5G", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                   onTap: () { onPick("ED_ROOM_5G"); Navigator.pop(context); },
               ),
            ],
          ),
        );
      }
    );
  }
}
