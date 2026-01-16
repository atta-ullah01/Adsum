import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class WorkDetailPage extends StatefulWidget {
  final Map<String, dynamic> workItem;

  const WorkDetailPage({super.key, required this.workItem});

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  final List<Map<String, dynamic>> _comments = [
    {"user_id": "prof_alan", "text": "Make sure to double check the determinants.", "created_at": "2h ago", "isMe": false},
    {"user_id": "current_user", "text": "Thanks professor!", "created_at": "1h ago", "isMe": true},
  ];

  void _addComment(String text) {
    setState(() {
      _comments.add({
        "user_id": "current_user",
        "text": text,
        "created_at": "Just now",
        "isMe": true
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> item = widget.workItem;
    final String workType = item['work_type'] ?? "ASSIGNMENT";
    
    // Determine Color & Icon based on work_type
    Color typeColor;
    IconData typeIcon;
    if (workType == 'EXAM') {
      typeColor = Colors.red;
      typeIcon = Ionicons.alert_circle;
    } else if (workType == 'QUIZ') {
      typeColor = Colors.purple;
      typeIcon = Ionicons.timer;
    } else {
      typeColor = Colors.blue; 
      typeIcon = Ionicons.document_text;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.share_social_outline, color: Colors.black),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Ionicons.ellipsis_vertical, color: Colors.black),
            onSelected: (value) {
              if (value == 'hide') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hidden from calendar")),
                );
                context.pop();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'hide',
                child: Row(
                  children: [
                    Icon(Ionicons.eye_off_outline, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Text("Hide from Calendar", style: GoogleFonts.dmSans()),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Meta Tags (Pills)
            Row(
              children: [
                _buildTag(item['course_code'] ?? "General", AppColors.primary),
                const SizedBox(width: 8),
                _buildTag(workType, typeColor, icon: typeIcon),
              ],
            ),
            const SizedBox(height: 16),
            
            // 2. Big Title
            Text(
              item['title'] ?? "Untitled Work",
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1, color: AppColors.textMain),
            ),
            const SizedBox(height: 16),

            // 3. Dynamic Key Dates / Info
            if (workType == 'ASSIGNMENT')
               _buildMetaRow(Ionicons.time_outline, "Due ${item['due_at'] ?? 'No Date'}"),
            
            if (workType == 'QUIZ')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(Ionicons.calendar_outline, "Window: ${item['start_at']} - ${item['due_at']}"),
                  const SizedBox(height: 8),
                   _buildMetaRow(Ionicons.hourglass_outline, "Duration: ${item['duration_minutes']} mins"),
                ],
              ),

             if (workType == 'EXAM')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(Ionicons.calendar, "Date: ${item['start_at']}"),
                  const SizedBox(height: 8),
                   _buildMetaRow(Ionicons.location_outline, "Venue: ${item['venue'] ?? 'TBD'}"),
                ],
              ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            
            // 4. Instructions / Description
            Text("DETAILS", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(
              item['description'] ?? "No additional details provided.",
              style: GoogleFonts.dmSans(fontSize: 16, height: 1.6, color: AppColors.textMain),
            ),
            
            const SizedBox(height: 32),
            
             // 6. Discussion
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("DISCUSSION", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1)),
                 TextButton.icon(
                   onPressed: () => _showAskSheet(context),
                   icon: Icon(Ionicons.chatbubble_ellipses_outline, size: 16, color: AppColors.primary),
                   label: Text("Ask", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                   style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                 )
              ],
            ),
            const SizedBox(height: 16),
            
            // Comment List (from work_comments schema)
            ..._comments.map((c) => _buildComment(c['user_id'], c['text'], c['created_at'], isMe: c['isMe'])),
            
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked as Done! 🎉")));
             context.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textMain, 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Ionicons.checkmark_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text("Mark as Completed", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text, 
          style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500)
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color, {bool isSolid = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: isSolid ? null : Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: isSolid ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: isSolid ? Colors.white : color,
              letterSpacing: 0.5
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String author, String text, String time, {bool isMe = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18, 
            backgroundColor: isMe ? Colors.grey[200] : Colors.blue[50], 
            child: Icon(Ionicons.person, size: 18, color: isMe ? Colors.grey : Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  topRight: const Radius.circular(16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(author, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                       Text(time, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey)),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Text(text, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMain, height: 1.4)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAskSheet(BuildContext context) {
    final TextEditingController ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24, left: 24, right: 24
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ask a Question", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Type your query here...",
                hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   if (ctrl.text.isNotEmpty) {
                     _addComment(ctrl.text);
                     context.pop();
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Post Question", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      )
    );
  }
}
