import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class LiveDiagnosticsSheet extends StatelessWidget {
  const LiveDiagnosticsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              const Icon(Ionicons.pulse, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Live Tracking", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Confidence Score: 65% (Medium)", style: GoogleFonts.dmSans(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildStatusRow(Ionicons.location, "GPS Location", "Inside Bounds", true),
          _buildStatusRow(Ionicons.wifi, "Wi-Fi Check", "Not Connected to 'Lab_1'", false),
          _buildStatusRow(Ionicons.walk, "Activity", "Too much movement", null), // null = warning
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Ionicons.hand_left_outline),
              label: const Text("I am Here (Override)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String value, bool? isSuccess) {
    Color color;
    IconData statusIcon;
    
    if (isSuccess == true) {
      color = Colors.green;
      statusIcon = Ionicons.checkmark_circle;
    } else if (isSuccess == false) {
      color = Colors.red;
      statusIcon = Ionicons.close_circle;
    } else {
      color = Colors.orange;
      statusIcon = Ionicons.warning;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                Text(value, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
          Icon(statusIcon, color: color, size: 24),
        ],
      ),
    );
  }
}

void showLiveDiagnostics(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const LiveDiagnosticsSheet(),
  );
}
