import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/dashboard/emergency_pinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:adsum/presentation/providers/action_center_provider.dart';
import 'package:adsum/domain/models/action_item.dart';
import 'package:go_router/go_router.dart';

class PriorityAlertCarousel extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  
  const PriorityAlertCarousel({
    super.key,
    required this.selectedDate,
  });

  @override
  ConsumerState<PriorityAlertCarousel> createState() => _PriorityAlertCarouselState();
}

class _PriorityAlertCarouselState extends ConsumerState<PriorityAlertCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  bool _isPast(DateTime date) {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return date.isBefore(todayStart);
  }

  int _getDayOffset(DateTime date) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final dateStart = DateTime(date.year, date.month, date.day);
    return dateStart.difference(todayStart).inDays;
  }

  List<Map<String, dynamic>> _getAlertsForDate(DateTime date, List<dynamic /*ActionItem*/ > actionItems) {
    // Don't show alerts for past dates
    if (_isPast(date)) {
      return [];
    }

    final dayOffset = _getDayOffset(date);
    List<Map<String, dynamic>> alerts = [];

    if (_isToday(date)) {
      // TODAY: Show Mock Exam + Action Items
      
      // 1. Mock Exam (Calendar Event)
      alerts.add({
        'title': 'Mid-Term Exam: DAA',
        'subtitle': 'Lecture Hall Complex • Room 405',
        'time': 'Starts in 45m',
        'color': AppColors.danger,
        'label': 'URGENT',
        'icon': Ionicons.alert_circle,
      });

      // 2. Action Items from Provider
      for (final item in actionItems) {
        // Cast check (dynamic list to support legacy calls if any, though provider gives ActionItem)
        if (item is! ActionItem) continue;

        if (item.type == ActionItemType.attendanceRisk) {
          alerts.add({
            'title': item.title,
            'subtitle': item.body ?? 'Attendance critical',
            'time': 'Risk Level: High',
            'color': Colors.orange,
            'label': 'ATTENDANCE',
            'icon': Ionicons.warning,
          });
        } else if (item.type == ActionItemType.assignmentDue) {
          alerts.add({
            'title': item.title,
            'subtitle': item.body ?? 'Submission pending',
            'time': 'Due soon',
            'color': Colors.blue,
            'label': 'ASSIGNMENT',
            'icon': Ionicons.document_text,
          });
        } else if (item.type == ActionItemType.conflict) {
           alerts.add({
            'title': item.title,
            'subtitle': 'Schedule Conflict Detected',
            'time': 'Action Required',
            'color': AppColors.danger,
            'label': 'CONFLICT',
            'icon': Ionicons.git_merge, // or alert
          });
        }
      }

    } else if (dayOffset == 1) {
      // TOMORROW: Show upcoming items
      alerts.add({
        'title': 'Study Group Session',
        'subtitle': 'Library Room 201',
        'time': 'Tomorrow 3 PM',
        'color': Colors.purple,
        'label': 'REMINDER',
        'icon': Ionicons.people,
      });
    } else if (dayOffset == 2) {
      // DAY +2: Exam day
      alerts.add({
        'title': 'Mid-Term: Data Structures',
        'subtitle': 'Exam Hall • 3 Hour Duration',
        'time': 'In 2 days',
        'color': AppColors.danger,
        'label': 'EXAM',
        'icon': Ionicons.school,
      });
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final actionItemsAsync = ref.watch(actionCenterProvider);
    final actionItems = actionItemsAsync.asData?.value ?? [];

    final alerts = _getAlertsForDate(widget.selectedDate, actionItems);

    // Hide carousel if no alerts
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Reset page if out of bounds (e.g. list shrank)
    if (_currentPage >= alerts.length) {
      _currentPage = 0;
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: alerts.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return GestureDetector(
                onTap: () {
                    if (alert['label'] == 'ASSIGNMENT') {
                        context.push('/assignments');
                    } else if (alert['label'] == 'ATTENDANCE' || alert['label'] == 'EXAM') {
                        context.push('/subject-detail', extra: {
                            'title': 'Course Name', // Mock fallback
                            'code': 'CS-XXX'
                        });
                    } else if (alert['label'] == 'CONFLICT') {
                        context.push('/action-center');
                    }
                },
                child: EmergencyPinner(
                  title: alert['title']!,
                  subtitle: alert['subtitle']!,
                  time: alert['time']!,
                  color: alert['color'],
                  label: alert['label'],
                  icon: alert['icon'],
                ),
              );
            },
          ),
        ),
        // Dot Indicators (only if more than 1 alert)
        if (alerts.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(alerts.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == index ? 24 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? alerts[_currentPage]['color'] 
                      : (alerts[_currentPage]['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
      ],
    );
  }
}
