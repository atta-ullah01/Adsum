import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/calendar_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final CalendarEvent? editEvent;
  const AddEventPage({super.key, this.initialDate, this.editEvent});

  @override
  ConsumerState<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _selectedDate;
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isAllDay = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.editEvent != null;
  
  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.editEvent?.title ?? '');
    _descCtrl = TextEditingController(text: widget.editEvent?.description ?? '');
    _selectedDate = widget.editEvent?.date ?? widget.initialDate ?? DateTime.now();
    
    // Parse times
    if (widget.editEvent?.startTime != null) {
      final parts = widget.editEvent!.startTime!.split(':');
      if (parts.length == 2) {
        _startTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0);
      }
    }
    if (widget.editEvent?.endTime != null) {
      final parts = widget.editEvent!.endTime!.split(':');
      if (parts.length == 2) {
        _endTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 10, minute: int.tryParse(parts[1]) ?? 0);
      }
    } else if (widget.editEvent != null && widget.editEvent!.startTime == null) {
      // If editing an event with no start time, assume all day
       _isAllDay = true;
    }
  }

  Future<void> _saveEvent() async {
    if (_titleCtrl.text.isEmpty) {
      _showError('Please enter a title');
      return;
    }

    if (!_isAllDay) {
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;
      if (endMinutes <= startMinutes) {
        _showError('End time must be after start time');
        return;
      }
    }
    
    setState(() => _isSaving = true);
    
    // Format times
    String? startStr;
    String? endStr;
    
    if (!_isAllDay) {
      startStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
      endStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
    }
    
    // Return map
    Navigator.pop(context, {
      'title': _titleCtrl.text.trim(),
      'date': _selectedDate,
      'type': 'Personal', // Fixed type
      'startTime': startStr,
      'endTime': endStr,
      'description': _descCtrl.text.isNotEmpty ? _descCtrl.text.trim() : null,
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditMode ? "Edit Event" : "New Event", 
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveEvent,
            child: _isSaving 
             ? const CupertinoActivityIndicator()
             : Text("Save", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title Input (Large)
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: GoogleFonts.outfit(color: Colors.black12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 32),
            
            // 2. Type Badge (Static)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Ionicons.person, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text("Personal Event", style: GoogleFonts.dmSans(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 3. Date & Time Section
            _buildSectionHeader("Time & Date"),
            const SizedBox(height: 16),
            
            // All Day Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Ionicons.time_outline, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Text("All-day", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                CupertinoSwitch(
                  value: _isAllDay, 
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isAllDay = v),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Date Picker Row
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime(2024), 
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(primary: AppColors.primary),
                      ),
                      child: child!,
                    );
                  }
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: Row(
                children: [
                   const Icon(Ionicons.calendar_clear_outline, color: Colors.grey, size: 20),
                   const SizedBox(width: 12),
                   Text(DateFormat('EEE, MMM d, yyyy').format(_selectedDate), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
                   const Spacer(),
                   // If not all day, show times inline? No, let's keep times separate for clarity
                ],
              ),
            ),
            
            if (!_isAllDay) ...[
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker("Starts", _startTime, (t) => setState(() => _startTime = t)),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Ionicons.arrow_forward, color: Colors.grey, size: 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker("Ends", _endTime, (t) => setState(() => _endTime = t)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
            
            // 4. Description
            _buildSectionHeader("Details"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!)
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: 5,
                style: GoogleFonts.dmSans(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Add notes, location, or details...",
                  hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(), 
      style: GoogleFonts.dmSans(
        fontSize: 12, 
        fontWeight: FontWeight.bold, 
        color: Colors.grey[400],
        letterSpacing: 1.0
      )
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onChanged(t);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50], 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(time.format(context), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
