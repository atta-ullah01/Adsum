import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/pages/dashboard/weekly_schedule_view.dart';
import 'package:adsum/presentation/widgets/global/global_fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9), // Glass-ish opacity
          borderRadius: BorderRadius.circular(40), // Fully rounded pill
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
               onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyScheduleView()));
               },
               child: _buildNavItem(Ionicons.grid_outline, false),
            ),
            _buildNavItem(Ionicons.calendar_outline, true), // Active
            
            // Floating Action Button Placeholder (Smaller, centered in pill)
            GestureDetector(
              onTap: () => showGlobalFabMenu(context),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.textMain,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.textMain.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Icon(Ionicons.add, color: Colors.white, size: 24),
              ),
            ),

            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: _buildNavItem(Ionicons.chatbubble_ellipses_outline, false),
            ),
            _buildNavItem(Ionicons.settings_outline, false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Icon(
      icon,
      size: 26,
      color: isActive ? AppColors.textMain : Colors.grey[400],
    );
  }
}
