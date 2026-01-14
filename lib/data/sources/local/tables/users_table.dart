import 'package:drift/drift.dart';

/// Users table - stores cached user profile
/// 
/// Maps to `/data/user.json` structure but in relational form.
/// Only one user should exist at a time (current logged-in user).
@DataClassName('User')
class Users extends Table {
  // Primary key
  TextColumn get userId => text()();
  
  // Profile
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get profileImage => text().nullable()();
  
  // Organization
  TextColumn get universityId => text().nullable()();
  TextColumn get homeHostelId => text().nullable()();
  TextColumn get defaultSection => text().withDefault(const Constant('A'))();
  
  // Settings stored as JSON for flexibility
  TextColumn get settingsJson => text().withDefault(const Constant('{}'))();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {userId};
}
