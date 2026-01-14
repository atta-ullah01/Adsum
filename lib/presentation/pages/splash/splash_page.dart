import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    // For the floating animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _checkSession();
  }
  
  Future<void> _checkSession() async {
    // Artificial minimum delay for branding
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final hasUser = await userRepo.hasUser();
      
      if (hasUser) {
        // Sync auth provider state
        ref.read(authProvider.notifier).loginAsUser();
        
        if (mounted) {
          context.go('/dashboard');
          return;
        }
      }
    } catch (e) {
      debugPrint("Session check error: $e");
    }
    
    if (mounted) {
      setState(() => _checkingSession = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // While checking, show a minimal splash or the same UI without buttons?
    // Let's show the UI but maybe loading indicator if it takes long? 
    // Actually, showing the full UI immediately is fine, if we redirect quickly it's just a blip.
    // If _checkingSession is true, maybe hide the "Get Started" button to prevent double nav.

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0), // match padding: 30px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Branding
              Text(
                '/adsum:',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              
              const Spacer(),

              // Hero Region
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Main Image
                    Image.asset(
                      'assets/onboarding_hero.png',
                      height: 280, 
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100, color: Colors.grey),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                    // Floating Element
                    Positioned(
                      top: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -10 * _controller.value),
                            child: child,
                          );
                        },
                        child: const Icon(Icons.add, size: 40, color: AppColors.textMain),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Text Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                      children: [
                        const TextSpan(text: 'Attendance.\n'),
                        TextSpan(
                          text: 'Simplified.',
                          style: TextStyle(color: AppColors.textMain.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Manage your entire campus life\nseamlessly from your pocket.',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: AppColors.textMain.withOpacity(0.7),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),

              const Spacer(),

              // Bottom Action
              if (_checkingSession)
                 const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () => context.push('/auth'),
                ).animate().slideY(begin: 0.5, end: 0, delay: 400.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
