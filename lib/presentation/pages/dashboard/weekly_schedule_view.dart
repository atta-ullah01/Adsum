import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class WeeklyScheduleView extends StatefulWidget {
  const WeeklyScheduleView({super.key});

  @override
  State<WeeklyScheduleView> createState() => _WeeklyScheduleViewState();
}

class _WeeklyScheduleViewState extends State<WeeklyScheduleView> {
  // Mock Data: 7 Days x 12 Time Slots (8am - 8pm)
  // We'll simplify and just show a grid-like view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Weekly Schedule', style: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Time Column
          SizedBox(
            width: 50,
            child: ListView.builder(
              itemCount: 13, // 8am to 8pm
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      '${index + 8}:00',
                      style: GoogleFonts.dmSans(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Days Grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 400, // Make it scrollable horizontally
                child: ListView.builder(
                  itemCount: 13,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        children: [
                          _buildEventBlock(index),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventBlock(int hour) {
    // Mock Logic to show blocks
    if (hour == 1) { // 9:00 AM
       return Expanded(
         child: Container(
           margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
           decoration: BoxDecoration(color: AppColors.pastelBlue, borderRadius: BorderRadius.circular(8)),
           child: Center(child: Text('App Design', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold))),
         ),
       );
    }
    if (hour == 3) { // 11:00 AM
       return Expanded(
         child: Container(
           margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
           decoration: BoxDecoration(color: AppColors.pastelPink, borderRadius: BorderRadius.circular(8)),
           child: Center(child: Text('Lab', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold))),
         ),
       );
    }
    return const Spacer();
  }
}
