import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/enrollment.dart';
import 'package:adsum/domain/models/schedule.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CreateCustomCoursePage extends ConsumerStatefulWidget {
  const CreateCustomCoursePage({super.key});

  @override
  ConsumerState<CreateCustomCoursePage> createState() => _CreateCustomCoursePageState();
}

class _CreateCustomCoursePageState extends ConsumerState<CreateCustomCoursePage> {
  Color _selectedColor = AppColors.pastelGreen;
  bool _isSaving = false;

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _instructorCtrl;
  late TextEditingController _attendanceCtrl;
  late TextEditingController _sectionCtrl;

  // Schedule State - Storing simple maps for UI, will convert to objects on save
  // Format: { 'day': 'Mon', 'start': '09:00', 'end': '10:00', 'loc': '...', 'wifi': '...', 'lat': double, 'long': double }
  final List<Map<String, dynamic>> _courseSlots = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _codeCtrl = TextEditingController();
    _instructorCtrl = TextEditingController();
    _attendanceCtrl = TextEditingController(text: "75");
    _sectionCtrl = TextEditingController(text: "A");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _instructorCtrl.dispose();
    _attendanceCtrl.dispose();
    _sectionCtrl.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (_nameCtrl.text.isEmpty || _codeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in Name and Code')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final enrollmentRepo = ref.read(enrollmentRepositoryProvider);
      final scheduleRepo = ref.read(scheduleRepositoryProvider);
      final user = ref.read(userProfileProvider).value; // For user ID if needed for bindings

      // 1. Create Enrollment with Custom Course
      final enrollment = await enrollmentRepo.addEnrollment(
        customCourse: CustomCourse(
          code: _codeCtrl.text,
          name: _nameCtrl.text,
          instructor: _instructorCtrl.text.isNotEmpty ? _instructorCtrl.text : 'Self',
        ),
        section: _sectionCtrl.text,
        targetAttendance: double.tryParse(_attendanceCtrl.text) ?? 75.0,
        // Convert color to hex string if needed, currently passing hex fallback
        colorTheme: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      );

      // 2. Add Schedule Slots & Bindings
      for (final slot in _courseSlots) {
        // Add Slot
        final dayEnum = DayOfWeek.fromString(slot['day'] as String);
        final start = slot['start'] as TimeOfDay;
        final end = slot['end'] as TimeOfDay;
        
        final customSlot = await scheduleRepo.addCustomSlot(
          enrollmentId: enrollment.enrollmentId,
          dayOfWeek: dayEnum,
          startTime: "${start.hour}:${start.minute.toString().padLeft(2, '0')}", 
          endTime: "${end.hour}:${end.minute.toString().padLeft(2, '0')}",
        );

        // Add Binding if location or wifi is set
        final hasLoc = slot['lat'] != null && slot['long'] != null;
        final hasWifi = slot['wifi'] != null && (slot['wifi'] as String).isNotEmpty;

        if (hasLoc || hasWifi) {
          await scheduleRepo.addBinding(
            userId: user?.userId ?? 'unknown_user', // Fallback if user not loaded (rare)
            ruleId: customSlot.ruleId,
            scheduleType: ScheduleType.custom,
            locationName: slot['loc'] as String?, // Can be null if only wifi
            locationLat: slot['lat'] as double?,
            locationLong: slot['long'] as double?,
            wifiSsid: slot['wifi'] as String?,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom course created!')));
        context.pop();
       // Trigger refresh if needed
       ref.invalidate(enrollmentsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating course: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  Text(
                    'New Custom Course',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                   _buildFormGroup('Course Name', 'e.g. Graphic Design', _nameCtrl),
                   _buildFormGroup('Course Code *', 'Required (e.g. CUST101)', _codeCtrl),
                   _buildFormGroup('Instructor / Professor', 'e.g. Prof. Sarah', _instructorCtrl),
                   
                   // Schedule Builder
                   Text('CLASS SCHEDULE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                   const SizedBox(height: 8),
                   
                   if (_courseSlots.isEmpty)
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: const Color(0xFFF9FAFB),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.grey[300]!)
                       ),
                       child: const Center(child: Text("No classes scheduled yet.", style: TextStyle(color: Colors.grey))),
                     )
                   else
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
                             child: Text(slot['day'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  Text("${(slot['start'] as TimeOfDay).format(context)} - ${(slot['end'] as TimeOfDay).format(context)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text((slot['loc'] as String?) ?? (slot['wifi'] != null ? 'Wi-Fi Only' : 'No Location'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                               ],
                             )
                           ),
                           if (slot['wifi'] != null) const Icon(Ionicons.wifi, size: 14, color: Colors.green),
                           if (slot['lat'] != null) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Ionicons.location, size: 14, color: Colors.blue)),
                           const SizedBox(width: 8),
                           InkWell(
                             onTap: () => setState(() => _courseSlots.remove(slot)),
                             child: const Icon(Ionicons.close_circle, color: Colors.red, size: 18)
                           ),
                         ],
                       ),
                     )),
                   
                   const SizedBox(height: 12),
                   GestureDetector(
                     onTap: _showAddSlotModal,
                     child: Container(
                       width: double.infinity,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                       decoration: BoxDecoration(
                         border: Border.all(color: AppColors.textMain, style: BorderStyle.solid),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: const Center(child: Text("+ Add Class Slot", style: TextStyle(fontWeight: FontWeight.bold))),
                     ),
                   ),
                   
                   const SizedBox(height: 24),
                   Text('CONFIGURATION', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                       Expanded(child: _buildFormGroup('Target Attendance %', '75', _attendanceCtrl)),
                       const SizedBox(width: 16),
                       Expanded(child: _buildFormGroup('Section', 'A', _sectionCtrl)),
                     ],
                   ),
                   
                   const SizedBox(height: 10),
                   Text('CARD COLOR', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                   const SizedBox(height: 8),
                   SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: [
                         _colorOption(AppColors.pastelGreen),
                         const SizedBox(width: 12),
                         _colorOption(AppColors.pastelPurple),
                         const SizedBox(width: 12),
                         _colorOption(AppColors.pastelOrange),
                         const SizedBox(width: 12),
                         _colorOption(const Color(0xFFE0F2FE)), // Light Blue
                         const SizedBox(width: 12),
                         _colorOption(const Color(0xFFFCE7F3)), // Light Pink
                       ],
                     ),
                   ),
                   const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: PrimaryButton(
                text: _isSaving ? 'Creating...' : 'Create Course',
                onPressed: _isSaving ? () {} : _createCourse,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormGroup(String label, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMain),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.dmSans(color: Colors.black38),
              border: InputBorder.none,
            ), 
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _colorOption(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 44 : 40,
        height: isSelected ? 44 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  // --- Picker Helpers for Modal ---
  void _pickLocationForModal(BuildContext modalContext, Function(String, double, double) onPick) {
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
              Text("Set Location", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                 leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: const Icon(Ionicons.location, color: Colors.blue)),
                 title: Text("Use Current Location", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                 subtitle: Text("Mock: LH-102 (12.934, 77.534)"),
                 onTap: () {
                   onPick("LH-102 (GPS)", 12.934, 77.534); // Mock GPS
                   Navigator.pop(context);
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
               Text("Select WiFi Network", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
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
            ],
          ),
        );
      }
    );
  }

  void _showAddSlotModal() {
    String? tempLocation;
    double? tempLat;
    double? tempLong;
    String? tempWifi;
    
    String selectedDay = 'Monday';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          
          String formatTime(TimeOfDay t) {
            final now = DateTime.now();
            final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
            return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Class Slot", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Day Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDay,
                      isExpanded: true,
                      onChanged: (v) => setModalState(() => selectedDay = v!),
                      items: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                           final t = await showTimePicker(context: context, initialTime: startTime);
                           if (t != null) setModalState(() => startTime = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(formatTime(startTime)), const Icon(Ionicons.time_outline, size: 16)]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                       child: InkWell(
                        onTap: () async {
                           final t = await showTimePicker(context: context, initialTime: endTime);
                           if (t != null) setModalState(() => endTime = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(formatTime(endTime)), const Icon(Ionicons.time_outline, size: 16)]),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Text("BINDINGS (OPTIONAL)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                           _pickLocationForModal(context, (loc, lat, long) {
                             setModalState(() {
                               tempLocation = loc;
                               tempLat = lat;
                               tempLong = long;
                             });
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
                PrimaryButton(text: "Add Slot", onPressed: () {
                   setState(() {
                     _courseSlots.add({
                       'day': selectedDay, 
                       'start': formatTime(startTime), 
                       'end': formatTime(endTime), 
                       'loc': tempLocation,
                       'lat': tempLat,
                       'long': tempLong,
                       'wifi': tempWifi
                     });
                   });
                   Navigator.pop(context);
                }),
                const SizedBox(height: 30),
              ],
            ),
          );
        }
      ),
    );
  }
}
