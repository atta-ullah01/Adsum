import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

enum ScheduleSource { admin, cr, user }

class ScheduleBlock extends StatelessWidget { // New: Explains the conflict logic ("Replaces Math")

  const ScheduleBlock({
    required this.title, required this.time, required this.location, required this.source, super.key,
    this.isCancelled = false,
    this.isUnconfirmed = false,
    this.resolutionNote,
  });
  final String title;
  final String time;
  final String location;
  final ScheduleSource source;
  final bool isCancelled;
  final bool isUnconfirmed;
  final String? resolutionNote;

  // Source-specific Colors (Bold logic)
  Color get _accentColor {
    if (isCancelled) return Colors.grey;
    switch (source) {
      case ScheduleSource.admin:
        return Colors.grey.shade700; // Neutral Professional
      case ScheduleSource.cr:
        return const Color(0xFF2979FF); // Distinct Blue (Action)
      case ScheduleSource.user:
        return const Color(0xFF9C27B0); // Personal Purple
    }
  }

  // Source-specific Icons
  IconData get _sourceIcon {
    switch (source) {
      case ScheduleSource.admin: return Ionicons.shield_checkmark_outline;
      case ScheduleSource.cr: return Ionicons.create_outline;
      case ScheduleSource.user: return Ionicons.person_outline;
    }
  }

  String get _sourceLabel {
    switch (source) {
      case ScheduleSource.admin: return 'Official';
      case ScheduleSource.cr: return 'CR Update';
      case ScheduleSource.user: return 'Personal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (source == ScheduleSource.cr) // Highlight CR changes slightly more
            BoxShadow(
              color: _accentColor.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isCancelled ? Colors.grey.shade300 : Colors.transparent, // Only border if cancelled
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: InkWell(
            onTap: () {
              context.push('/subject-detail', extra: {
                'title': title,
                'code': 'CS-101', // Mock Code for now
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Color Strip (The unifying design language)
                Container(
                  width: 6,
                  color: isCancelled ? Colors.grey : _accentColor,
                ),

                 Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Time + Source Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              time,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCancelled ? Colors.grey : Colors.black87,
                              ),
                            ),
                            // Source Tag + Resolution
                            Row(
                              mainAxisSize: MainAxisSize.min, // Fix: Don't try to fill width unnecessarily
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _accentColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_sourceIcon, size: 12, color: _accentColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        _sourceLabel,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Conflict Resolution Note
                                if (resolutionNote != null) ...[
                                   const SizedBox(width: 8),
                                   Flexible( // Fix: Use Flexible instead of Expanded to respect parent constraints
                                     child: Text(
                                       resolutionNote!,
                                       style: GoogleFonts.dmSans(
                                         fontSize: 11,
                                         color: Colors.orange[800],
                                         fontStyle: FontStyle.italic,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   )
                                ]
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Title
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 16, // Reduced slightly for elegance
                            fontWeight: FontWeight.w600,
                            color: isCancelled ? Colors.grey : Colors.black87,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Location
                        Row(
                          children: [
                            Icon(Ionicons.location_outline, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        // Unconfirmed/Cancelled Badges (Footer)
                        if (isCancelled) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                 const Icon(Ionicons.alert_circle, size: 14, color: Colors.red),
                                 const SizedBox(width: 6),
                                 Text(
                                  'Class Cancelled',
                                  style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
