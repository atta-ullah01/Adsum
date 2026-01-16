import 'package:adsum/domain/models/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddEventParams {

  const AddEventParams({this.editEvent, this.initialDate});
  final CalendarEvent? editEvent;
  final DateTime? initialDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddEventParams &&
          runtimeType == other.runtimeType &&
          editEvent == other.editEvent &&
          initialDate == other.initialDate;

  @override
  int get hashCode => editEvent.hashCode ^ initialDate.hashCode;
}

class AddEventState {

  AddEventState({
    required this.title,
    required this.description,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    this.isSaving = false,
  });
  final String title;
  final String description;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAllDay;
  final bool isSaving;

  AddEventState copyWith({
    String? title,
    String? description,
    DateTime? selectedDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAllDay,
    bool? isSaving,
  }) {
    return AddEventState(
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDate: selectedDate ?? this.selectedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AddEventViewModel extends AutoDisposeFamilyNotifier<AddEventState, AddEventParams> {
  @override
  AddEventState build(AddEventParams arg) {
    // Default values
    var initialDate = arg.initialDate ?? DateTime.now();
    var startTime = const TimeOfDay(hour: 9, minute: 0);
    var endTime = const TimeOfDay(hour: 10, minute: 0);
    var isAllDay = false;
    var title = '';
    var description = '';

    if (arg.editEvent != null) {
      final evt = arg.editEvent!;
      title = evt.title;
      description = evt.description ?? '';
      initialDate = evt.date;
      
      if (evt.startTime != null) {
        final parts = evt.startTime!.split(':');
        if (parts.length == 2) {
          startTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0);
        }
      }
      
      if (evt.endTime != null) {
        final parts = evt.endTime!.split(':');
        if (parts.length == 2) {
          endTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 10, minute: int.tryParse(parts[1]) ?? 0);
        }
      } else if (evt.startTime == null) {
         isAllDay = true;
      }
    }

    return AddEventState(
      title: title,
      description: description,
      selectedDate: initialDate,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
    );
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setStartTime(TimeOfDay time) {
    state = state.copyWith(startTime: time);
  }

  void setEndTime(TimeOfDay time) {
    state = state.copyWith(endTime: time);
  }

  void setAllDay(bool isAllDay) {
    state = state.copyWith(isAllDay: isAllDay);
  }

  void setSaving(bool isSaving) {
    state = state.copyWith(isSaving: isSaving);
  }
}

final addEventViewModelProvider = NotifierProvider.family.autoDispose<AddEventViewModel, AddEventState, AddEventParams>(AddEventViewModel.new);
