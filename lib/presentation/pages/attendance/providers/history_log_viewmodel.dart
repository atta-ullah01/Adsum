import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryLogState {

  HistoryLogState({
    required this.currentMonth,
    required this.selectedDay,
  });
  final DateTime currentMonth;
  final int selectedDay;

  HistoryLogState copyWith({
    DateTime? currentMonth,
    int? selectedDay,
  }) {
    return HistoryLogState(
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

class HistoryLogViewModel extends AutoDisposeNotifier<HistoryLogState> {
  @override
  HistoryLogState build() {
    final now = DateTime.now();
    return HistoryLogState(
      currentMonth: now,
      selectedDay: now.day,
    );
  }

  void setSelectedDay(int day) {
    state = state.copyWith(selectedDay: day);
  }

  void setMonth(DateTime month) {
    state = state.copyWith(currentMonth: month);
  }
}

final historyLogViewModelProvider = NotifierProvider.autoDispose<HistoryLogViewModel, HistoryLogState>(HistoryLogViewModel.new);
