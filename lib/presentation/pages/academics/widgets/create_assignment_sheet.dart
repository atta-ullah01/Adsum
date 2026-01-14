import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateAssignmentSheet extends StatefulWidget {
  final String? initialSubject;
  
  const CreateAssignmentSheet({
    super.key,
    this.initialSubject,
  });

  @override
  State<CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState extends State<CreateAssignmentSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _venueCtrl = TextEditingController(); // New
  final TextEditingController _durationCtrl = TextEditingController(); // New
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0); // New for Exams/Quizzes
  
  late String _selectedSubject;
  String _selectedType = "Assignment";
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject ?? "CS-302";
  }

  @override
  Widget build(BuildContext context) {
    // CR-Only Mode: Always broadcast
    const buttonColor = AppColors.accent;
    const buttonText = "Broadcast to Class";

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
        top: 24, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              children: [
                Text("Issue Course Work", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                // CR Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("CR AUTHORITY", style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent)),
                ),
              ],
          ),
          const SizedBox(height: 24),
          
          // Title Input
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: "Task Title",
              labelStyle: GoogleFonts.dmSans(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Ionicons.list_outline),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
              children: [
                  // Subject Dropdown
                  Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: InputDecoration(
                          labelText: "Subject",
                          labelStyle: GoogleFonts.dmSans(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        // Ensure selected subject is always in the list
                        items:  {...{"CS-302", "PH-401", "HS-101"}, _selectedSubject}.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 14)))).toList(),
                        onChanged: (val) => setState(() => _selectedSubject = val!),
                      ),
                  ),
                  const SizedBox(width: 12),
                  // Type Dropdown
                  Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: "Type",
                          labelStyle: GoogleFonts.dmSans(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        items: ["Assignment", "Project", "Quiz", "Exam"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 14)))).toList(),
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                  ),
              ],
          ),
          
          const SizedBox(height: 16),
          
          // Conditional Inputs
          if (_selectedType == 'Exam' || _selectedType == 'Quiz') ...[
             // Date & Time Row
             Row(
               children: [
                 Expanded(
                   child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (d != null) setState(() => _selectedDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Ionicons.calendar_outline, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('d MMM').format(_selectedDate), style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: InkWell(
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _selectedTime);
                      if (t != null) setState(() => _selectedTime = t);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Ionicons.time_outline, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(_selectedTime.format(context), style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             
             // Venue (Exam) or Duration (Quiz)
             if (_selectedType == 'Exam')
               TextField(
                 controller: _venueCtrl,
                 decoration: InputDecoration(
                   labelText: "Venue / Seat",
                   hintText: "e.g. LH-101 • A4",
                   filled: true,
                   fillColor: Colors.grey[50],
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                   prefixIcon: const Icon(Ionicons.location_outline),
                 ),
               ),
               
             if (_selectedType == 'Quiz')
               TextField(
                 controller: _durationCtrl,
                 keyboardType: TextInputType.number,
                 decoration: InputDecoration(
                   labelText: "Duration (minutes)",
                   hintText: "e.g. 45",
                   filled: true,
                   fillColor: Colors.grey[50],
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                   prefixIcon: const Icon(Ionicons.hourglass_outline),
                 ),
               ),
          ] else ...[
             // Standard Due Date (Homework/Project)
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context, 
                    initialDate: _selectedDate, 
                    firstDate: DateTime.now(), 
                    lastDate: DateTime(2030)
                  );
                  if (d != null) setState(() => _selectedDate = d);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Ionicons.calendar_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text("Due: ${DateFormat('EEE, d MMM').format(_selectedDate)}", style: GoogleFonts.dmSans(fontSize: 16)),
                      const Spacer(),
                      const Icon(Ionicons.chevron_forward, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
          ],
          
          const SizedBox(height: 16),
          
          // Optional Description
          TextField(
            controller: _descriptionCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "Instructions (Optional)",
              hintText: "e.g. Submit via email",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Ionicons.document_text_outline),
            ),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_titleCtrl.text.isEmpty) return;
                
                // Format Start Date+Time for Exams/Quizzes
                final formattedDate = DateFormat('EEE, d MMM').format(_selectedDate);
                final formattedTime = _selectedTime.format(context);
                final startAt = "$formattedDate, $formattedTime"; // e.g., "Mon, 10 Dec, 9:00 AM"

                context.pop({
                  "title": _titleCtrl.text,
                  "subject": _selectedSubject,
                  "deadline": formattedDate, // Due Date (Assignments) or End Date (Quiz window)
                  "start_at": startAt,      // For Exam/Quiz
                  "type": _selectedType,
                  "venue": _venueCtrl.text,
                  "duration_minutes": _durationCtrl.text,
                  "description": _descriptionCtrl.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(buttonText, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
