import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const AddEventPage({super.key, this.initialDate});

  @override
  ConsumerState<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _startDate = widget.initialDate ?? DateTime.now();
    _endDate = _startDate;
  }

  Future<void> _saveEvent() async {
    if (_titleCtrl.text.isEmpty) return;
    
    setState(() => _isSaving = true);
    
    try {
      final calendarService = ref.read(calendarServiceProvider);
      
      // Format times as HH:mm strings
      final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
      
      await calendarService.addEvent(
        title: _titleCtrl.text,
        date: _startDate,
        startTime: startTimeStr,
        endTime: endTimeStr,
        description: _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event Created!')),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Event", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveEvent,
            child: _isSaving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Save", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            Text("Event Title", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "e.g. Project Submission",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black12),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Date & Time
            _buildDateTimeField("Starts", _startDate, _startTime, (d) => setState(() => _startDate = d), (t) => setState(() => _startTime = t)),
            const SizedBox(height: 16),
            _buildDateTimeField("Ends", _endDate, _endTime, (d) => setState(() => _endDate = d), (t) => setState(() => _endTime = t)),
            
            const SizedBox(height: 32),
            
            // Description
            Text("Description", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                hintText: "Add details...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(String label, DateTime date, TimeOfDay time, Function(DateTime) onDate, Function(TimeOfDay) onTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: const Icon(Ionicons.calendar_outline, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(DateFormat("EEE, d MMM yyyy").format(date), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        
        // Pickers
        Row(
          children: [
            InkWell(
              onTap: () async {
                 final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2025), lastDate: DateTime(2030));
                 if (d != null) onDate(d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Text("Change Date", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                 final t = await showTimePicker(context: context, initialTime: time);
                 if (t != null) onTime(t);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                child: Text(time.format(context), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )
      ],
    );
  }
}
