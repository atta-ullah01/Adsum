import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class ScheduleCard extends StatelessWidget {

  const ScheduleCard({
    required this.title, required this.subtitle, required this.tag, required this.tagColor, required this.tagTextColor, required this.leftBorderColor, super.key,
    this.backgroundColor = Colors.white,
    this.isLab = false,
    this.isExam = false,
    this.isLive = false,
    this.voteCount,
    this.showVoting = false,
    this.isCancelled = false, // New property
    this.onPulseTap,
    this.onTap, // New property
  });
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final Color leftBorderColor;
  final Color backgroundColor;
  final bool isLab;
  final bool isExam;
  final bool isLive; 
  final bool isCancelled; // New property
  final int? voteCount;
  final bool showVoting;
  final VoidCallback? onPulseTap;
  final VoidCallback? onTap; // New property

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLive ? Colors.black87 : Colors.grey.shade200, 
          width: isLive ? 2 : 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tag + Pulse
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               GestureDetector(
                 onTap: isLive ? onPulseTap : null,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: isLive ? leftBorderColor : tagColor,
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       if (isLive) 
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Ionicons.scan_circle, size: 14, color: Colors.white),
                          ),
                       Text(
                         isLive ? 'Live • Tap to Verify' : tag,
                         style: GoogleFonts.dmSans(
                           fontSize: 11,
                           fontWeight: FontWeight.bold,
                           color: isLive ? Colors.white : tagTextColor,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               if (isLive) 
                 const Icon(Ionicons.pulse, size: 18, color: Colors.green),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Title & Subtitle
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isExam ? Ionicons.time_outline : (isLab ? Ionicons.wifi_outline : Ionicons.location_outline),
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Footer: Votes (Only if showVoting is true and voteCount > 0)
          if (showVoting && voteCount != null && voteCount! > 0) ...[
            const SizedBox(height: 20),
            Text(
              '$voteCount Present',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ]
        ],
      ),
    );

    // Apply Opacity for cancelled
    if (isCancelled) {
      cardContent = Opacity(opacity: 0.6, child: cardContent);
    }

    // Wrap in GestureDetector for card tap
    return GestureDetector(
      onTap: onTap,
      child: cardContent,
    );
  }
}
