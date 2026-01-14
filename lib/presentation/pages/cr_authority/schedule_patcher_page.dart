import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

// --- Models ---

enum CRStatus { authorized, pending, none }

class CourseAccess {
  final String code;
  final String title;
  final String section;
  final CRStatus status;
  final Color pastelColor;

  CourseAccess({
    required this.code,
    required this.title,
    required this.section,
    required this.status,
    required this.pastelColor,
  });
}

class ScheduleSlot {
  final String id;
  final String day;
  final String time;
  final String location;
  final String type; // Lecture, Lab, Tutorial
  final int weekday; // 1=Monday, 7=Sunday (matches DateTime.weekday)

  ScheduleSlot({
    required this.id,
    required this.day,
    required this.time,
    required this.location,
    required this.type,
    required this.weekday,
  });
  
  String get displayLabel => "$day • $time • $location";
}

// --- Page ---

class SchedulePatcherPage extends StatefulWidget {
  const SchedulePatcherPage({super.key});

  @override
  State<SchedulePatcherPage> createState() => _SchedulePatcherPageState();
}

class _SchedulePatcherPageState extends State<SchedulePatcherPage> {
  
  // --- Mock Data ---
  final List<CourseAccess> _courses = [
    CourseAccess(code: 'CS101', title: 'Intro to CS', section: 'A', status: CRStatus.authorized, pastelColor: const Color(0xFFFFEAD1)),
    CourseAccess(code: 'PH100', title: 'Physics', section: 'B', status: CRStatus.none, pastelColor: const Color(0xFFE2F6E9)),
    CourseAccess(code: 'MA201', title: 'Calculus', section: 'A', status: CRStatus.pending, pastelColor: const Color(0xFFE8E2F6)),
  ];

  List<ScheduleSlot> _getSlots(String courseCode) {
    // In real app, fetch from enrollments.json or global_schedules
    return [
      ScheduleSlot(id: '1', day: 'Monday', time: '09:00 - 10:00', location: 'LH-102', type: 'Lecture', weekday: 1),
      ScheduleSlot(id: '2', day: 'Wednesday', time: '09:00 - 10:00', location: 'LH-102', type: 'Lecture', weekday: 3),
      ScheduleSlot(id: '3', day: 'Friday', time: '14:00 - 16:00', location: 'Lab 2', type: 'Lab', weekday: 5),
    ];
  }

