import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/cr/cr_tools_sheet.dart';
import 'package:adsum/presentation/widgets/dashboard/date_strip.dart';
import 'package:adsum/presentation/widgets/dashboard/live_diagnostics_sheet.dart';
import 'package:adsum/presentation/widgets/dashboard/priority_alert_carousel.dart';
import 'package:adsum/presentation/widgets/dashboard/schedule_card.dart';
import 'package:adsum/presentation/widgets/dashboard/timeline_item.dart';
import 'package:adsum/presentation/widgets/global/global_fab_menu.dart';
import 'package:adsum/presentation/widgets/global/global_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();

  // Mock data for multiple dates
  // Key: day offset from today (0 = today, -1 = yesterday, 1 = tomorrow)
  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final today = DateTime.now();
    final dayDiff = date.difference(DateTime(today.year, today.month, today.day)).inDays;

    // Common mess events (appear every day)
    final messEvents = [
      {
        'time': '08:00 AM',
        'sortTime': 800,
        'type': 'Mess',
        'title': 'Breakfast',
        'subtitle': _getBreakfastForDay(date.weekday),
        'color': Colors.grey.shade700,
        'bgColor': Colors.grey.shade100,
        'borderColor': Colors.grey,
      },
      {
        'time': '12:30 PM',
        'sortTime': 1230,
        'type': 'Mess',
        'title': 'Lunch',
        'subtitle': _getLunchForDay(date.weekday),
        'color': Colors.grey.shade700,
        'bgColor': Colors.grey.shade100,
        'borderColor': Colors.grey,
      },
    ];

    // Date-specific events
    if (dayDiff == 0) {
      // TODAY
      return [
        {
          'time': '07:00 AM',
          'sortTime': 700,
          'type': 'Personal',
          'title': 'Gym Session',
          'subtitle': 'Cardio & Abs',
          'color': Colors.purple,
          'bgColor': Colors.purple.shade50,
          'borderColor': Colors.purple,
        },
        ...messEvents,
        {
          'time': '09:30 AM',
          'sortTime': 930,
          'type': 'Lecture',
          'title': 'Mobile App Design',
          'subtitle': 'LH-102 • Prof. Sarah',
          'color': Colors.grey,
          'bgColor': const Color(0xFFEEEEEE),
          'borderColor': AppColors.primary,
          'avatars': ['1', '2', '3', '4'],
          'isLive': true,
        },
        {
          'time': '10:30 AM',
          'sortTime': 1030,
          'type': 'Rescheduled',
          'title': 'Data Structures',
          'subtitle': 'From 9:30 AM • LH-102',
          'color': Colors.blue,
          'bgColor': Colors.blue.shade50,
          'borderColor': Colors.blue,
        },
        {
          'time': '11:00 AM',
          'sortTime': 1100,
          'type': 'Cancelled',
          'title': 'Website Design',
          'subtitle': 'CR: "Prof on leave"',
          'color': Colors.red,
          'bgColor': Colors.red.shade50,
          'borderColor': Colors.red,
          'isCancelled': true,
        },
        {
          'time': '02:00 PM',
          'sortTime': 1400,
          'type': 'Quiz',
          'title': 'Math Quiz 1',
          'subtitle': 'LH-2 • 30 Mins',
          'color': const Color(0xFFB45309),
          'bgColor': AppColors.pastelYellow,
          'borderColor': AppColors.accent,
          'isExam': true,
        },
        {
          'time': '04:00 PM',
          'sortTime': 1600,
          'type': 'Extra Class',
          'title': 'Linear Algebra',
          'subtitle': 'C-201 • Prof. Sharma',
          'color': AppColors.primary,
          'bgColor': AppColors.pastelBlue,
          'borderColor': AppColors.primary,
        },
      ];
    } else if (dayDiff == 1) {
      // TOMORROW
      return [
        ...messEvents,
        {
          'time': '09:00 AM',
          'sortTime': 900,
          'type': 'Lecture',
          'title': 'Database Systems',
          'subtitle': 'LH-3 • Prof. Kumar',
          'color': Colors.grey,
          'bgColor': const Color(0xFFEEEEEE),
          'borderColor': AppColors.primary,
        },
        {
          'time': '11:00 AM',
          'sortTime': 1100,
          'type': 'Lecture',
          'title': 'Operating Systems',
          'subtitle': 'LH-1 • Prof. Mehta',
          'color': Colors.grey,
          'bgColor': const Color(0xFFEEEEEE),
          'borderColor': AppColors.primary,
        },
        {
          'time': '03:00 PM',
          'sortTime': 1500,
          'type': 'Personal',
          'title': 'Study Group',
          'subtitle': 'Library • Room 201',
          'color': Colors.purple,
          'bgColor': Colors.purple.shade50,
          'borderColor': Colors.purple,
        },
      ];
    } else if (dayDiff == -1) {
      // YESTERDAY
      return [
        ...messEvents,
        {
          'time': '10:00 AM',
          'sortTime': 1000,
          'type': 'Lecture',
          'title': 'Computer Networks',
          'subtitle': 'LH-2 • Prof. Singh',
          'color': Colors.grey,
          'bgColor': const Color(0xFFEEEEEE),
          'borderColor': AppColors.primary,
        },
        {
          'time': '02:00 PM',
          'sortTime': 1400,
          'type': 'Laboratory',
          'title': 'Networks Lab',
          'subtitle': 'Lab 101',
          'color': AppColors.secondary,
          'bgColor': const Color(0xFFFFECE6),
          'borderColor': AppColors.secondary,
        },
      ];
    } else if (dayDiff == 2) {
      // DAY AFTER TOMORROW - Example: Exam Day
      return [
        ...messEvents,
        {
          'time': '09:00 AM',
          'sortTime': 900,
          'type': 'Exam',
          'title': 'Mid-Term: Data Structures',
          'subtitle': 'Exam Hall • 3 Hours',
          'color': const Color(0xFFB45309),
          'bgColor': AppColors.pastelYellow,
          'borderColor': AppColors.accent,
          'isExam': true,
        },
      ];
    } else {
      // Other days - just mess and a few classes
      return [
        ...messEvents,
        {
          'time': '10:00 AM',
          'sortTime': 1000,
          'type': 'Lecture',
          'title': 'Algorithms',
          'subtitle': 'LH-1 • Prof. Roy',
          'color': Colors.grey,
          'bgColor': const Color(0xFFEEEEEE),
          'borderColor': AppColors.primary,
        },
      ];
    }
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
    return items[weekday - 1];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    // Get events for selected date and sort
    final timelineEvents = _getEventsForDate(_selectedDate);
    timelineEvents.sort((a, b) => (a['sortTime'] as int).compareTo(b['sortTime'] as int));

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

            // Priority Alert Carousel (conditionally visible)
            PriorityAlertCarousel(selectedDate: _selectedDate),

            const SizedBox(height: 8),

            // Scrollable Timeline Content
            Expanded(
              child: Stack(
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

                  // Show "No Events" if empty
                  if (timelineEvents.isEmpty)
                    Center(
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
                    )
                  else
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: timelineEvents.length,
                      itemBuilder: (context, index) {
                        final event = timelineEvents[index];

                        Widget card = ScheduleCard(
                          tag: event['type'],
                          tagColor: event['bgColor'],
                          tagTextColor: event['color'],
                          title: event['title'],
                          subtitle: event['subtitle'],
                          leftBorderColor: event['borderColor'],
                          avatars: event['avatars'] ?? [],
                          isLive: event['isLive'] ?? false,
                          isExam: event['isExam'] ?? false,
                          onPulseTap: event['isLive'] == true ? () => showLiveDiagnostics(context) : null,
                        );

                        // Wrap cancelled in opacity
                        if (event['isCancelled'] == true) {
                          card = Opacity(opacity: 0.6, child: card);
                        }

                        // Navigate to details on tap
                        if (['Lecture', 'Rescheduled', 'Extra Class', 'Cancelled', 'Laboratory', 'Exam', 'Quiz'].contains(event['type'])) {
                          card = GestureDetector(
                            onTap: () => context.push('/subject-detail', extra: {
                              'title': event['title'],
                              'code': 'CS-XXX',
                            }),
                            child: card,
                          );
                        } else if (event['type'] == 'Mess') {
                           card = GestureDetector(
                             onTap: () => context.push('/mess'),
                             child: card,
                           );
                        } else if (event['type'] == 'Personal') {
                           card = GestureDetector(
                             onTap: () => context.push('/calendar'),
                             child: card,
                           );
                        }

                        return TimelineItem(
                          time: event['time'],
                          child: card,
                        );
                      },
                    ),
                ],
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
