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

  group('WorkRepository', () {
    test('getAll returns empty list initially', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final works = await repo.getAll();
      expect(works, isEmpty);
    });

    test('add creates work item with generated ID', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      final work = await repo.add(
        courseCode: 'CS101',
        workType: WorkType.assignment,
        title: 'Homework 1',
        dueAt: DateTime(2026, 1, 20),
        description: 'Complete exercises 1-10',
      );

      expect(work.workId, isNotEmpty);
      expect(work.courseCode, 'CS101');
      expect(work.title, 'Homework 1');
      expect(work.workType, WorkType.assignment);
    });

    test('getForCourse filters by course code', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      await repo.add(courseCode: 'CS101', workType: WorkType.assignment, title: 'HW1');
      await repo.add(courseCode: 'MATH101', workType: WorkType.quiz, title: 'Quiz1');
      await repo.add(courseCode: 'CS101', workType: WorkType.project, title: 'Project1');

      final cs101Work = await repo.getForCourse('CS101');
      expect(cs101Work.length, 2);
      expect(cs101Work.every((w) => w.courseCode == 'CS101'), true);
    });

    test('getById returns correct work item', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      final created = await repo.add(
        courseCode: 'PHYS101',
        workType: WorkType.exam,
        title: 'Midterm',
      );

      final fetched = await repo.getById(created.workId);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Midterm');
    });

    test('getById returns null for non-existent ID', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final fetched = await repo.getById('non_existent');
      expect(fetched, isNull);
    });

    test('update modifies existing work', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      final created = await repo.add(
        courseCode: 'CS101',
        workType: WorkType.assignment,
        title: 'Original Title',
      );

      final updated = Work(
        workId: created.workId,
        courseCode: created.courseCode,
        workType: created.workType,
        title: 'Updated Title',
        createdAt: created.createdAt,
      );
      await repo.update(updated);

      final fetched = await repo.getById(created.workId);
      expect(fetched!.title, 'Updated Title');
    });

    test('delete removes work item', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      final created = await repo.add(
        courseCode: 'CS101',
        workType: WorkType.assignment,
        title: 'To Delete',
      );

      await repo.delete(created.workId);
      final fetched = await repo.getById(created.workId);
      expect(fetched, isNull);
    });

    test('updateState creates and updates work state', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      final work = await repo.add(
        courseCode: 'CS101',
        workType: WorkType.assignment,
        title: 'Stateful Work',
      );

      // Initial state should be null
      var state = await repo.getState(work.workId);
      expect(state, isNull);

      // Create state
      await repo.updateState(WorkState(workId: work.workId, status: WorkStatus.submitted));
      state = await repo.getState(work.workId);
      expect(state, isNotNull);
      expect(state!.status, WorkStatus.submitted);

      // Update state
      await repo.updateState(state.copyWith(status: WorkStatus.graded, grade: 'A'));
      state = await repo.getState(work.workId);
      expect(state!.status, WorkStatus.graded);
      expect(state.grade, 'A');
    });

    test('getAllStates returns all work states', () async {
      final repo = helper.container.read(workRepositoryProvider);
      
      final w1 = await repo.add(courseCode: 'A', workType: WorkType.assignment, title: 'W1');
      final w2 = await repo.add(courseCode: 'B', workType: WorkType.quiz, title: 'W2');

      await repo.updateState(WorkState(workId: w1.workId, status: WorkStatus.submitted));
      await repo.updateState(WorkState(workId: w2.workId, status: WorkStatus.graded, grade: 'B'));

      final states = await repo.getAllStates();
      expect(states.length, 2);
    });
  });
}
