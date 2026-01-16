import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class SubjectSyllabusTab extends ConsumerWidget {

  const SubjectSyllabusTab({
    required this.courseCode, super.key,
  });
  final String courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syllabusAsync = ref.watch(customSyllabusProvider(courseCode));
    final progressAsync = ref.watch(syllabusProgressProvider(courseCode));

    return syllabusAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading syllabus: $err')),
      data: (syllabus) {
        final units = syllabus?.units ?? [];
        if (units.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Ionicons.book_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No syllabus found', style: GoogleFonts.dmSans(color: Colors.grey)),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    context.push('/syllabus-editor', extra: {'courseCode': courseCode});
                  },
                  icon: const Icon(Ionicons.add),
                  label: const Text('Create Syllabus'),
                ),
              ],
            ),
          );
        }

        final completedTopicIds = progressAsync.asData?.value ?? [];

        var totalTopics = 0;
        var completedTopics = 0;
        for (final unit in units) {
          for (final topic in unit.topics) {
            totalTopics++;
            if (completedTopicIds.contains(topic.topicId)) completedTopics++;
          }
        }

        final progress = totalTopics == 0 ? 0.0 : completedTopics / totalTopics;
        final percentage = '${(progress * 100).toInt()}%';

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 1. Progress Card
            FadeSlideTransition(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreen,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Overall Progress', style: GoogleFonts.dmSans(color: Colors.green[900], fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$completedTopics / $totalTopics Topics', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900])),
                          ],
                        ),
                        Text(percentage, style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.green[900])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white,
                        color: Colors.green,
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Modules', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                TextButton.icon(
                  onPressed: () {
                    context.push('/syllabus-editor', extra: {'courseCode': courseCode});
                  },
                  icon: const Icon(Ionicons.create_outline, size: 18),
                  label: const Text('Edit / Import'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 16),

            // 2. Units Accordion List
            ...List.generate(units.length, (index) {
              final unit = units[index];
              return FadeSlideTransition(
                index: index + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgApp,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(unit.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 16)),
                        subtitle: Text('${unit.topics.length} Topics', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13)),
                        childrenPadding: const EdgeInsets.only(bottom: 16),
                        iconColor: AppColors.textMain,
                        children: unit.topics.map<Widget>((topic) {
                          final isDone = completedTopicIds.contains(topic.topicId);
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            title: Text(
                              topic.title,
                              style: GoogleFonts.dmSans(
                                color: isDone ? Colors.grey[400] : AppColors.textMain,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            leading: _buildCustomCheckbox(isDone, () async {
                              // Optimistic update handled by provider invalidation in service
                              await ref.read(syllabusServiceProvider).toggleComplete(courseCode, topic.topicId);
                              ref.invalidate(syllabusProgressProvider(courseCode));
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCustomCheckbox(bool isChecked, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isChecked ? AppColors.primary : Colors.grey.shade400, width: 2),
        ),
        child: isChecked ? const Icon(Ionicons.checkmark, size: 16, color: Colors.white) : null,
      ),
    );
  }
}
