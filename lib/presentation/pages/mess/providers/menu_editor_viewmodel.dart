import 'package:adsum/domain/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MenuEditorState {

  MenuEditorState({
    required this.selectedDay,
    this.isSaving = false,
  });
  final MessDayOfWeek selectedDay;
  final bool isSaving;

  MenuEditorState copyWith({
    MessDayOfWeek? selectedDay,
    bool? isSaving,
  }) {
    return MenuEditorState(
      selectedDay: selectedDay ?? this.selectedDay,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class MenuEditorViewModel extends AutoDisposeFamilyNotifier<MenuEditorState, MessDayOfWeek> {
  @override
  MenuEditorState build(MessDayOfWeek arg) {
    return MenuEditorState(selectedDay: arg);
  }

  void setDay(MessDayOfWeek day) {
    state = state.copyWith(selectedDay: day);
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }
}

final menuEditorViewModelProvider = NotifierProvider.family.autoDispose<MenuEditorViewModel, MenuEditorState, MessDayOfWeek>(MenuEditorViewModel.new);
