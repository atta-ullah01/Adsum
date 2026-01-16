import 'dart:io';

import 'package:adsum/core/utils/app_logger.dart';
import 'package:adsum/data/sources/local/tables/global_schedules_table.dart';
import 'package:adsum/data/sources/local/tables/offline_queue_table.dart';
import 'package:adsum/data/sources/local/tables/sync_metadata_table.dart';
import 'package:adsum/data/sources/local/tables/users_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Main application database using Drift (SQLite).
/// 
/// Stores runtime data that requires fast queries:
/// - User profile (cached from cloud)
/// - Global Schedules (University Timetable Cache)
/// - Offline sync queue
/// - Sync metadata
@DriftDatabase(tables: [
  Users,
  GlobalSchedules,
  OfflineQueue,
  SyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        AppLogger.info('Database created', tags: ['database', 'migration']);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        AppLogger.info(
          'Database migration',
          context: {'from': from, 'to': to},
          tags: ['database', 'migration'],
        );
        
        if (from < 2) {
          // Schema v2: Replace Enrollments with GlobalSchedules
          // We can't easily drop tables in Drift without raw SQL usually, 
          // but createTable checks for existence.
          // Since Enrollments was dead code, data loss isn't an issue.
          await m.createTable(globalSchedules);
          // Optional: await m.deleteTable('enrollments'); if we wanted to be clean
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        
        // Verify schema integrity
        if (details.wasCreated) {
          AppLogger.info('Fresh database created', tags: ['database']);
        } else if (details.hadUpgrade) {
          AppLogger.info('Database upgraded', tags: ['database']);
        }
      },
    );
  }

  // ============ User Operations ============

  /// Get current user (should only be one)
  Future<User?> getCurrentUser() => select(users).getSingleOrNull();

  /// Insert or update user
  Future<void> upsertUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  /// Clear user on logout
  Future<void> clearUser() => delete(users).go();

  // ============ Global Schedule Operations (Cache) ============

  /// Check if we have cached schedules for a course
  Future<bool> hasSchedulesForCourse(String courseCode) async {
    final count = countAll();
    final query = selectOnly(globalSchedules)
      ..where(globalSchedules.courseCode.equals(courseCode))
      ..addColumns([count]);
    final result = await query.getSingle();
    return (result.read(count) ?? 0) > 0;
  }

  /// Get cached schedules for a course (Layer 1)
  Future<List<GlobalScheduleEntity>> getSchedulesForCourse(String courseCode) {
    return (select(globalSchedules)..where((t) => t.courseCode.equals(courseCode))).get();
  }

  /// Cache schedules (Clear old -> Insert new)
  Future<void> cacheGlobalSchedules(String courseCode, List<GlobalSchedulesCompanion> entries) async {
    await transaction(() async {
      // 1. Clear existing cache for this course
      await (delete(globalSchedules)..where((t) => t.courseCode.equals(courseCode))).go();
      
      // 2. Insert new entries
      await batch((batch) {
        batch.insertAll(globalSchedules, entries);
      });
    });
  }

  /// Clear all cached schedules
  Future<void> clearScheduleCache() => delete(globalSchedules).go();

  // ============ Offline Queue Operations ============

  /// Get pending queue items
  Future<List<OfflineQueueItem>> getPendingQueueItems() {
    return (select(offlineQueue)
          ..where((q) => q.status.equals('PENDING'))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  /// Get items ready for retry
  Future<List<OfflineQueueItem>> getRetryableItems() {
    final now = DateTime.now();
    return (select(offlineQueue)
          ..where((q) =>
              q.status.equals('PENDING') &
              (q.nextRetryAt.isNull() | q.nextRetryAt.isSmallerOrEqualValue(now)))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  /// Add item to queue
  Future<int> enqueue(OfflineQueueCompanion item) {
    return into(offlineQueue).insert(item);
  }

  /// Update queue item status
  Future<void> updateQueueItemStatus(
    int id,
    String status, {
    int? retryCount,
    DateTime? nextRetryAt,
    String? errorMessage,
  }) {
    return (update(offlineQueue)..where((q) => q.id.equals(id))).write(
      OfflineQueueCompanion(
        status: Value(status),
        retryCount: retryCount != null ? Value(retryCount) : const Value.absent(),
        nextRetryAt: nextRetryAt != null ? Value(nextRetryAt) : const Value.absent(),
        lastError: errorMessage != null ? Value(errorMessage) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark item as synced and remove
  Future<void> markSynced(int id) {
    return (delete(offlineQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Move to dead letter queue
  Future<void> moveToDeadLetter(int id, String errorMessage) {
    return updateQueueItemStatus(id, 'DEAD_LETTER', errorMessage: errorMessage);
  }

  /// Get dead letter items
  Future<List<OfflineQueueItem>> getDeadLetterItems() {
    return (select(offlineQueue)
          ..where((q) => q.status.equals('DEAD_LETTER'))
          ..orderBy([(q) => OrderingTerm.desc(q.updatedAt)]))
        .get();
  }

  /// Clear completed/dead items
  Future<void> clearProcessedQueue() {
    return (delete(offlineQueue)
          ..where((q) => q.status.isIn(['SYNCED', 'DEAD_LETTER'])))
        .go();
  }

  // ============ Sync Metadata Operations ============

  /// Get last sync time for entity
  Future<DateTime?> getLastSyncTime(String entityType) async {
    final row = await (select(syncMetadata)
          ..where((s) => s.entityType.equals(entityType)))
        .getSingleOrNull();
    return row?.lastSyncedAt;
  }

  /// Update sync metadata
  Future<void> updateSyncMetadata(String entityType, {String? etag}) async {
    await into(syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion(
        entityType: Value(entityType),
        lastSyncedAt: Value(DateTime.now()),
        etag: etag != null ? Value(etag) : const Value.absent(),
      ),
    );
  }

  // ============ Utilities ============

  /// Clear all data (for logout or reset)
  Future<void> clearAllData() async {
    await delete(users).go();
    await delete(globalSchedules).go();
    await delete(offlineQueue).go();
    await delete(syncMetadata).go();
    AppLogger.info('All database data cleared', tags: ['database']);
  }

  /// Get database file path
  static Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'adsum.db');
  }
}

/// Opens native SQLite connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbPath = await AppDatabase.getDatabasePath();
    final file = File(dbPath);
    
    AppLogger.info(
      'Opening database',
      context: {'path': dbPath},
      tags: ['database'],
    );
    
    return NativeDatabase.createInBackground(
      file,
      logStatements: kDebugMode,
    );
  });
}
