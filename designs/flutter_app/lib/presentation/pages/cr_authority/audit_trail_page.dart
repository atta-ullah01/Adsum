import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/dashboard/date_strip.dart';
import 'package:adsum/presentation/widgets/dashboard/schedule_card.dart';
import 'package:adsum/presentation/widgets/dashboard/timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class AuditTrailPage extends StatefulWidget {
  const AuditTrailPage({super.key});

  @override
  State<AuditTrailPage> createState() => _AuditTrailPageState();
}

class _AuditTrailPageState extends State<AuditTrailPage> {
  String _selectedCourse = 'CS101';
  DateTime _selectedDate = DateTime.now();
  
  // Mock Schedule Data showing patch history
  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    return [
      {
        'id': '1',
        'time': '09:00 AM',
        'sortTime': 900,
        'type': 'Cancelled',
        'title': 'Applied Physics',
        'subtitle': 'Reason: "Prof Unavailable"',
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
        'borderColor': Colors.red,
        'isPatchable': true,
      },
      {
        'id': '2',
        'time': '02:00 PM',
        'sortTime': 1400,
        'type': 'Rescheduled',
        'title': 'DS Lab',
        'subtitle': 'New Time: 2 PM • Lab 2',
        'color': Colors.blue,
        'bgColor': Colors.blue.shade50,
        'borderColor': Colors.blue,
        'isPatchable': true,
      },
      {
        'id': '3',
        'time': '04:00 PM',
        'sortTime': 1600,
        'type': 'Extra Class',
        'title': 'Data Structures',
        'subtitle': 'Reason: "Doubt Session"',
        'color': Colors.green,
        'bgColor': Colors.green.shade50,
        'borderColor': Colors.green,
        'isPatchable': true,
      },
       {
        'id': '4',
        'time': '11:00 AM',
        'sortTime': 1100,
        'type': 'Swap Room',
        'title': 'Calculus',
        'subtitle': 'New Room: LH-205',
        'color': Colors.purple,
        'bgColor': Colors.purple.shade50,
        'borderColor': Colors.purple,
        'isPatchable': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              "CR Audit Trail",
              style: GoogleFonts.outfit(
                color: AppColors.textMain, 
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
             Text(
              "View schedule modifications",
              style: GoogleFonts.dmSans(
                color: Colors.grey, 
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Course Selector Widget
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24), // Pill shape
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourse,
                icon: const Icon(Ionicons.chevron_down, size: 14, color: AppColors.primary),
                style: GoogleFonts.dmSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                borderRadius: BorderRadius.circular(16),
                items: ['CS101', 'PH100'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedCourse = v!),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Date Strip (Reused from Dashboard)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: DateStrip(
              initialDate: _selectedDate, 
              enablePast: false, // Disable past dates
              daysCount: 14, // 2 Weeks lookahead
              onDateSelected: (d) => setState(() => _selectedDate = d),
            ),
          ),
          
          // 2. Timeline
          Expanded(
            child: Stack(
              children: [
                 // Timeline Connector Line
                Positioned(
                  left: 83, top: 0, bottom: 0,
                  child: Container(width: 2, color: Colors.grey[200]),
                ),
                
                ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 100),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final isPatchable = event['isPatchable'] as bool;
                    
                    Widget card = ScheduleCard(
                      tag: event['type'],
                      tagColor: event['bgColor'],
                      tagTextColor: event['color'],
                      title: event['title'],
                      subtitle: event['subtitle'],
                      leftBorderColor: event['borderColor'],
                      // Add an "Edit" badge if patchable
                      isLive: false, 
                    );

                      // Visual cue for details
                      card = Stack(
                        children: [
                          card,
                          Positioned(
                            right: 12, top: 12,
                            child: Icon(Ionicons.information_circle_outline, size: 16, color: event['color']),
                          )
                        ],
                      );

                    return TimelineItem(
                      time: event['time'],
                      child: GestureDetector(
                        onTap: () => _showPatchDetails(context, event),
                        child: card,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPatchDetails(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text("Patch Details", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow("Event", event['title']),
            _buildDetailRow("Status", event['type']),
            _buildDetailRow("Time", event['time']),
            _buildDetailRow("Reason", event['subtitle']),
            _buildDetailRow("Issued By", "You (CR)"),
            _buildDetailRow("Issued At", "Jan 14, 2026 • 10:30 AM"),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
