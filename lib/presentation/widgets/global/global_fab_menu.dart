import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class GlobalFabMenu extends StatelessWidget {
  const GlobalFabMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
            
            // Navigation Section - 4 items
            Text('Navigate', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavIcon(context, Ionicons.stats_chart, 'Academics', () {
                   context.pop();
                   context.push('/academics');
                }),
                _buildNavIcon(context, Ionicons.notifications_outline, 'Actions', () {
                   context.pop();
                   context.push('/action-center');
                }),
                _buildNavIcon(context, Ionicons.calendar_outline, 'Calendar', () {
                   context.pop();
                   context.push('/calendar');
                }),
                _buildNavIcon(context, Ionicons.restaurant_outline, 'Mess', () {
                   context.pop();
                   context.push('/mess');
                }),
              ],
            ),
            
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),

            // Quick Actions Section - 3 items
            Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildActionItem(context, Ionicons.book_outline, 'Add Course', 'Enroll in a new subject', () {
               context.pop();
               context.push('/manage-courses');
            }),
            _buildActionItem(context, Ionicons.add_circle_outline, 'Add Event', 'Create personal reminder', () {
               context.pop();
               context.push('/calendar'); // TODO: Pass add mode parameter
            }),
            _buildActionItem(context, Ionicons.settings_outline, 'Settings', 'App preferences & profile', () {
               context.pop();
               context.push('/settings');
            }),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.bgApp,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textMain, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: const BoxDecoration(
                color: AppColors.bgApp,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textMain),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Helper to show the sheet
void showGlobalFabMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Fix Logic: Allows sheet to be taller than half screen if needed
    backgroundColor: Colors.transparent,
    builder: (context) => const GlobalFabMenu(),
  );
}
