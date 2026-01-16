import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Structured logging with levels, context, and file rotation.
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in', context: {'userId': '123'}, tags: ['auth']);
/// AppLogger.error('Failed to sync', error: e, stackTrace: st);
/// ```
class AppLogger {
  
  AppLogger._();
  static AppLogger? _instance;
  static File? _logFile;
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int _maxLogFiles = 7;
  
  /// Set to false during tests to avoid MissingPluginException from path_provider
  static bool enableFileLogging = true;
  
  static Future<void> initialize() async {
    if (_instance != null) return;
    _instance = AppLogger._();
    await _initLogFile();
  }
  
  static Future<void> _initLogFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${dir.path}/logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      
      final today = DateTime.now().toIso8601String().split('T')[0];
      _logFile = File('${logsDir.path}/adsum_$today.log');
      
      // Rotate old logs
      await _rotateLogsIfNeeded(logsDir);
    } catch (e) {
      debugPrint('Failed to initialize logger: $e');
    }
  }
  
  static Future<void> _rotateLogsIfNeeded(Directory logsDir) async {
    try {
      final files = await logsDir.list().where((f) => f.path.endsWith('.log')).toList();
      if (files.length > _maxLogFiles) {
        // Sort by modification time, delete oldest
        final sorted = files.cast<File>().toList()
          ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        for (var i = 0; i < files.length - _maxLogFiles; i++) {
          await sorted[i].delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to rotate logs: $e');
    }
  }
  
  // Log levels
  static void debug(String message, {Map<String, dynamic>? context, List<String>? tags}) {
    _log(LogLevel.debug, message, context: context, tags: tags);
  }
  
  static void info(String message, {Map<String, dynamic>? context, List<String>? tags}) {
    _log(LogLevel.info, message, context: context, tags: tags);
  }
  
  static void warn(String message, {Map<String, dynamic>? context, List<String>? tags, Object? error}) {
    _log(LogLevel.warn, message, context: context, tags: tags, error: error);
  }
  
  static void error(String message, {Map<String, dynamic>? context, List<String>? tags, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, context: context, tags: tags, error: error, stackTrace: stackTrace);
  }
  
  static void fatal(String message, {Map<String, dynamic>? context, List<String>? tags, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, context: context, tags: tags, error: error, stackTrace: stackTrace);
  }
  
  static void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? context,
    List<String>? tags,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      context: context,
      tags: tags,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );
    
    // Console output (debug mode only for debug level)
    if (level != LogLevel.debug || kDebugMode) {
      debugPrint(entry.toConsoleString());
    }
    
    // File output (async, fire-and-forget)
    _writeToFile(entry);
    
    // Remote reporting for errors (hook point for Crashlytics/Sentry)
    if (level == LogLevel.error || level == LogLevel.fatal) {
      _reportToRemote(entry);
    }
  }
  
  static Future<void> _writeToFile(LogEntry entry) async {
    if (!enableFileLogging) return;
    try {
      if (_logFile == null) await _initLogFile();
      if (_logFile == null) return;
      
      // Check file size
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > _maxFileSizeBytes) {
          await _initLogFile(); // Will create new file for new day
        }
      }
      
      await _logFile!.writeAsString(
        '${entry.toJsonString()}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint('Failed to write log: $e');
    }
  }
  
  static void _reportToRemote(LogEntry entry) {
    // TODO: Integrate with Crashlytics/Sentry
    // FirebaseCrashlytics.instance.recordError(entry.error, entry.stackTrace);
  }
  
  /// Export logs for support tickets (strips PII)
  static Future<String?> exportLogs({bool redactPii = true}) async {
    try {
      if (_logFile == null || !await _logFile!.exists()) return null;
      var content = await _logFile!.readAsString();
      
      if (redactPii) {
        // Basic PII redaction
        content = content.replaceAll(RegExp(r'[\w.-]+@[\w.-]+\.\w+'), '[EMAIL]');
        content = content.replaceAll(RegExp(r'\b\d{10}\b'), '[PHONE]');
        content = content.replaceAll(RegExp(r'"user_?[Ii]d"\s*:\s*"[^"]+"'), '"userId": "[REDACTED]"');
      }
      
      return content;
    } catch (e) {
      debugPrint('Failed to export logs: $e');
      return null;
    }
  }
  
  /// Clear all logs
  static Future<void> clearLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${dir.path}/logs');
      if (await logsDir.exists()) {
        await logsDir.delete(recursive: true);
      }
      _logFile = null;
    } catch (e) {
      debugPrint('Failed to clear logs: $e');
    }
  }
}

enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal;
  
  String get symbol {
    switch (this) {
      case LogLevel.debug: return '🔍';
      case LogLevel.info: return 'ℹ️';
      case LogLevel.warn: return '⚠️';
      case LogLevel.error: return '❌';
      case LogLevel.fatal: return '💀';
    }
  }
}

class LogEntry {
  
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.context,
    this.tags,
    this.error,
    this.stackTrace,
  });
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? context;
  final List<String>? tags;
  final String? error;
  final String? stackTrace;
  
  String toConsoleString() {
    final buffer = StringBuffer();
    buffer.write('${level.symbol} [${level.name.toUpperCase()}] ');
    buffer.write('${timestamp.toIso8601String()} ');
    buffer.write(message);
    
    if (tags != null && tags!.isNotEmpty) {
      buffer.write(' [${tags!.join(', ')}]');
    }
    
    if (context != null && context!.isNotEmpty) {
      buffer.write(' $context');
    }
    
    if (error != null) {
      buffer.write('\n  Error: $error');
    }
    
    return buffer.toString();
  }
  
  String toJsonString() {
    final map = <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
    };
    
    if (context != null) map['context'] = context;
    if (tags != null) map['tags'] = tags;
    if (error != null) map['error'] = error;
    if (stackTrace != null) map['stackTrace'] = stackTrace;
    
    // Simple JSON encoding without adding a dependency
    return map.toString();
  }
}
