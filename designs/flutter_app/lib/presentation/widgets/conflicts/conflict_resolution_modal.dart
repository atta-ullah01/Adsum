import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:adsum/core/theme/app_colors.dart';

class ConflictResolutionModal extends StatelessWidget {
  final VoidCallback onResolveKeepExisting;
  final VoidCallback onResolveAcceptNew;

  const ConflictResolutionModal({
    super.key,
    required this.onResolveKeepExisting,
    required this.onResolveAcceptNew,
  });

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
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Ionicons.warning, color: Colors.red),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Schedule Conflict", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("You can't be in two places at once.", style: GoogleFonts.dmSans(color: Colors.grey)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // The Clash: "Versus" View
          Row(
            children: [
              // Left: Incoming (The Intruder)
              Expanded(
                child: _buildConflictCard(
                  title: "Extra Class",
                  subtitle: "Mathematics",
                  time: "4:00 PM",
                  color: AppColors.primary,
                  isIncoming: true,
                ),
              ),
              
              // VS Badge
              Container(
                width: 30, height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ]
                ),
                child: Text("VS", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
              ),
              
              // Right: Existing (The Plan)
              Expanded(
                child: _buildConflictCard(
                  title: "Gym",
                  subtitle: "Personal",
                  time: "4:00 PM",
                  color: Colors.purple,
                  isIncoming: false,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onResolveAcceptNew,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Skip Gym", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onResolveKeepExisting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Keep Gym", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          TextButton(
             onPressed: () => Navigator.pop(context),
             child: Text("Decide Later", style: GoogleFonts.dmSans(color: Colors.grey)),
          )
        ],
      ),
    );
  }

  Widget _buildConflictCard({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required bool isIncoming,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIncoming ? Colors.white : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
           color: isIncoming ? Colors.grey.shade200 : color.withOpacity(0.2), 
           width: isIncoming ? 1 : 2
        ),
      ),
      child: Column(
        children: [
          if (isIncoming)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
              child: Text("NEW CHANGE", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
          
          Text(time, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}

// Helper to show modal
void showConflictResolutionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => ConflictResolutionModal(
      onResolveAcceptNew: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resolved: Gym Skipped. Attending Class.")));
      },
      onResolveKeepExisting: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resolved: Class Hidden. Keeping Gym.")));
      },
    ),
  );
}
