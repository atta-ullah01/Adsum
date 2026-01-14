import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/core/utils/app_logger.dart';

/// Helper class to manage test infrastructure
class TestHelper {
  late Directory tempDir;
  late JsonFileService jsonService;
  late ProviderContainer container;

  Future<void> setUp() async {
    AppLogger.enableFileLogging = false;
    tempDir = await Directory.systemTemp.createTemp('adsum_test_');
    jsonService = JsonFileService();
    await jsonService.initialize(overrideBasePath: tempDir.path);
    container = ProviderContainer(
      overrides: [
        jsonFileServiceProvider.overrideWithValue(jsonService),
      ],
    );
  }

  Future<void> tearDown() async {
    container.dispose();
    await tempDir.delete(recursive: true);
  }
}
