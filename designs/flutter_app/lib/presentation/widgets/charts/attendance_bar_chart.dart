import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceBarChart extends StatelessWidget {
  final List<bool> history; // true = present, false = absent

  const AttendanceBarChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(history.length, (index) {
          final isPresent = history[index];
          return _buildBar(context, isPresent, index);
        }),
      ),
    );
  }

  Widget _buildBar(BuildContext context, bool isPresent, int index) {
    // Staggered height animation mock (using static heights for now, could be animated)
    // Present = High bar, Absent = Lower bar (or just different color)
    // Actually, let's make them same max height but filled differently?
    // User asked for "stats from that day". Let's assume standardized height but color indicates status.
    
    // Aesthetic decision: 
    // Present: Green, 80% height
    // Absent: Red, 40% height
    
    final height = isPresent ? 0.8 : 0.4;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 80 * height, // Base height 80
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: (isPresent ? Colors.green : Colors.red).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "D-${history.length - 1 - index}", // D-4, D-3...
          style: GoogleFonts.dmSans(fontSize: 10, color: Colors.grey),
        )
      ],
    );
  }
}
