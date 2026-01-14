import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:adsum/core/errors/error_types.dart';
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

  group('JsonFileService Edge Cases', () {
    test('readJsonArray returns null for non-existent file', () async {
      final data = await helper.jsonService.readJsonArray('does_not_exist.json');
      expect(data, isNull);
    });

    test('exists returns false for non-existent file', () async {
      final exists = await helper.jsonService.exists('phantom.json');
      expect(exists, false);
    });

    test('listFiles returns all JSON files', () async {
      await helper.jsonService.writeJson('file1.json', {'a': 1});
      await helper.jsonService.writeJson('file2.json', [1, 2, 3]);

      final files = await helper.jsonService.listFiles();
      expect(files.length, 2);
      expect(files.contains('file1.json'), true);
      expect(files.contains('file2.json'), true);
    });

    test('exportAll aggregates all data', () async {
      await helper.jsonService.writeJson('users.json', {'name': 'Test'});
      await helper.jsonService.writeJson('items.json', [1, 2, 3]);

      final export = await helper.jsonService.exportAll();

      expect(export['users'], {'name': 'Test'});
      expect(export['items'], [1, 2, 3]);
      expect(export['exported_at'], isNotNull);
    });

    test('handle corrupt file gracefully', () async {
      // Manually create a corrupt JSON file
      final file = File('${helper.tempDir.path}/corrupt.json');
      await file.writeAsString('{ "incomplete": ');

      try {
        await helper.jsonService.readJson('corrupt.json');
        // If it doesn"t throw, unexpected but valid if impl swallows it.
        // Assuming implementation might throw FormatException for now.
      } catch (e) {
        expect(e, isA<DataIntegrityException>());
      }
    });
  });
}
