import 'dart:convert';
import 'dart:io';

import 'package:adsum/core/errors/error_types.dart';
import 'package:adsum/core/utils/app_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service for reading/writing local JSON files with atomic writes.
/// 
/// Implements the "document" storage pattern from SCHEMA.md Part 2.
/// Features:
/// - Atomic writes (write to .tmp, then rename)
/// - Automatic backup before overwrite
/// - Schema validation
/// - Error recovery
class JsonFileService {
  static const String _dataDir = 'data';
  static const String _backupSuffix = '.backup';
  static const String _tempSuffix = '.tmp';
  
  String? _basePath;
  
  /// Initialize the service
  /// Initialize the service
  Future<void> initialize({String? overrideBasePath}) async {
    if (_basePath != null) return;
    
    if (overrideBasePath != null) {
      _basePath = overrideBasePath;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      _basePath = p.join(appDir.path, _dataDir);
    }
    
    // Ensure data directory exists
    final dir = Directory(_basePath!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      AppLogger.info('Created data directory', context: {'path': _basePath});
    }
  }
  
  String _getFilePath(String filename) {
    if (_basePath == null) {
      throw const DataIntegrityException(
        message: 'JsonFileService not initialized',
        type: DataIntegrityErrorType.corruptedFile,
      );
    }
    return p.join(_basePath!, filename);
  }
  
  // ============ Read Operations ============
  
  /// Read and parse a JSON file
  Future<dynamic> readJson(String filename) async {
    await initialize();
    final path = _getFilePath(filename);
    final file = File(path);
    
    if (!await file.exists()) {
      AppLogger.debug('JSON file not found, returning null', context: {'filename': filename});
      return null;
    }
    
    try {
      final content = await file.readAsString();
      return jsonDecode(content);
    } on FormatException catch (e, st) {
      AppLogger.error(
        'Failed to parse JSON file',
        context: {'filename': filename},
        error: e,
        stackTrace: st,
      );
      
      // Try to recover from backup
      final recovered = await _recoverFromBackup(filename);
      if (recovered != null) return recovered;
      
      throw DataIntegrityException(
        message: 'JSON parse error: ${e.message}',
        type: DataIntegrityErrorType.parseError,
        affectedEntity: filename,
        originalError: e,
        stackTrace: st,
      );
    } on FileSystemException catch (e, st) {
      AppLogger.error(
        'Failed to read JSON file',
        context: {'filename': filename},
        error: e,
        stackTrace: st,
      );
      throw DataIntegrityException(
        message: 'File read error: ${e.message}',
        type: DataIntegrityErrorType.corruptedFile,
        affectedEntity: filename,
        originalError: e,
        stackTrace: st,
      );
    }
  }
  
  /// Read JSON as a Map
  Future<Map<String, dynamic>?> readJsonObject(String filename) async {
    final data = await readJson(filename);
    if (data == null) return null;
    if (data is! Map<String, dynamic>) {
      throw DataIntegrityException(
        message: 'Expected JSON object but got ${data.runtimeType}',
        type: DataIntegrityErrorType.parseError,
        affectedEntity: filename,
      );
    }
    return data;
  }
  
  /// Read JSON as a List
  Future<List<dynamic>?> readJsonArray(String filename) async {
    final data = await readJson(filename);
    if (data == null) return null;
    if (data is! List) {
      throw DataIntegrityException(
        message: 'Expected JSON array but got ${data.runtimeType}',
        type: DataIntegrityErrorType.parseError,
        affectedEntity: filename,
      );
    }
    return data;
  }
  
  // ============ Write Operations ============
  
  /// Write JSON data atomically
  /// 
  /// Process:
  /// 1. Create backup of existing file (if exists)
  /// 2. Write to temporary file
  /// 3. Rename temp to target (atomic on most filesystems)
  Future<void> writeJson(String filename, dynamic data, {bool backup = true}) async {
    await initialize();
    final path = _getFilePath(filename);
    final file = File(path);
    final tempPath = '$path$_tempSuffix';
    final tempFile = File(tempPath);
    
    try {
      // Create backup if file exists
      if (backup && await file.exists()) {
        await _createBackup(filename);
      }
      
      // Write to temp file
      final json = const JsonEncoder.withIndent('  ').convert(data);
      await tempFile.writeAsString(json);
      
      // Atomic rename
      await tempFile.rename(path);
      
      AppLogger.debug(
        'Wrote JSON file',
        context: {'filename': filename, 'size': json.length},
      );
    } on FileSystemException catch (e, st) {
      // Clean up temp file if it exists
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      AppLogger.error(
        'Failed to write JSON file',
        context: {'filename': filename},
        error: e,
        stackTrace: st,
      );
      
      throw DataIntegrityException(
        message: 'File write error: ${e.message}',
        type: DataIntegrityErrorType.corruptedFile,
        affectedEntity: filename,
        originalError: e,
        stackTrace: st,
      );
    }
  }
  
