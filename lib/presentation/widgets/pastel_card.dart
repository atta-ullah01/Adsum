
import 'package:flutter/material.dart';

class PastelCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double padding;

  final Color? borderColor;
  final double borderWidth;

  const PastelCard({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.onTap,
    this.padding = 24.0,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor ?? Colors.black.withOpacity(0.02), width: borderWidth),
          boxShadow: backgroundColor == Colors.white
             ? [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.03),
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
