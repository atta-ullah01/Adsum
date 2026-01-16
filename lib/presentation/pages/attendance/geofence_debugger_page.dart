import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class GeofenceDebuggerPage extends StatefulWidget {

  const GeofenceDebuggerPage({required this.courseTitle, super.key});
  final String courseTitle;

  @override
  State<GeofenceDebuggerPage> createState() => _GeofenceDebuggerPageState();
}

class _GeofenceDebuggerPageState extends State<GeofenceDebuggerPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Geofence Debugger', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debugging: ${widget.courseTitle}',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
             
             // 1. Radar Visualizer
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Radar Waves
                   ...List.generate(3, (index) {
                     return AnimatedBuilder(
                       animation: _controller,
                       builder: (context, child) {
                         final value = (_controller.value + index * 0.33) % 1.0;
                         return Container(
                           width: 300 * value,
                           height: 300 * value,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.green.withOpacity(1 - value)),
                           ),
                         );
                       },
                     );
                   }),
                   
                   // Class Polygon (Mock Square)
                   Container(
                     width: 150, height: 150,
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                       color: Colors.blueAccent.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(16)
                     ),
                     child: Center(child: Text('CLASSROOM ZONE', style: GoogleFonts.outfit(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                   ),
                   
                   // User Dot (Inside)
                   Positioned(
                     child: Container(
                       width: 16, height: 16,
                       decoration: const BoxDecoration(
                         color: Colors.green,
                         shape: BoxShape.circle,
                         boxShadow: [BoxShadow(color: Colors.green, blurRadius: 10)]
                       ),
                     ),
                   )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. Live Scoreboard
            Text('Live Scoreboard', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildScoreCard('GPS Accuracy', '4.2m', Colors.green, Ionicons.locate)),
                const SizedBox(width: 16),
                Expanded(child: _buildScoreCard('Wi-Fi Signal', '-58 dBm', Colors.green, Ionicons.wifi)),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreCard('Total Confidence', '88% (High)', AppColors.primary, Ionicons.shield_checkmark, isFullWidth: true),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // 3. Calibration
            Text('Calibration', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
            Text('If you are inside the class but getting low confidence, calibrate the Wi-Fi signature.', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wi-Fi Signature Updated!')));
                },
                icon: const Icon(Ionicons.scan_outline),
                label: const Text('Calibrate Wi-Fi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, Color color, IconData icon, {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: isFullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
