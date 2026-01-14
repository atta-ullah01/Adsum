import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/pastel_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adsum/presentation/providers/auth_provider.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _backButton(context),
                  ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                   // Hero Image Placeholder (Icon for now)
                   Center(
                     child: Image.asset(
                       'assets/auth_hero.png',
                       height: 120,
                       errorBuilder: (context, error, stackTrace) => 
                           const Icon(Ionicons.shield_checkmark, size: 100, color: AppColors.pastelBlue),
                     ),
                   ).animate().scale(delay: 200.ms),
                   
                   const SizedBox(height: 10),
                   
                   Text(
                     'University Identity',
                     textAlign: TextAlign.center,
                     style: GoogleFonts.outfit(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                     ),
                   ).animate().fadeIn().moveY(begin: 10, end: 0),

                   const SizedBox(height: 30),

                   // Vertical Form Stack
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(24),
                       boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                       ],
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         _buildInputLabel('University'),
                         _buildDropdownField('Select University', 'IIT Delhi'),
                         const SizedBox(height: 16),
                         
                         _buildInputLabel('Hostel'),
                         _buildDropdownField('Select Hostel', 'Hostel Udaigiri'),
                         const SizedBox(height: 16),
                         
                         Row(
                           children: [
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   _buildInputLabel('Section'),
                                   _buildTextField('Ex: A, B1', 'A'),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               flex: 2,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   _buildInputLabel('Full Name (Optional)'),
                                   _buildTextField('Enter Name', ''),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                   
                   const SizedBox(height: 30),

                   // Identity Cards
                   PastelCard(
                     backgroundColor: AppColors.pastelYellow,
                     onTap: () {
                        // Mock User Login
                        ref.read(authProvider.notifier).loginAsUser();
                        context.push('/ocr');
                     },
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.6),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Text(
                                 'Student',
                                 style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                               ),
                             ),
                             const Icon(Ionicons.logo_google, size: 28, color: Colors.black54),
                           ],
                         ),
                         const SizedBox(height: 20),
                         Text('Login with Google', style: Theme.of(context).textTheme.titleLarge),
                         Text('University Account', style: Theme.of(context).textTheme.bodySmall),
                       ],
                     ),
                   ).animate().slideY(begin: 0.3, end: 0, delay: 200.ms).fadeIn(),

                   const SizedBox(height: 20),

                   PastelCard(
                     backgroundColor: AppColors.pastelPurple,
                     onTap: () {
                        ref.read(authProvider.notifier).loginAsGuest();
                        context.push('/ocr');
                     },
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Guest Mode', style: Theme.of(context).textTheme.titleLarge),
                             Text('Local Storage Only', style: Theme.of(context).textTheme.bodySmall),
                           ],
                         ),
                         Container(
                           width: 40, height: 40,
                           decoration: BoxDecoration(
                             color: Colors.white.withValues(alpha: 0.6),
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(Ionicons.person, size: 20),
                         )
                       ],
                     ),
                   ).animate().slideY(begin: 0.3, end: 0, delay: 300.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label.toUpperCase(), style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5
      )),
    );
  }

  Widget _buildDropdownField(String hint, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value.isEmpty ? hint : value, 
            style: GoogleFonts.dmSans(fontSize: 15, color: value.isEmpty ? Colors.grey : AppColors.textMain)
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }
  
  Widget _buildTextField(String hint, String initialValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initialValue.isEmpty ? hint : initialValue,
        style: GoogleFonts.dmSans(fontSize: 15, color: initialValue.isEmpty ? Colors.grey : AppColors.textMain),
      ),
    );
  }
  Widget _backButton(BuildContext context) {
    return GestureDetector(
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
    );
  }
  
  Widget _avatar() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
         color: Colors.grey[200],
         shape: BoxShape.circle,
      ),
        child: const Icon(Ionicons.person, color: Colors.grey),
    );
  }

  Widget _buildMiniAvatar(Color color) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
