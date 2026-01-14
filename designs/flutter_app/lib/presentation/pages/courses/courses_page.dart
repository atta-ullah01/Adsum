import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/course_card.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CoursesPage extends StatefulWidget {
  final bool showWizard;
  const CoursesPage({super.key, this.showWizard = true});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  bool _showSearchResults = false;
  
  // Track which course is being edited. Using a unique ID or index.
  // For simplicity using index + type differentiation
  int? _editingGlobalIndex;
  bool _isEditingCustomCourse = false;
  
  Color _selectedColor = AppColors.pastelPurple;
  
  // Custom Course State
  final List<Map<String, String>> _courseSlots = [
    {'day': 'Mon', 'time': '14:00 - 15:00', 'loc': 'Room 305'},
  ];

  // Global Courses State (Mock)
  final List<Map<String, dynamic>> _globalCourses = [
    {
      'title': 'Compiler Design',
      'code': 'CS3002',
      'startTime': '09:00 AM',
      'endTime': '10:00 AM',
      'location': 'LH-1',
      'instructor': 'Dr. Anetha',
      'color': AppColors.pastelGreen,
      'section': 'A',
      'target': '75',
      'slots': [
        {'day': 'Mon', 'time': '09:00 - 10:00', 'loc': 'LH-1', 'bind_loc': null, 'bind_wifi': null},
        {'day': 'Wed', 'time': '11:00 - 12:00', 'loc': 'LH-1', 'bind_loc': null, 'bind_wifi': null},
      ]
    },
    {
      'title': 'Data Structures',
      'code': 'CS3001',
      'startTime': '10:00 AM',
      'endTime': '11:00 AM',
      'location': 'LH-2',
      'instructor': 'Prof. Raman',
      'color': AppColors.pastelOrange,
      'section': 'B',
      'target': '80',
      'slots': [
        {'day': 'Tue', 'time': '10:00 - 11:00', 'loc': 'LH-2', 'bind_loc': null, 'bind_wifi': 'IIITU_WIFI'},
        {'day': 'Thu', 'time': '14:00 - 15:00', 'loc': 'Lab-3', 'bind_loc': 'My Seat (GPS)', 'bind_wifi': null},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    children: [
                      // Title
                      Text(
                        'My Courses',
                        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_globalCourses.length + 1} courses enrolled',
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
                              _searchItem('Operating Systems', 'CS3001 • Dr. James'),
                              _searchItem('Computer Networks', 'CS3005 • Prof. Kumar'),
                            ],
                          ),
                        ).animate().fadeIn().moveY(begin: 10, end: 0),
                      ],

                      const SizedBox(height: 30),

                      // Timeline - Global Courses
                      ..._globalCourses.asMap().entries.map((entry) {
                         int idx = entry.key;
                         var course = entry.value;
                         bool isEditing = _editingGlobalIndex == idx;
                         
                         return Column(
                           children: [
                             CourseCard(
                               startTime: course['startTime'],
                               endTime: course['endTime'],
                               title: course['title'],
                               location: course['location'],
                               instructor: course['instructor'],
                               color: course['color'],
                               isGlobal: true,
                               onTap: () {
                                   setState(() {
                                     // Toggle edit mode
                                     if (_editingGlobalIndex == idx) {
                                       _editingGlobalIndex = null;
                                     } else {
                                       _editingGlobalIndex = idx;
                                       // Close custom edit if open
                                       _isEditingCustomCourse = false;
                                     }
                                   });
                               },
                             ).animate().slideY(begin: 0.2, end: 0, delay: (100 * (idx + 1)).ms).fadeIn(),
                             
                             // Global Course Edit Panel
                             if (isEditing)
                               _buildGlobalEditPanel(idx, course),
                           ],
                         );
                      }),

                      // Custom Course
                      CourseCard(
                        startTime: '02:00 PM',
                        endTime: '03:00 PM',
                        title: 'My Elective',
                        location: 'Room 305',
                        instructor: 'Self',
                        color: _selectedColor,
                        isCustom: true,
                        onTap: () {
                           setState(() {
                             _isEditingCustomCourse = !_isEditingCustomCourse;
                           });
                        },
                      ).animate().slideY(begin: 0.2, end: 0, delay: 300.ms).fadeIn(),
                      
                      // Edit Panel
                      if (_isEditingCustomCourse)
                        Container(
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
                               _buildFormInput('Course Name', 'My Elective'),
                               const SizedBox(height: 12),
                               _buildFormInput('Course Code *', 'CUST001'),
                               const SizedBox(height: 12),
                               _buildFormInput('Instructor', 'Self'),
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
                               
                               // New Config Fields
                               Row(
                                 children: [
                                   Expanded(child: _buildFormInput('Section', 'A')), // Default from User
                                   const SizedBox(width: 8),
                                   Expanded(child: _buildFormInput('Target %', '75%')),
                                 ],
                               ),
                               const SizedBox(height: 12),

                               const SizedBox(height: 12),
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
                                   Expanded(child: PrimaryButton(text: 'Save', onPressed: () => setState(() => _isEditingCustomCourse = false))),
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
                        ).animate().scaleY(alignment: Alignment.topCenter, duration: 200.ms),

                    ],
                  ),
                ),
              ],
            ),
            
            // Bottom Button (Wizard Only)
            if (widget.showWizard)
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: PrimaryButton(
                  text: 'Confirm & Continue',
                  icon: Ionicons.arrow_forward,
                  onPressed: () {
                    context.push('/sensors');
                  },
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFormInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
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
}
