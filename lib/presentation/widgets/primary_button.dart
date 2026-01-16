import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {

  const PrimaryButton({
    required this.text, super.key,
    this.onPressed,
    this.icon,
    this.isBlack = true,
    this.backgroundColor,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isBlack;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isBlack
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ]
            : [
                 BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(32),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              color: isBlack ? AppColors.black : (backgroundColor ?? AppColors.white),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.outfit(
                    color: isBlack ? AppColors.white : AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 10),
                  Icon(
                    icon,
                    size: 20,
                    color: isBlack ? AppColors.white : AppColors.textMain,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
