import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/pastel_card.dart';
import 'package:adsum/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adsum/presentation/providers/auth_provider.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/user_profile.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form State
  String? _selectedUniversityId;
  String? _selectedHostelId;
  final _sectionController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _sectionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      // 1. Create User Model
      final user = UserProfile(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}', 
        universityId: _selectedUniversityId!,
        fullName: _nameController.text.isEmpty ? 'Student' : _nameController.text,
        email: 'student@university.edu',
        defaultSection: _sectionController.text.isEmpty ? 'A' : _sectionController.text.toUpperCase(),
        homeHostelId: _selectedHostelId, // Optional
        settings: const UserSettings(notificationsEnabled: true),
      );

      // 2. Save to Repository
      await ref.read(userRepositoryProvider).saveUser(user);

      // 3. Update Auth Provider State (Mock login for now)
      ref.read(authProvider.notifier).loginAsUser();

      // 4. Navigate
      if (mounted) {
        context.push('/ocr'); // Proceed to next onboarding step
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final universitiesAsync = ref.watch(universitiesProvider);
    
    // We can only fetch hostels if a university is selected (and we have its ID)
    // But since _selectedUniversityId is initialized to null or we need to wait for universities,
    // let's handle the user flow: Select Uni -> Then Select Hostel
    
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
                   Form(
                     key: _formKey,
                     child: Container(
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
                           
                           universitiesAsync.when(
                             loading: () => const LinearProgressIndicator(),
                             error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                             data: (universities) {
                               return _buildDropdownField(
                                 'Select University',
                                 _selectedUniversityId, 
                                 universities.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                                 (val) {
                                   setState(() {
                                     _selectedUniversityId = val as String?;
                                     _selectedHostelId = null; // Reset hostel when uni changes
                                   });
                                 },
                                 validator: (val) => val == null ? 'Required' : null,
                                 key: const Key('dropdown_university'),
                               );
                             }
                           ),

                           const SizedBox(height: 16),
                           
                           _buildInputLabel('Hostel'),
                           
                           if (_selectedUniversityId == null)
                             Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                               width: double.infinity,
                               child: Text("Select University first", style: GoogleFonts.dmSans(color: Colors.grey)),
                             )
                           else
                             Consumer(
                               builder: (context, ref, child) {
                                  final hostelsAsync = ref.watch(hostelsProvider(_selectedUniversityId!));
                                  return hostelsAsync.when(
                                    loading: () => const LinearProgressIndicator(),
                                    error: (err, _) => Text('Error loading hostels', style: const TextStyle(color: Colors.red)),
                                    data: (hostels) {
                                      return _buildDropdownField(
                                         'Select Hostel',
                                         _selectedHostelId,
                                         hostels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                                         (val) {
                                           setState(() => _selectedHostelId = val as String?);
                                         },
                                         // No validator => Optional
                                         key: const Key('dropdown_hostel'),
                                      );
                                    }
                                  );
                               }
                             ),
                           
                           const SizedBox(height: 16),
                           
                           Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     _buildInputLabel('Section'),
                                     _buildTextField(
                                       'Ex: A', 
                                       _sectionController,
                                       // No validation needed as we default to 'A'
                                       key: const Key('input_section'),
                                     ),
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
                                     _buildTextField('Enter Name', _nameController),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                   ),
                   
                   const SizedBox(height: 30),

                   // Identity Cards
                   if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                   else ...[
                     PastelCard(
                       key: const Key('card_student'),
                       backgroundColor: AppColors.pastelYellow,
                       onTap: _registerUser,
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
                               const Icon(Ionicons.arrow_forward_circle, size: 28, color: Colors.black54),
                             ],
                           ),
                           const SizedBox(height: 20),
                           Text('Continue', style: Theme.of(context).textTheme.titleLarge),
                           Text('Save Profile', style: Theme.of(context).textTheme.bodySmall),
                         ],
                       ),
                     ).animate().slideY(begin: 0.3, end: 0, delay: 200.ms).fadeIn(),

                     const SizedBox(height: 20),

                     PastelCard(
                       backgroundColor: AppColors.pastelPurple,
                       onTap: () {
                          // Allow guest mode (skip persistence or save rough generic profile?)
                          // For now, save a Generic Guest Profile
                          _nameController.text = "Guest";
                          _sectionController.text = "A"; 
                          _registerUser();
                       },
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('Skip Setup', style: Theme.of(context).textTheme.titleLarge),
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
                   ]
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

  Widget _buildDropdownField(String hint, String? value, List<DropdownMenuItem<String>> items, ValueChanged<Object?> onChanged, {String? Function(String?)? validator, Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMain),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: Colors.grey),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        validator: validator,
      ),
    );
  }
  
  Widget _buildTextField(String hint, TextEditingController controller, {String? Function(String?)? validator, Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMain),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
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
}
