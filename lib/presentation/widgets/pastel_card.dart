
import 'package:flutter/material.dart';

class PastelCard extends StatelessWidget {

  const PastelCard({
    required this.child, required this.backgroundColor, super.key,
    this.onTap,
    this.padding = 24.0,
    this.borderColor,
    this.borderWidth = 1.0,
  });
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double padding;

  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor ?? Colors.black.withValues(alpha: 0.02), width: borderWidth),
          boxShadow: backgroundColor == Colors.white
             ? [
                 BoxShadow(
                   color: backgroundColor.withValues(alpha: 0.1),
                   blurRadius: 20,
                   offset: const Offset(0, 4),
                 ),
               ]
             : null,
        ),
        child: child,
      ),
    );
  }
}
