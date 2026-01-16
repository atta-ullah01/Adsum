
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- State Class ---
class DashboardState {

  const DashboardState({
    required this.selectedDate,
    required this.greeting,
    required this.timelineEvents,
  });
  final DateTime selectedDate;
  final String greeting;
  final AsyncValue<List<ScheduleEvent>> timelineEvents;

  DashboardState copyWith({
    DateTime? selectedDate,
    String? greeting,
    AsyncValue<List<ScheduleEvent>>? timelineEvents,
  }) {
    return DashboardState(
      selectedDate: selectedDate ?? this.selectedDate,
      greeting: greeting ?? this.greeting,
      timelineEvents: timelineEvents ?? this.timelineEvents,
    );
  }
}

// --- ViewModel ---
class DashboardViewModel extends AutoDisposeNotifier<DashboardState> {
  @override
  DashboardState build() {
    final now = DateTime.now();
    return DashboardState(
      selectedDate: now,
      greeting: _calculateGreeting(),
      timelineEvents: const AsyncValue.loading(),
    );
  }

  /// Initialize and load data
  Future<void> loadData() async {
    // Initial fetch
    await selectDate(state.selectedDate);
  }

  /// Change selected date and refresh data
  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date, timelineEvents: const AsyncValue.loading());

    try {
      // 1. Fetch Schedule Events
      final scheduleService = ref.read(scheduleServiceProvider);
      final scheduleEvents = await scheduleService.getEventsForDate(date);

      // 2. Fetch Mess Menu
      final messService = ref.read(messServiceProvider);
      final messDay = MessDayOfWeek.fromDateTime(date);
      final messMenus = await messService.getMenusForDay(messDay);

      // 3. Merge & Sort
      final allEvents = <ScheduleEvent>[...scheduleEvents];
      
      // Convert Mess to Events
      for (final menu in messMenus) {
        allEvents.add(_convertMessToEvent(menu, date));
      }

      // Sort by start time
      allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

      state = state.copyWith(timelineEvents: AsyncValue.data(allEvents));
    } catch (e, st) {
      state = state.copyWith(timelineEvents: AsyncValue.error(e, st));
    }
  }

  String _calculateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  ScheduleEvent _convertMessToEvent(MessMenu menu, DateTime date) {
    final timeParts = menu.startTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 8;
    final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
    final startTime = DateTime(date.year, date.month, date.day, hour, minute);
    
    final endParts = menu.endTime.split(':');
    final endHour = int.tryParse(endParts[0]) ?? hour + 1;
    final endMinute = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0;
    final endTime = DateTime(date.year, date.month, date.day, endHour, endMinute);
    
    return ScheduleEvent(
      id: 'mess_${menu.menuId}',
      title: menu.mealType.displayName,
      subtitle: menu.items,
      startTime: startTime,
      endTime: endTime,
      type: ScheduleEventType.event,
      color: '#616161',
      metadata: const {'isMess': true, 'bgColor': '#F5F5F5'},
    );
  }
}

// --- Provider ---
final dashboardViewModelProvider = NotifierProvider.autoDispose<DashboardViewModel, DashboardState>(() {
  return DashboardViewModel();
});
