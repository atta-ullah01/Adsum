import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final helper = TestHelper();

  setUp(() async {
    await helper.setUp();
  });

  tearDown(() async {
    await helper.tearDown();
  });

  group('SyllabusRepository', () {
    test('getProgress returns empty list initially', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      final progress = await repo.getProgress('CS101');
      expect(progress, isEmpty);
    });

    test('saveProgress stores topic IDs', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      
      await repo.saveProgress('CS101', ['T1', 'T2', 'T3']);
      final progress = await repo.getProgress('CS101');
      
      expect(progress.length, 3);
      expect(progress, contains('T1'));
      expect(progress, contains('T2'));
      expect(progress, contains('T3'));
    });

    test('clearProgress removes all progress for course', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      
      await repo.saveProgress('CS101', ['T1', 'T2']);
      await repo.clearProgress('CS101');
      
      final progress = await repo.getProgress('CS101');
      expect(progress, isEmpty);
    });

    test('getAllCustom returns empty list initially', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      final syllabi = await repo.getAllCustom();
      expect(syllabi, isEmpty);
    });

    test('saveCustomSyllabus creates new syllabus', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      
      const syllabus = CustomSyllabus(
        courseCode: 'CS101',
        units: [
          SyllabusUnit(
            unitId: 'U1',
            title: 'Introduction',
            unitOrder: 1,
            topics: [
              SyllabusTopic(topicId: 'T1', title: 'Overview'),
              SyllabusTopic(topicId: 'T2', title: 'Setup'),
            ],
          ),
        ],
      );

      await repo.saveCustomSyllabus(syllabus);
      
      final fetched = await repo.getCustomSyllabus('CS101');
      expect(fetched, isNotNull);
      expect(fetched!.units.length, 1);
      expect(fetched.units.first.topics.length, 2);
    });

    test('saveCustomSyllabus updates existing syllabus', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      
      // Create initial
      await repo.saveCustomSyllabus(const CustomSyllabus(
        courseCode: 'CS101',
        units: [SyllabusUnit(unitId: 'U1', title: 'Old', unitOrder: 1)],
      ));

      // Update
      await repo.saveCustomSyllabus(const CustomSyllabus(
        courseCode: 'CS101',
        units: [SyllabusUnit(unitId: 'U1', title: 'New', unitOrder: 1)],
      ));

      final fetched = await repo.getCustomSyllabus('CS101');
      expect(fetched!.units.first.title, 'New');
    });

    test('getCustomSyllabus returns null for non-existent course', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      final syllabus = await repo.getCustomSyllabus('UNKNOWN');
      expect(syllabus, isNull);
    });

    test('deleteCustomSyllabus removes syllabus and clears progress', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      
      await repo.saveCustomSyllabus(const CustomSyllabus(
        courseCode: 'CS101',
        units: [SyllabusUnit(unitId: 'U1', title: 'Unit', unitOrder: 1, topics: [
          SyllabusTopic(topicId: 'T1', title: 'Topic'),
        ])],
      ));
      await repo.saveProgress('CS101', ['T1']);

      await repo.deleteCustomSyllabus('CS101');

      final syllabus = await repo.getCustomSyllabus('CS101');
      final progress = await repo.getProgress('CS101');
      expect(syllabus, isNull);
      expect(progress, isEmpty);
    });
  });
}
