import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/attendance/providers/history_log_viewmodel.dart';
import 'package:adsum/presentation/pages/attendance/widgets/history_calendar.dart';
import 'package:adsum/presentation/pages/attendance/widgets/history_day_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class HistoryLogPage extends ConsumerWidget {
  
  const HistoryLogPage({
    required this.courseTitle, super.key,
    this.courseCode,
  });
  final String courseTitle;
  final String? courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 0. View Model State
    final vmState = ref.watch(historyLogViewModelProvider);
    final vmNotifier = ref.read(historyLogViewModelProvider.notifier);

    // 1. Resolve Enrollment
    final enrollmentsAsync = ref.watch(enrollmentsProvider);
    final enrollment = enrollmentsAsync.asData?.value.firstWhere(
      (e) => e.courseCode == courseCode,
      orElse: () => Enrollment(enrollmentId: 'unknown', courseCode: courseCode ?? '', startDate: DateTime.now()),
    );
    
    // 2. Fetch Logs if enrollment found
    final logsAsync = enrollment?.enrollmentId != 'unknown'
        ? ref.watch(attendanceLogsProvider(enrollment!.enrollmentId))
        : const AsyncValue<List<AttendanceLog>>.data([]);
        
    // 3. Fetch Calendar Events (Holidays)
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('History Log', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              courseTitle,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Ionicons.chevron_back, size: 20, color: Colors.grey),
                  onPressed: () {
                     vmNotifier.setMonth(DateTime(vmState.currentMonth.year, vmState.currentMonth.month - 1));
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(vmState.currentMonth),
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Ionicons.chevron_forward, size: 20, color: Colors.grey),
                  onPressed: () {
                     vmNotifier.setMonth(DateTime(vmState.currentMonth.year, vmState.currentMonth.month + 1));
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            if (logsAsync.isLoading || eventsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              HistoryCalendar(
                currentMonth: vmState.currentMonth, 
                selectedDay: vmState.selectedDay, 
                logs: logsAsync.asData?.value ?? [], 
                events: eventsAsync.asData?.value ?? [],
                onDaySelected: vmNotifier.setSelectedDay,
              ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Selected Day Details
            Text(
              "Details for ${DateFormat('MMM').format(vmState.currentMonth)} ${vmState.selectedDay}",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
             if (logsAsync.hasValue && eventsAsync.hasValue)
              HistoryDayDetails(
                day: vmState.selectedDay, 
                currentMonth: vmState.currentMonth,
                logs: logsAsync.value!, 
                events: eventsAsync.value!
              ),
          ],
        ),
      ),
    );
  }
}