  /// Update a JSON object by merging with existing data
  Future<void> updateJsonObject(
    String filename,
    Map<String, dynamic> updates, {
    Map<String, dynamic> Function(Map<String, dynamic>)? transformer,
  }) async {
    var existing = await readJsonObject(filename) ?? <String, dynamic>{};
    
    if (transformer != null) {
      existing = transformer(existing);
    }
    
    existing.addAll(updates);
    await writeJson(filename, existing);
  }
  
  /// Append to a JSON array
  Future<void> appendToJsonArray(String filename, dynamic item) async {
    final existing = await readJsonArray(filename) ?? [];
    existing.add(item);
    await writeJson(filename, existing);
  }
  
  /// Update item in JSON array by key
  Future<bool> updateInJsonArray(
    String filename, {
    required String keyField,
    required String keyValue,
    required Map<String, dynamic> updates,
  }) async {
    final existing = await readJsonArray(filename);
    if (existing == null) return false;
    
    var found = false;
    for (var i = 0; i < existing.length; i++) {
      if (existing[i] is Map && existing[i][keyField] == keyValue) {
        final current = Map<String, dynamic>.from(existing[i] as Map);
        current.addAll(updates);
        existing[i] = current;
        found = true;
        break;
      }
    }
    
    if (found) {
      await writeJson(filename, existing);
    }
    return found;
  }
  
  /// Remove item from JSON array by key
  Future<bool> removeFromJsonArray(
    String filename, {
    required String keyField,
    required String keyValue,
  }) async {
    final existing = await readJsonArray(filename);
    if (existing == null) return false;
    
    final lengthBefore = existing.length;
    existing.removeWhere(
      (item) => item is Map && item[keyField] == keyValue,
    );
    
    if (existing.length != lengthBefore) {
      await writeJson(filename, existing);
      return true;
    }
    return false;
  }
  
  // ============ Backup & Recovery ============
  
  Future<void> _createBackup(String filename) async {
    final path = _getFilePath(filename);
    final backupPath = '$path$_backupSuffix';
    
    try {
      await File(path).copy(backupPath);
      AppLogger.debug('Created backup', context: {'filename': filename});
    } catch (e) {
      // Non-fatal, log and continue
      AppLogger.warn('Failed to create backup', context: {'filename': filename}, error: e);
    }
  }
  
  Future<dynamic> _recoverFromBackup(String filename) async {
    final path = _getFilePath(filename);
    final backupPath = '$path$_backupSuffix';
    final backupFile = File(backupPath);
    
    if (!await backupFile.exists()) {
      AppLogger.warn('No backup available for recovery', context: {'filename': filename});
      return null;
    }
    
    try {
      final content = await backupFile.readAsString();
      final data = jsonDecode(content);
      
      // Restore from backup
      await backupFile.copy(path);
      AppLogger.info('Recovered from backup', context: {'filename': filename});
      
      return data;
    } catch (e) {
      AppLogger.error('Backup recovery failed', context: {'filename': filename}, error: e);
      return null;
    }
  }
  
  // ============ Utilities ============
  
  /// Check if a JSON file exists
  Future<bool> exists(String filename) async {
    await initialize();
    return File(_getFilePath(filename)).exists();
  }
  
  /// Delete a JSON file
  Future<void> delete(String filename, {bool includeBackup = false}) async {
    await initialize();
    final path = _getFilePath(filename);
    
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    
    if (includeBackup) {
      final backupFile = File('$path$_backupSuffix');
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    }
  }
  
  /// List all JSON files in data directory
  Future<List<String>> listFiles() async {
    await initialize();
    final dir = Directory(_basePath!);
    final files = await dir.list().toList();
    
    return files
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => p.basename(f.path))
        .toList();
  }
  
  /// Get data directory path
  Future<String> getDataPath() async {
    await initialize();
    return _basePath!;
  }
  
  /// Export all data to a single backup file
  Future<Map<String, dynamic>> exportAll() async {
    final files = await listFiles();
    final export = <String, dynamic>{
      'exported_at': DateTime.now().toIso8601String(),
      'version': 1,
    };
    
    for (final filename in files) {
      try {
        export[filename.replaceAll('.json', '')] = await readJson(filename);
      } catch (e) {
        AppLogger.warn('Skipped file in export', context: {'filename': filename}, error: e);
      }
    }
    
    return export;
  }
}
