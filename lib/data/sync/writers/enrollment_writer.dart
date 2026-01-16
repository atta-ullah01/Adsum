
import 'package:adsum/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnrollmentWriter {

  EnrollmentWriter(this._client);
  final SupabaseClient _client;

  Future<void> sync(Map<String, dynamic> payload) async {
    try {
      final data = Map<String, dynamic>.from(payload);
      data.remove('synced');
      
      // Upsert into user_enrollments
      await _client.from('user_enrollments').upsert(
        data,
        onConflict: 'enrollment_id',
      );
      
      AppLogger.info('Synced enrollment: ${data['enrollment_id']}', tags: ['sync', 'enrollment']);
    } catch (e, stack) {
      AppLogger.error('Failed to sync enrollment', error: e, stackTrace: stack, tags: ['sync', 'enrollment']);
      rethrow;
    }
  }
}
