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
  
  List<Map<String, String>> _courseSlots = [
    {'day': 'Mon', 'time': '14:00 - 15:00', 'loc': 'Room 305'},
  ];

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customCodeCtrl.dispose();
    _customInstructorCtrl.dispose();
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
                              onSubmitted: (_) => setState(() => _showSearchResults = false),
                              decoration: InputDecoration(
                                hintText: 'Search courses...',
                                hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                                prefixIcon: const Icon(Ionicons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                                  GestureDetector(
                                    onTap: () => context.push('/create-custom'),
                                    child: _searchItemProminent(),
                                  ),
                                  // Mock Search Items for now
                                  _searchItem('Operating Systems', 'CS3001 • Dr. James'),
                                  _searchItem('Computer Networks', 'CS3005 • Prof. Kumar'),
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
                                   startTime: 'TBD', // TODO: Get from schedule logic
                                   endTime: 'TBD',
                                   title: course.courseName,
                                   location: 'TBD', // TODO: Fetch from schedule
                                   instructor: 'TBD',
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
                            return CourseCard(
                              startTime: 'Custom',
                              endTime: '',
                              title: course.customCourse?.name ?? 'Custom Course',
                              location: 'Custom',
                              instructor: course.customCourse?.instructor ?? 'Self',
                              color: _parseColor(course.colorTheme),
                              isCustom: true,
                              onTap: () {
                                // TODO: Edit Custom Course
                              },
                            ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn();
                          }),
                                                   // Modifying this block to just call the method
                           if (_isEditingCustomCourse)
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
  Widget _searchItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.pastelBlue, borderRadius: BorderRadius.circular(10)),
            child: const Text('GLOBAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
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
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Class Slot", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildDropdownField('Day of Week', 'Monday', onChanged: (val) {}),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Start', '09:00')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('End', '10:00')),
                ],
              ),
              const SizedBox(height: 12),
              _buildFormInput('Location Name', ''),
              
              const SizedBox(height: 20),
              const Text("BINDINGS (stored in schedule_bindings.json)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pickLocationForSlot(context, (val) {
                          setModalState(() => tempLocation = val);
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
                // Mock: In real app, save slot with bindings to custom_schedules + schedule_bindings
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Slot added${tempLocation != null ? ' with GPS' : ''}${tempWifi != null ? ' + WiFi' : ''}"))
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  
  void _pickLocationForSlot(BuildContext modalContext, Function(String) onPick) {
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
               value: ['A', 'B', 'C', 'D'].contains(value) ? value : 'A', // Simple validation
               isExpanded: true,
               items: ['A', 'B', 'C', 'D'].map((String item) {
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
           // Schedule Builder
           const Text("CLASS SCHEDULE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 8),
           
           ..._courseSlots.map((slot) => Container(
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
                 const Icon(Ionicons.wifi, size: 14, color: Colors.green), // Indicator
                 const SizedBox(width: 8),
                 const Icon(Ionicons.close_circle, color: Colors.red, size: 18),
               ],
             ),
           )),
           
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
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.red),
                   borderRadius: BorderRadius.circular(50),
                 ),
                 child: const Icon(Ionicons.trash, color: Colors.red, size: 20),
               )
             ],
           )
        ],
      ),
    ).animate().scaleY(alignment: Alignment.topCenter, duration: 200.ms);
  }

  Future<void> _saveCustomCourse() async {
    // 1. Create Custom Course Object
    final customCourse = CustomCourse(
      code: _customCodeCtrl.text,
      name: _customNameCtrl.text,
      instructor: _customInstructorCtrl.text,
    );

    // 2. Add via Repository
    try {
      final enrollment = await ref.read(enrollmentRepositoryProvider).addEnrollment(
        customCourse: customCourse,
        colorTheme: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      );
      
      // 3. Add slots to ScheduleRepository
      final scheduleRepo = ref.read(scheduleRepositoryProvider);
      
      for (final slotMap in _courseSlots) {
        final dayStr = slotMap['day']!;
        final timeStr = slotMap['time']!; // "14:00 - 15:00"
        
        DayOfWeek? day;
        switch (dayStr) {
          case 'Mon': day = DayOfWeek.monday; break;
          case 'Tue': day = DayOfWeek.tuesday; break;
          case 'Wed': day = DayOfWeek.wednesday; break;
          case 'Thu': day = DayOfWeek.thursday; break;
          case 'Fri': day = DayOfWeek.friday; break;
          case 'Sat': day = DayOfWeek.saturday; break;
          case 'Sun': day = DayOfWeek.sunday; break;
        }
        
        if (day != null) {
           final parts = timeStr.split(' - ');
           if (parts.length == 2) {
             await scheduleRepo.addCustomSlot(
               enrollmentId: enrollment.enrollmentId,
               dayOfWeek: day,
               startTime: parts[0],
               endTime: parts[1],
             );
           }
        }
      }
      
      setState(() {
        _isEditingCustomCourse = false;
        // Clear form
        _customNameCtrl.clear();
        _customCodeCtrl.clear();
        // Reset slots? _courseSlots is final list defined at top currently. 
        // Ideally should be stateful. For now reset to default or keep it.
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course & Schedule Saved!")));
        // Invalidate provider to refresh list
        ref.invalidate(enrollmentsProvider); // This might be handled by watch stream but safe to invalidate
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildFormInput(String label, String value, {TextEditingController? controller}) {
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
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: value, // Use value as hint if controller is managed elsewhere
            ),
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

  /*
  // --- Global Course Edit Panel ---
  Widget _buildGlobalEditPanel(int index, Map<String, dynamic> course) {
    List<Map<String, dynamic>> slots = course['slots'];
    
    return Container(
      margin: const EdgeInsets.only(left: 90, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Read-only Info
           Row(
             children: [
               Expanded(child: _buildReadOnlyField('Course', course['title'])),
             ],
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(child: _buildReadOnlyField('Code', course['code'])),
               const SizedBox(width: 8),
               Expanded(child: _buildReadOnlyField('Instructor', course['instructor'])),
             ],
           ),

           const SizedBox(height: 16),
           const Text("MY ENROLLMENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
           const SizedBox(height: 12),
           
           // Enrollment Fields (Section, Target)
           Row(
             children: [
               Expanded(
                 child: _buildDropdownField('Section', course['section'] ?? 'A', 
                   onChanged: (val) {
                     setState(() {
                       _globalCourses[index]['section'] = val;
                     });
                   }
                 )
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: _buildEditableField('Target %', course['target'] ?? '75', 
                   onChanged: (val) {
                     // In real app, validate and save
                     setState(() {
                       _globalCourses[index]['target'] = val;
                     });
                   }
                 )
               ),
             ],
           ),
           
           const SizedBox(height: 16),
           const Text("MY BINDINGS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
           const SizedBox(height: 4),
           const Text("Customize detection per slot. Global settings apply otherwise.", style: TextStyle(fontSize: 10, color: Colors.grey)),
           const SizedBox(height: 12),
           
           // Warning for Global courses
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.2))),
             child: const Row(
               children: [
                 Icon(Ionicons.information_circle, size: 16, color: Colors.blue),
                 SizedBox(width: 8),
                 Expanded(child: Text("You can only modify bindings for global courses, not the schedule itself.", style: TextStyle(fontSize: 11, color: Colors.blue))),
               ],
             ),
           ),
           const SizedBox(height: 12),

           // Schedule Slots with Bindings
           ...slots.asMap().entries.map((entry) {
             int sIdx = entry.key;
             var slot = entry.value;
             String? locBind = slot['bind_loc'];
             String? wifiBind = slot['bind_wifi'];

             return Container(
               margin: const EdgeInsets.only(bottom: 8),
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[200]!)
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                         child: Text(slot['day'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                       ),
                       const SizedBox(width: 12),
                       Text(slot['time'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                       const Spacer(),
                       Text(slot['loc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                     ],
                   ),
                   const Divider(height: 20),
                   // Binding Buttons
                   Row(
                     children: [
                       Expanded(
                         child: InkWell(
                           onTap: () {
                             _pickLocationForSlot(context, (val) {
                               setState(() {
                                 _globalCourses[index]['slots'][sIdx]['bind_loc'] = val;
                               });
                             });
                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                             decoration: BoxDecoration(
                               color: locBind != null ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                               border: Border.all(color: locBind != null ? Colors.blue : Colors.grey[300]!),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Ionicons.navigate, size: 12, color: locBind != null ? Colors.blue : Colors.grey),
                                 const SizedBox(width: 6),
                                 Flexible(child: Text(locBind ?? "Bind GPS", style: TextStyle(fontSize: 11, color: locBind != null ? Colors.blue : Colors.grey[700], overflow: TextOverflow.ellipsis))),
                               ],
                             ),
                           ),
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: InkWell(
                           onTap: () {
                             _pickWifiForSlot(context, (val) {
                               setState(() {
                                 _globalCourses[index]['slots'][sIdx]['bind_wifi'] = val;
                               });
                             });
                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                             decoration: BoxDecoration(
                               color: wifiBind != null ? Colors.green.withOpacity(0.1) : Colors.transparent,
                               border: Border.all(color: wifiBind != null ? Colors.green : Colors.grey[300]!),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Ionicons.wifi, size: 12, color: wifiBind != null ? Colors.green : Colors.grey),
                                 const SizedBox(width: 6),
                                 Flexible(child: Text(wifiBind ?? "Bind WiFi", style: TextStyle(fontSize: 11, color: wifiBind != null ? Colors.green : Colors.grey[700], overflow: TextOverflow.ellipsis))),
                               ],
                             ),
                           ),
                         ),
                       ),
                     ],
                   )
                 ],
               ),
             );
           }),

           const SizedBox(height: 16),
            const Text('Card Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _colorOptionForGlobal(index, AppColors.pastelGreen),
                const SizedBox(width: 8),
                _colorOptionForGlobal(index, AppColors.pastelPurple),
                const SizedBox(width: 8),
                _colorOptionForGlobal(index, AppColors.pastelOrange),
                const SizedBox(width: 8),
                _colorOptionForGlobal(index, AppColors.pastelBlue),
                const SizedBox(width: 8),
                _colorOptionForGlobal(index, const Color(0xFFFCE7F3)), // Pink
              ],
            ),
           const SizedBox(height: 16),

           Row(
             children: [
               Expanded(child: PrimaryButton(text: 'Save Changes', onPressed: () => setState(() => _editingGlobalIndex = null))),
               const SizedBox(width: 10),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.red),
                   borderRadius: BorderRadius.circular(50),
                 ),
                 child: const Icon(Ionicons.trash, color: Colors.red, size: 20),
               )
             ],
           )
        ],
      ),
    ).animate().scaleY(alignment: Alignment.topCenter, duration: 200.ms);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          child: Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        )
      ],
    );
  }

  Widget _buildEditableField(String label, String value, {required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), // Tighter padding for text field
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
             decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

    Widget _colorOptionForGlobal(int index, Color color) {
    bool isSelected = _globalCourses[index]['color'] == color;
    return GestureDetector(
      onTap: () => setState(() => _globalCourses[index]['color'] = color),
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
    // We'll use local state controllers/variables initialized in build or initState if possible, 
    // but here we might need to rely on the passed enrollment and update it via a copy.
    // However, for simplicity in this "placeholder" phase, let's just show editable fields that directly update a pending state object or use controllers.
    
    // Since this is inside a ListView builder, using controllers is tricky without a separate widget.
    // But since only ONE panel is open at a time (_editingGlobalIndex), we can perhaps just use standard Inputs.
    
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
            // ROI Read-only
            _buildReadOnlyField('Course Code', enrollment.courseCode ?? 'N/A'),
            const SizedBox(height: 12),
            
            // Editable Section
            _buildActionInput('Section', enrollment.section, (val) async {
               // Immediate update for single fields or batch? 
               // Let's do batch on Save.
               // We need a local state variable for the "editing" enrollment.
               // For now, let's just implement immediate update for simplicity or unimplemented warning.
            }),
            const SizedBox(height: 12),

            // Read-Only Warning
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8), 
                  border: Border.all(color: Colors.blue.withOpacity(0.2))
              ),
              child: const Row(
                children: [
                  Icon(Ionicons.information_circle, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(child: Text("Schedule/Bindings for global courses are managed via the detailed view.", style: TextStyle(fontSize: 11, color: Colors.blue))),
                ],
              ),
            ),
             const SizedBox(height: 12),
             
             // Target Attendance
            Text('Target Attendance: ${enrollment.targetAttendance.toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Slider(
              value: enrollment.targetAttendance,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${enrollment.targetAttendance.toInt()}%',
              onChanged: (val) {
                 // Update provider immediately? 
                 // Better to have a 'Save' button pattern. 
                 // But for now, let's keep it simple.
                 // We will need a `_pendingEdits` map or similar if we want to support editing without saving immediately.
                 // Given the constraints, let's make this read-only/placeholder or simple direct update.
              },
              onChangeEnd: (val) {
                 final updated = enrollment.copyWith(targetAttendance: val);
                 ref.read(enrollmentRepositoryProvider).updateEnrollment(updated);
                 ref.invalidate(enrollmentsProvider);
              },
            ),

            const SizedBox(height: 16),
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
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: PrimaryButton(
                  text: 'Close', 
                  onPressed: () => setState(() => _editingEnrollmentId = null)
                )),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await ref.read(enrollmentRepositoryProvider).deleteEnrollment(enrollment.enrollmentId);
                    ref.invalidate(enrollmentsProvider);
                    setState(() => _editingEnrollmentId = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Ionicons.trash, color: Colors.red, size: 20),
                  ),
                )
              ],
            )
        ],
      )
    ).animate().scaleY(alignment: Alignment.topCenter, duration: 200.ms);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          child: Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        )
      ],
    );
  }

  Widget _buildActionInput(String label, String value, Function(String) onChanged) {
    // Simplified for now, just header + text
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
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), 
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
