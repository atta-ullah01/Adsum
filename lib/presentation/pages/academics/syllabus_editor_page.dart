import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/syllabus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/core/theme/app_colors.dart';

class SyllabusEditorPage extends ConsumerStatefulWidget {
  final String courseCode;
  
  const SyllabusEditorPage({super.key, required this.courseCode});

  @override
  ConsumerState<SyllabusEditorPage> createState() => _SyllabusEditorPageState();
}

class _SyllabusEditorPageState extends ConsumerState<SyllabusEditorPage> {
  // Local state for editing
  List<SyllabusUnit> _units = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSyllabus();
    });
  }

  Future<void> _loadSyllabus() async {
    final syllabus = await ref.read(customSyllabusProvider(widget.courseCode).future);
    if (syllabus != null) {
      if (mounted) {
        setState(() {
          _units = List.from(syllabus.units);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _units = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSyllabus() async {
    final newSyllabus = CustomSyllabus(
      courseCode: widget.courseCode,
      units: _units,
    );
    
    await ref.read(syllabusServiceProvider).saveCustomSyllabus(newSyllabus);
    
    // Invalidate provider to refresh detail page
    ref.invalidate(customSyllabusProvider(widget.courseCode));
    ref.invalidate(syllabusProgressProvider(widget.courseCode));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syllabus Saved!")));
      context.pop();
    }
  }

  void _addUnit() {
    setState(() {
      _units.add(SyllabusUnit(
        unitId: 'unit_${DateTime.now().millisecondsSinceEpoch}',
        title: "Unit ${_units.length + 1}",
        unitOrder: _units.length + 1,
        topics: [],
      ));
    });
  }

  void _addTopic(int unitIndex) {
    setState(() {
      final unit = _units[unitIndex];
      final newTopics = List<SyllabusTopic>.from(unit.topics);
      newTopics.add(SyllabusTopic(
        topicId: 'topic_${DateTime.now().millisecondsSinceEpoch}',
        title: "New Topic",
      ));
      
      _units[unitIndex] = unit.copyWith(topics: newTopics);
    });
  }

  void _removeTopic(int unitIndex, int topicIndex) {
    setState(() {
      final unit = _units[unitIndex];
      final newTopics = List<SyllabusTopic>.from(unit.topics);
      newTopics.removeAt(topicIndex);
      _units[unitIndex] = unit.copyWith(topics: newTopics);
    });
  }

  void _updateUnitTitle(int index, String title) {
    setState(() {
       _units[index] = _units[index].copyWith(title: title);
    });
  }

  void _updateTopicTitle(int unitIndex, int topicIndex, String title) {
    setState(() {
      final unit = _units[unitIndex];
      final newTopics = List<SyllabusTopic>.from(unit.topics);
      newTopics[topicIndex] = newTopics[topicIndex].copyWith(title: title);
      _units[unitIndex] = unit.copyWith(topics: newTopics);
    });
  }

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
            onPressed: _saveSyllabus,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
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
          
          if (_units.isEmpty)
            Center(child: Text("No units added yet.", style: GoogleFonts.dmSans(color: Colors.grey))),

          ..._units.asMap().entries.map((entry) => _buildUnitCard(entry.key, entry.value)).toList(),
          
          const SizedBox(height: 80), // Fab space
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addUnit,
        label: const Text("Add Unit"),
        icon: const Icon(Ionicons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildUnitCard(int index, SyllabusUnit unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: TextFormField(
          initialValue: unit.title,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (val) => _updateUnitTitle(index, val),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          ...unit.topics.asMap().entries.map((topicEntry) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: TextFormField(
              initialValue: topicEntry.value.title,
              style: GoogleFonts.dmSans(fontSize: 14),
              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              onChanged: (val) => _updateTopicTitle(index, topicEntry.key, val),
            ),
            trailing: IconButton(
              icon: const Icon(Ionicons.trash_outline, size: 16, color: Colors.red),
              onPressed: () => _removeTopic(index, topicEntry.key),
            ),
          )),
          TextButton.icon(
             onPressed: () => _addTopic(index),
             icon: const Icon(Ionicons.add_circle_outline, size: 16),
             label: const Text("Add Topic"),
          )
        ],
      ),
    );
  }
}
