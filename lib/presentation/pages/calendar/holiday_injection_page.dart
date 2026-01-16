import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/pages/calendar/providers/holiday_injection_viewmodel.dart';
import 'package:adsum/presentation/pages/calendar/widgets/extracted_holiday_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class HolidayInjectionPage extends ConsumerWidget {
  const HolidayInjectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(holidayInjectionViewModelProvider);
    final notifier = ref.read(holidayInjectionViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Import Holidays', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
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
                         Text('holiday_circular_2026.pdf', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.grey[700])),
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
              decoration: const BoxDecoration(
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
                       Text('Extracted Events', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                         child: Text('High Confidence', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                       )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.extractedEvents.length,
                      itemBuilder: (context, index) {
                        return ExtractedHolidayCard(event: state.extractedEvents[index]);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.isProcessing ? null : () async {
                        await notifier.importHolidays();
                        if (context.mounted) {
                           context.pop();
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Holidays Imported to Calendar!')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: state.isProcessing 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Confirm & Update Calendar', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
}
