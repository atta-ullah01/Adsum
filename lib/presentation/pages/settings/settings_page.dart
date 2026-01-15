import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 24)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
            icon: const Icon(Ionicons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            ),
        ),
      ),
      body: asyncUser.when(
        data: (user) => _buildContent(context, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserProfile? user) {
    // Fallback for null user (shouldn't happen in auth flow, but safe to handle)
    final userName = user?.fullName ?? "Guest User";
    final uni = user?.universityId == null ? "Not Connected" : "MIT ADT University"; // Mock lookup for now
    final hostel = user?.homeHostelId ?? "Local Storage";
    final isGuest = user == null;
    final settings = user?.settings ?? const UserSettings();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Card
          InkWell(
            onTap: () async {
                // TODO: Implement actual profile editing
                final result = await context.push('/settings/profile');
                if (result != null) {
                   ref.refresh(userProfileProvider);
                }
            },
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                      ),
                      child: CircleAvatar(
                      radius: 32,
                      backgroundColor: isGuest ? Colors.grey : AppColors.primary,
                      child: Text(userName.isNotEmpty ? userName[0] : '?', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                        const SizedBox(height: 4),
                        Text(uni, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey)),
                        Text(hostel, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Ionicons.chevron_forward, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 2. Preferences
          Text("PREFERENCES", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Ionicons.moon,
            color: const Color(0xFF6B7280), // Cool Grey
            title: "Dark Mode",
            subtitle: "System Default",
            trailing: Switch(
              value: settings.themeMode == 'DARK',
              onChanged: (val) => _updateSettings(settings.copyWith(themeMode: val ? 'DARK' : 'LIGHT')),
              activeColor: Colors.grey,
            )
          ),
          _buildSettingTile(
            icon: Ionicons.notifications,
            color: const Color(0xFFEC4899), // Pink
            title: "Notifications",
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (val) => _updateSettings(settings.copyWith(notificationsEnabled: val)),
               activeColor: AppColors.primary,
               inactiveTrackColor: Colors.grey.shade200,
            )
          ),
          
          const SizedBox(height: 40),
          
          // 3. Privacy & Data
          Text("PRIVACY & DATA", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Ionicons.eye_off,
            color: const Color(0xFF8B5CF6), // Purple
            title: "Private Mode",
            subtitle: isGuest ? "Not available for Guest" : "Hide sensitive data",
            trailing: Switch(
              value: isGuest ? false : settings.isPrivateMode,
              onChanged: isGuest ? null : (val) => _updateSettings(settings.copyWith(isPrivateMode: val)),
              activeColor: const Color(0xFF8B5CF6),
              inactiveTrackColor: Colors.grey.shade200,
            )
          ),

          _buildSettingTile(
            icon: Ionicons.download,
            color: const Color(0xFF3B82F6), // Blue
            title: "Export Data",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exporting data to JSON...")));
            }
          ),
          _buildSettingTile(
            icon: Ionicons.cloud_upload,
            color: const Color(0xFFF59E0B), // Amber
            title: "Import Data",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select backup file to restore...")));
            }
          ),
          _buildSettingTile(
            icon: Ionicons.trash,
            color: const Color(0xFFEF4444), // Red
            title: "Clear All Data",
            isDanger: true,
            onTap: () => _showResetDialog(context),
          ),
          
          const SizedBox(height: 48),
          Center(child: Text("Adsum v1.0.0 (Data Connected)", style: GoogleFonts.dmSans(color: Colors.grey[300], fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    await ref.read(userRepositoryProvider).updateSettings(newSettings);
    ref.refresh(userProfileProvider);
  }

  Widget _buildSettingTile({
    required IconData icon, 
    required Color color, 
    required String title, 
    String? subtitle, 
    Widget? trailing, 
    VoidCallback? onTap,
    bool isDanger = false
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(16)
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16, color: isDanger ? const Color(0xFFEF4444) : AppColors.textMain)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey)) : null,
        trailing: trailing ?? (onTap != null ? Container( 
            width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Ionicons.chevron_forward, size: 18, color: Colors.grey)
        ) : null),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Reset App?", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("This will delete all your local data including scanned courses and attendance history. This action cannot be undone.", style: GoogleFonts.dmSans(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey))),
          TextButton(
            onPressed: () async {
               // Hard reset
               await ref.read(userRepositoryProvider).deleteUser();
               if (context.mounted) {
                 Navigator.pop(context);
                 context.go('/auth'); // Redirect to auth
               }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text("Nuke Data", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }
}
