import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/pages/calendar/providers/holiday_injection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExtractedHolidayCard extends StatelessWidget {

  const ExtractedHolidayCard({
    required this.event, super.key,
  });
  final ExtractedEvent event;

  @override
  Widget build(BuildContext context) {
    // Format date string for display (mock data was already formatted strings in original, but VM uses DateTime)
    // We should format it.
    // Original used string dates like '04 April 2026'.
    // Let's assume standard formatting.
    final dateStr = '${event.date.day} ${_getMonthName(event.date.month)} ${event.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: event.isLowConfidence ? Border.all(color: AppColors.warning) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(event.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
               Text(dateStr, style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 13)),
             ],
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: event.isLowConfidence ? AppColors.pastelOrange : AppColors.pastelPurple,
               borderRadius: BorderRadius.circular(8),
             ),
             child: Text(event.type, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold)),
           )
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
