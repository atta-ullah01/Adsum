import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:adsum/presentation/pages/calendar/add_event_page.dart';

class AcademicCalendarPage extends StatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  DateTime _focusedMonth = DateTime(2026, 1);
  DateTime _selectedDay = DateTime.now();
  
  // Mock Data
  final Map<String, List<Map<String, dynamic>>> _events = {
    "2025-11": [
      {"date": DateTime(2025, 11, 4), "title": "Diwali", "type": "Holiday", "source": "Admin", "isActive": true},
      {"date": DateTime(2025, 11, 14), "title": "Children's Day", "type": "DaySwap", "order": "Fri", "source": "Admin", "isActive": true},
    ],
    "2025-12": [
      {"date": DateTime(2025, 12, 12), "title": "End Semester Exams", "type": "Exam", "source": "Admin", "isActive": true},
      {"date": DateTime(2025, 12, 25), "title": "Christmas", "type": "Holiday", "source": "Admin", "isActive": true},
    ],
    "2026-01": [
      {"date": DateTime(2026, 01, 01), "title": "New Year", "type": "Holiday", "source": "Admin", "isActive": true},
      {"date": DateTime(2026, 01, 10), "title": "CS101 Cancelled", "type": "Cancel", "source": "CR", "isActive": true, "course": "CS101"},
      {"date": DateTime(2026, 01, 12), "title": "PH100 Rescheduled to 3 PM", "type": "Reschedule", "source": "CR", "isActive": true, "course": "PH100", "newTime": "15:00"},
      {"date": DateTime(2026, 01, 14), "title": "MA102 Extra Class", "type": "ExtraClass", "source": "CR", "isActive": true, "course": "MA102", "time": "16:00"},
      {"date": DateTime(2026, 01, 15), "title": "CS101 Assignment 1", "type": "Assignment", "source": "Course", "isActive": true, "dueAt": "23:59"},
      {"date": DateTime(2026, 01, 15), "title": "Math Quiz 1", "type": "Quiz", "source": "Course", "isActive": true, "dueAt": "14:00"}, // Same day as assignment
      {"date": DateTime(2026, 01, 15), "title": "Gym Session", "type": "Personal", "source": "User", "isActive": true}, // Same day
      {"date": DateTime(2026, 01, 26), "title": "Republic Day", "type": "Holiday", "source": "Admin", "isActive": true},
      {"date": DateTime(2026, 01, 27), "title": "Following Monday Schedule", "type": "DaySwap", "order": "Mon", "source": "CR", "isActive": true},
    ],
    "2026-04": [
       {"date": DateTime(2026, 04, 04), "title": "Mahavir Jayanti", "type": "Holiday", "source": "Admin", "isActive": true},
       {"date": DateTime(2026, 04, 07), "title": "Good Friday", "type": "Holiday", "source": "Admin", "isActive": true},
       {"date": DateTime(2026, 04, 14), "title": "Dr. Ambedkar Jayanti", "type": "Holiday", "source": "Admin", "isActive": true},
    ]
  };

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
            onPressed: () => context.push('/calendar/inject'),
            tooltip: "Import Holidays",
          )
        ],
      ),
      body: Column(
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
                      Text(
                        DateFormat("MMMM yyyy").format(_focusedMonth),
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
                      return _buildDayCell(day);
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
              child: _buildAgendaList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEventPage(initialDate: _selectedDay))
          );
          
          if (result != null && result is Map) {
             setState(() {
                DateTime d = result['date'];
                String key = DateFormat("yyyy-MM").format(d);
                if (!_events.containsKey(key)) _events[key] = [];
                _events[key]!.add(result as Map<String, dynamic>);
             });
          }
        },
        backgroundColor: Colors.black,
        icon: const Icon(Ionicons.add, color: Colors.white),
        label: Text("Event", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    List<Map<String, dynamic>> events = _getEventsOnDate(day);
    bool isSelected = isSameDay(day, _selectedDay);
    bool isToday = isSameDay(day, DateTime.now());
    
    // Get unique marker colors for this day
    List<Color> markerColors = events.where((e) => e['isActive']).map((event) {
      if (event['type'] == 'Holiday') return AppColors.danger;
      if (event['type'] == 'Exam' || event['type'] == 'Quiz') return AppColors.accent;
      if (['Cancel', 'Reschedule', 'ExtraClass', 'DaySwap'].contains(event['type'])) return AppColors.primary;
      if (event['type'] == 'Personal') return AppColors.secondary;
      if (event['type'] == 'Assignment') return Colors.orange;
      return Colors.grey;
    }).toSet().toList(); // Remove duplicates

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

  Widget _buildAgendaList() {
    List<Map<String, dynamic>> dayEvents = _getEventsOnDate(_selectedDay);
    
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
        ),
          
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

  Widget _buildEventDetailsCard(Map<String, dynamic> event) {
    bool isHoliday = event['type'] == "Holiday";
    bool isExam = event['type'] == "Exam";
    bool isAssignment = event['type'] == "Assignment";
    bool isQuiz = event['type'] == "Quiz";
    bool isCRModification = ['Cancel', 'Reschedule', 'ExtraClass', 'DaySwap'].contains(event['type']);
    bool isActive = event['isActive'];
    
    // Premium Colors
    // Exam and Quiz share the same color (Yellow/Accent)
    // CR Modifications (Cancel, Reschedule, ExtraClass, DaySwap) share blue
    Color bgDate = isHoliday ? AppColors.pastelPink : ((isExam || isQuiz) ? AppColors.pastelYellow : (isCRModification ? AppColors.pastelBlue : AppColors.pastelBlue));
    Color textDate = isHoliday ? AppColors.danger : ((isExam || isQuiz) ? const Color(0xFFB45309) : (isCRModification ? AppColors.primary : AppColors.primary));
    
    if (event['type'] == 'Personal') {
       bgDate = AppColors.pastelPurple;
       textDate = AppColors.secondary;
    } else if (isAssignment) {
       bgDate = Colors.orange.shade50;
       textDate = Colors.orange;
    }
    // Quiz color logic removed as it now shares with Exam

    return FadeSlideTransition(
      index: 0,
      child: InkWell(
        onTap: () => _showDayOrderSheet(event),
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
                     child: Text(event['type'].toUpperCase(), style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: textDate)),
                   ),
                   if (isActive)
                     Icon(Ionicons.notifications_outline, color: textDate, size: 20)
                 ],
               ),
               const SizedBox(height: 16),
               Text(event['title'], style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
               if (event.containsKey('description') && event['description'].isNotEmpty)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(event['description'], style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey)),
                 ),
                 
               const SizedBox(height: 24),
               const Divider(),
               const SizedBox(height: 16),
               
               Row(
                 children: [
                    _buildMetaItem(Ionicons.person_outline, "Source: ${event['source']}"),
                    if (event.containsKey('order')) ...[
                       const SizedBox(width: 24),
                       _buildMetaItem(Ionicons.swap_horizontal, "Follows ${event['order']}"),
                    ],
                    if (event.containsKey('dueAt')) ...[
                       const SizedBox(width: 24),
                       _buildMetaItem(Ionicons.time_outline, "Due: ${event['dueAt']}"),
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
  
  Map<String, dynamic>? _getEventOnDate(DateTime date) {
    String key = DateFormat("yyyy-MM").format(date);
    if (!_events.containsKey(key)) return null;
    try {
      return _events[key]!.firstWhere((e) => isSameDay(e['date'], date));
    } catch (e) {
      return null;
    }
  }
  
  // NEW: Get ALL events on a specific date
  List<Map<String, dynamic>> _getEventsOnDate(DateTime date) {
    String key = DateFormat("yyyy-MM").format(date);
    if (!_events.containsKey(key)) return [];
    return _events[key]!.where((e) => isSameDay(e['date'], date)).toList();
  }
  
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // Keep _showDayOrderSheet mostly same, just update styles if needed
  void _showDayOrderSheet(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text("Edit Day Details", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
            Text("Date: ${DateFormat("EEEE, d MMMM yyyy").format(event['date'])}", style: GoogleFonts.dmSans(color: Colors.grey)),
            
            const SizedBox(height: 24),
            
            // Toggle Active
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Active Event", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              trailing: Switch(
                value: event['isActive'], 
                onChanged: (val) {
                  setState(() => event['isActive'] = val);
                  Navigator.pop(context);
                },
                activeThumbColor: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (event['isActive'] && (event['type'] == 'DaySwap' || event['type'] == 'Holiday')) ...[
               Text("Day Order Override", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey)),
               const SizedBox(height: 12),
               Wrap(
                 spacing: 8,
                 children: ["Default", "Mon", "Tue", "Wed", "Thu", "Fri"].map((day) {
                   bool isSelected = (event['order'] ?? "Default") == day || (day == "Default" && !event.containsKey('order'));
                   return ChoiceChip(
                     label: Text(day),
                     selected: isSelected,
                     onSelected: (val) {
                       setState(() {
                         if (day == "Default") {
                           event.remove('order');
                           if (event['title'].contains("Holiday")) event['type'] = "Holiday";
                         } else {
                           event['order'] = day;
                           event['type'] = "DaySwap";
                         }
                         event['source'] = "User";
                       });
                       Navigator.pop(context);
                     },
                     selectedColor: Colors.black,
                     labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                   );
                 }).toList(),
               )
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
