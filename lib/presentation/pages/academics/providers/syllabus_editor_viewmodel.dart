import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/syllabus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SyllabusEditorState {

  SyllabusEditorState({
    this.units = const [],
    this.isLoading = true,
    this.isSaving = false,
  });
  final List<SyllabusUnit> units;
  final bool isLoading;
  final bool isSaving;

  SyllabusEditorState copyWith({
    List<SyllabusUnit>? units,
    bool? isLoading,
    bool? isSaving,
  }) {
    return SyllabusEditorState(
      units: units ?? this.units,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SyllabusEditorViewModel extends AutoDisposeFamilyNotifier<SyllabusEditorState, String> {
  @override
  SyllabusEditorState build(String courseCode) {
    _loadSyllabus(courseCode);
    return SyllabusEditorState();
  }

  Future<void> _loadSyllabus(String courseCode) async {
    final syllabus = await ref.read(customSyllabusProvider(courseCode).future);
    if (syllabus != null) {
      state = state.copyWith(units: List.from(syllabus.units), isLoading: false);
    } else {
      state = state.copyWith(units: [], isLoading: false);
    }
  }

  Future<void> saveSyllabus(String courseCode) async {
    state = state.copyWith(isSaving: true);
    
    final newSyllabus = CustomSyllabus(
      courseCode: courseCode,
      units: state.units,
    );
    
    await ref.read(syllabusServiceProvider).saveCustomSyllabus(newSyllabus);
    
    ref.invalidate(customSyllabusProvider(courseCode));
    ref.invalidate(syllabusProgressProvider(courseCode));
    
    state = state.copyWith(isSaving: false);
  }

  void addUnit() {
    final newUnits = List<SyllabusUnit>.from(state.units);
    newUnits.add(SyllabusUnit(
      unitId: 'unit_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Unit ${newUnits.length + 1}',
      unitOrder: newUnits.length + 1,
    ));
    state = state.copyWith(units: newUnits);
  }

  void addTopic(int unitIndex) {
    if (unitIndex < 0 || unitIndex >= state.units.length) return;
    
    final unit = state.units[unitIndex];
    final newTopics = List<SyllabusTopic>.from(unit.topics);
    newTopics.add(SyllabusTopic(
      topicId: 'topic_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Topic',
    ));
    
    final newUnits = List<SyllabusUnit>.from(state.units);
    newUnits[unitIndex] = unit.copyWith(topics: newTopics);
    state = state.copyWith(units: newUnits);
  }

  void removeTopic(int unitIndex, int topicIndex) {
    if (unitIndex < 0 || unitIndex >= state.units.length) return;
    
    final unit = state.units[unitIndex];
    if (topicIndex < 0 || topicIndex >= unit.topics.length) return;

    final newTopics = List<SyllabusTopic>.from(unit.topics);
    newTopics.removeAt(topicIndex);
    
    final newUnits = List<SyllabusUnit>.from(state.units);
    newUnits[unitIndex] = unit.copyWith(topics: newTopics);
    state = state.copyWith(units: newUnits);
  }

  void updateUnitTitle(int index, String title) {
    if (index < 0 || index >= state.units.length) return;
    
    final newUnits = List<SyllabusUnit>.from(state.units);
    newUnits[index] = newUnits[index].copyWith(title: title);
    state = state.copyWith(units: newUnits);
  }

  void updateTopicTitle(int unitIndex, int topicIndex, String title) {
    if (unitIndex < 0 || unitIndex >= state.units.length) return;
    
    final unit = state.units[unitIndex];
    if (topicIndex < 0 || topicIndex >= unit.topics.length) return;
    
    final newTopics = List<SyllabusTopic>.from(unit.topics);
    newTopics[topicIndex] = newTopics[topicIndex].copyWith(title: title);
    
    final newUnits = List<SyllabusUnit>.from(state.units);
    newUnits[unitIndex] = unit.copyWith(topics: newTopics);
    state = state.copyWith(units: newUnits);
  }
}

final syllabusEditorViewModelProvider = NotifierProvider.family.autoDispose<SyllabusEditorViewModel, SyllabusEditorState, String>(SyllabusEditorViewModel.new);
