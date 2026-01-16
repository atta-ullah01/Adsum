import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/dashboard/providers/dashboard_viewmodel.dart';
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
  @override
  void initState() {
    super.initState();
    // Initialize data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider.notifier).loadData();
    });
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
    // Watch ViewModel logic
    final vmState = ref.watch(dashboardViewModelProvider);
    final vm = ref.read(dashboardViewModelProvider.notifier);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(vmState),

            // Date Strip
            DateStrip(
              initialDate: vmState.selectedDate,
              onDateSelected: vm.selectDate,
            ),

            // Priority Alert Carousel (Pass logic if needed, but keeping simple for now)
            PriorityAlertCarousel(selectedDate: vmState.selectedDate),

            const SizedBox(height: 8),

            // Scrollable Timeline Content
            // Scrollable Timeline Content
            Expanded(
              child: _buildTimeline(vmState.timelineEvents),
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

  Widget _buildHeader(DashboardState vmState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
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
                      vmState.greeting,
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
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
                    border: Border.all(color: Colors.grey.shade100),
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
    );
  }

  Widget _buildTimeline(AsyncValue<List<ScheduleEvent>> timelineEvents) {
    return timelineEvents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (allEvents) {
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

                VoidCallback? onTap;

                // Navigate logic
                if (event.type == ScheduleEventType.exam || event.type == ScheduleEventType.event) { 
                   // Assignments & Exams -> Work Detail
                   final workData = event.metadata['work_data'] as Map<String, dynamic>?;
                   if (workData != null) {
                      onTap = () => context.push('/academics/detail', extra: workData);
                   }
                }
                
                if (onTap == null) {
                  // Fallback for course classes only (NOT exams - those need work_data)
                  if ((event.type == ScheduleEventType.classSession || event.type == ScheduleEventType.lab) && !event.isCancelled) {
                    onTap = () => context.push('/subject-detail', extra: {
                        'title': event.title,
                        'code': event.metadata['course_code'] ?? 'N/A', 
                        'enrollmentId': event.enrollmentId,
                      });
                  } else if (event.type == ScheduleEventType.conflict) {
                    onTap = () => context.push('/action-center');
                  } else if (isMess) {
                    onTap = () => context.push('/mess');
                  } else if (event.type == ScheduleEventType.personal || event.type == ScheduleEventType.holiday) {
                      // Link personal events and holidays to calendar
                    onTap = () => context.push('/calendar');
                  }
                  // Note: Exams without work_data will have no tap action (graceful fallback)
                }

                Widget card = ScheduleCard(
                  tag: isMess ? 'Mess' : (event.type.name[0].toUpperCase() + event.type.name.substring(1)),
                  tagColor: bgColor,
                  tagTextColor: mainColor,
                  title: event.title,
                  subtitle: event.subtitle,
                  leftBorderColor: mainColor,
                  isLive: event.isCurrent && !isMess,
                  isExam: event.type == ScheduleEventType.exam,
                  isCancelled: event.isCancelled,
                  onTap: onTap,
                  
                  // Voting / Social Proof (Academic Only)
                  showVoting: event.type.isAcademic && !event.isCancelled,
                  voteCount: (event.isCurrent || event.isPast) ? (event.id.hashCode % 30 + 10) : 0, // Mock count

                  onPulseTap: (event.isCurrent && !isMess) 
                      ? () => showLiveDiagnostics(context) 
                      : null,
                );

                return TimelineItem(
                  key: ValueKey(event.id),
                  time: timeStr,
                  child: card,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

