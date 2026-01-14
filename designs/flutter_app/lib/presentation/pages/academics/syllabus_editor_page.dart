import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/core/theme/app_colors.dart';

class SyllabusEditorPage extends StatefulWidget {
  const SyllabusEditorPage({super.key});

  @override
  State<SyllabusEditorPage> createState() => _SyllabusEditorPageState();
}

class _SyllabusEditorPageState extends State<SyllabusEditorPage> {
  // Mock Data
  final List<Map<String, dynamic>> _units = [
    {
      "title": "Unit 1: Introduction",
      "topics": ["Basics of Flutter", "Widget Tree", "State Management"]
    },
    {
      "title": "Unit 2: Networking",
      "topics": ["REST API", "JSON Parsing", "Error Handling"]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Syllabus", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.save_outline, color: AppColors.primary),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syllabus Saved!")));
               context.pop();
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Import Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pastelBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Ionicons.document_text_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Import Syllabus", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      Text("Paste JSON or Upload File", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Ionicons.cloud_upload_outline, color: AppColors.primary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Import Modal Opened (Simulated)")));
                  },
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text("Units & Topics", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          ..._units.map((unit) => _buildUnitCard(unit)).toList(),
          
          const SizedBox(height: 80), // Fab space
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           setState(() {
             _units.add({"title": "New Unit", "topics": []});
           });
        },
        label: const Text("Add Unit"),
        icon: const Icon(Ionicons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(unit['title'], style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          ...(unit['topics'] as List).map((topic) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(topic, style: GoogleFonts.dmSans(fontSize: 14)),
            trailing: IconButton(
              icon: const Icon(Ionicons.trash_outline, size: 16, color: Colors.red),
              onPressed: () {},
            ),
          )),
          TextButton.icon(
             onPressed: () {},
             icon: const Icon(Ionicons.add_circle_outline, size: 16),
             label: const Text("Add Topic"),
          )
        ],
      ),
    );
  }
}
