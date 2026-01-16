import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/pages/calendar/providers/add_event_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class EventForm extends StatefulWidget {

  const EventForm({
    required this.state, required this.notifier, super.key,
  });
  final AddEventState state;
  final AddEventViewModel notifier;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  static final _minDate = DateTime(2024);
  static final _maxDate = DateTime(2030);

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _titleCtrl = TextEditingController(text: widget.state.title);
    _descCtrl = TextEditingController(text: widget.state.description);
    
    _titleCtrl.addListener(() {
      if (_titleCtrl.text != widget.state.title) {
        widget.notifier.setTitle(_titleCtrl.text);
      }
    });

    _descCtrl.addListener(() {
      if (_descCtrl.text != widget.state.description) {
        widget.notifier.setDescription(_descCtrl.text);
      }
    });
  }

  @override
  void didUpdateWidget(EventForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.title != widget.state.title && _titleCtrl.text != widget.state.title) {
        // Only update if the change came from outside (not from our own listener)
        // Actually, since we are using a listener that updates the notifier, 
        // passing it back here might cause a loop or cursor jump if not careful.
        // However, this is for when the *external* state changes (e.g. initial load or reset).
        // A simple check is usually enough.
        // For text fields, usually you only want to update if the value is drastically different 
        // or if it's a "reset" action. 
        // For this simple implementation, let's keep it safe:
        // If the state title changed and it doesn't match our controller, update it.
       final selection = _titleCtrl.selection;
       _titleCtrl.text = widget.state.title;
        // Try to restore cursor if possible, though it might be tricky if text length changed.
       if (selection.end <= widget.state.title.length) {
         _titleCtrl.selection = selection;
       } else {
         _titleCtrl.selection = TextSelection.collapsed(offset: widget.state.title.length);
       }
    }
    
    if (oldWidget.state.description != widget.state.description && _descCtrl.text != widget.state.description) {
       final selection = _descCtrl.selection;
       _descCtrl.text = widget.state.description;
       if (selection.end <= widget.state.description.length) {
         _descCtrl.selection = selection;
       } else {
         _descCtrl.selection = TextSelection.collapsed(offset: widget.state.description.length);
       }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Title Input (Large)
        TextField(
          controller: _titleCtrl,
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Title',
            hintStyle: GoogleFonts.outfit(color: Colors.black12),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        
        const SizedBox(height: 32),
        
        // 2. Type Badge (Static for now)
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
              Text('Personal Event', style: GoogleFonts.dmSans(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 3. Date & Time Section
        _buildSectionHeader('Time & Date'),
        const SizedBox(height: 16),
        
        // All Day Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Ionicons.time_outline, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Text('All-day', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            CupertinoSwitch(
              value: widget.state.isAllDay, 
              activeTrackColor: AppColors.primary,
              onChanged: (v) => widget.notifier.setAllDay(v),
            ),
          ],
        ),
        const Divider(height: 32),
        
        // Date Picker Row
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context, 
              initialDate: widget.state.selectedDate, 
              firstDate: _minDate, 
              lastDate: _maxDate,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                );
              }
            );
            if (d != null) widget.notifier.setDate(d);
          },
          child: Row(
            children: [
               const Icon(Ionicons.calendar_clear_outline, color: Colors.grey, size: 20),
               const SizedBox(width: 12),
               Text(DateFormat('EEE, MMM d, yyyy').format(widget.state.selectedDate), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        
        if (!widget.state.isAllDay) ...[
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(context, 'Starts', widget.state.startTime, (t) => widget.notifier.setStartTime(t)),
              ),
              const SizedBox(width: 16),
              const Icon(Ionicons.arrow_forward, color: Colors.grey, size: 16),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(context, 'Ends', widget.state.endTime, (t) => widget.notifier.setEndTime(t)),
              ),
            ],
          ),
        ],

        const SizedBox(height: 32),
        
        // 4. Description
        _buildSectionHeader('Details'),
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
              hintText: 'Add notes, location, or details...',
              hintStyle: GoogleFonts.dmSans(color: Colors.grey),
              border: InputBorder.none,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(), 
      style: GoogleFonts.dmSans(
        fontSize: 12, 
        fontWeight: FontWeight.bold, 
        color: Colors.grey[400],
        letterSpacing: 1
      )
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
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
