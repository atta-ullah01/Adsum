import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MessMealCard extends StatelessWidget {

  const MessMealCard({
    required this.menu, super.key,
  });
  final MessMenu menu;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (menu.mealType) {
      case MealType.breakfast:
         color = AppColors.pastelOrange;
         icon = Ionicons.sunny;
      case MealType.lunch:
         color = AppColors.pastelGreen;
         icon = Ionicons.restaurant;
      case MealType.snacks:
         color = AppColors.pastelBlue;
         icon = Ionicons.cafe;
      case MealType.dinner:
         color = AppColors.pastelPurple;
         icon = Ionicons.moon;
    }
    
    // Check if Modified
    final isModified = menu.isModified;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
        border: isModified ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(icon, size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(menu.mealType.displayName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${menu.startTime} - ${menu.endTime}', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              if (isModified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Edited', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                )
            ],
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: menu.itemsList.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
            )).toList(),
          )
        ],
      ),
    );
  }
}
