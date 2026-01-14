import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

// --- Enums mimicking DATA_FLOW.md ---
enum DayType {
  classDay,
  holiday,
  cancelled,
  rescheduled,
  noClass,
}

enum AttendanceStatus {
  presentAuto,
  presentManual,
  absent,
  pending,
}

// Data Model for a Single Day
class CalendarEntry {
  final DayType type;
  final AttendanceStatus? status; // Only relevant if type == classDay
  final String? description; // e.g. "Diwali" or verification method

  const CalendarEntry({
    required this.type,
    this.status,
    this.description,
  });
}

class HistoryLogPage extends StatefulWidget {
  final String courseTitle;
  
  const HistoryLogPage({super.key, required this.courseTitle});

  @override
  State<HistoryLogPage> createState() => _HistoryLogPageState();
}

class _HistoryLogPageState extends State<HistoryLogPage> {
  // Mock Data using Structured Model
  final Map<int, CalendarEntry> _calendarData = {
    // Week 1
    1: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto, description: "WiFi Verified"),
    2: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto, description: "WiFi Verified"),
    3: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentManual, description: "Self-Marked"),
    5: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.absent, description: "Missed"),
    
    // Week 2
    7: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    8: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    9: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.pending, description: "Waiting for CR"),
    
    // Week 3
    12: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.absent),
    13: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    14: CalendarEntry(type: DayType.holiday, description: "Diwali"),
    15: CalendarEntry(type: DayType.cancelled, description: "Prof Sick"),
    16: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    
    // Week 4
    19: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    20: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    21: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
    22: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.pending),
    23: CalendarEntry(type: DayType.classDay, status: AttendanceStatus.presentAuto),
  }; 

  int _selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
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
            Text(
              "November 2025", 
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Custom Calendar Grid
            _buildCalendarGrid(),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Selected Day Details
            Text(
              "Details for Nov $_selectedDay",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDayDetails(_selectedDay),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 30, 
      itemBuilder: (context, index) {
        final day = index + 1;
        final entry = _calendarData[day] ?? const CalendarEntry(type: DayType.noClass);
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
            case AttendanceStatus.presentAuto:
              bgColor = AppColors.pastelGreen;
              textColor = Colors.green[800]!;
              break;
            case AttendanceStatus.presentManual:
              bgColor = Colors.transparent;
              border = Border.all(color: Colors.green[800]!, width: 1.5);
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

  Widget _buildDayDetails(int day) {
    final entry = _calendarData[day] ?? const CalendarEntry(type: DayType.noClass);
    
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
         case AttendanceStatus.presentAuto:
           statusText = "Present (Auto)";
           statusColor = Colors.green[800]!;
           icon = Ionicons.checkmark_circle;
           break;
         case AttendanceStatus.presentManual:
           statusText = "Present (Manual)";
           statusColor = Colors.green[800]!;
           icon = Ionicons.checkmark_circle_outline;
           fillIcon = false;
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
            if (entry.status == AttendanceStatus.pending)
              // VERIFY button for pending
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showVerifyDialog(context),
                  icon: const Icon(Ionicons.checkmark_done_outline),
                  label: const Text("Verify Attendance"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange[800],
                  ),
                ),
              )
            else
              // EDIT button for already marked
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Ionicons.create_outline),
                  label: const Text("Edit Status"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              )
          ]
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Verify Attendance", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Were you present for this class?", style: GoogleFonts.dmSans(color: Colors.grey)),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Ionicons.checkmark_circle, color: Colors.green),
              title: const Text("I was Present"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as Present ✓")),
                );
              },
            ),
            ListTile(
              leading: Icon(Ionicons.close_circle, color: AppColors.danger),
              title: const Text("I was Absent"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as Absent")),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Edit Status", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Ionicons.checkmark_circle, color: Colors.green),
              title: const Text("Present"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Status updated to Present")),
                );
              },
            ),
            ListTile(
              leading: Icon(Ionicons.close_circle, color: AppColors.danger),
              title: const Text("Absent"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Status updated to Absent")),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
