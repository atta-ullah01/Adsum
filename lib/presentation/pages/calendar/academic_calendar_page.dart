import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:adsum/presentation/pages/calendar/add_event_page.dart';

class AcademicCalendarPage extends ConsumerStatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  ConsumerState<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends ConsumerState<AcademicCalendarPage> {
  DateTime _focusedMonth = DateTime(2026, 1);
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default to today or focused month
    if (_selectedDay.year != _focusedMonth.year || _selectedDay.month != _focusedMonth.month) {
       _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch Events from Provider
    final eventsAsync = ref.watch(calendarEventsProvider);
    
    // Derived days list
    List<DateTime> days = _getDaysInMonth(_focusedMonth);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Academic Calendar", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
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
                       Expanded(child: Text("Not implemented, too poor to buy API keys 🥲", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
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
            tooltip: "Import Holidays",
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
              Container(
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
                            onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                          ),
                          GestureDetector(
                            onTap: () {
                              final now = DateTime.now();
                              setState(() {
                                _focusedMonth = DateTime(now.year, now.month);
                                _selectedDay = DateTime(now.year, now.month, now.day);
                              });
                            },
                            child: Text(
                              DateFormat("MMMM yyyy").format(_focusedMonth),
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Ionicons.chevron_forward, color: Colors.grey),
                            onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                          ),
                        ],
                      ),
                    ),
                    
                    // Weekday Headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                            .map((d) => SizedBox(width: 40, child: Center(child: Text(d, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey)))))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Grid
                    SizedBox(
                      height: 300, // Fixed height for grid roughly
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: days.length + _getFirstWeekdayOfMonth(_focusedMonth) - 1,
                        itemBuilder: (context, index) {
                          int offset = _getFirstWeekdayOfMonth(_focusedMonth) - 1;
                          if (index < offset) return const SizedBox(); 
                          DateTime day = days[index - offset];
                          return _buildDayCell(day, events);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // 2. Selected Day Events (Agenda)
              Expanded(
                child: Container(
                  color: AppColors.bgApp,
                  child: _buildAgendaList(events),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEventPage(initialDate: _selectedDay))
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
        },
        backgroundColor: Colors.black,
        icon: const Icon(Ionicons.add, color: Colors.white),
        label: Text("Event", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, List<CalendarEvent> allEvents) {
    List<CalendarEvent> events = _getEventsOnDate(day, allEvents);
    bool isSelected = isSameDay(day, _selectedDay);
    bool isToday = isSameDay(day, DateTime.now());
    
    // Get unique marker colors
    List<Color> markerColors = events.where((e) => e.isActive).map((event) {
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
      onTap: () => setState(() => _selectedDay = day),
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
              "${day.day}", 
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                color: isSelected ? Colors.white : (isToday ? Colors.black : Colors.black87)
              )
            ),
          ),
          const SizedBox(height: 4),
          // Show up to 3 dots for multiple events
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

  Widget _buildAgendaList(List<CalendarEvent> allEvents) {
    List<CalendarEvent> dayEvents = _getEventsOnDate(_selectedDay, allEvents);
    
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat("EEEE, d MMMM").format(_selectedDay), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            if (dayEvents.isEmpty) 
              Text("No events", style: GoogleFonts.dmSans(color: Colors.grey[400], fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Show ALL events for this day
        ...dayEvents.asMap().entries.map((entry) => 
          Padding(
            padding: EdgeInsets.only(bottom: entry.key < dayEvents.length - 1 ? 16 : 0),
            child: _buildEventDetailsCard(entry.value),
          )
        ).toList(),
          
        if (dayEvents.isEmpty)
          Center(
             child: Padding(
               padding: const EdgeInsets.only(top: 40),
               child: Column(
                 children: [
                   Icon(Ionicons.calendar_clear_outline, size: 48, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text("Nothing scheduled for today", style: GoogleFonts.dmSans(color: Colors.grey[400])),
                   const SizedBox(height: 8),
                   TextButton(
                     onPressed: () {}, // Handled by FAB
                     child: Text("Tap + to add an event", style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.bold))
                   )
                 ],
               ),
             ),
          )
      ],
    );
  }

  Widget _buildEventDetailsCard(CalendarEvent event) {
    // Colors based on Type
    Color bgDate;
    Color textDate;
    
    switch (event.type) {
      case CalendarEventType.holiday:
        bgDate = AppColors.pastelPink;
        textDate = AppColors.danger;
        break;
      case CalendarEventType.exam:
      case CalendarEventType.quiz:
        bgDate = AppColors.pastelYellow;
        textDate = const Color(0xFFB45309);
        break;
      case CalendarEventType.assignment:
        bgDate = AppColors.pastelOrange;
        textDate = Colors.deepOrange;
        break;
      case CalendarEventType.daySwap:
        bgDate = AppColors.pastelBlue;
        textDate = AppColors.primary;
        break;
      case CalendarEventType.personal:
        bgDate = AppColors.pastelPurple;
        textDate = AppColors.secondary;
        break;
      default:
        bgDate = Colors.grey.shade100;
        textDate = Colors.grey.shade700;
    }

    return FadeSlideTransition(
      index: 0,
      child: InkWell(
        onTap: () => _showEventOptionsSheet(event),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
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
                       _buildMetaItem(Ionicons.time_outline, "All Day"),
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

  // Helpers
  List<DateTime> _getDaysInMonth(DateTime month) {
    int days = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }
  
  int _getFirstWeekdayOfMonth(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday;
  }
  
  List<CalendarEvent> _getEventsOnDate(DateTime date, List<CalendarEvent> allEvents) {
    return allEvents.where((e) => isSameDay(e.date, date)).toList();
  }
  
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Show event options bottom sheet (Edit, Delete, Hide)
  void _showEventOptionsSheet(CalendarEvent event) {
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
              title: Text("Edit Event", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              subtitle: Text("Modify title, date, or time", style: GoogleFonts.dmSans(color: Colors.grey)),
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
              title: Text("Delete Event", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: Text("Remove from calendar", style: GoogleFonts.dmSans(color: Colors.grey)),
              onTap: () async {
                Navigator.pop(ctx);
                
                // Confirm deletion
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text("Delete Event?", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    content: Text("Are you sure you want to delete \"${event.title}\"?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await ref.read(calendarServiceProvider).deleteEvent(event.eventId);
                  ref.invalidate(calendarEventsProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("\"${event.title}\" deleted"), behavior: SnackBarBehavior.floating),
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
