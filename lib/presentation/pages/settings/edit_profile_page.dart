import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

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
  String _uniName = "Select University";
  String _hostelName = "Select Hostel";

  // Mock Data (Static config for now)
  final List<Map<String, String>> _universities = [
      {'id': 'u1', 'name': 'MIT ADT University'},
      {'id': 'u2', 'name': 'IIT Delhi'},
      {'id': 'u3', 'name': 'Bits Pilani'},
  ];

  final List<Map<String, String>> _hostels = [
      {'id': 'h1', 'uni_id': 'u1', 'name': 'Kapoor Hall'},
      {'id': 'h2', 'uni_id': 'u1', 'name': 'Nanda Hall'},
      {'id': 'h3', 'uni_id': 'u2', 'name': 'Aravali Hostel'},
      {'id': 'h4', 'uni_id': 'u2', 'name': 'Karakoram Hostel'},
      {'id': 'h5', 'uni_id': 'u3', 'name': 'Gandhi Bhawan'},
  ];
  
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

  void _updateDisplayNames() {
      if (_selectedUniId != null) {
        final uni = _universities.firstWhere((u) => u['id'] == _selectedUniId, orElse: () => {'name': 'Select University'});
        _uniName = uni['name']!;
      } else {
        _uniName = "Select University";
      }

      if (_selectedHostelId != null) {
        final hostel = _hostels.firstWhere((h) => h['id'] == _selectedHostelId, orElse: () => {'name': 'Select Hostel'});
        _hostelName = hostel['name']!;
      } else {
        _hostelName = "Select Hostel";
      }
      
      if (mounted) setState(() {});
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final currentUser = ref.read(userProfileProvider).value;
      if (currentUser == null) throw Exception("User not loaded");

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 24)),
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
                      : Text("Save", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading profile: $err")),
        data: (user) {
          if (user == null) {
            return Center(child: Text("Profile not found", style: GoogleFonts.dmSans(color: Colors.red)));
          }

          if (!_isInitialized) {
            _nameCtrl.text = user.fullName;
            _sectionCtrl.text = user.defaultSection;
            _selectedUniId = user.universityId;
            _selectedHostelId = user.homeHostelId;
            // Set defaults if null to match mock behavior if desired, or leave null
            if (_selectedUniId == null) {
               _selectedUniId = 'u1'; // Default to MIT ADT for demo
               _selectedHostelId = 'h1';
            }
            _updateDisplayNames();
            _isInitialized = true;
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                       Container(
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
                             child: Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : "A", style: GoogleFonts.outfit(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold))
                         ),
                       ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.black, 
                              shape: BoxShape.circle, 
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
                          ),
                          child: const Icon(Ionicons.camera, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                _buildField("Full Name", _nameCtrl, Ionicons.person),
                const SizedBox(height: 24),
                
                // University Selector
                _buildSelector("University", _uniName, Ionicons.school, () => _showPicker(
                    title: "Select University",
                    items: _universities,
                    onSelected: (id) {
                        setState(() {
                            _selectedUniId = id;
                            _selectedHostelId = null; // Reset Hostel on Uni Change
                            _updateDisplayNames();
                        });
                    }
                )),
                
                const SizedBox(height: 24),
                
                // Hostel Selector (Dependent)
                _buildSelector("Hostel / Residence", _hostelName, Ionicons.home, () {
                    if (_selectedUniId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a university first")));
                        return;
                    }
                    final filteredHostels = _hostels.where((h) => h['uni_id'] == _selectedUniId).toList();
                    _showPicker(
                        title: "Select Hostel",
                        items: filteredHostels,
                        onSelected: (id) {
                             setState(() {
                                 _selectedHostelId = id;
                                 _updateDisplayNames();
                             });
                        }
                    );
                }),

                const SizedBox(height: 24),
                _buildField("Default Section", _sectionCtrl, Ionicons.people),
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
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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

  void _showPicker({required String title, required List<Map<String, String>> items, required Function(String) onSelected}) {
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
                         Padding(padding: const EdgeInsets.all(24), child: Text("No items found", style: GoogleFonts.dmSans(color: Colors.grey))),
                      ...items.map((item) => ListTile(
                          title: Text(item['name']!, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                          onTap: () {
                              onSelected(item['id']!);
                              context.pop();
                          },
                      ))
                  ],
              ),
          )
      );
  }
}
