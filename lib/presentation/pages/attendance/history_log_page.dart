import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Enums mimicking DATA_FLOW.md ---
enum DayType {
  classDay,
  holiday,
  cancelled,
  rescheduled,
  noClass,
}

// Data Model for a Single Day
class CalendarEntry {
  final DayType type;
  final AttendanceStatus? status; // Only relevant if type == classDay
  final String? description; // e.g. "Diwali" or verification method
  final AttendanceLog? log; // Source log if available

  const CalendarEntry({
    required this.type,
    this.status,
    this.description,
    this.log,
  });
}

class HistoryLogPage extends ConsumerStatefulWidget {
  final String courseTitle;
  final String? courseCode; // Enforce filtering by course
  
  const HistoryLogPage({
    super.key, 
    required this.courseTitle,
    this.courseCode,
  });

  @override
  ConsumerState<HistoryLogPage> createState() => _HistoryLogPageState();
}

class _HistoryLogPageState extends ConsumerState<HistoryLogPage> {
  DateTime _currentMonth = DateTime.now();
  int _selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Enrollment
    final enrollmentsAsync = ref.watch(enrollmentsProvider);
    final enrollment = enrollmentsAsync.asData?.value.firstWhere(
      (e) => e.courseCode == widget.courseCode,
      orElse: () => Enrollment(enrollmentId: 'unknown', courseCode: widget.courseCode ?? ''),
    );
    
    // 2. Fetch Logs if enrollment found
    final logsAsync = enrollment?.enrollmentId != 'unknown'
        ? ref.watch(attendanceLogsProvider(enrollment!.enrollmentId))
        : const AsyncValue<List<AttendanceLog>>.data([]);
        
    // 3. Fetch Calendar Events (Holidays)
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("History Log", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              widget.courseTitle,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // Month Navigation could go here
              ],
            ),
            const SizedBox(height: 24),
            
            if (logsAsync.isLoading || eventsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              // Custom Calendar Grid
              _buildCalendarGrid(logsAsync.asData?.value ?? [], eventsAsync.asData?.value ?? []),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Selected Day Details
            Text(
              "Details for ${DateFormat('MMM').format(_currentMonth)} $_selectedDay",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
             if (logsAsync.hasValue && eventsAsync.hasValue)
              _buildDayDetails(_selectedDay, logsAsync.value!, eventsAsync.value!),
          ],
        ),
      ),
    );
  }

  // Helper to get entry for a specific day
  CalendarEntry _getEntryForDay(int day, List<AttendanceLog> logs, List<CalendarEvent> events) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    
    // Check for Holiday
    final holiday = events.firstWhere(
      (e) => isSameDay(e.date, date) && e.type == CalendarEventType.holiday,
      orElse: () => CalendarEvent(eventId: '', title: '', date: date, type: CalendarEventType.personal), // Dummy
    );
    if (holiday.eventId.isNotEmpty) {
      return CalendarEntry(type: DayType.holiday, description: holiday.title);
    }

    // Check for Log
    try {
        final log = logs.firstWhere((l) => isSameDay(l.date, date));
        // Map Log Status to UI Type/Status
        return CalendarEntry(
          type: DayType.classDay,
          status: log.status,
          description: log.source.name, // e.g. "WIFI"
          log: log,
        );
    } catch (_) {
        // No log found
        return const CalendarEntry(type: DayType.noClass);
    }
  }

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCalendarGrid(List<AttendanceLog> logs, List<CalendarEvent> events) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

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
        final isSelected = day == _selectedDay;
        
        Color bgColor = Colors.transparent;
        Color textColor = Colors.black87;
        BoxBorder? border;
        
        // 1. Determine Visuals based on Type
        if (entry.type == DayType.holiday) {
          bgColor = AppColors.pastelPurple;
          textColor = AppColors.primary;
        } else if (entry.type == DayType.cancelled) {
          bgColor = Colors.grey.withOpacity(0.15); // Cancelled = Grey
          textColor = Colors.grey[600]!;
        } else if (entry.type == DayType.rescheduled) {
           bgColor = AppColors.pastelBlue; 
           textColor = Colors.blue[800]!;
        } else if (entry.type == DayType.classDay) {
          // 2. If Class, check Status
          switch (entry.status) {
            case AttendanceStatus.present:
              bgColor = AppColors.pastelGreen;
              textColor = Colors.green[800]!;
              break;
            case AttendanceStatus.absent:
              bgColor = AppColors.danger.withOpacity(0.15);
              textColor = AppColors.danger;
              break;
            case AttendanceStatus.pending:
              bgColor = AppColors.pastelOrange;
              textColor = Colors.orange[800]!;
              break;
            default:
              textColor = AppColors.textMain;
          }
        } else {
           // No Class
           textColor = AppColors.textMuted;
        }

        // Selection Override
        if (isSelected) {
          border = Border.all(color: AppColors.primary, width: 2);
        }

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDay = day);
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              "$day",
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

  Widget _buildDayDetails(int day, List<AttendanceLog> logs, List<CalendarEvent> events) {
    final entry = _getEntryForDay(day, logs, events);
    
    if (entry.type == DayType.noClass) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("No class scheduled for this day.", style: GoogleFonts.dmSans(color: AppColors.textMuted)),
        ),
      );
    }

    String statusText = "";
    Color statusColor = AppColors.black;
    IconData icon = Ionicons.help_outline;
    String time = "10:00 AM - 11:00 AM";
    String description = entry.description ?? "Regular Session";
    bool fillIcon = true;

    // Logic Tree: Type -> Status
    if (entry.type == DayType.holiday) {
       statusText = "Holiday";
       statusColor = AppColors.primary;
       icon = Ionicons.calendar;
       description = entry.description ?? "University Holiday";
    
    } else if (entry.type == DayType.cancelled) {
       statusText = "Cancelled";
       statusColor = AppColors.textMuted;
       icon = Ionicons.ban;
       description = entry.description ?? "Class cancelled";
       
    } else if (entry.type == DayType.classDay) {
       // Check Status
       switch (entry.status!) {
         case AttendanceStatus.present:
           statusText = "Present";
           statusColor = Colors.green[800]!;
           icon = Ionicons.checkmark_circle;
           break;
         case AttendanceStatus.absent:
           statusText = "Absent";
           statusColor = AppColors.danger;
           icon = Ionicons.close_circle;
           break;
         case AttendanceStatus.pending:
           statusText = "Pending";
           statusColor = Colors.orange[800]!;
           icon = Ionicons.help_circle;
           break;
       }
    }

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
                  color: fillIcon ? statusColor.withOpacity(0.1) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: fillIcon ? null : Border.all(color: statusColor, width: 2),
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
          
          if (entry.type == DayType.classDay) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Placeholder: In a real app, logic to mark attendance goes here
             SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance override coming soon in Phase 3")));
                  },
                  icon: const Icon(Ionicons.flag_outline),
                  label: const Text("Report Issue"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              )
          ]
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context) {
    // Logic for verification (skipped for now as Phase 2B focus is viewing data)
  }

  void _showEditDialog(BuildContext context) {
     // Logic for edit (skipped for now)
  }
}
