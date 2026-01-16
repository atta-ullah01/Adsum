import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class EventCard extends StatelessWidget {

  const EventCard({
    required this.event, super.key,
    this.onTap,
  });
  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Colors based on Type
    Color bgDate;
    Color textDate;
    
    switch (event.type) {
      case CalendarEventType.holiday:
        bgDate = AppColors.pastelPink;
        textDate = AppColors.danger;
      case CalendarEventType.exam:
      case CalendarEventType.quiz:
        bgDate = AppColors.pastelYellow;
        textDate = const Color(0xFFB45309);
      case CalendarEventType.assignment:
        bgDate = AppColors.pastelOrange;
        textDate = Colors.deepOrange;
      case CalendarEventType.daySwap:
        bgDate = AppColors.pastelBlue;
        textDate = AppColors.primary;
      case CalendarEventType.personal:
        bgDate = AppColors.pastelPurple;
        textDate = AppColors.secondary;
      default:
        bgDate = Colors.grey.shade100;
        textDate = Colors.grey.shade700;
    }

    return FadeSlideTransition(
      index: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(color: bgDate, borderRadius: BorderRadius.circular(12)),
                     child: Text(event.type.displayName.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: textDate)),
                   ),
                   if (event.isActive)
                     Icon(Ionicons.notifications_outline, color: textDate, size: 20)
                 ],
               ),
               const SizedBox(height: 16),
               Text(event.title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
               if (event.description != null && event.description!.isNotEmpty)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(event.description!, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey)),
                 ),
                 
               const SizedBox(height: 24),
               const Divider(),
               const SizedBox(height: 16),
               
               Row(
                 children: [
                    _buildMetaItem(Ionicons.calendar_outline, "Date: ${DateFormat('d MMM').format(event.date)}"),
                    if (event.startTime != null) ...[
                       const SizedBox(width: 24),
                       _buildMetaItem(Ionicons.time_outline, event.startTime!),
                    ] else ...[
                       const SizedBox(width: 24),
                       _buildMetaItem(Ionicons.time_outline, 'All Day'),
                    ]
                 ],
               )
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMetaItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}
