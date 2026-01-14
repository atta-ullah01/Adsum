import 'package:drift/drift.dart';

/// OfflineQueue table - stores pending sync operations
/// 
/// Implements the offline-first sync pattern:
/// 1. User action → immediate local update
/// 2. Enqueue sync operation
/// 3. Process queue when online
/// 4. Retry with exponential backoff on failure
@DataClassName('OfflineQueueItem')
class OfflineQueue extends Table {
  // Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();
  
  // Action details
  TextColumn get actionType => text()(); // CREATE, UPDATE, DELETE
  TextColumn get entityType => text()(); // user, enrollment, attendance, etc.
  TextColumn get entityId => text()(); // ID of the affected entity
  TextColumn get payloadJson => text()(); // Full data payload as JSON
  
  // Sync status
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // PENDING, SYNCED, DEAD_LETTER
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
