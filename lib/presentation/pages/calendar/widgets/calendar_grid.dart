import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class CalendarGrid extends StatelessWidget {

  const CalendarGrid({
    required this.focusedMonth, required this.selectedDay, required this.events, required this.onDaySelected, required this.onPageChanged, super.key,
  });
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final Function(DateTime selectedDay, DateTime focusedMonth) onDaySelected;
  final Function(DateTime focusedMonth) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(focusedMonth);

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          // Month Nav
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Ionicons.chevron_back, color: Colors.grey),
                  onPressed: () => onPageChanged(DateTime(focusedMonth.year, focusedMonth.month - 1)),
                ),
                GestureDetector(
                  onTap: () {
                    final now = DateTime.now();
                    onDaySelected(DateTime(now.year, now.month, now.day), DateTime(now.year, now.month));
                  },
                  child: Text(
                    DateFormat('MMMM yyyy').format(focusedMonth),
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                IconButton(
                  icon: const Icon(Ionicons.chevron_forward, color: Colors.grey),
                  onPressed: () => onPageChanged(DateTime(focusedMonth.year, focusedMonth.month + 1)),
                ),
              ],
            ),
          ),
          
          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => SizedBox(width: 40, child: Center(child: Text(d, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey)))))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          
          // Grid
          SizedBox(
            height: 300, 
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: days.length + _getFirstWeekdayOfMonth(focusedMonth) - 1,
              itemBuilder: (context, index) {
                final offset = _getFirstWeekdayOfMonth(focusedMonth) - 1;
                if (index < offset) return const SizedBox(); 
                final day = days[index - offset];
                return _buildDayCell(day);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    final dayEvents = _getEventsOnDate(day, events);
    final isSelected = isSameDay(day, selectedDay);
    final isToday = isSameDay(day, DateTime.now());
    
    final markerColors = dayEvents.where((e) => e.isActive).map((event) {
      switch (event.type) {
        case CalendarEventType.holiday: return AppColors.danger;
        case CalendarEventType.exam:
        case CalendarEventType.quiz: return AppColors.accent;
        case CalendarEventType.assignment: return Colors.orange;
        case CalendarEventType.daySwap: return AppColors.primary;
        case CalendarEventType.personal: return AppColors.secondary;
        default: return Colors.grey;
      }
    }).toSet().toList();

    return InkWell(
      onTap: () => onDaySelected(day, focusedMonth),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : (isToday ? Colors.grey[200] : Colors.transparent),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}', 
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                color: isSelected ? Colors.white : (isToday ? Colors.black : Colors.black87)
              )
            ),
          ),
          const SizedBox(height: 4),
          if (markerColors.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: markerColors.take(3).map((color) => 
                Container(
                  width: 5, height: 5, 
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)
                )
              ).toList(),
            )
          else 
            const SizedBox(height: 6),
        ],
      ),
    );
  }

  // Helpers
  List<DateTime> _getDaysInMonth(DateTime month) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }
  
  int _getFirstWeekdayOfMonth(DateTime month) {
    return DateTime(month.year, month.month).weekday;
  }
  
  List<CalendarEvent> _getEventsOnDate(DateTime date, List<CalendarEvent> allEvents) {
    return allEvents.where((e) => isSameDay(e.date, date)).toList();
  }
  
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
