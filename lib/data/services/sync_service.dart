
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:adsum/core/utils/app_logger.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/data/sources/local/app_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for processing the offline queue.
/// 
/// - Monitors connectivity
/// - Processes pending items with exponential backoff
/// - Handles dead letter queue
class SyncService {

  SyncService(this._db, this._ref, {Connectivity? connectivity}) 
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }
  final AppDatabase _db;
  final Ref _ref; // To access other providers/writers
  final Connectivity _connectivity;
  
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          processQueue();
        }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Trigger queue processing
  Future<void> processQueue() async {
    if (_isSyncing) return;
    
    // Check connectivity
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      AppLogger.info('Offline, skipping sync', tags: ['sync']);
      return;
    }

    _isSyncing = true;
    AppLogger.info('Starting sync process', tags: ['sync']);

    try {
      final pendingItems = await _db.getPendingQueueItems();
      
      for (final item in pendingItems) {
        // Double check connectivity in loop?
        // Check if item is ready for retry
        if (item.nextRetryAt != null && item.nextRetryAt!.isAfter(DateTime.now())) {
          continue;
        }

        try {
          await _processItem(item);
          
          // Success: Mark as done or delete
          await _db.updateQueueItemStatus(item.id, 'COMPLETED');
          AppLogger.info('Synced item ${item.id} (${item.entityType})', tags: ['sync']);
          
        } catch (e) {
          await _handleSyncError(item, e);
        }
      }
    } catch (e, stack) {
      AppLogger.error('Sync process failed', error: e, stackTrace: stack, tags: ['sync']);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processItem(OfflineQueueItem item) async {
    AppLogger.debug('Processing item ${item.id}: ${item.entityType}', tags: ['sync']);
    
    // Decode payload
    final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;

    // Delegate to specific writer based on Entity Type
    switch (item.entityType) {
      case 'ENROLLMENT':
        await _ref.read(enrollmentWriterProvider).sync(payload);
      case 'ATTENDANCE_LOG':
        await _ref.read(attendanceWriterProvider).sync(payload);
      case 'USER_SETTINGS':
        await _ref.read(settingsWriterProvider).sync(payload);
      default:
        throw Exception('Unknown queue entity type: ${item.entityType}');
    }
    
    // Simulate network delay for now
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _handleSyncError(OfflineQueueItem item, dynamic error) async {
    final retryCount = (item.retryCount ?? 0) + 1;
    const maxRetries = 5;

    if (retryCount >= maxRetries) {
      await _db.updateQueueItemStatus(
        item.id, 
        'DEAD_LETTER',
        errorMessage: error.toString(),
      );
      AppLogger.error('Item ${item.id} moved to DEAD_LETTER', error: error, tags: ['sync']);
      // TODO: Create ActionItem for user notification
    } else {
      // Exponential backoff: 2^retry seconds
      final backoffSeconds = pow(2, retryCount).toInt();
      final nextRetry = DateTime.now().add(Duration(seconds: backoffSeconds));
      
      await _db.updateQueueItemStatus(
        item.id, 
        'PENDING', // Keep pending but update retry info
        retryCount: retryCount,
        nextRetryAt: nextRetry,
        errorMessage: error.toString(),
      );
      AppLogger.warn('Item ${item.id} failed, retrying in ${backoffSeconds}s', error: error, tags: ['sync']);
    }
  }
}
