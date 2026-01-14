import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final Color leftBorderColor;
  final Color backgroundColor;
  final List<String> avatars; // Placeholder URLs or Asset Paths
  final bool isLab;
  final bool isExam;
  final bool isLive; // New: Highlight active card
  final VoidCallback? onPulseTap; // Callback for live pulse interaction

  const ScheduleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.leftBorderColor,
    this.backgroundColor = Colors.white,
    this.avatars = const [],
    this.isLab = false,
    this.isExam = false,
    this.isLive = false,
    this.onPulseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // Fully rounded
        boxShadow: [
          // Premium Glow for Live Card
          if (isLive)
            BoxShadow(
              color: leftBorderColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // Subtle diffuse
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
        // Gradient Border Effect (simulated with container or border)
        border: Border.all(
          color: isLive ? leftBorderColor.withValues(alpha: 0.5) : Colors.transparent, 
          width: isLive ? 1.5 : 0
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               GestureDetector(
                onTap: isLive ? onPulseTap : null, // Only tappable if live
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLive ? leftBorderColor : tagColor,
                    borderRadius: BorderRadius.circular(20), // Pill shape for button look
                    boxShadow: isLive ? [
                      BoxShadow(color: leftBorderColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      if (isLive) 
                         const Padding(
                           padding: EdgeInsets.only(right: 6),
                           child: Icon(Ionicons.scan_circle, size: 14, color: Colors.white),
                         ),
                      Text(
                        isLive ? "Live • Tap to Verify" : tag,
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
                const Icon(Ionicons.pulse, size: 16, color: Colors.green),
            ],
          ),
          
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isExam ? Ionicons.time_outline : (isLab ? Ionicons.wifi_outline : Ionicons.location_outline),
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          if (avatars.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 24,
              child: Stack(
                children: List.generate(avatars.length, (index) {
                  return Positioned(
                    left: index * 16.0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                       // Placeholder icon for avatar
                      child: const Icon(Icons.person, size: 14, color: Colors.white), 
                    ),
                  );
                }),
              ),
            )
          ]
        ],
      ),
    );
  }
}
