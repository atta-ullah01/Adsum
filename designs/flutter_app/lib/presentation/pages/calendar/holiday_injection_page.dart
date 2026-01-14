import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class HolidayInjectionPage extends StatefulWidget {
  const HolidayInjectionPage({super.key});

  @override
  State<HolidayInjectionPage> createState() => _HolidayInjectionPageState();
}

class _HolidayInjectionPageState extends State<HolidayInjectionPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Import Holidays", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Top: PDF Preview (Mock)
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Stack(
                children: [
                   Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Ionicons.document_text, size: 64, color: Colors.grey),
                         const SizedBox(height: 16),
                         Text("holiday_circular_2026.pdf", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                       ],
                     ),
                   ),
                   // Overlay Grid Lines
                   Positioned.fill(
                     child: GridPaper(color: Colors.blue.withOpacity(0.1), interval: 50),
                   )
                ],
              ),
            ),
          ),
          
          // Bottom: Extracted List
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text("Extracted Events", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                         child: Text("High Confidence", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                       )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView(
                      children: [
                         _buildExtractedItem("Mahavir Jayanti", "04 April 2026", "Holiday"),
                         _buildExtractedItem("Good Friday", "07 April 2026", "Holiday"),
                         _buildExtractedItem("Dr. Ambedkar Jayanti", "14 April 2026", "Holiday"),
                         _buildExtractedItem("Mid-Sem Pattern", "18 May 2026", "Exam Info", isLowConfidence: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _isProcessing = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Holidays Imported to Calendar!")));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isProcessing 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Confirm & Update Calendar", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExtractedItem(String title, String date, String type, {bool isLowConfidence = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: isLowConfidence ? Border.all(color: AppColors.warning) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
               Text(date, style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 13)),
             ],
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: isLowConfidence ? AppColors.pastelOrange : AppColors.pastelPurple,
               borderRadius: BorderRadius.circular(8),
             ),
             child: Text(type, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold)),
           )
        ],
      ),
    );
  }
}
