import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/attendance/widgets/history_log_types.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class HistoryDayDetails extends StatelessWidget {

  const HistoryDayDetails({
    required this.day, required this.currentMonth, required this.logs, required this.events, super.key,
  });
  final int day;
  final DateTime currentMonth;
  final List<AttendanceLog> logs;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final entry = _getEntryForDay(day, logs, events);
    
    // Holiday case
    if (entry.type == DayType.holiday) {
      return _buildDetailCard(
        statusText: 'Holiday',
        statusColor: AppColors.primary,
        icon: Ionicons.calendar,
        time: 'All Day',
        description: entry.description ?? 'University Holiday',
      );
    }
    
    // No class case
    if (entry.type == DayType.noClass) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No class scheduled for this day.', style: GoogleFonts.dmSans(color: AppColors.textMuted)),
        ),
      );
    }

    // Class day: Show ALL slots
    final dayLogs = _getLogsForDay(day, logs);
    
    return Column(
      children: dayLogs.map((log) {
        String statusText;
        Color statusColor;
        IconData icon;
        
        switch (log.status) {
          case AttendanceStatus.present:
            statusText = 'Present';
            statusColor = Colors.green[800]!;
            icon = Ionicons.checkmark_circle;
          case AttendanceStatus.absent:
            statusText = 'Absent';
            statusColor = AppColors.danger;
            icon = Ionicons.close_circle;
          case AttendanceStatus.pending:
            statusText = 'Pending';
            statusColor = Colors.orange[800]!;
            icon = Ionicons.help_circle;
        }
        
        final timeDisplay = log.startTime != null ? '${log.startTime}' : '—';
        final sourceText = log.source.name.toUpperCase();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDetailCard(
            statusText: statusText,
            statusColor: statusColor,
            icon: icon,
            time: timeDisplay,
            description: "Source: $sourceText${log.slotId != null ? ' • ${log.slotId}' : ''}",
            showReportButton: true,
            context: context, 
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailCard({
    required String statusText,
    required Color statusColor,
    required IconData icon,
    required String time,
    required String description,
    bool showReportButton = false,
    BuildContext? context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: statusColor)),
                    Text(time, style: GoogleFonts.dmSans(color: AppColors.textMain)),
                    Text(description, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (showReportButton && context != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance override coming soon in Phase 3')));
                },
                icon: const Icon(Ionicons.flag_outline, size: 16),
                label: const Text('Report Issue'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
            )
          ]
        ],
      ),
    );
  }

  // Duplicated helpers to keep widget self-contained (or could extract to util)
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
