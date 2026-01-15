import 'dart:convert';
import 'dart:io';

/// Helper to load mock data fixtures for testing
/// 
/// Usage:
/// ```dart
/// final enrollments = await MockDataFixtures.loadEnrollments();
/// final actionItems = await MockDataFixtures.loadActionItems();
/// ```
class MockDataFixtures {
  static const String _basePath = 'test/fixtures/mock_data';
  
  /// Load enrollments fixture
  static Future<List<Map<String, dynamic>>> loadEnrollments() async {
    return _loadJsonArray('enrollments.json');
  }
  
  /// Load action items fixture
  static Future<List<Map<String, dynamic>>> loadActionItems() async {
    return _loadJsonArray('action_items.json');
  }
  
  /// Load events fixture
  static Future<List<Map<String, dynamic>>> loadEvents() async {
    return _loadJsonArray('events.json');
  }
  
  /// Load attendance logs fixture
  static Future<List<Map<String, dynamic>>> loadAttendance() async {
    return _loadJsonArray('attendance.json');
  }
  
  /// Load custom schedules fixture
  static Future<List<Map<String, dynamic>>> loadCustomSchedules() async {
    return _loadJsonArray('custom_schedules.json');
  }
  
  /// Load schedule bindings fixture
  static Future<List<Map<String, dynamic>>> loadScheduleBindings() async {
    return _loadJsonArray('schedule_bindings.json');
  }
  
  /// Load menu cache fixture
  static Future<Map<String, dynamic>> loadMenuCache() async {
    return _loadJsonObject('menu_cache.json');
  }
  
  /// Load user profile fixture
  static Future<Map<String, dynamic>> loadUser() async {
    return _loadJsonObject('user.json');
  }
  
  /// Load all fixtures into a map
  static Future<Map<String, dynamic>> loadAll() async {
    return {
      'user': await loadUser(),
      'enrollments': await loadEnrollments(),
      'action_items': await loadActionItems(),
      'events': await loadEvents(),
      'attendance': await loadAttendance(),
      'custom_schedules': await loadCustomSchedules(),
      'schedule_bindings': await loadScheduleBindings(),
      'menu_cache': await loadMenuCache(),
    };
  }
  
  // ============ Private Helpers ============
  
  static Future<List<Map<String, dynamic>>> _loadJsonArray(String filename) async {
    final file = File('$_basePath/$filename');
    final content = await file.readAsString();
    final json = jsonDecode(content) as List;
    return json.cast<Map<String, dynamic>>();
  }
  
  static Future<Map<String, dynamic>> _loadJsonObject(String filename) async {
    final file = File('$_basePath/$filename');
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }
}

/// Extension to copy fixture data to JsonFileService for integration tests
extension MockDataFixturesSetup on MockDataFixtures {
  /// Copy all fixtures to the JsonFileService data directory
  /// This is useful for integration tests that use the real JsonFileService
  static Future<void> copyToDataDirectory(String dataPath) async {
    final fixtures = await MockDataFixtures.loadAll();
    
    // Write each fixture to the data directory
    await File('$dataPath/user.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['user']),
    );
    await File('$dataPath/enrollments.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['enrollments']),
    );
    await File('$dataPath/action_items.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['action_items']),
    );
    await File('$dataPath/events.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['events']),
    );
    await File('$dataPath/attendance.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['attendance']),
    );
    await File('$dataPath/custom_schedules.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['custom_schedules']),
    );
    await File('$dataPath/schedule_bindings.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['schedule_bindings']),
    );
    await File('$dataPath/menu_cache.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(fixtures['menu_cache']),
    );
  }
}
