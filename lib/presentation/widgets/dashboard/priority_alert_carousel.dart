import 'package:adsum/domain/models/action_item.dart';
import 'package:adsum/presentation/providers/action_center_provider.dart';
import 'package:adsum/presentation/widgets/dashboard/emergency_pinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class PriorityAlertCarousel extends ConsumerStatefulWidget {
  
  const PriorityAlertCarousel({
    required this.selectedDate, super.key,
  });
  final DateTime selectedDate;

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
    final alerts = <Map<String, dynamic>>[];

    if (_isToday(date)) {
      // TODAY: Show Action Items from Repository
      for (final item in actionItems) {
        if (item is! ActionItem) continue;

        if (item.type == ActionItemType.attendanceRisk) {
          alerts.add({
            'title': item.title,
            'subtitle': item.body,
            'time': item.payload['current_per'] ?? 'Risk Level: High',
            'color': item.accentColor,
            'label': 'ATTENDANCE',
            'icon': Ionicons.warning,
            'payload': item.payload,
          });
        } else if (item.type == ActionItemType.assignmentDue) {
          alerts.add({
            'title': item.title,
            'subtitle': item.payload['course'] ?? 'Course',
            'time': item.payload['due_text'] ?? 'Due soon',
            'color': item.accentColor,
            'label': 'ASSIGNMENT',
            'icon': Ionicons.document_text,
            'payload': item.payload,
          });
        } else if (item.type == ActionItemType.conflict) {
          final sourceA = item.payload['sourceA'] as Map<String, dynamic>?;
          final sourceB = item.payload['sourceB'] as Map<String, dynamic>?;
          alerts.add({
            'title': item.title,
            'subtitle': '${sourceA?['title'] ?? 'Event A'} vs ${sourceB?['title'] ?? 'Event B'}',
            'time': 'Action Required',
            'color': item.accentColor,
            'label': 'CONFLICT',
            'icon': Ionicons.git_merge,
            'payload': item.payload,
          });
        } else if (item.type == ActionItemType.verify) {
          alerts.add({
            'title': item.title,
            'subtitle': item.payload['course'] ?? 'Course',
            'time': 'Verification Needed',
            'color': item.accentColor,
            'label': 'VERIFY',
            'icon': Ionicons.help_circle,
            'payload': item.payload,
          });
        } else if (item.type == ActionItemType.scheduleChange) {
          alerts.add({
            'title': item.title,
            'subtitle': item.body,
            'time': 'Schedule Update',
            'color': item.accentColor,
            'label': 'CHANGE',
            'icon': Ionicons.information_circle,
            'payload': item.payload,
          });
        }
      }
    } else if (dayOffset > 0 && dayOffset <= 3) {
      // FUTURE (1-3 days): Show assignment and conflict items that are still pending
      for (final item in actionItems) {
        if (item is! ActionItem) continue;
        if (item.type == ActionItemType.assignmentDue || item.type == ActionItemType.conflict) {
          alerts.add({
            'title': item.title,
            'subtitle': item.body,
            'time': 'In $dayOffset day${dayOffset > 1 ? 's' : ''}',
            'color': item.accentColor,
            'label': item.type == ActionItemType.assignmentDue ? 'UPCOMING' : 'CONFLICT',
            'icon': item.type == ActionItemType.assignmentDue ? Ionicons.document_text : Ionicons.git_merge,
            'payload': item.payload,
          });
        }
      }
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
                    if (alert['label'] == 'ASSIGNMENT' || alert['label'] == 'UPCOMING') {
                        context.push('/assignments');
                    } else if (alert['label'] == 'ATTENDANCE') {
                        context.push('/subject-detail', extra: {
                            'title': alert['payload']?['course'] ?? 'Course',
                            'code': 'N/A'
                        });
                    } else if (alert['label'] == 'CONFLICT' || alert['label'] == 'VERIFY' || alert['label'] == 'CHANGE') {
                        context.push('/action-center');
                    }
                },
                child: EmergencyPinner(
                  title: alert['title'] as String,
                  subtitle: alert['subtitle'] as String,
                  time: alert['time'] as String,
                  color: alert['color'] as Color,
                  label: alert['label'] as String,
                  icon: alert['icon'] as IconData,
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
              final alertColor = alerts[_currentPage]['color'] as Color;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == index ? 24 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? alertColor 
                      : alertColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
      ],
    );
  }
}
