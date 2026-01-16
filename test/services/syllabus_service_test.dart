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

  group('SyllabusService Integration', () {
    test('calculateCompletionPercentage works', () async {
      final repo = helper.container.read(syllabusRepositoryProvider);
      final service = helper.container.read(syllabusServiceProvider);

      // Create custom syllabus
      const topic1 = SyllabusTopic(topicId: 'T1', title: 'Start');
      const topic2 = SyllabusTopic(topicId: 'T2', title: 'End');
      const unit = SyllabusUnit(unitId: 'U1', title: 'Unit 1', unitOrder: 1, topics: [topic1, topic2]);
      
      await repo.saveCustomSyllabus(const CustomSyllabus(courseCode: 'MATH101', units: [unit]));

      // Initially 0%
      expect(await service.getCompletionPercentage('MATH101'), 0.0);

      // Mark T1 complete -> 50%
      await service.markComplete('MATH101', 'T1');
      expect(await service.getCompletionPercentage('MATH101'), 50.0);

      // Mark T2 complete -> 100%
      await service.markComplete('MATH101', 'T2');
      expect(await service.getCompletionPercentage('MATH101'), 100.0);
    });

    test('markComplete adds topic to progress', () async {
      final service = helper.container.read(syllabusServiceProvider);

      await service.markComplete('CS101', 'T1');
      await service.markComplete('CS101', 'T2');

      final progress = await service.getProgress('CS101');
      expect(progress.length, 2);
      expect(progress, contains('T1'));
      expect(progress, contains('T2'));
    });

    test('markComplete is idempotent', () async {
      final service = helper.container.read(syllabusServiceProvider);

      await service.markComplete('CS101', 'T1');
      await service.markComplete('CS101', 'T1');
      await service.markComplete('CS101', 'T1');

      final progress = await service.getProgress('CS101');
      expect(progress.length, 1);
    });

    test('markIncomplete removes topic from progress', () async {
      final service = helper.container.read(syllabusServiceProvider);

      await service.markComplete('CS101', 'T1');
      await service.markComplete('CS101', 'T2');
      await service.markIncomplete('CS101', 'T1');

      final progress = await service.getProgress('CS101');
      expect(progress.length, 1);
      expect(progress, contains('T2'));
    });

    test('toggleComplete switches state', () async {
      final service = helper.container.read(syllabusServiceProvider);

      // Initially not complete
      var progress = await service.getProgress('CS101');
      expect(progress.contains('T1'), false);

      // Toggle to complete
      final result1 = await service.toggleComplete('CS101', 'T1');
      expect(result1, true); // Now complete
      progress = await service.getProgress('CS101');
      expect(progress.contains('T1'), true);

      // Toggle back to incomplete
      final result2 = await service.toggleComplete('CS101', 'T1');
      expect(result2, false); // Now incomplete
      progress = await service.getProgress('CS101');
      expect(progress.contains('T1'), false);
    });

    test('getCustomSyllabus returns null for non-existent course', () async {
      final service = helper.container.read(syllabusServiceProvider);
      final syllabus = await service.getCustomSyllabus('UNKNOWN');
      expect(syllabus, isNull);
    });

    test('saveCustomSyllabus and getCustomSyllabus work', () async {
      final service = helper.container.read(syllabusServiceProvider);

      const syllabus = CustomSyllabus(
        courseCode: 'CS101',
        units: [
          SyllabusUnit(unitId: 'U1', title: 'Intro', unitOrder: 1, topics: [
            SyllabusTopic(topicId: 'T1', title: 'Overview'),
          ]),
        ],
      );

      await service.saveCustomSyllabus(syllabus);
      final fetched = await service.getCustomSyllabus('CS101');

      expect(fetched, isNotNull);
      expect(fetched!.courseCode, 'CS101');
      expect(fetched.units.first.title, 'Intro');
    });

    test('deleteCustomSyllabus removes syllabus and progress', () async {
      final service = helper.container.read(syllabusServiceProvider);

      await service.saveCustomSyllabus(const CustomSyllabus(
        courseCode: 'CS101',
        units: [SyllabusUnit(unitId: 'U1', title: 'Unit', unitOrder: 1, topics: [
          SyllabusTopic(topicId: 'T1', title: 'Topic'),
        ])],
      ));
      await service.markComplete('CS101', 'T1');

      await service.deleteCustomSyllabus('CS101');

      final syllabus = await service.getCustomSyllabus('CS101');
      final progress = await service.getProgress('CS101');
      expect(syllabus, isNull);
      expect(progress, isEmpty);
    });
  });
}
