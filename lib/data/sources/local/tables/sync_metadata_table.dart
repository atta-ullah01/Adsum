import 'package:drift/drift.dart';

/// SyncMetadata table - tracks last sync times for entities
/// 
/// Used to:
/// - Determine when to fetch updates
/// - Support incremental sync with ETags
/// - Detect stale data
@DataClassName('SyncMeta')
class SyncMetadata extends Table {
  // Entity type as primary key (e.g., 'courses', 'schedules')
  TextColumn get entityType => text()();
  
  // Last successful sync
  DateTimeColumn get lastSyncedAt => dateTime()();
  
  // ETag for conditional requests (if supported by API)
  TextColumn get etag => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {entityType};
}
