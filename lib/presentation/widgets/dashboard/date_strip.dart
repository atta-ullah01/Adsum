import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateStrip extends StatefulWidget {

  const DateStrip({
    required this.initialDate, super.key,
    this.onDateSelected,
    this.enablePast = true,
    this.daysCount = 7,
  });
  final DateTime initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final bool enablePast;
  final int daysCount;

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late int _selectedIndex;
  late List<DateTime> _weekDates;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    // If past is disabled, start from today
    final startOffset = widget.enablePast ? -3 : 0;
    
    _weekDates = List.generate(widget.daysCount, (i) => DateTime(
      _today.year, _today.month, _today.day
    ).add(Duration(days: startOffset + i)));
    
    // Find index of initial date
    _selectedIndex = _weekDates.indexWhere(
      (d) => d.day == widget.initialDate.day && 
             d.month == widget.initialDate.month &&
             d.year == widget.initialDate.year
    );
    
    // Default to first available if not found or invalid
    if (_selectedIndex == -1) _selectedIndex = 0;
    
    // If enabling past, try to center today (index 3) if initial is today
    if (widget.enablePast && _selectedIndex == -1) _selectedIndex = 3;
  }

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    return date.day == _today.day && 
           date.month == _today.month && 
           date.year == _today.year;
  }

  bool _isPast(DateTime date) {
    final todayStart = DateTime(_today.year, _today.month, _today.day);
    return date.isBefore(todayStart);
  }

  // Mock: check if date has events (for demo, dates with day > 10 have events)
  bool _hasEvents(DateTime date) {
    return date.day % 2 == 1 || _isToday(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // Slightly taller to accommodate "Today" label
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _weekDates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = _weekDates[index];
          final isSelected = index == _selectedIndex;
          final isToday = _isToday(date);
          final isPast = _isPast(date);
          final hasEvent = _hasEvents(date);
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onDateSelected?.call(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                // Selected: Dark fill
                // Today (not selected): Primary color ring
                // Past (not selected): Slightly grey
                // Future (not selected): White
                color: isSelected 
                    ? AppColors.textMain 
                    : (isPast ? Colors.grey.shade50 : Colors.white),
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected 
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))] 
                  : [],
                border: Border.all(
                  color: isToday && !isSelected 
                      ? AppColors.primary 
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Today" label or Day name
                  Text(
                    isToday ? 'Today' : _dayName(date),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Colors.white70 
                          : (isToday ? AppColors.primary : (isPast ? Colors.grey.shade400 : Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Date number
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Colors.white 
                          : (isPast ? Colors.grey.shade400 : AppColors.textMain),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Event dot indicator
                  Container(
                    width: 4, height: 4,
                    decoration: BoxDecoration(
                      color: hasEvent 
                          ? (isSelected ? AppColors.pastelYellow : AppColors.primary) 
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
