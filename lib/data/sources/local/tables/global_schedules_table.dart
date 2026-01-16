import 'package:drift/drift.dart';

/// Global Schedules table - matches `/data/global_schedules` (Supabase)
/// 
/// Stores the university timetable locally for offline access.
/// This is a cache of the shared data, unlike strictly local data which is in JSON.
@DataClassName('GlobalScheduleEntity')
class GlobalSchedules extends Table {
  // Primary key
  TextColumn get ruleId => text()();
  
  // Foreign Key to Course
  TextColumn get courseCode => text()();
  
  // Schedule Fields
  TextColumn get section => text().nullable()();
  TextColumn get dayOfWeek => text()(); // MON, TUE...
  TextColumn get startTime => text()(); // HH:mm
  TextColumn get endTime => text()(); // HH:mm
  
  // Location/Binding Defaults
  TextColumn get locationName => text()();
  RealColumn get locationLat => real().nullable()();
  RealColumn get locationLong => real().nullable()();
  TextColumn get wifiSsid => text().nullable()();
  
  // Metadata
  DateTimeColumn get lastSyncedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {ruleId};
}
