import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/calendar/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class AgendaList extends StatelessWidget {

  const AgendaList({
    required this.selectedDay, required this.events, required this.onEventTap, required this.onAddTap, super.key,
  });
  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsOnDate(selectedDay, events);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('EEEE, d MMMM').format(selectedDay), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            if (dayEvents.isEmpty) 
              Text('No events', style: GoogleFonts.dmSans(color: Colors.grey[400], fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Show ALL events for this day
        ...dayEvents.asMap().entries.map((entry) => 
          Padding(
            padding: EdgeInsets.only(bottom: entry.key < dayEvents.length - 1 ? 16 : 0),
            child: EventCard(
              event: entry.value,
              onTap: () => onEventTap(entry.value),
            ),
          )
        ),
          
        if (dayEvents.isEmpty)
          Center(
             child: Padding(
               padding: const EdgeInsets.only(top: 40),
               child: Column(
                 children: [
                   Icon(Ionicons.calendar_clear_outline, size: 48, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text('Nothing scheduled for today', style: GoogleFonts.dmSans(color: Colors.grey[400])),
                   const SizedBox(height: 8),
                   TextButton(
                     onPressed: onAddTap,
                     child: Text('Tap + to add an event', style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.bold))
                   )
                 ],
               ),
             ),
          )
      ],
    );
  }

  List<CalendarEvent> _getEventsOnDate(DateTime date, List<CalendarEvent> allEvents) {
    return allEvents.where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
  }
}
