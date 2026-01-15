/// Mock Data Seeder for testing the main dashboard
/// 
/// Loads data from test fixture files and seeds the local JSON storage.
/// This ensures consistency between test fixtures and runtime seeding.
///
/// Fixture location: test/fixtures/mock_data/

import 'dart:convert';
import 'dart:io';

import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to seed mock data from fixture files
class MockDataSeeder {
  final JsonFileService _jsonService;
  
  /// Base path to fixture files (relative to project root)
  static const String _fixturesPath = 'test/fixtures/mock_data';
  
  MockDataSeeder(this._jsonService);
  
  /// Seeds all mock data from fixture files
  /// Call this to populate dashboard with test data
  Future<void> seedAllData() async {
    await _seedFromFixture('user.json');
    await _seedFromFixture('enrollments.json');
    await _seedFromFixture('action_items.json');
    await _seedFromFixture('events.json');
    await _seedFromFixture('attendance.json');
    await _seedFromFixture('custom_schedules.json');
    await _seedFromFixture('schedule_bindings.json');
    await _seedFromFixture('menu_cache.json');
    await _seedFromFixture('course_work.json');
    await _seedFromFixture('schedule_modifications.json');
  }
  
  /// Clear all mock data
  Future<void> clearAllData() async {
    await _jsonService.delete('user.json');
    await _jsonService.delete('enrollments.json');
    await _jsonService.delete('action_items.json');
    await _jsonService.delete('events.json');
    await _jsonService.delete('attendance.json');
    await _jsonService.delete('custom_schedules.json');
    await _jsonService.delete('schedule_bindings.json');
    await _jsonService.delete('menu_cache.json');
    await _jsonService.delete('course_work.json');
    await _jsonService.delete('schedule_modifications.json');
  }
  
  /// Seed a single file from fixtures
  Future<void> _seedFromFixture(String filename) async {
    try {
      final data = await _loadFixture(filename);
      await _jsonService.writeJson(filename, data, backup: false);
    } catch (e) {
      debugPrint('MockDataSeeder: Failed to seed $filename: $e');
    }
  }
  
  /// Load fixture file content
  Future<dynamic> _loadFixture(String filename) async {
    // Try loading from file system first (for tests and desktop)
    final file = File('$_fixturesPath/$filename');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content);
    }
    
    // Fallback: try loading from assets (for release builds if bundled)
    try {
      final content = await rootBundle.loadString('$_fixturesPath/$filename');
      return jsonDecode(content);
    } catch (_) {
      throw Exception('Fixture not found: $filename');
    }
  }
  
  // ============ Individual Seeders ============
  
  /// Seed only enrollments
  Future<void> seedEnrollments() async {
    await _seedFromFixture('enrollments.json');
  }
  
  /// Seed only action items
  Future<void> seedActionItems() async {
    await _seedFromFixture('action_items.json');
  }
  
  /// Seed only events
  Future<void> seedEvents() async {
    await _seedFromFixture('events.json');
  }
  
  /// Seed only attendance logs
  Future<void> seedAttendance() async {
    await _seedFromFixture('attendance.json');
  }
  
  /// Seed only custom schedules
  Future<void> seedCustomSchedules() async {
    await _seedFromFixture('custom_schedules.json');
  }
  
  /// Seed only schedule bindings
  Future<void> seedScheduleBindings() async {
    await _seedFromFixture('schedule_bindings.json');
  }
  
  /// Seed only mess menu cache
  Future<void> seedMessMenu() async {
    await _seedFromFixture('menu_cache.json');
  }
  
  /// Seed only user profile
  Future<void> seedUserProfile() async {
    await _seedFromFixture('user.json');
  }

  /// Seed only course work
  Future<void> seedCourseWork() async {
    await _seedFromFixture('course_work.json');
  }

  /// Alias for seedCourseWork
  Future<void> seedWork() async {
    await seedCourseWork();
  }

  /// Seed only schedule modifications
  Future<void> seedScheduleModifications() async {
    await _seedFromFixture('schedule_modifications.json');
  }
  
  // ============ Status Check ============
  
  /// Check if mock data is already seeded
  Future<bool> isSeeded() async {
    final files = [
      'user.json',
      'enrollments.json',
      'action_items.json',
      'events.json',
      'attendance.json',
      'custom_schedules.json',
      'schedule_bindings.json',
      'menu_cache.json',
      'course_work.json',
      'schedule_modifications.json',
    ];
    
    for (final f in files) {
      if (!await _jsonService.exists(f)) return false;
    }
    return true;
  }
  
  /// Get seeding status for all files
  Future<Map<String, bool>> getStatus() async {
    return {
      'user': await _jsonService.exists('user.json'),
      'enrollments': await _jsonService.exists('enrollments.json'),
      'action_items': await _jsonService.exists('action_items.json'),
      'events': await _jsonService.exists('events.json'),
      'attendance': await _jsonService.exists('attendance.json'),
      'custom_schedules': await _jsonService.exists('custom_schedules.json'),
      'schedule_bindings': await _jsonService.exists('schedule_bindings.json'),
      'menu_cache': await _jsonService.exists('menu_cache.json'),
      'course_work': await _jsonService.exists('course_work.json'),
      'schedule_modifications': await _jsonService.exists('schedule_modifications.json'),
    };
  }
}
