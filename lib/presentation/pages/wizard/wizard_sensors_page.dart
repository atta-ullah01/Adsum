import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WizardSensorsPage extends ConsumerStatefulWidget {
  const WizardSensorsPage({super.key});

  @override
  ConsumerState<WizardSensorsPage> createState() => _WizardSensorsPageState();
}

class _WizardSensorsPageState extends ConsumerState<WizardSensorsPage> {
  // State for toggles (defaults match UserSettings defaults)
  bool _geofenceEnabled = false;
  bool _motionEnabled = false;
  bool _batteryEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null && mounted) {
      setState(() {
        _geofenceEnabled = userProfile.settings.sensorGeofenceEnabled;
        _motionEnabled = userProfile.settings.sensorMotionEnabled;
        _batteryEnabled = userProfile.settings.sensorBatteryOptimizationDisabled;
      });
    }
  }

  Future<void> _toggleGeofence(bool value) async {
    if (value) {
      setState(() => _isLoading = true);
      final granted = await ref.read(permissionServiceProvider).requestLocationPermission();
      setState(() => _isLoading = false);
      
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable Location permission in Settings')),
        );
        return;
      }
    }
    setState(() => _geofenceEnabled = value);
  }

  Future<void> _toggleMotion(bool value) async {
    if (value) {
      setState(() => _isLoading = true);
      final granted = await ref.read(permissionServiceProvider).requestActivityPermission();
      setState(() => _isLoading = false);
      
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable Activity Recognition in Settings')),
        );
        return;
      }
    }
    setState(() => _motionEnabled = value);
  }

  Future<void> _toggleBattery(bool value) async {
    if (value) {
      await ref.read(permissionServiceProvider).requestBatteryOptimization();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please disable battery optimization for this app')),
        );
      }
    }
    setState(() => _batteryEnabled = value);
  }

  Future<void> _saveAndFinish() async {
    setState(() => _isLoading = true);
    
    // Get current user profile
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null) {
      // Update settings
      final updatedSettings = userProfile.settings.copyWith(
        sensorGeofenceEnabled: _geofenceEnabled,
        sensorMotionEnabled: _motionEnabled,
        sensorBatteryOptimizationDisabled: _batteryEnabled,
      );
      
      await ref.read(userRepositoryProvider).updateSettings(updatedSettings);
    }
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      // Navigate to Dashboard - Clear Stack
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
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
                        child: const Text('Step 3 / 3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Hero
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset(
                          'assets/sensors_hero.png',
                          width: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Ionicons.settings, size: 100, color: Colors.grey),
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Magic Settings',
                        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Grant permissions to enable auto-attendance.',
                        style: GoogleFonts.dmSans(fontSize: 16, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 40),

                      // Grid Layout
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0, // Square ratio
                        children: [
                          _buildSensorCard(
                            icon: Ionicons.location,
                            title: 'Geofence',
                            subtitle: 'Auto-mark in class',
                            color: AppColors.pastelBlue,
                            delay: 100,
                            isEnabled: _geofenceEnabled,
                            onChanged: _toggleGeofence,
                          ),
                          _buildSensorCard(
                            icon: Ionicons.walk,
                            title: 'Motion',
                            subtitle: 'Activity Check',
                            color: AppColors.pastelYellow,
                            delay: 200,
                            isEnabled: _motionEnabled,
                            onChanged: _toggleMotion,
                          ),
                          _buildSensorCard(
                            icon: Ionicons.battery_charging,
                            title: 'Battery',
                            subtitle: 'Run in bg',
                            color: AppColors.pastelGreen,
                            delay: 300,
                            isEnabled: _batteryEnabled,
                            onChanged: _toggleBattery,
                          ),
                          _buildFinishCard(context, delay: 300),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
    required bool isEnabled,
    required Future<void> Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 18, color: Colors.black),
                ),
                // Simulated iOS Switch/Checkbox
                Container(
                  width: 50, height: 30,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34), 
                    color: isEnabled ? Colors.black : Colors.black12
                  ),
                  child: Align(
                    alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                       width: 24, height: 24,
                       decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
              ],
            )
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: delay.ms).fadeIn();
  }

  Widget _buildFinishCard(BuildContext context, {required int delay}) {
    return GestureDetector(
      onTap: _saveAndFinish,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'Finish',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.2, end: 0, delay: delay.ms).fadeIn(),
    );
  }
}
