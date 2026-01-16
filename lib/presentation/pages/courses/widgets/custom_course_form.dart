
import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

// Extracted widget for Custom Course Creation/Editing
class CustomCourseForm extends ConsumerStatefulWidget {

  const CustomCourseForm({
    required this.onCancel, required this.onSave, super.key,
    this.initialData,
  });
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  @override
  ConsumerState<CustomCourseForm> createState() => _CustomCourseFormState();
}

class _CustomCourseFormState extends ConsumerState<CustomCourseForm> {
  // Form State
  late TextEditingController _nameCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _instructorCtrl;
  late TextEditingController _sectionCtrl;
  late TextEditingController _targetAttendanceCtrl;
  late TextEditingController _totalExpectedCtrl;
  
  late DateTime _startDate;
  late Color _selectedColor;
  late List<Map<String, dynamic>> _slots;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};
    
    _nameCtrl = TextEditingController(text: (data['name'] as String?) ?? 'My Elective');
    _codeCtrl = TextEditingController(text: (data['code'] as String?) ?? 'CUST001');
    _instructorCtrl = TextEditingController(text: (data['instructor'] as String?) ?? 'Self');
    _sectionCtrl = TextEditingController(text: (data['section'] as String?) ?? 'A');
    _targetAttendanceCtrl = TextEditingController(text: (data['targetAttendance'] as double?)?.toString() ?? '75.0');
    _totalExpectedCtrl = TextEditingController(text: (data['totalExpected'] as int?)?.toString() ?? '30');
    
    _startDate = (data['startDate'] as DateTime?) ?? DateTime.now();
    _selectedColor = (data['color'] as Color?) ?? AppColors.pastelPurple;
    
    if (data['slots'] != null) {
      _slots = List<Map<String, dynamic>>.from(data['slots'] as List);
    } else {
       _slots = [
         {'day': 'Mon', 'time': '14:00 - 15:00', 'loc': 'Classroom', 'wifi': null}
       ];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _instructorCtrl.dispose();
    _sectionCtrl.dispose();
    _targetAttendanceCtrl.dispose();
    _totalExpectedCtrl.dispose();
    super.dispose();
  }

  void _addSlot() {
    // Show modal to add slot (simplified for extracted widget)
    // For now just add a placeholder to demonstrate list update
    setState(() {
      _slots.add({
        'day': 'Wed', 
        'time': '10:00 - 11:00', 
        'loc': 'Lab',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Course Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: widget.onCancel, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 20),

          // Basic Info Fields
          _buildTextField('Course Name', _nameCtrl),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Code', _codeCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Instructor', _instructorCtrl)),
            ],
          ),

          const SizedBox(height: 20),
          Text('Schedule & Slots', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          ..._slots.asMap().entries.map((entry) {
            final slot = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                     child: const Icon(Ionicons.time_outline, size: 16),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("${slot['day']} • ${slot['time']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                         Text("${slot['loc']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                       ],
                     ),
                   ),
                   IconButton(
                     icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                     onPressed: () => setState(() => _slots.removeAt(entry.key)),
                   )
                ],
              ),
            );
          }),

          TextButton.icon(
            onPressed: _addSlot,
            icon: const Icon(Icons.add),
            label: const Text('Add Class Slot'),
          ),

          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Save Course',
            onPressed: () {
               widget.onSave({
                 'name': _nameCtrl.text,
                 'code': _codeCtrl.text,
                 'instructor': _instructorCtrl.text,
                 'section': _sectionCtrl.text,
                 'targetAttendance': double.tryParse(_targetAttendanceCtrl.text) ?? 75.0,
                 'totalExpected': int.tryParse(_totalExpectedCtrl.text) ?? 30,
                 'color': _selectedColor,
                 'startDate': _startDate,
                 'slots': _slots,
               });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: AppColors.bgApp,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
