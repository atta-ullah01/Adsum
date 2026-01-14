import 'package:drift/drift.dart';

/// Enrollments table - stores user's course enrollments
/// 
/// Maps to `/data/enrollments.json` structure.
/// Supports both catalog courses (course_code) and custom courses (custom_course_json).
@DataClassName('Enrollment')
class Enrollments extends Table {
  // Primary key
  TextColumn get enrollmentId => text()();
  
  // Course reference - one of these should be non-null
  TextColumn get courseCode => text().nullable()(); // For catalog courses
  TextColumn get customCourseJson => text().nullable()(); // For custom courses (JSON object)
  
  // Enrollment details
  TextColumn get section => text().withDefault(const Constant('A'))();
  RealColumn get targetAttendance => real().withDefault(const Constant(75.0))();
  TextColumn get colorTheme => text().withDefault(const Constant('#6366F1'))();
  
  // Stats stored as JSON for flexibility
  TextColumn get statsJson => text().withDefault(const Constant('{"total_classes":0,"attended":0,"safe_bunks":0}'))();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {enrollmentId};
}
