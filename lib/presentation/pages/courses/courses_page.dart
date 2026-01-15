import 'dart:async';
import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/course_card.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CoursesPage extends ConsumerStatefulWidget {
  final bool showWizard;
  const CoursesPage({super.key, this.showWizard = true});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  bool _showSearchResults = false;
  
  // Track which course is being edited using ID
  String? _editingEnrollmentId;
  bool _isEditingCustomCourse = false;
  
  Color _selectedColor = AppColors.pastelPurple;
  
  // Form State for new custom course
  final TextEditingController _customNameCtrl = TextEditingController(text: 'My Elective');
  final TextEditingController _customCodeCtrl = TextEditingController(text: 'CUST001');
  final TextEditingController _customInstructorCtrl = TextEditingController(text: 'Self');
  final TextEditingController _customSectionCtrl = TextEditingController(text: 'A');
  final TextEditingController _customTargetAttendanceCtrl = TextEditingController(text: '75');
  final TextEditingController _customTotalExpectedCtrl = TextEditingController(text: '30');
  DateTime _startDate = DateTime.now();
  
  List<Map<String, dynamic>> _courseSlots = [
    {'day': 'Mon', 'time': '14:00 - 15:00', 'loc': 'Room 305', 'wifi': null, 'gps_lat': null, 'gps_long': null},
  ];

  // Search State
  List<Course> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    // Get user's university ID
    final userAsync = ref.read(userProfileProvider);
    final universityId = userAsync.value?.universityId ?? 'iit_delhi'; // Fallback for dev
    
    debugPrint('[SEARCH DEBUG] Query: "$query", University ID: "$universityId"');
    
    final results = await ref.read(sharedDataRepositoryProvider).searchCourses(universityId, query);
    debugPrint('[SEARCH DEBUG] Found ${results.length} results');
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _showSearchResults = true;
      });
    }
  }

  Future<void> _enrollInCourse(Course course, List<Enrollment> existing) async {
    final isEnrolled = existing.any((e) => e.effectiveCourseCode == course.courseCode);
    
    if (isEnrolled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Already enrolled in ${course.name}")));
      return;
    }

    // Show enrollment modal
    _showEnrollmentModal(course);
  }

  void _showEnrollmentModal(Course course) {
    String section = 'A';
    double targetAttendance = 75.0;
    Color selectedColor = AppColors.pastelPurple;
    
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
                Text("Enroll in ${course.name}", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(course.courseCode, style: GoogleFonts.dmSans(color: Colors.grey)),
                const SizedBox(height: 20),
                
                // Section
                Text("SECTION", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                Text("TARGET ATTENDANCE %", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Slider(
                  value: targetAttendance,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  label: "${targetAttendance.toInt()}%",
                  onChanged: (val) => setModalState(() => targetAttendance = val),
                ),
                Center(child: Text("${targetAttendance.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold))),
                
                const SizedBox(height: 16),
                
                // Semester Start (Read-Only for Global)
                _buildReadOnlyField("Semester Start", "Jan 6, 2026 (University Calendar)"),
                
                const SizedBox(height: 16),
                
                // Color
                Text("CARD COLOR", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  text: "Confirm Enrollment",
                  onPressed: () async {
                    final colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';
                    final result = await ref.read(enrollmentRepositoryProvider).addEnrollment(
                      courseCode: course.courseCode,
                      catalogInstructor: course.instructor,
                      section: section,
                      targetAttendance: targetAttendance,
                      colorTheme: colorHex,
                    );
                    
                    if (result == null && mounted) {
                      // Duplicate enrollment
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Already enrolled in ${course.name} (Section $section)"), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    ref.invalidate(enrollmentsProvider);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enrolled in ${course.name} 🎉")));
                      setState(() {
                        _showSearchResults = false;
                        _searchResults = [];
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

  Widget _modalColorOption(Color color, Color selected, Function(Color) onTap) {
    final isSelected = color.value == selected.value;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: isSelected ? const Icon(Icons.check, size: 16) : null,
      ),
    );
  }

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customCodeCtrl.dispose();
    _customInstructorCtrl.dispose();
    _customSectionCtrl.dispose();
    _customTargetAttendanceCtrl.dispose();
    _customTotalExpectedCtrl.dispose();
    super.dispose();
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
            if (_showSearchResults) setState(() => _showSearchResults = false);
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
                         Text("Manage Courses", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              onTap: () => setState(() => _showSearchResults = true),
                              onChanged: _onSearchChanged,
                              onSubmitted: _performSearch,
                              decoration: InputDecoration(
                                hintText: 'Search by Course Code (e.g. CS101)...',
                                hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                                prefixIcon: const Icon(Ionicons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                suffixIcon: _isSearching 
                                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) 
                                    : null,
                              ),
                            ),
                          ),
                          
                          // Search Results
                          if (_showSearchResults) ...[
                            const SizedBox(height: 10),
                             Container(
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(16),
                                 boxShadow: [
                                   BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
                                 ],
                               ),
                               child: Column(
                                 children: [
                                   // Always show option to create custom course
                                   GestureDetector(
                                     onTap: () {
                                       setState(() {
                                         // Close search, reset form, show creation mode
                                         _showSearchResults = false;
                                         _searchResults = [];
                                         _editingEnrollmentId = null; // null = creating new
                                         _isEditingCustomCourse = true;
                                         
                                         // Reset form to defaults
                                         _customNameCtrl.text = 'My Elective';
                                         _customCodeCtrl.text = 'CUST001';
                                         _customInstructorCtrl.text = 'Self';
                                         _customSectionCtrl.text = 'A';
                                         _customTargetAttendanceCtrl.text = '75';
                                         _customTotalExpectedCtrl.text = '30';
                                         _selectedColor = AppColors.pastelPurple;
                                         _startDate = DateTime.now();
                                         _courseSlots = [{'day': 'Mon', 'time': '14:00 - 15:00', 'loc': 'Room 305', 'wifi': null, 'gps_lat': null, 'gps_long': null}];
                                       });
                                     },
                                     child: _searchItemProminent(),
                                   ),

                                   if (_searchResults.isEmpty && !_isSearching)
                                     Padding(
                                       padding: const EdgeInsets.all(16),
                                       child: Text("No other courses found.", style: GoogleFonts.dmSans(color: Colors.grey)),
                                     ),

                                   ..._searchResults.map((course) => GestureDetector(
                                     onTap: () => _enrollInCourse(course, enrollments),
                                     child: _searchItem(
                                       course.name, 
                                       '${course.courseCode} • ${course.instructor}',
                                       isEnrolled: enrollments.any((e) => e.effectiveCourseCode == course.courseCode)
                                     ),
                                   )),
                                 ],
                               ),
                             ).animate().fadeIn().moveY(begin: 10, end: 0),
                          ],

                          const SizedBox(height: 30),

                          if (enrollments.isEmpty)
                            const Center(child: Text("No courses added yet. Search above!")),

                          // Timeline - Global Courses
                          ...globalEnrollments.map((course) {
                             bool isEditing = _editingEnrollmentId == course.enrollmentId;
                             
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
                                    // Toggle on (Populate form)
                                    _editingEnrollmentId = course.enrollmentId;
                                    _isEditingCustomCourse = true;
                                    _customNameCtrl.text = course.customCourse?.name ?? '';
                                    _customCodeCtrl.text = course.customCourse?.code ?? '';
                                    _customInstructorCtrl.text = course.customCourse?.instructor ?? '';
                                    _customSectionCtrl.text = course.section;
                                    _customTargetAttendanceCtrl.text = course.targetAttendance.toString();
                                    _customTotalExpectedCtrl.text = (course.customCourse?.totalExpected ?? 30).toString();
                                    _selectedColor = _parseColor(course.colorTheme);
                                    _startDate = course.startDate;
                                  }
                                });
                              },
                            ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),
                            
                            if (_isEditingCustomCourse && _editingEnrollmentId == course.enrollmentId)
                              _buildCustomCourseForm(),
                             ],
                            );
                          }),
                          
                          // Show inline form for CREATING new custom course (when _editingEnrollmentId is null)
                          if (_isEditingCustomCourse && _editingEnrollmentId == null)
                            _buildCustomCourseForm(),
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
  Widget _searchItem(String title, String subtitle, {bool isEnrolled = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEnrolled ? Colors.green[50] : AppColors.pastelBlue, 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              isEnrolled ? 'ENROLLED' : 'GLOBAL', 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: isEnrolled ? Colors.green : Colors.blue
              )
            ),
          ),
        ],
      )
    );
  }

  Widget _searchItemProminent() {
     return Container(
       margin: const EdgeInsets.all(8),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: AppColors.pastelYellow,
         borderRadius: BorderRadius.circular(12),
       ),
       child: Row(
         children: [
           Container(
             width: 32, height: 32,
             decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
             child: const Icon(Ionicons.add, size: 20),
           ),
           const SizedBox(width: 12),
           const Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Create Custom Course', style: TextStyle(fontWeight: FontWeight.bold)),
               Text('Can\'t find it? Add your own.', style: TextStyle(fontSize: 12, color: Colors.black54)),
             ],
           )
         ],
       ),
     );
  }
  void _showAddSlotModal() {
    String? tempLocation;
    String? tempWifi;
    double? tempLat;
    double? tempLong;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        String selectedDay = 'Mon';
        TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
        TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
        final TextEditingController locCtrl = TextEditingController(text: tempLocation ?? 'Classroom');
        
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Class Slot", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                _buildDropdownField('Day of Week', selectedDay, onChanged: (val) {
                  if (val != null) setModalState(() => selectedDay = val);
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: () async {
                         final picked = await showTimePicker(context: context, initialTime: startTime);
                         if (picked != null) setModalState(() => startTime = picked);
                      },
                      child: _buildTimePicker('Start', startTime.format(context))
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: GestureDetector(
                      onTap: () async {
                         final picked = await showTimePicker(context: context, initialTime: endTime);
                         if (picked != null) setModalState(() => endTime = picked);
                      },
                      child: _buildTimePicker('End', endTime.format(context))
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormInput('Location Name', '', controller: locCtrl),
                
                const SizedBox(height: 20),
                const Text("BINDINGS (stored in schedule_bindings.json)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pickLocationForSlot(context, (name, lat, long) {
                            setModalState(() {
                               tempLocation = name;
                               tempLat = lat;
                               tempLong = long;
                               locCtrl.text = name; 
                            });
                          });
                        },
                        icon: Icon(Ionicons.navigate, size: 16, color: tempLocation != null ? Colors.blue : Colors.black),
                        label: Text(tempLocation ?? "Bind GPS", style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
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
                          _pickWifiForSlot(context, (val) {
                            setModalState(() => tempWifi = val);
                          });
                        },
                        icon: Icon(Ionicons.wifi, size: 16, color: tempWifi != null ? Colors.green : Colors.black),
                        label: Text(tempWifi ?? "Bind Wi-Fi", style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
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
                PrimaryButton(text: "Add Slot", onPressed: () {
                  // Add to liststate
                  setState(() {
                    _courseSlots.add({
                      'day': selectedDay, 
                      // Format manually to ensure HH:mm consistency if needed, or use context format
                      'time': '${startTime.format(context)} - ${endTime.format(context)}', 
                      'loc': locCtrl.text.isNotEmpty ? locCtrl.text : 'Classroom',
                      'wifi': tempWifi,
                      'gps_lat': tempLat,
                      'gps_long': tempLong
                    });
                  });
 
                  Navigator.pop(context);
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _pickLocationForSlot(BuildContext modalContext, Function(String name, double? lat, double? long) onPick) {
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
                     onPick("LH-102 (GPS)", 12.934, 77.534);
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

  void _pickWifiForSlot(BuildContext modalContext, Function(String) onPick) {
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

  Widget _buildDropdownField(String label, String value, {ValueChanged<String?>? onChanged}) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
         const SizedBox(height: 4),
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // Adjusted padding to match text field
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: Colors.grey[300]!) // Match border style
           ),
           child: DropdownButtonHideUnderline(
             child: DropdownButton<String>(
               value: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].contains(value) ? value : 'Mon',
               isExpanded: true,
               items: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((String item) {
                 return DropdownMenuItem<String>(
                   value: item,
                   child: Text(item),
                 );
               }).toList(),
               onChanged: onChanged,
               style: const TextStyle(color: Colors.black, fontSize: 14),
             ),
           ),
         ),
       ],
     );
  }

  Widget _buildTimePicker(String label, String time) {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
       decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(12)),
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(time), const Icon(Ionicons.time_outline, size: 16)]),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 4),
           Container(
             width: double.infinity,
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.grey[300]!)
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("${date.day}/${date.month}/${date.year}", style: const TextStyle(fontSize: 16)),
                 const Icon(Ionicons.calendar_outline, size: 18, color: Colors.grey)
               ],
             ),
           ),
        ],
      ),
    );
  }

  // --- Custom Course Form ---
  Widget _buildCustomCourseForm() {
    return Container(
      margin: const EdgeInsets.only(left: 90, bottom: 20), // Align with card column
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildFormInput('Course Name', 'My Elective', controller: _customNameCtrl),
           const SizedBox(height: 12),
           _buildFormInput('Course Code *', 'CUST001', controller: _customCodeCtrl),
           const SizedBox(height: 12),
           _buildFormInput('Instructor', 'Self', controller: _customInstructorCtrl),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(child: _buildFormInput('Section', 'A', controller: _customSectionCtrl)),
               const SizedBox(width: 12),
               Expanded(child: _buildFormInput('Target %', '75', controller: _customTargetAttendanceCtrl, keyboardType: TextInputType.number)),
             ],
           ),
           const SizedBox(height: 12),
           _buildFormInput('Total Expected Classes', '30', controller: _customTotalExpectedCtrl, keyboardType: TextInputType.number),
           const SizedBox(height: 12),
           _buildDatePicker('Start Date', _startDate, onTap: () async {
             final picked = await showDatePicker(
               context: context,
               initialDate: _startDate,
               firstDate: DateTime(2024),
               lastDate: DateTime(2030),
             );
             if (picked != null) setState(() => _startDate = picked);
           }),
           const SizedBox(height: 12),
           // Schedule Builder
           const Text("CLASS SCHEDULE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 8),
           
           ..._courseSlots.asMap().entries.map((entry) {
             final index = entry.key;
             final slot = entry.value;
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
                          Text(slot['time']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(slot['loc']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                       ],
                     )
                   ),
                   if (slot['wifi'] != null) ...[
                     const Icon(Ionicons.wifi, size: 14, color: Colors.green),
                     const SizedBox(width: 8),
                   ],
                   GestureDetector(
                     onTap: () {
                        setState(() {
                          _courseSlots.removeAt(index);
                        });
                     },
                     child: const Icon(Ionicons.close_circle, color: Colors.red, size: 18)
                   ),
                 ],
               ),
             );
           }).toList(),
           
           GestureDetector(
             onTap: _showAddSlotModal,
             child: Container(
               padding: const EdgeInsets.symmetric(vertical: 10),
               decoration: BoxDecoration(
                 border: Border.all(color: AppColors.textMain, style: BorderStyle.solid),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Center(child: Text("+ Add Slot", style: TextStyle(fontWeight: FontWeight.bold))),
             ),
           ),

           const SizedBox(height: 16),
           
           const Text('Card Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 8),
           Row(
             children: [
               _colorOption(AppColors.pastelGreen),
               const SizedBox(width: 8),
               _colorOption(AppColors.pastelPurple),
               const SizedBox(width: 8),
               _colorOption(AppColors.pastelOrange),
               const SizedBox(width: 8),
               _colorOption(AppColors.pastelBlue),
               const SizedBox(width: 8),
               _colorOption(const Color(0xFFFCE7F3)), // Pink
             ],
           ),
           const SizedBox(height: 16),
           Row(
             children: [
               Expanded(
                 child: PrimaryButton(
                   text: 'Save Course', 
                   onPressed: _saveCustomCourse,
                 ),
               ),
               const SizedBox(width: 10),
               Container(
                 width: 44, height: 44,
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.red),
                   borderRadius: BorderRadius.circular(50),
                 ),
                 child: IconButton(
                    icon: const Icon(Ionicons.trash, color: Colors.red, size: 20),
                    onPressed: _deleteCustomCourse,
                 ),
               )
             ],
           )
        ],
      ),
    ).animate().scaleY(alignment: Alignment.topCenter, duration: 200.ms);
  }

  Future<void> _saveCustomCourse() async {
    final customCourse = CustomCourse(
      code: _customCodeCtrl.text,
      name: _customNameCtrl.text,
      instructor: _customInstructorCtrl.text,
      totalExpected: int.tryParse(_customTotalExpectedCtrl.text) ?? 30,
    );
    final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';

    try {
      if (_editingEnrollmentId != null) {
        // UPDATE EXISTING
        final repo = ref.read(enrollmentRepositoryProvider);
        final existing = await repo.getEnrollment(_editingEnrollmentId!);
        
        if (existing != null) {
          final updated = existing.copyWith(
            customCourse: customCourse,
            colorTheme: colorHex,
            section: _customSectionCtrl.text,
            targetAttendance: double.tryParse(_customTargetAttendanceCtrl.text) ?? 75.0,
            startDate: _startDate,
          );
          await repo.updateEnrollment(updated);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Updated!")));
        }
      } else {
        // CREATE NEW
        final enrollment = await ref.read(enrollmentRepositoryProvider).addEnrollment(
          customCourse: customCourse,
          colorTheme: colorHex,
          section: _customSectionCtrl.text,
          targetAttendance: double.tryParse(_customTargetAttendanceCtrl.text) ?? 75.0,
          startDate: _startDate,
        );
        
        if (enrollment == null) {
          // Duplicate course
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Course '${customCourse.code}' already exists in Section ${_customSectionCtrl.text}"), backgroundColor: Colors.red),
          );
          return;
        }
        
        // Add slots (Only for new courses for now, as editing slots is complex)
        final scheduleRepo = ref.read(scheduleRepositoryProvider);
        for (final slotMap in _courseSlots) {
          final dayStr = slotMap['day']!;
          final timeStr = slotMap['time']!;
          
          DayOfWeek? day;
          switch (dayStr) {
            case 'Mon': case 'Monday': day = DayOfWeek.mon; break;
            case 'Tue': case 'Tuesday': day = DayOfWeek.tue; break;
            case 'Wed': case 'Wednesday': day = DayOfWeek.wed; break;
            case 'Thu': case 'Thursday': day = DayOfWeek.thu; break;
            case 'Fri': case 'Friday': day = DayOfWeek.fri; break;
            case 'Sat': case 'Saturday': day = DayOfWeek.sat; break;
            case 'Sun': case 'Sunday': day = DayOfWeek.sun; break;
          }
          
          if (day != null) {
             final parts = timeStr.split(' - ');
             if (parts.length == 2) {
               final savedSlot = await scheduleRepo.addCustomSlot(
                 enrollmentId: enrollment.enrollmentId,
                 dayOfWeek: day,
                 startTime: parts[0],
                 endTime: parts[1],
               );

               // Save Bindings if any
               if (slotMap['gps_lat'] != null || slotMap['wifi'] != null) {
                  await scheduleRepo.addBinding(
                    userId: 'current_user',
                    ruleId: savedSlot.ruleId,
                    scheduleType: ScheduleType.custom,
                    locationName: slotMap['loc'] as String?,
                    locationLat: slotMap['gps_lat'] as double?,
                    locationLong: slotMap['gps_long'] as double?,
                    wifiSsid: slotMap['wifi'] as String?,
                  );
               }

               if (slotMap['wifi'] != null) {
                  await scheduleRepo.addBinding(
                    userId: 'user_001',
                    ruleId: savedSlot.ruleId,
                    scheduleType: ScheduleType.custom,
                    wifiSsid: slotMap['wifi'],
                  );
               }
             }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Created!")));
      }
      
      setState(() {
        _isEditingCustomCourse = false;
        _editingEnrollmentId = null;
        _customNameCtrl.clear();
        _customCodeCtrl.clear();
        _customInstructorCtrl.clear();
      });
      ref.invalidate(enrollmentsProvider);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteCustomCourse() async {
    // If creating a new course (id is null), "Delete" just means Cancel
    if (_editingEnrollmentId == null) {
       setState(() {
         _isEditingCustomCourse = false;
         _customNameCtrl.clear();
         _customCodeCtrl.clear();
         _customInstructorCtrl.clear();
         _customSectionCtrl.clear();
         _customTargetAttendanceCtrl.clear();
         _customTotalExpectedCtrl.clear();
         _courseSlots = []; // Reset slots
       });
       return;
    }
    
    // Confirm Dialog for existing course
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Course?"), 
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ]
      )
    );

    if (confirm == true) {
      await ref.read(enrollmentRepositoryProvider).deleteEnrollment(_editingEnrollmentId!);
      ref.invalidate(enrollmentsProvider);
      setState(() {
         _isEditingCustomCourse = false;
         _editingEnrollmentId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Deleted")));
    }
  }

  Widget _buildFormInput(String label, String value, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller, // Use controller if provided
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: value, // Use value as hint if controller is managed elsewhere
              counterText: "", // Hide default counter
            ),
            maxLength: keyboardType == TextInputType.number ? 3 : null,
            style: const TextStyle(fontSize: 14),
          ),
        )
      ],
    );
  }
  
  Widget _colorOption(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  // --- Global Course Edit Panel ---

  Widget _buildGlobalEditPanel(Enrollment enrollment) {
    return Container(
      margin: const EdgeInsets.only(left: 90, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header Info (Read Only)
            _buildReadOnlyField('Course Name', enrollment.courseName),
            const SizedBox(height: 12),
            _buildReadOnlyField('Course Code', enrollment.courseCode ?? 'N/A'),
            const SizedBox(height: 12),
            _buildReadOnlyField('Instructor', enrollment.instructor ?? 'TBD'),
             const SizedBox(height: 12),
            
            // Editable: Section
            Row(
              children: [
                Expanded(child: _buildActionInput('Section', enrollment.section, (val) {
                   // Logic to handle update (e.g. via controller or direct repo update)
                   // Since we need to save, we might need a controller or a "Save" button for the whole form.
                   // For now, let's just make it look like the Custom form's input.
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildActionInput('Target %', enrollment.targetAttendance.toInt().toString(), (val) async {
                   final newTarget = double.tryParse(val);
                   if (newTarget != null) {
                      final updated = enrollment.copyWith(targetAttendance: newTarget);
                      await ref.read(enrollmentRepositoryProvider).updateEnrollment(updated);
                      ref.invalidate(enrollmentsProvider);
                   }
                }, keyboardType: TextInputType.number)),
              ],
            ),
             const SizedBox(height: 12),

             // Read-only: Start Date
            _buildReadOnlyField('Semester Start', 'Jan 6, 2026 (University Calendar)'),
            const SizedBox(height: 12),
            
            // Slots (Read Only / Bindable)
            const Text("SCHEDULE (Global - Fixed)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            
            // Mock Slots List
            ...['Mon 10:00 - 11:00 (LH 101)', 'Wed 11:00 - 12:00 (LH 101)', 'Fri 09:00 - 10:00 (LH 101)'].map((slotStr) {
               return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
                child: Column(
                  children: [
                    Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(children: [
                            const Icon(Ionicons.calendar, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(slotStr, style: const TextStyle(fontSize: 13)),
                         ]),
                       ],
                    ),
                    const SizedBox(height: 8),
                    // Bind Buttons Row
                    Row(
                      children: [
                         Expanded(
                           child: GestureDetector(
                             onTap: () {
                                _pickLocationForSlot(context, (name, lat, long) {
                                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GPS Bound to Slot! (Mock)")));
                                });
                             },
                             child: Container(
                               padding: const EdgeInsets.symmetric(vertical: 6),
                               decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                               child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                 Text("Bind GPS", style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                                 SizedBox(width: 4),
                                 Icon(Ionicons.navigate_circle, color: Colors.blue, size: 14)
                               ]), 
                             ),
                           ),
                         ),
                         const SizedBox(width: 8),
                         Expanded(
                           child: GestureDetector(
                             onTap: () {
                                _pickWifiForSlot(context, (val) {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("WiFi Bound: $val (Mock)")));
                                });
                             },
                             child: Container(
                               padding: const EdgeInsets.symmetric(vertical: 6),
                               decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                               child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                 Text("Bind WiFi", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                 SizedBox(width: 4),
                                 Icon(Ionicons.wifi, color: Colors.green, size: 14)
                               ]), 
                             ),
                           ),
                         ),
                      ],
                    )
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 20),
            
            const Text('Card Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _colorOptionForGlobal(enrollment, AppColors.pastelGreen),
                const SizedBox(width: 8),
                _colorOptionForGlobal(enrollment, AppColors.pastelPurple),
                const SizedBox(width: 8),
                _colorOptionForGlobal(enrollment, AppColors.pastelOrange),
                const SizedBox(width: 8),
                _colorOptionForGlobal(enrollment, AppColors.pastelBlue),
                const SizedBox(width: 8),
                _colorOptionForGlobal(enrollment, const Color(0xFFFCE7F3)), // Pink
              ],
            ),
            const SizedBox(height: 20),

             Row(
               children: [
                 Expanded(
                   child: PrimaryButton(
                     text: 'Close', 
                     onPressed: () {
                        setState(() => _editingEnrollmentId = null);
                     },
                   ),
                 ),
                 const SizedBox(width: 10),
                 Container(
                   width: 44, height: 44,
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.red),
                     borderRadius: BorderRadius.circular(50),
                   ),
                   child: IconButton(
                      icon: const Icon(Ionicons.trash, color: Colors.red, size: 20),
                      onPressed: () {
                         ref.read(enrollmentRepositoryProvider).deleteEnrollment(enrollment.enrollmentId);
                         ref.invalidate(enrollmentsProvider);
                      },
                   ),
                 )
               ],
             )
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildReadOnlyField(String label, String value, {bool isEditable = false}) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
             if (isEditable)
               const Text("EDIT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
           ],
         ),
         const SizedBox(height: 4),
         Container(
           width: double.infinity,
           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
           decoration: BoxDecoration(
             color: isEditable ? Colors.white : Colors.grey[100],
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: isEditable ? Colors.grey[300]! : Colors.transparent)
           ),
           child: Text(
             value,
             style: GoogleFonts.dmSans(
               color: isEditable ? Colors.black : Colors.black54,
               fontWeight: FontWeight.w500,
               fontSize: 14,
             ),
           ),
         ),
       ],
     );
  }
  
  Widget _buildActionInput(String label, String value, Function(String) onChanged, {TextInputType? keyboardType}) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
         const SizedBox(height: 4),
         Container(
           width: double.infinity,
           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: Colors.grey[300]!),
           ),
           child: TextField(
             controller: TextEditingController(text: value),
             keyboardType: keyboardType,
             onSubmitted: onChanged,
             decoration: const InputDecoration(
               border: InputBorder.none,
               isDense: true,
               contentPadding: EdgeInsets.zero,
             ),
             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), 
           ), 
         )
       ],
     );
  }

  Widget _colorOptionForGlobal(Enrollment enrollment, Color color) {
    bool isSelected = _parseColor(enrollment.colorTheme) == color;
    return GestureDetector(
      onTap: () async {
        final hex = '#${color.value.toRadixString(16).substring(2)}';
        final updated = enrollment.copyWith(colorTheme: hex);
        await ref.read(enrollmentRepositoryProvider).updateEnrollment(updated);
        ref.invalidate(enrollmentsProvider); // Refresh UI
      },
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}
