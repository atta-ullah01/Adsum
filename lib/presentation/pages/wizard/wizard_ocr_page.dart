import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/presentation/widgets/pastel_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class WizardOcrPage extends ConsumerStatefulWidget {
  const WizardOcrPage({super.key});

  @override
  ConsumerState<WizardOcrPage> createState() => _WizardOcrPageState();
}

class _WizardOcrPageState extends ConsumerState<WizardOcrPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
               
               const SizedBox(height: 32),

               // Personalized Header
               Consumer(builder: (context, ref, _) {
                  final userAsync = ref.watch(userProfileProvider);
                  final name = userAsync.value?.fullName.split(' ').first ?? 'Student';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $name 👋',
                        style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Let's set up your academic courses",
                        style: GoogleFonts.dmSans(fontSize: 16, color: AppColors.textMain.withOpacity(0.6)),
                      ),
                    ],
                  ).animate().fadeIn().moveY(begin: 10, end: 0);
               }),

               const SizedBox(height: 32),
              // Grid Options
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Option 1: Scan (Clickable with SnackBar)
                    Expanded(
                      child: PastelCard(
                        backgroundColor: const Color(0xFFFFE4C7), // Pastel Peach
                        borderColor: Colors.black,
                        borderWidth: 1.5,
                        onTap: () {
                           ScaffoldMessenger.of(context).clearSnackBars();
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Row(
                                 children: [
                                   const Icon(Ionicons.alert_circle, color: Colors.white, size: 20),
                                   const SizedBox(width: 12),
                                   Expanded(child: Text('Not implemented, too poor to buy API keys 🥲', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                                 ],
                               ),
                               backgroundColor: const Color(0xFF1F2937), // Dark grey like reference
                               behavior: SnackBarBehavior.floating,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                               margin: const EdgeInsets.all(24),
                               elevation: 0,
                             )
                           );
                        },
                        padding: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Ionicons.scan, color: Colors.black),
                             ),
                             const SizedBox(height: 16),
                             Text('Scan Slip', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                             const SizedBox(height: 4),
                             Text('Auto-detect courses from image', style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),

                    const SizedBox(height: 16),

                    // Option 2: Manual (Active)
                    Expanded(
                      child: PastelCard(
                        backgroundColor: const Color(0xFFDCFCE7), // Pastel Green
                        borderColor: Colors.black,
                        borderWidth: 1.5,
                        onTap: () => context.push('/courses'),
                        padding: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Ionicons.create, color: Colors.black),
                             ),
                             const SizedBox(height: 16),
                             Text('Manual Entry', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                             const SizedBox(height: 4),
                             Text('Type course codes manually', style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 0.3, end: 0, delay: 300.ms).fadeIn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
