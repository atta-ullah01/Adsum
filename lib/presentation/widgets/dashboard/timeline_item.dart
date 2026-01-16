import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineItem extends StatelessWidget {

  const TimelineItem({required this.time, required this.child, super.key});
  final String time;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24), // var(--pad-page)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                time,
                textAlign: TextAlign.right,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Timeline Node
          Container(
            width: 20,
            height: 24, // Match top padding of text for alignment
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 20), // Align with text top
            child: Container(
              width: 12, 
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!, width: 2), // Neutral gray
              ),
            ),
          ),
          const SizedBox(width: 20), // Padding between node and card
          // Card
          Expanded(child: child),
        ],
      ),
    );
  }
}
