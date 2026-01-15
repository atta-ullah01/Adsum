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

  // Convert MessMenu items to ScheduleEvents for timeline display
  List<ScheduleEvent> _convertMessToEvents(List<MessMenu> menus, DateTime date) {
    final events = <ScheduleEvent>[];
    
    for (final menu in menus) {
      final timeParts = menu.startTime.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 8;
      final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
      final startTime = DateTime(date.year, date.month, date.day, hour, minute);
      
      final endParts = menu.endTime.split(':');
      final endHour = int.tryParse(endParts[0]) ?? hour + 1;
      final endMinute = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0;
      final endTime = DateTime(date.year, date.month, date.day, endHour, endMinute);
      
      events.add(ScheduleEvent(
        id: 'mess_${menu.menuId}',
        title: menu.mealType.displayName,
        subtitle: menu.items,
        startTime: startTime,
        endTime: endTime,
        type: ScheduleEventType.event,
        color: '#616161',
        metadata: {'isMess': true, 'bgColor': '#F5F5F5'},
      ));
    }
    
    return events;
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
                    Consumer(
                      builder: (context, ref, _) {
                        final userAsync = ref.watch(userProfileProvider);
                        final userName = userAsync.maybeWhen(
                          data: (user) => user?.fullName ?? 'User',
                          orElse: () => 'User',
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        );
                      },
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
              child: Consumer(
                builder: (context, ref, _) {
                  final scheduleResult = ref.watch(scheduleForDateProvider(_selectedDate));
                  final messDay = MessDayOfWeek.fromDateTime(_selectedDate);
                  final messMenusAsync = ref.watch(messMenuForDayProvider(messDay));
                  
                  // Extract mess menus from AsyncValue (default to empty if loading/error)
                  final messMenus = messMenusAsync.maybeWhen(
                    data: (menus) => menus,
                    orElse: () => <MessMenu>[],
                  );
                  
                  return scheduleResult.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (events) {
                      // Convert and merge mess events
                      final messEvents = _convertMessToEvents(messMenus, _selectedDate);
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
                            isLive: event.isCurrent && !isMess,
                            isExam: event.type == ScheduleEventType.exam,
                            
                            // Voting / Social Proof (Academic Only)
                            showVoting: event.type.isAcademic && !event.isCancelled,
                            voteCount: (event.isCurrent || event.isPast) ? (event.id.hashCode % 30 + 10) : 0, // Mock count

                            
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
                                'code': event.metadata['course_code'] ?? 'N/A', 
                                'enrollmentId': event.enrollmentId,
                              }),
                              child: card,
                            );
                          } else if (event.type == ScheduleEventType.conflict) {
                             card = GestureDetector(
                               onTap: () => context.push('/action-center'),
                               child: card,
                             );
                          } else if (isMess) {
                            card = GestureDetector(
                              onTap: () => context.push('/mess'),
                              child: card,
                            );
                          } else if (event.type == ScheduleEventType.personal || event.type == ScheduleEventType.holiday || event.type == ScheduleEventType.exam) {
                             // Link exams and personal events (that aren't academic sessions) to calendar
                             card = GestureDetector(
                               onTap: () => context.push('/calendar'),
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
