import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarState {

  CalendarState({
    required this.focusedMonth,
    required this.selectedDay,
  });
  final DateTime focusedMonth;
  final DateTime selectedDay;

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDay,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

class CalendarViewModel extends AutoDisposeNotifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      focusedMonth: DateTime(now.year, now.month),
      selectedDay: now,
    );
  }

  void onDaySelected(DateTime day, DateTime focusedDay) {
    state = state.copyWith(
      selectedDay: day,
      focusedMonth: focusedDay,
    );
  }

  void onPageChanged(DateTime focusedMonth) {
    state = state.copyWith(focusedMonth: focusedMonth);
  }

  void setFocusedMonth(DateTime month) {
    state = state.copyWith(focusedMonth: month);
  }
}

final calendarViewModelProvider = NotifierProvider.autoDispose<CalendarViewModel, CalendarState>(CalendarViewModel.new);
