
import 'package:adsum/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsWriter {

  SettingsWriter(this._client);
  final SupabaseClient _client;

  Future<void> sync(Map<String, dynamic> payload) async {
    try {
      // Payload contains the settings map and the user_id context
      // We expect payload to have 'userId' or we get it from auth?
      // OfflineQueueItem payload should contain necessary IDs.
      
      final userId = payload['userId'] as String?;
      final settings = payload['settings'] as Map<String, dynamic>?;
      
      if (userId == null || settings == null) {
        throw Exception('Invalid settings payload: missing userId or settings');
      }

      // Update 'settings' column in 'users' table
      await _client.from('users').update({
        'settings': settings,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
      
      AppLogger.info('Synced settings for $userId', tags: ['sync', 'settings']);
    } catch (e, stack) {
      AppLogger.error('Failed to sync settings', error: e, stackTrace: stack, tags: ['sync', 'settings']);
      rethrow;
    }
  }
}
