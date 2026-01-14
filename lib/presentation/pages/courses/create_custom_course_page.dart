import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CreateCustomCoursePage extends StatefulWidget {
  const CreateCustomCoursePage({super.key});

  @override
  State<CreateCustomCoursePage> createState() => _CreateCustomCoursePageState();
}

class _CreateCustomCoursePageState extends State<CreateCustomCoursePage> {
  Color _selectedColor = AppColors.pastelGreen;

  // Schedule State
  final List<Map<String, String>> _courseSlots = [
     // Start empty or with default
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // As per HTML style='background: white'
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
                  const SizedBox(width: 44), // Spacer
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                   _buildFormGroup('Course Name', 'e.g. Graphic Design'),
                   _buildFormGroup('Course Code *', 'Required (e.g. CUST101)'),
                   _buildFormGroup('Instructor / Professor', 'e.g. Prof. Sarah'),
                   
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
                           const Icon(Ionicons.wifi, size: 14, color: Colors.green),
                           const SizedBox(width: 8),
                           const Icon(Ionicons.close_circle, color: Colors.red, size: 18),
                         ],
                       ),
                     )),
                   
                   const SizedBox(height: 12),
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
                       Expanded(child: _buildFormGroup('Target Attendance %', '75')),
                       const SizedBox(width: 16),
                       Expanded(child: _buildFormGroup('Section', 'A')),
                     ],
                   ),
                   
                   const SizedBox(height: 10),
                   Text('CARD COLOR', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                   const SizedBox(height: 8),
                   Row(
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
                text: 'Create Course',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom course created!')));
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormGroup(String label, String placeholder, {bool isTime = false}) {
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
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMain),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.dmSans(color: Colors.black38),
              border: InputBorder.none,
              // Adjust alignment for time inputs if needed
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
  // Note: callback is used to update the State INSIDE the StatefulBuilder of the modal
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
              Text("Set Location", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                 leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: const Icon(Ionicons.location, color: Colors.blue)),
                 title: Text("Use Current Location", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                 subtitle: Text("Detected: LH-102 (12.934, 77.534)"),
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
    String? tempWifi;

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
                Text("Add Class Slot", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                _buildDropdownField('Day of Week', 'Monday'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTimePicker('Start', '09:00')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTimePicker('End', '10:00')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormGroup('Location Name', ''),
                
                const SizedBox(height: 20),
                const Text("BINDINGS (OPTIONAL)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                PrimaryButton(text: "Add Slot", onPressed: () {
                   setState(() {
                     _courseSlots.add({
                       'day': 'Mon', 
                       'time': '09:00 - 10:00', 
                       'loc': tempLocation ?? 'New Loc' // Use picked location if available
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
  
  Widget _buildDropdownField(String label, String value) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
       decoration: BoxDecoration(
         color: const Color(0xFFF9FAFB),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: const Color(0xFFE5E7EB)),
       ),
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value), const Icon(Icons.arrow_drop_down)]),
     );
  }

  Widget _buildTimePicker(String label, String time) {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
       decoration: BoxDecoration(
         color: const Color(0xFFF9FAFB),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: const Color(0xFFE5E7EB)),
       ),
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(time), const Icon(Ionicons.time_outline, size: 16)]),
    );
  }
}