  // --- State ---
  late CourseAccess _selectedCourse;
  String? _selectedAction; // CANCEL, RESCHEDULE, EXTRA, SWAP
  ScheduleSlot? _selectedSlot;
  DateTime? _affectedDate; // Date of original class being modified
  DateTime? _newDate; // New date (for Reschedule/Extra)
  TimeOfDay _newStartTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _newEndTime = const TimeOfDay(hour: 11, minute: 0);
  final _locationController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCourse = _courses.first;
  }

  bool get _needsSlotSelection => _selectedAction == 'CANCEL' || _selectedAction == 'RESCHEDULE' || _selectedAction == 'SWAP';
  bool get _needsAffectedDate => _selectedAction == 'CANCEL' || _selectedAction == 'RESCHEDULE' || _selectedAction == 'SWAP';
  bool get _needsNewDateTime => _selectedAction == 'RESCHEDULE' || _selectedAction == 'EXTRA';
  bool get _needsNewLocation => _selectedAction == 'RESCHEDULE' || _selectedAction == 'EXTRA' || _selectedAction == 'SWAP';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CR Authority", style: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Ionicons.close, color: Colors.black), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Course Selector
            Text("Courses", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: _courses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) => _buildCourseCard(_courses[i]),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Content (based on auth status)
            if (_selectedCourse.status == CRStatus.authorized)
              _buildPatcherFlow()
            else
              _buildUnauthorizedView(),
          ],
        ),
      ),
      bottomSheet: _canSubmit() ? _buildSubmitSheet() : null,
    );
  }

  // --- Course Card ---
  Widget _buildCourseCard(CourseAccess course) {
    final isSelected = _selectedCourse == course;
    return GestureDetector(
      onTap: () => setState(() { 
        _selectedCourse = course; 
        _selectedAction = null; 
        _selectedSlot = null; 
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: course.pastelColor,
          borderRadius: BorderRadius.circular(28),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(course.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("${course.code} • ${course.section}", style: GoogleFonts.dmSans(fontSize: 11, color: Colors.black54)),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(_statusIcon(course.status), size: 14, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(CRStatus s) {
    switch(s) {
      case CRStatus.authorized: return Ionicons.key;
      case CRStatus.pending: return Ionicons.time;
      case CRStatus.none: return Ionicons.lock_closed;
    }
  }

  // --- Patcher Flow ---
  Widget _buildPatcherFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Action Selector
        Text("What do you want to do?", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildActionChip("Cancel", Ionicons.close_circle, Colors.red, 'CANCEL'),
            _buildActionChip("Reschedule", Ionicons.calendar, Colors.blue, 'RESCHEDULE'),
            _buildActionChip("Extra Class", Ionicons.add_circle, Colors.green, 'EXTRA'),
            _buildActionChip("Swap Room", Ionicons.swap_horizontal, Colors.purple, 'SWAP'),
          ],
        ),

        if (_selectedAction != null) ...[
          const SizedBox(height: 28),
          
          // Step 2 (conditional): Slot Selection - for Cancel, Reschedule, Swap
          if (_needsSlotSelection) ...[
            Text("Which slot?", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._getSlots(_selectedCourse.code).map((s) => _buildSlotTile(s)),
            const SizedBox(height: 24),
          ],

          // Step 3a: Affected Date - "Which occurrence?" (for Cancel, Reschedule, Swap)
          if (_needsAffectedDate) ...[
            Text("Which date is affected?", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDatePicker(
              _affectedDate, 
              (d) => setState(() => _affectedDate = d),
              restrictToWeekday: _selectedSlot?.weekday,
            ),
            const SizedBox(height: 24),
          ],

          // Step 3b: New Date/Time - for Reschedule and Extra Class
          if (_needsNewDateTime) ...[
            Text(_selectedAction == 'EXTRA' ? "When?" : "Reschedule to:", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // New Date (same day or different)
            _buildDatePicker(_newDate, (d) => setState(() => _newDate = d), label: _selectedAction == 'EXTRA' ? "Date" : "New Date"),
            const SizedBox(height: 12),
            // New Time
            Row(
              children: [
                Expanded(child: _buildTimePicker("Start", _newStartTime, (t) => setState(() => _newStartTime = t))),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker("End", _newEndTime, (t) => setState(() => _newEndTime = t))),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Step 4: New Location - for Reschedule, Extra, Swap
          if (_needsNewLocation) ...[
            Text("New Location", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInputBox(_locationController, "e.g. LH-201, Lab 3", Ionicons.location_outline),
            const SizedBox(height: 24),
          ],

          // Step 5: Reason - always required
          Text("Reason", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInputBox(_reasonController, "Why this change?", Ionicons.chatbubble_outline, maxLines: 2),
          
          const SizedBox(height: 100), // Space for bottom sheet
        ],
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, Color color, String value) {
    final isSelected = _selectedAction == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAction = value;
        _selectedSlot = null;
        _affectedDate = null;
        _newDate = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textMain)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotTile(ScheduleSlot slot) {
    final isSelected = _selectedSlot?.id == slot.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSlot = slot),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Ionicons.radio_button_on : Ionicons.radio_button_off, 
                 color: isSelected ? AppColors.primary : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${slot.day} • ${slot.time}", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  Text("${slot.type} @ ${slot.location}", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(DateTime? date, ValueChanged<DateTime> onPicked, {String label = "Select Date", int? restrictToWeekday}) {
    // Check if current date is valid for the weekday restriction
    bool hasWarning = restrictToWeekday != null && date != null && date.weekday != restrictToWeekday;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? _findNextWeekday(DateTime.now(), restrictToWeekday),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              selectableDayPredicate: restrictToWeekday != null
                  ? (d) => d.weekday == restrictToWeekday
                  : null,
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasWarning ? Colors.red.shade50 : Colors.grey.shade50, 
              borderRadius: BorderRadius.circular(20),
              border: hasWarning ? Border.all(color: Colors.red, width: 2) : null,
            ),
            child: Row(
              children: [
                Icon(Ionicons.calendar_outline, color: hasWarning ? Colors.red : Colors.grey),
                const SizedBox(width: 12),
                Text(
                  date == null ? label : "${date.day}/${date.month}/${date.year}",
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: date == null ? Colors.grey : (hasWarning ? Colors.red : AppColors.textMain)),
                ),
              ],
            ),
          ),
        ),
        if (hasWarning)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              "⚠️ Selected date doesn't match slot day (${_selectedSlot?.day})",
              style: GoogleFonts.dmSans(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
  
  DateTime _findNextWeekday(DateTime from, int? weekday) {
    if (weekday == null) return from;
    DateTime next = from;
    while (next.weekday != weekday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Widget _buildTimePicker(String label, TimeOfDay time, ValueChanged<TimeOfDay> onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey)),
            Text(time.format(context), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: GoogleFonts.dmSans(color: Colors.grey),
        ),
      ),
    );
  }

  // --- Unauthorized View ---
  Widget _buildUnauthorizedView() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Icon(_selectedCourse.status == CRStatus.pending ? Ionicons.hourglass_outline : Ionicons.shield_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_selectedCourse.status == CRStatus.pending ? "Request Pending" : "Unauthorized", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _selectedCourse.status == CRStatus.pending 
                ? "Admin is reviewing your request."
                : "You need approval to manage this schedule.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: Colors.grey),
          ),
          if (_selectedCourse.status == CRStatus.none) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Sent!"))),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: Text("Request Access", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  // --- Submit ---
  bool _canSubmit() {
    if (_selectedCourse.status != CRStatus.authorized) return false;
    if (_selectedAction == null) return false;
    if (_needsSlotSelection && _selectedSlot == null) return false;
    if (_needsAffectedDate && _affectedDate == null) return false;
    if (_needsNewDateTime && _newDate == null) return false;
    return true;
  }

  Widget _buildSubmitSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Patch Signed & Submitted!")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text("Sign & Submit", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
