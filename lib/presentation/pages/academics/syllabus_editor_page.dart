import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/pages/academics/providers/syllabus_editor_viewmodel.dart';
import 'package:adsum/presentation/pages/academics/widgets/syllabus/syllabus_import_card.dart';
import 'package:adsum/presentation/pages/academics/widgets/syllabus/syllabus_unit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class SyllabusEditorPage extends ConsumerWidget {
  const SyllabusEditorPage({required this.courseCode, super.key});
  final String courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmState = ref.watch(syllabusEditorViewModelProvider(courseCode));
    final vmNotifier = ref.read(syllabusEditorViewModelProvider(courseCode).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Syllabus', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: vmState.isSaving 
               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
               : const Icon(Ionicons.save_outline, color: AppColors.primary),
            onPressed: vmState.isSaving ? null : () async {
               await vmNotifier.saveSyllabus(courseCode);
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syllabus Saved!')));
                 context.pop();
               }
            },
          )
        ],
      ),
      body: vmState.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SyllabusImportCard(),
          
          const SizedBox(height: 32),
          Text('Units & Topics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (vmState.units.isEmpty)
            Center(child: Text('No units added yet.', style: GoogleFonts.dmSans(color: Colors.grey))),

          ...vmState.units.asMap().entries.map((entry) => SyllabusUnitCard(
             index: entry.key, 
             unit: entry.value,
             onUpdateTitle: vmNotifier.updateUnitTitle,
             onAddTopic: vmNotifier.addTopic,
             onRemoveTopic: vmNotifier.removeTopic,
             onUpdateTopicTitle: vmNotifier.updateTopicTitle,
          )),
          
          const SizedBox(height: 80), 
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vmNotifier.addUnit,
        label: const Text('Add Unit'),
        icon: const Icon(Ionicons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
