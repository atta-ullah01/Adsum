import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _sectionCtrl;
  bool _isInitialized = false;
  bool _isSaving = false;
  
  // Selection State
  String? _selectedUniId;
  String? _selectedHostelId;
  
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _sectionCtrl = TextEditingController();
  }
  
  @override
  void dispose() {
    _nameCtrl.dispose();
    _sectionCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final currentUser = ref.read(userProfileProvider).value;
      if (currentUser == null) throw Exception('User not loaded');

      final updatedUser = currentUser.copyWith(
        fullName: _nameCtrl.text.trim(),
        defaultSection: _sectionCtrl.text.trim(),
        universityId: _selectedUniId,
        homeHostelId: _selectedHostelId,
      );

      await ref.read(userRepositoryProvider).saveUser(updatedUser);
      
      // Update provider
      ref.invalidate(userProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final universitiesAsync = ref.watch(universitiesProvider);
    
    // Derived State for Display Names
    var uniName = 'Select University';
    if (universitiesAsync.hasValue && _selectedUniId != null) {
      try {
        final u = universitiesAsync.value!.firstWhere((u) => u.id == _selectedUniId);
        uniName = u.name;
      } catch (_) {
        // ID not found in list (maybe old data or loading)
      }
    }

    var hostelName = 'Select Hostel';
    // We only fetch hostels if a university is selected
    if (_selectedUniId != null) {
      final hostelsAsync = ref.watch(hostelsProvider(_selectedUniId!));
       if (hostelsAsync.hasValue && _selectedHostelId != null) {
          try {
             final h = hostelsAsync.value!.firstWhere((h) => h.id == _selectedHostelId);
             hostelName = h.name;
          } catch (_) {}
       }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 24)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
                icon: const Icon(Ionicons.close, color: Colors.black),
                onPressed: () => context.pop(),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
            ),
        ),
        actions: [
            Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    ),
                    child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : Text('Save', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (user) {
          if (user == null) {
            return Center(child: Text('Profile not found', style: GoogleFonts.dmSans(color: Colors.red)));
          }

          if (!_isInitialized) {
            _nameCtrl.text = user.fullName;
            _sectionCtrl.text = user.defaultSection;
            _selectedUniId = user.universityId;
            _selectedHostelId = user.homeHostelId;
            _isInitialized = true;
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                         color: Colors.white, 
                         shape: BoxShape.circle, 
                         border: Border.all(color: Colors.grey.shade100, width: 2),
                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))]
                     ),
                     child: CircleAvatar(
                         radius: 64, 
                         backgroundColor: AppColors.primary, 
                         child: Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : 'A', style: GoogleFonts.outfit(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold))
                     ),
                   ),
                ),
                const SizedBox(height: 48),
                
                _buildField('Full Name', _nameCtrl, Ionicons.person),
                const SizedBox(height: 24),
                
                // University Selector
                _buildSelector('University', uniName, Ionicons.school, () {
                    universitiesAsync.whenData((unis) {
                      _showPicker<University>(
                        title: 'Select University',
                        items: unis,
                        getName: (u) => u.name,
                        onSelected: (u) {
                           setState(() {
                               _selectedUniId = u.id;
                               _selectedHostelId = null; // Reset Hostel on Uni Change
                           });
                        }
                      );
                    });
                }),
                
                const SizedBox(height: 24),
                
                // Hostel Selector (Dependent)
                _buildSelector('Hostel / Residence', hostelName, Ionicons.home, () {
                    if (_selectedUniId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a university first')));
                        return;
                    }
                    // Fetch hostels for selected uni
                    // We access the provider here to pass data to picker, assuming it's loaded or will load
                    // Using ref.read here might be stale if we don't watch it, but we are watching it in build.
                    // However, we need the LIST to show the picker.
                    // If it's loading, we can't show the picker yet.
                    
                    final hostelsState = ref.read(hostelsProvider(_selectedUniId!));
                    
                    hostelsState.when(
                      data: (hostels) {
                         if (hostels.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hostels found for this university')));
                            return;
                         }
                         _showPicker<Hostel>(
                            title: 'Select Hostel',
                            items: hostels,
                            getName: (h) => h.name,
                            onSelected: (h) {
                               setState(() {
                                   _selectedHostelId = h.id;
                               });
                            }
                         );
                      },
                      loading: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading hostels...'))),
                      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))),
                    );
                }),

                const SizedBox(height: 24),
                _buildField('Default Section', _sectionCtrl, Ionicons.people),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 13, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
            controller: ctrl,
            onChanged: (_) => setState(() {}), // Rebuild for avatar update
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMain),
            decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: Icon(icon, color: Colors.grey.shade400, size: 22),
                ),
                prefixIconConstraints: const BoxConstraints(),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
            ),
        )
      ],
    );
  }

  Widget _buildSelector(String label, String value, IconData icon, VoidCallback onTap) {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 13, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                    children: [
                        Icon(icon, color: Colors.grey.shade400, size: 22),
                        const SizedBox(width: 12),
                        Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                        const Spacer(),
                        const Icon(Ionicons.chevron_down, color: Colors.grey, size: 18)
                    ],
                ),
            ),
        )
      ],
    );
  }

  void _showPicker<T>({required String title, required List<T> items, required String Function(T) getName, required Function(T) onSelected}) {
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (items.isEmpty)
                         Padding(padding: const EdgeInsets.all(24), child: Text('No items found', style: GoogleFonts.dmSans(color: Colors.grey))),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(getName(item), style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                              onTap: () {
                                  onSelected(item);
                                  context.pop();
                              },
                            );
                          }
                        ),
                      )
                  ],
              ),
          )
      );
  }
}
