import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/calendar_event.dart';
import 'package:adsum/presentation/pages/calendar/providers/add_event_viewmodel.dart';
import 'package:adsum/presentation/pages/calendar/widgets/event_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class AddEventPage extends ConsumerWidget {
  const AddEventPage({super.key, this.initialDate, this.editEvent});
  final DateTime? initialDate;
  final CalendarEvent? editEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = AddEventParams(editEvent: editEvent, initialDate: initialDate);
    final vmState = ref.watch(addEventViewModelProvider(params));
    final vmNotifier = ref.read(addEventViewModelProvider(params).notifier);
    
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
          editEvent != null ? 'Edit Event' : 'New Event', 
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: vmState.isSaving ? null : () => _saveEvent(context, vmState, vmNotifier),
            child: vmState.isSaving 
             ? const CupertinoActivityIndicator()
             : Text('Save', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EventForm(state: vmState, notifier: vmNotifier),
      ),
    );
  }

  Future<void> _saveEvent(BuildContext context, AddEventState state, AddEventViewModel notifier) async {
    if (state.title.isEmpty) {
      _showError(context, 'Please enter a title');
      return;
    }

    if (!state.isAllDay) {
      final startMinutes = state.startTime.hour * 60 + state.startTime.minute;
      final endMinutes = state.endTime.hour * 60 + state.endTime.minute;
      if (endMinutes <= startMinutes) {
        _showError(context, 'End time must be after start time');
        return;
      }
    }
    
    notifier.setSaving(true);
    
    String? startStr;
    String? endStr;
    
    if (!state.isAllDay) {
      startStr = '${state.startTime.hour.toString().padLeft(2, '0')}:${state.startTime.minute.toString().padLeft(2, '0')}';
      endStr = '${state.endTime.hour.toString().padLeft(2, '0')}:${state.endTime.minute.toString().padLeft(2, '0')}';
    }
    
    Navigator.pop(context, {
      'title': state.title.trim(),
      'date': state.selectedDate,
      'type': 'Personal', 
      'startTime': startStr,
      'endTime': endStr,
      'description': state.description.isNotEmpty ? state.description.trim() : null,
    });
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}
