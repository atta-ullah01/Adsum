import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:math' as math;

class LiveDiagnosticsSheet extends StatefulWidget {
  const LiveDiagnosticsSheet({super.key});

  @override
  State<LiveDiagnosticsSheet> createState() => _LiveDiagnosticsSheetState();
}

class _LiveDiagnosticsSheetState extends State<LiveDiagnosticsSheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Center
          Center(
            child: Container(
              width: 48, height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2.5)),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Live Verification", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                   Text("Scanning environment...", style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              // Confidence Score Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text("65%", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(width: 6),
                    Text("Confidence", style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),
          
          const SizedBox(height: 32),
          
          // GRID LAYOUT of Cards
          Row(
            children: [
               Expanded(
                 child: _buildGridCard(
                   title: "GPS Signal",
                   subtitle: "Inside Bounds",
                   icon: Ionicons.location,
                   bg: AppColors.pastelBlue,
                   accent: Colors.blue,
                   isSuccess: true,
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: _buildGridCard(
                   title: "Access Point",
                   subtitle: "Searching...",
                   icon: Ionicons.wifi,
                   bg: AppColors.pastelPurple,
                   accent: Colors.deepPurple,
                   isSuccess: false, // In progress
                   isLoading: true,
                 ),
               ),
            ],
          ),
          const SizedBox(height: 16),
           Row(
            children: [
               Expanded(
                 child: _buildGridCard(
                   title: "Activity",
                   subtitle: "Stationary",
                   icon: Ionicons.walk,
                   bg: AppColors.pastelGreen,
                   accent: Colors.teal,
                   isSuccess: true,
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: _buildGridCard(
                   title: "Present",
                   subtitle: "32 Verified",
                   icon: Ionicons.people,
                   bg: AppColors.pastelOrange,
                   accent: Colors.orange,
                   isSuccess: true,
                 ),
               ),
            ],
          ),
          


          
          const SizedBox(height: 24),
          
          // Action Button - Mark Present
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text("Mark Present", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  
  Widget _buildAvatar(double left, String initial, Color color) {
    return Positioned(
      left: left,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
        child: Center(child: Text(initial, style: GoogleFonts.dmSans(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
  
  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bg,
    required Color accent,
    bool isSuccess = false,
    bool isLoading = false,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 2), // Thicker black border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                 child: Icon(icon, color: accent, size: 18),
               ),
               if (isLoading)
                 SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: accent))
               else if (isSuccess)
                 Icon(Ionicons.checkmark_circle, color: accent, size: 20)
               else
                 Icon(Ionicons.alert_circle, color: accent, size: 20)
             ],
           ),
           const Spacer(),
           Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
           Text(subtitle, style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

void showLiveDiagnostics(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const SingleChildScrollView(
      child: Padding(
         padding: EdgeInsets.only(top: 80),
         child: LiveDiagnosticsSheet(),
      )
    ),
  );
}
