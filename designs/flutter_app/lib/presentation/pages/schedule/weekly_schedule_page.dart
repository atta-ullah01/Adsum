import 'package:adsum/presentation/widgets/schedule/schedule_block.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentDayIndex = 0; // 0 = Monday

  final List<String> _days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Weekly Schedule",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Enhanced Day Selector
          Container(
            height: 90,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemBuilder: (context, index) {
                final isSelected = _currentDayIndex == index;
                // Mock dates for visual context
                final date = 16 + index; 
                
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade200, 
                        width: 1
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[index],
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$date",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 7,
              onPageChanged: (index) {
                setState(() => _currentDayIndex = index);
              },
              itemBuilder: (context, index) {
                return _buildDaySchedule(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(int dayIndex) {
    // Mock Data based on day
    if (dayIndex == 6) { // Sunday
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.cafe_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No classes today", style: GoogleFonts.dmSans(color: Colors.grey)),
          ],
        ),
      );
    }

    // Creating varied lists for demo
    List<Widget> children = [];
    
    // 9:00 AM Class (Base)
    children.add(_buildEditableBlock(const ScheduleBlock(
      time: "09:00",
      title: "Mobile App Design",
      location: "LH-102",
      source: ScheduleSource.admin,
    )));

    // 11:00 AM (CR Change - Extra Class)
    if (dayIndex == 1) { // Tuesday
       children.add(_buildEditableBlock(const ScheduleBlock(
        time: "11:00",
        title: "TOC Extra Class",
        location: "LH-201",
        source: ScheduleSource.cr,
        resolutionNote: "Replaces: Physics Lab", // Clarity: Shows what was overridden
      )));
    }
    
    // 11:00 AM (Normal Lab)
    if (dayIndex == 0) { // Monday
       children.add(_buildEditableBlock(const ScheduleBlock(
        time: "11:00",
        title: "Computer Lab",
        location: "Lab 4",
        source: ScheduleSource.admin,
      )));
    }
    
    // 2:00 PM (User Override - Bunk)
    if (dayIndex == 2) { // Wednesday
       children.add(_buildEditableBlock(const ScheduleBlock(
        time: "14:00",
        title: "Skip: Economics",
        location: "LH-105",
        source: ScheduleSource.user,
        isCancelled: true, // Visual trick to show skipped
        resolutionNote: "Conflict: Gym Session", // Clarity: Why it is skipped
      )));
    }
    
     // 4:00 PM (CR Cancelled)
    if (dayIndex == 0) { // Monday
       children.add(_buildEditableBlock(const ScheduleBlock(
        time: "16:00",
        title: "Maths Tutorial",
        location: "LH-101",
        source: ScheduleSource.cr,
        isCancelled: true,
      )));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: children,
    );
  }

  // Wrapper for CR Editing
  Widget _buildEditableBlock(ScheduleBlock block) {
    // Mock CR Check
    const bool isCR = true;
    
    if (!isCR) return block;

    return GestureDetector(
      onLongPress: () {
        _showEditSheet(context, block);
      },
      child: Stack(
        children: [
          block,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Ionicons.pencil, size: 12, color: Colors.orange),
            ),
          )
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, ScheduleBlock block) {
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
            Text("Edit Schedule", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Modify ${block.title} at ${block.time}", style: GoogleFonts.dmSans(color: Colors.grey)),
            const SizedBox(height: 24),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Ionicons.close_circle, color: Colors.red),
              ),
              title: Text("Cancel Class", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              subtitle: Text("Notify students of cancellation", style: GoogleFonts.dmSans(fontSize: 12)),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Class Cancelled & Notification Sent 📢")));
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Ionicons.time, color: Colors.blue),
              ),
              title: Text("Reschedule", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              subtitle: Text("Move to a different time slot", style: GoogleFonts.dmSans(fontSize: 12)),
              onTap: () {
                 context.pop();
              },
            ),
             const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Ionicons.location, color: Colors.green),
              ),
              title: Text("Change Venue", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              subtitle: Text("Update location from ${block.location}", style: GoogleFonts.dmSans(fontSize: 12)),
              onTap: () {
                 context.pop();
              },
            ),
          ],
        ),
      )
    );
  }
}
