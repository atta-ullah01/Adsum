import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/calendar/add_event_page.dart';
import 'package:adsum/presentation/pages/calendar/providers/calendar_viewmodel.dart';
import 'package:adsum/presentation/pages/calendar/widgets/agenda_list.dart';
import 'package:adsum/presentation/pages/calendar/widgets/calendar_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class AcademicCalendarPage extends ConsumerStatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  ConsumerState<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends ConsumerState<AcademicCalendarPage> {

  @override
  Widget build(BuildContext context) {
    // Watch State
    final calendarState = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final eventsAsync = ref.watch(calendarEventsProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Academic Calendar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.cloud_upload_outline, color: Colors.black),
            onPressed: () {
               ScaffoldMessenger.of(context).clearSnackBars();
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Row(
                     children: [
                       const Icon(Ionicons.alert_circle, color: Colors.white, size: 20),
                       const SizedBox(width: 12),
                       Expanded(child: Text('Not implemented correctly yet.', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                     ],
                   ),
                   backgroundColor: const Color(0xFF1F2937),
                   behavior: SnackBarBehavior.floating,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                   margin: const EdgeInsets.all(24),
                   elevation: 0,
                 )
               );
            },
            tooltip: 'Import Holidays',
          )
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading calendar: $err')),
        data: (events) {
          return Column(
            children: [
              // 1. Calendar View
              CalendarGrid(
                focusedMonth: calendarState.focusedMonth,
                selectedDay: calendarState.selectedDay,
                events: events,
                onDaySelected: viewModel.onDaySelected,
                onPageChanged: viewModel.onPageChanged,
              ),
              
              // 2. Selected Day Events (Agenda)
              Expanded(
                child: ColoredBox(
                  color: AppColors.bgApp,
                  child: AgendaList(
                    selectedDay: calendarState.selectedDay,
                    events: events,
                    onAddTap: () => _navigateToAddEvent(context, calendarState.selectedDay),
                    onEventTap: (event) => _showEventOptionsSheet(context, event, ref),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEvent(context, calendarState.selectedDay),
        backgroundColor: Colors.black,
        icon: const Icon(Ionicons.add, color: Colors.white),
        label: Text('Event', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _navigateToAddEvent(BuildContext context, DateTime date) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEventPage(initialDate: date))
    );
    
    if (result != null && result is Map) {
       // Add Event via Service
       final typeStr = result['type'] as String? ?? 'Personal';
       final type = CalendarEventType.values.firstWhere(
         (e) => e.name.toLowerCase() == typeStr.toLowerCase(), 
         orElse: () => CalendarEventType.personal
       );

       await ref.read(calendarServiceProvider).addEvent(
         title: result['title'],
         date: result['date'],
         type: type,
         startTime: result['startTime'],
         endTime: result['endTime'],
         description: result['description'],
       );
       // Verify/Invalidate
       ref.invalidate(calendarEventsProvider);
    }
  }

  /// Show event options bottom sheet (Edit, Delete, Hide)
  void _showEventOptionsSheet(BuildContext context, CalendarEvent event, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Ionicons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Edit Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Ionicons.pencil, color: Colors.blue, size: 20),
              ),
              title: Text('Edit Event', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              subtitle: Text('Modify title, date, or time', style: GoogleFonts.dmSans(color: Colors.grey)),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEventPage(
                      initialDate: event.date,
                      editEvent: event,
                    ),
                  ),
                );
                
                if (result != null && result is Map) {
                  final typeStr = result['type'] as String? ?? 'Personal';
                  final type = CalendarEventType.values.firstWhere(
                    (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
                    orElse: () => CalendarEventType.personal,
                  );
                  
                  final updated = CalendarEvent(
                    eventId: event.eventId, // Keep same ID
                    title: result['title'],
                    date: result['date'],
                    type: type,
                    startTime: result['startTime'],
                    endTime: result['endTime'],
                    description: result['description'],
                  );
                  
                  await ref.read(calendarServiceProvider).updateEvent(updated);
                  ref.invalidate(calendarEventsProvider);
                }
              },
            ),
            
            const SizedBox(height: 8),
            
            // Delete Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Ionicons.trash, color: Colors.red, size: 20),
              ),
              title: Text('Delete Event', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: Text('Remove from calendar', style: GoogleFonts.dmSans(color: Colors.grey)),
              onTap: () async {
                Navigator.pop(ctx);
                
                // Confirm deletion
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text('Delete Event?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    content: Text('Are you sure you want to delete "${event.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                
                if (confirm ?? false) {
                  await ref.read(calendarServiceProvider).deleteEvent(event.eventId);
                  ref.invalidate(calendarEventsProvider);
                  // Since we are in a modal sheet, using context here refers to the sheet's context if we weren't careful, 
                  // but we popped the sheet. The scaffold context is 'context'.
                  // Check mounted
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${event.title}" deleted'), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
