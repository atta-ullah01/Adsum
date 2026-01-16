import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeSlideTransition extends StatelessWidget {

  const FadeSlideTransition({
    required this.child, required this.index, super.key,
    this.delay = const Duration(milliseconds: 50),
  });
  final Widget child;
  final int index;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 600.ms, delay: delay * index, curve: Curves.easeOutQuad)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: delay * index, curve: Curves.easeOutQuad);
  }
}
