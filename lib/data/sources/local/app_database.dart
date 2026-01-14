import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:adsum/core/utils/app_logger.dart';
import 'package:adsum/data/sources/local/tables/users_table.dart';
import 'package:adsum/data/sources/local/tables/enrollments_table.dart';
import 'package:adsum/data/sources/local/tables/offline_queue_table.dart';
import 'package:adsum/data/sources/local/tables/sync_metadata_table.dart';

part 'app_database.g.dart';

/// Main application database using Drift (SQLite).
/// 
/// Stores runtime data that requires fast queries:
/// - User profile (cached from cloud)
/// - Enrollments with stats
/// - Offline sync queue
/// - Sync metadata
@DriftDatabase(tables: [
  Users,
  Enrollments,
  OfflineQueue,
  SyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
        // Add migration logic here as schema evolves
        // Example:
        // if (from < 2) {
        //   await m.addColumn(users, users.newColumn);
        // }
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

  // ============ Enrollment Operations ============

  /// Get all enrollments
  Future<List<Enrollment>> getAllEnrollments() => select(enrollments).get();

  /// Watch enrollments for reactive UI
  Stream<List<Enrollment>> watchEnrollments() => select(enrollments).watch();

  /// Get enrollment by ID
  Future<Enrollment?> getEnrollmentById(String id) {
    return (select(enrollments)..where((e) => e.enrollmentId.equals(id)))
        .getSingleOrNull();
  }

  /// Upsert enrollment
  Future<void> upsertEnrollment(EnrollmentsCompanion enrollment) async {
    await into(enrollments).insertOnConflictUpdate(enrollment);
  }

  /// Delete enrollment
  Future<void> deleteEnrollment(String id) async {
    await (delete(enrollments)..where((e) => e.enrollmentId.equals(id))).go();
  }

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
    await delete(enrollments).go();
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
