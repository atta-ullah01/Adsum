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

  group('ActionItemRepository', () {
    test('add creates pending action item', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);

      final item = await repo.add(
        type: ActionItemType.conflict,
        title: 'Schedule Conflict',
        body: 'CS101 and MATH101 overlap on Monday',
        payload: {'slot_ids': ['s1', 's2']},
      );

      expect(item.itemId, isNotEmpty);
      expect(item.isPending, true);
      expect(item.type, ActionItemType.conflict);
    });

    test('getPending filters resolved items', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);

      final item1 = await repo.add(
        type: ActionItemType.verify,
        title: 'Verify Attendance',
        body: 'Were you in CS101?',
      );
      await repo.add(
        type: ActionItemType.attendanceRisk,
        title: 'Low Attendance',
        body: 'You are at 60%',
      );

      // Resolve item1
      await repo.resolve(item1.itemId, Resolution.yesPresent);

      final pending = await repo.getPending();
      expect(pending.length, 1);
      expect(pending.first.type, ActionItemType.attendanceRisk);
    });

    test('getByType filters by action type', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);

      await repo.add(type: ActionItemType.assignmentDue, title: 'HW1', body: 'Due tomorrow');
      await repo.add(type: ActionItemType.assignmentDue, title: 'HW2', body: 'Due next week');
      await repo.add(type: ActionItemType.scheduleChange, title: 'Room Change', body: 'New room');

      final assignments = await repo.getByType(ActionItemType.assignmentDue);
      expect(assignments.length, 2);
    });

    test('resolve marks item as resolved with resolution type', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);

      final item = await repo.add(
        type: ActionItemType.conflict,
        title: 'Pick One',
        body: 'Choose source A or B',
      );

      await repo.resolve(item.itemId, Resolution.keepMine);

      final fetched = await repo.getById(item.itemId);
      expect(fetched!.isPending, false);
      expect(fetched.resolution, Resolution.keepMine);
      expect(fetched.resolvedAt, isNotNull);
    });

    test('delete removes action item', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);

      final item = await repo.add(type: ActionItemType.verify, title: 'Test', body: 'Body');
      await repo.delete(item.itemId);

      final fetched = await repo.getById(item.itemId);
      expect(fetched, isNull);
    });

    test('clearResolved keeps only pending items', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);

      final item1 = await repo.add(type: ActionItemType.verify, title: 'A', body: 'a');
      await repo.add(type: ActionItemType.verify, title: 'B', body: 'b');
      await repo.resolve(item1.itemId, Resolution.acknowledged);

      await repo.clearResolved();

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.title, 'B');
    });

    test('delete non-existent item should not throw', () async {
      final repo = helper.container.read(actionItemRepositoryProvider);
      // Should complete without error
      await repo.delete('non_existent_id');
      final items = await repo.getAll();
      expect(items.isEmpty, true);
    });
  });
}
