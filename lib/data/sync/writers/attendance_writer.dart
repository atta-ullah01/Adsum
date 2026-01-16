
import 'package:adsum/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceWriter {

  AttendanceWriter(this._client);
  final SupabaseClient _client;

  Future<void> sync(Map<String, dynamic> payload) async {
    try {
      // payload comes from OfflineQueueItem.payload which is the JSON of the entity
      
      // Ensure we clean up local-only fields if any
      // 'synced' is local metadata, Supabase doesn't need it (or ignores it if extra)
      final data = Map<String, dynamic>.from(payload);
      data.remove('synced');
      
      // Upsert into attendance_log
      // We use log_id as constraint
      await _client.from('attendance_log').upsert(
        data,
        onConflict: 'log_id',
      );
      
      AppLogger.info('Synced attendance log: ${data['log_id']}', tags: ['sync', 'attendance']);
    } catch (e, stack) {
      AppLogger.error('Failed to sync attendance', error: e, stackTrace: stack, tags: ['sync', 'attendance']);
      rethrow;
    }
  }
}
