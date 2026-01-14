import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/cr/cr_tools_sheet.dart';
import 'package:adsum/presentation/widgets/dashboard/date_strip.dart';
import 'package:adsum/presentation/widgets/dashboard/live_diagnostics_sheet.dart';
import 'package:adsum/presentation/widgets/dashboard/priority_alert_carousel.dart';
import 'package:adsum/presentation/widgets/dashboard/schedule_card.dart';
import 'package:adsum/presentation/widgets/dashboard/timeline_item.dart';
import 'package:adsum/presentation/widgets/global/global_fab_menu.dart';
import 'package:adsum/presentation/widgets/global/global_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DateTime _selectedDate = DateTime.now();

  // Helper to generate Mess events (Mock for now until MessRepository exists)
  List<ScheduleEvent> _getMessEvents(DateTime date) {
    // Only show mess for today/future or recent past
    // Simple logic: Breakfast at 8, Lunch at 12:30
    final events = <ScheduleEvent>[];
    final breakfastTime = DateTime(date.year, date.month, date.day, 8, 0);
    final lunchTime = DateTime(date.year, date.month, date.day, 12, 30);

    events.add(ScheduleEvent(
      id: 'mess_breakfast_${date.day}',
      title: 'Breakfast',
      subtitle: _getBreakfastForDay(date.weekday),
      startTime: breakfastTime,
      endTime: breakfastTime.add(const Duration(minutes: 30)),
      type: ScheduleEventType.event, // Using event type for Mess
      color: '#616161', // Grey 700
      metadata: {'isMess': true, 'bgColor': '#F5F5F5'}, // Grey 100
    ));

    events.add(ScheduleEvent(
      id: 'mess_lunch_${date.day}',
      title: 'Lunch',
      subtitle: _getLunchForDay(date.weekday),
      startTime: lunchTime,
      endTime: lunchTime.add(const Duration(minutes: 45)),
      type: ScheduleEventType.event,
      color: '#616161',
      metadata: {'isMess': true, 'bgColor': '#F5F5F5'},
    ));

    return events;
  }

  String _getBreakfastForDay(int weekday) {
    const items = [
      'Poha, Tea, Eggs',
      'Idli, Sambar, Coffee',
      'Paratha, Curd, Tea',
      'Upma, Tea, Banana',
      'Bread, Omelette, Juice',
      'Chole Bhature, Lassi',
      'Pancakes, Milk, Fruits',
    ];
    // Safety check for index
    if (weekday < 1 || weekday > 7) return items[0];
    return items[weekday - 1];
  }

  String _getLunchForDay(int weekday) {
    const items = [
      'Rice, Dal, Roti, Paneer',
      'Rice, Rajma, Salad',
      'Biryani, Raita',
      'Rice, Dal Makhani, Roti',
      'Pulao, Kadhi, Papad',
      'Chole Rice, Pickle',
      'Special Thali',
    ];
    if (weekday < 1 || weekday > 7) return items[0];
    return items[weekday - 1];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Color _parseColor(String hex) {
    try {
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch schedule data
    final scheduleAsync = ref.watch(scheduleForDateProvider(_selectedDate));

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        "Attaullah",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),

                  // Actions Row
                  Row(
                    children: [
                      // CR ACTION
                      GestureDetector(
                        onTap: () => showCRTools(context),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
                          ),
                          child: const Icon(Ionicons.megaphone, size: 20, color: Colors.orange),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          showSearch(context: context, delegate: GlobalSearchDelegate());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade100, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Ionicons.search_outline, size: 20, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Avatar
                      GestureDetector(
                        onTap: () {
                          context.push('/settings/profile');
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage("https://i.pravatar.cc/150?u=attaullah"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Date Strip with callback
            DateStrip(
              initialDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),

            // Priority Alert Carousel
            PriorityAlertCarousel(selectedDate: _selectedDate),

            const SizedBox(height: 8),

            // Scrollable Timeline Content
            Expanded(
              child: scheduleAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (events) {
                  // Merge with mess events
                  final messEvents = _getMessEvents(_selectedDate);
                  final allEvents = [...events, ...messEvents];
                  
                  // Sort by start time
                  allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

                  if (allEvents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Ionicons.calendar_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No events for this day',
                            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      // Timeline Connector Line
                      Positioned(
                        left: 83,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: Colors.grey[200],
                        ),
                      ),

                      ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: allEvents.length,
                        itemBuilder: (context, index) {
                          final event = allEvents[index];
                          final isMess = event.metadata['isMess'] == true;
                          final bgColor = isMess 
                              ? _parseColor((event.metadata['bgColor'] as String?) ?? '#F5F5F5')
                              : _parseColor(event.color).withValues(alpha: 0.1);
                          final mainColor = _parseColor(event.color);
                          final timeStr = DateFormat('hh:mm a').format(event.startTime);

                          Widget card = ScheduleCard(
                            tag: isMess ? 'Mess' : (event.type.name[0].toUpperCase() + event.type.name.substring(1)),
                            tagColor: bgColor,
                            tagTextColor: mainColor,
                            title: event.title,
                            subtitle: event.subtitle,
                            leftBorderColor: mainColor,
                            avatars: const [], // TODO: Add avatars based on course
                            isLive: event.isCurrent && !isMess,
                            isExam: event.type == ScheduleEventType.exam,
                            onPulseTap: (event.isCurrent && !isMess) 
                                ? () => showLiveDiagnostics(context) 
                                : null,
                          );

                          // Wrap cancelled in opacity
                          if (event.isCancelled) {
                            card = Opacity(opacity: 0.6, child: card);
                          }

                          // Navigate logic
                          if (event.type.isAcademic && !event.isCancelled) {
                            card = GestureDetector(
                              onTap: () => context.push('/subject-detail', extra: {
                                'title': event.title,
                                'code': 'View Details', // Fetched by ID
                                'enrollmentId': event.enrollmentId,
                              }),
                              child: card,
                            );
                          } else if (isMess) {
                            card = GestureDetector(
                              onTap: () => context.push('/mess'),
                              child: card,
                            );
                          }

                          return TimelineItem(
                            time: timeStr,
                            child: card,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showGlobalFabMenu(context),
        backgroundColor: AppColors.textMain,
        child: const Icon(Ionicons.grid, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
