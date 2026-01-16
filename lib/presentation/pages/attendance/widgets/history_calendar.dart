import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/attendance/widgets/history_log_types.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryCalendar extends StatelessWidget {

  const HistoryCalendar({
    required this.currentMonth, required this.selectedDay, required this.logs, required this.events, required this.onDaySelected, super.key,
  });
  final DateTime currentMonth;
  final int selectedDay;
  final List<AttendanceLog> logs;
  final List<CalendarEvent> events;
  final Function(int) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: daysInMonth, 
      itemBuilder: (context, index) {
        final day = index + 1;
        final entry = _getEntryForDay(day, logs, events);
        final isSelected = day == selectedDay;
        
        var bgColor = Colors.transparent;
        var textColor = Colors.black87;
        BoxBorder? border;
        
        if (entry.type == DayType.holiday) {
          bgColor = AppColors.pastelPurple;
          textColor = AppColors.primary;
        } else if (entry.type == DayType.cancelled) {
          bgColor = Colors.grey.withOpacity(0.15);
          textColor = Colors.grey[600]!;
        } else if (entry.type == DayType.rescheduled) {
           bgColor = AppColors.pastelBlue; 
           textColor = Colors.blue[800]!;
        } else if (entry.type == DayType.classDay) {
          switch (entry.status) {
            case AttendanceStatus.present:
              bgColor = AppColors.pastelGreen;
              textColor = Colors.green[800]!;
            case AttendanceStatus.absent:
              bgColor = AppColors.danger.withOpacity(0.15);
              textColor = AppColors.danger;
            case AttendanceStatus.pending:
              bgColor = AppColors.pastelOrange;
              textColor = Colors.orange[800]!;
            default:
              textColor = AppColors.textMain;
          }
        } else {
           textColor = AppColors.textMuted;
        }

        if (isSelected) {
          border = Border.all(color: AppColors.primary, width: 2);
        }

        return GestureDetector(
          onTap: () => onDaySelected(day),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: textColor,
                decoration: entry.type == DayType.cancelled ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }

  CalendarEntry _getEntryForDay(int day, List<AttendanceLog> logs, List<CalendarEvent> events) {
    final date = DateTime(currentMonth.year, currentMonth.month, day);
    
    final holiday = events.firstWhere(
      (e) => isSameDay(e.date, date) && e.type == CalendarEventType.holiday,
      orElse: () => CalendarEvent(eventId: '', title: '', date: date),
    );
    if (holiday.eventId.isNotEmpty) {
      return CalendarEntry(type: DayType.holiday, description: holiday.title);
    }

    final dayLogs = _getLogsForDay(day, logs);
    
    if (dayLogs.isEmpty) {
      return const CalendarEntry(type: DayType.noClass);
    }
    
    final hasAbsent = dayLogs.any((l) => l.status == AttendanceStatus.absent);
    final hasPending = dayLogs.any((l) => l.status == AttendanceStatus.pending);
    final allPresent = dayLogs.every((l) => l.status == AttendanceStatus.present);
    
    AttendanceStatus aggregateStatus;
    if (allPresent) {
      aggregateStatus = AttendanceStatus.present;
    } else if (hasAbsent || hasPending) {
      aggregateStatus = hasPending ? AttendanceStatus.pending : AttendanceStatus.absent;
    } else {
      aggregateStatus = AttendanceStatus.pending;
    }
    
    final slotCount = dayLogs.length;
    return CalendarEntry(
      type: DayType.classDay,
      status: aggregateStatus,
      description: slotCount > 1 ? '$slotCount slots' : dayLogs.first.source.name,
      log: dayLogs.first,
    );
  }

  List<AttendanceLog> _getLogsForDay(int day, List<AttendanceLog> logs) {
    final date = DateTime(currentMonth.year, currentMonth.month, day);
    return logs.where((l) => isSameDay(l.date, date)).toList()
      ..sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
  }

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
