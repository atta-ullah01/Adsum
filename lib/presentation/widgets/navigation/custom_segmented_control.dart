import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSegmentedControl extends StatelessWidget {

  const CustomSegmentedControl({
    required this.tabs, required this.selectedIndex, required this.onIndexChanged, super.key,
  });
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final tabWidth = totalWidth / tabs.length;
        
        return Container(
          height: 48,
          // Transparent background for a cleaner "Navbar" look
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.black12)), // Thin divider line
          ),
          child: Stack(
            children: [
              // 1. The Sliding Underline Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                bottom: 0,
                width: tabWidth,
                height: 3, // Height of the underline
                child: Center(
                  child: Container(
                    width: tabWidth * 0.6, // Indicator is 60% of tab width for a sleek look
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, // Brand color
                      borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                ),
              ),
              
              // 2. The Text Labels
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onIndexChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.outfit(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            // Active: Primary Color, Inactive: Muted Grey
                            color: isSelected ? AppColors.primary : AppColors.textMain.withValues(alpha: 0.5),
                            fontSize: 15, // Slightly larger
                          ),
                          child: Text(tabs[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
