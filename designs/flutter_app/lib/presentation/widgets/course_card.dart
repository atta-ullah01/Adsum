import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CourseCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String title;
  final String location;
  final String instructor;
  final Color color;
  final bool isGlobal;
  final bool isCustom;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.location,
    required this.instructor,
    required this.color,
    this.isGlobal = false,
    this.isCustom = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    startTime,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endTime,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Card Column
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$location • $instructor',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textMain.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isGlobal)
                      Icon(
                        Ionicons.lock_closed_outline,
                        color: AppColors.textMain.withOpacity(0.4),
                        size: 24,
                      ),
                    if (isCustom)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Ionicons.create,
                          size: 16,
                          color: AppColors.textMain.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
