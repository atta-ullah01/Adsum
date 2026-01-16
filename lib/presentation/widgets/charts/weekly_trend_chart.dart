import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyTrendChart extends StatelessWidget { // List of percentages (0.0 to 1.0) for each week

  const WeeklyTrendChart({required this.weeklyAttendance, super.key});
  final List<double> weeklyAttendance;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(weeklyAttendance.length, (index) {
          final percentage = weeklyAttendance[index];
          return _buildBar(context, percentage, index);
        }),
      ),
    );
  }

  Widget _buildBar(BuildContext context, double percentage, int index) {
    // Height calculation relative to 100 max height
    // If percentage is 0.8, height is roughly 80% of max available bar height
    
    final barHeight = 100 * percentage;
    final isCurrentWeek = index == weeklyAttendance.length - 1;
    final color = percentage >= 0.75 ? AppColors.primary : Colors.redAccent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Percentage Label
        Text(
          '${(percentage * 100).toInt()}%',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        
        // The Bar
        Container(
          width: 30, // Thicker bars
          height: barHeight, 
          decoration: BoxDecoration(
            color: isCurrentWeek ? color : color.withOpacity(0.3), // Highlight current week
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        
        // Week Label
        Text(
          'W${index + 1}',
          style: GoogleFonts.dmSans(
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            color: isCurrentWeek ? AppColors.textMain : Colors.grey[400]
          ),
        )
      ],
    );
  }
}
