import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class WizardOcrPage extends StatelessWidget {
  const WizardOcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Header
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: const Icon(Ionicons.chevron_back, size: 20),
                    ),
                  ),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: Colors.black,
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const Text('Step 1 / 3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                   ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Image (Centered)
              Center(
                 child: Image.asset(
                   'assets/scan_hero.png',
                   height: 160,
                   errorBuilder: (context, error, stackTrace) => 
                       const Icon(Ionicons.scan_circle, size: 100, color: AppColors.pastelBlue),
                 ),
              ).animate().scale(delay: 200.ms),

              const SizedBox(height: 20),

              Text(
                'Scan Course Slip',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ).animate().fadeIn().moveY(begin: 10, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Point camera at your registration slip to auto-import courses.',
                style: GoogleFonts.dmSans(fontSize: 16, color: AppColors.textMuted),
                textAlign: TextAlign.start,
              ).animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),
              
              const SizedBox(height: 30),

              // Main Action Card (Dashed)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                     // Camera logic
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pastelBlue,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.1), width: 2, style: BorderStyle.solid), // Dashed border workaround
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Container(
                           width: 80, height: 80,
                           decoration: BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
                           ),
                           child: const Icon(Ionicons.camera, size: 32, color: AppColors.textMain),
                         ),
                         const SizedBox(height: 16),
                         Text('Tap to Open Camera', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 4),
                         Text('or upload from gallery', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMain.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ),
              ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),

              const SizedBox(height: 30),
              
              // Bottom Buttons
              PrimaryButton(
                text: 'Capture',
                onPressed: () => context.push('/courses'),
              ).animate().slideY(begin: 0.2, end: 0, delay: 300.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: () => context.push('/courses'),
                child: Text(
                  'Skip scan, add manually',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14, 
                    color: AppColors.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
