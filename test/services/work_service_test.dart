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

  group('WorkService Integration', () {
    test('getPending returns only valid pending items', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final service = helper.container.read(workServiceProvider);

      final futureDate = DateTime.now().add(const Duration(days: 3));
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      // 1. Valid pending work
      final work1 = await repo.add(courseCode: 'CS101', workType: WorkType.assignment, title: 'HW1', dueAt: futureDate);
      
      // 2. Past due work
      await repo.add(courseCode: 'CS101', workType: WorkType.quiz, title: 'Quiz1', dueAt: pastDate);
      
      // 3. Submitted work (future due but done)
      final work3 = await repo.add(courseCode: 'CS101', workType: WorkType.project, title: 'Proj1', dueAt: futureDate);
      await service.markSubmitted(work3.workId);

      final pending = await service.getPending();
      expect(pending.length, 1);
      expect(pending.first.workId, work1.workId);
    });

    test('getPending sorts by due date', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final service = helper.container.read(workServiceProvider);

      final date1 = DateTime.now().add(const Duration(days: 5));
      final date2 = DateTime.now().add(const Duration(days: 1));
      final date3 = DateTime.now().add(const Duration(days: 3));

      await repo.add(courseCode: 'A', workType: WorkType.assignment, title: 'Later', dueAt: date1);
      await repo.add(courseCode: 'B', workType: WorkType.quiz, title: 'Earliest', dueAt: date2);
      await repo.add(courseCode: 'C', workType: WorkType.project, title: 'Middle', dueAt: date3);

      final pending = await service.getPending();
      expect(pending[0].title, 'Earliest');
      expect(pending[1].title, 'Middle');
      expect(pending[2].title, 'Later');
    });

    test('getPendingCount returns correct count', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final service = helper.container.read(workServiceProvider);

      final futureDate = DateTime.now().add(const Duration(days: 3));
      await repo.add(courseCode: 'A', workType: WorkType.assignment, title: 'W1', dueAt: futureDate);
      await repo.add(courseCode: 'B', workType: WorkType.quiz, title: 'W2', dueAt: futureDate);

      final count = await service.getPendingCount();
      expect(count, 2);
    });

    test('getForCourse returns course-specific work', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final service = helper.container.read(workServiceProvider);

      await repo.add(courseCode: 'CS101', workType: WorkType.assignment, title: 'CS HW');
      await repo.add(courseCode: 'MATH101', workType: WorkType.quiz, title: 'Math Quiz');
      await repo.add(courseCode: 'CS101', workType: WorkType.project, title: 'CS Project');

      final csWork = await service.getForCourse('CS101');
      expect(csWork.length, 2);
    });

    test('markSubmitted updates work state', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final service = helper.container.read(workServiceProvider);

      final work = await repo.add(
        courseCode: 'CS101',
        workType: WorkType.assignment,
        title: 'Test Work',
        dueAt: DateTime.now().add(const Duration(days: 1)),
      );

      await service.markSubmitted(work.workId);

      final state = await repo.getState(work.workId);
      expect(state, isNotNull);
      expect(state!.status, WorkStatus.submitted);
    });

    test('markGraded updates work state with grade', () async {
      final repo = helper.container.read(workRepositoryProvider);
      final service = helper.container.read(workServiceProvider);

      final work = await repo.add(
        courseCode: 'CS101',
        workType: WorkType.exam,
        title: 'Final Exam',
      );

      await service.markGraded(work.workId, 'A+');

      final state = await repo.getState(work.workId);
      expect(state, isNotNull);
      expect(state!.status, WorkStatus.graded);
      expect(state.grade, 'A+');
    });
  });
}
