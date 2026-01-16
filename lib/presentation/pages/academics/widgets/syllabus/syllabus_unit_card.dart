import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/syllabus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class SyllabusUnitCard extends StatelessWidget {

  const SyllabusUnitCard({
    required this.index, required this.unit, required this.onUpdateTitle, required this.onAddTopic, required this.onRemoveTopic, required this.onUpdateTopicTitle, super.key,
  });
  final int index;
  final SyllabusUnit unit;
  final Function(int, String) onUpdateTitle;
  final Function(int) onAddTopic;
  final Function(int, int) onRemoveTopic;
  final Function(int, int, String) onUpdateTopicTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        key: ValueKey(unit.unitId), // Unique key for widget
        title: TextFormField(
          initialValue: unit.title,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (val) => onUpdateTitle(index, val),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          ...unit.topics.asMap().entries.map((topicEntry) {
            final topicIndex = topicEntry.key;
            final topic = topicEntry.value;
            return ListTile(
              key: ValueKey(topic.topicId),
              contentPadding: EdgeInsets.zero,
              title: TextFormField(
                initialValue: topic.title,
                style: GoogleFonts.dmSans(fontSize: 14),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                onChanged: (val) => onUpdateTopicTitle(index, topicIndex, val),
              ),
              trailing: IconButton(
                icon: const Icon(Ionicons.trash_outline, size: 16, color: Colors.red),
                onPressed: () => onRemoveTopic(index, topicIndex),
              ),
            );
          }),
          TextButton.icon(
             onPressed: () => onAddTopic(index),
             icon: const Icon(Ionicons.add_circle_outline, size: 16),
             label: const Text('Add Topic'),
          )
        ],
      ),
    );
  }
}
