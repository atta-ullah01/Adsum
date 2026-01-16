
import 'dart:async';

import 'package:adsum/core/utils/app_logger.dart';
import 'package:adsum/data/repositories/action_item_repository.dart';
import 'package:adsum/domain/models/action_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {

  RealtimeService(this._client, this._actionItemRepository);
  final SupabaseClient _client;
  final ActionItemRepository _actionItemRepository;
  
  final List<RealtimeChannel> _activeChannels = [];

  /// Subscribe to global schedule changes for enrolled courses
  void subscribeToScheduleChanges(List<String> courseCodes) {
    if (courseCodes.isEmpty) return;

    // We can filter by course_code in the channel
    // Supabase allows: 
    // channel('public:schedule_modifications').on(postgresChanges, filter: 'course_code=in.(${courseCodes.join(",")})')
    // But 'in' filter support for realtime might be limited, usually per-row or per-table.
    // If we subscribe to all modifications and filter in client if needed, or iterate.
    // For simplicity, subscribe to the table and filter in callback if course code matches.
    
    final channel = _client.channel('public:schedule_modifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'schedule_modifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.inFilter,
          column: 'course_code',
          value: courseCodes,
        ),
        callback: (payload) {
          _handleScheduleChange(payload.newRecord);
        },
      )
      .subscribe();
      
    _activeChannels.add(channel);
    AppLogger.info('Subscribed to schedule_modifications', tags: ['realtime']);
  }

  void subscribeToCourseWork(List<String> courseCodes) {
    if (courseCodes.isEmpty) return;

    final channel = _client.channel('public:course_work')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'course_work',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.inFilter,
          column: 'course_code',
          value: courseCodes,
        ),
        callback: (payload) {
          _handleNewWork(payload.newRecord);
        },
      )
      .subscribe();
      
    _activeChannels.add(channel);
    AppLogger.info('Subscribed to course_work', tags: ['realtime']);
  }
  
  // Live Presence logic (ephemeral)
  RealtimeChannel? _presenceChannel;
  // This might be stream controller exposed to UI
  final _presenceStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get presenceStream => _presenceStreamController.stream;

  void subscribeToLivePresence(String currentSlotId) {
    // Unsubscribe previous if any
    _presenceChannel?.unsubscribe();
    
    _presenceChannel = _client.channel('public:presence:$currentSlotId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'presence_confirmations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'rule_id',
          value: currentSlotId,
        ),
        callback: (payload) {
          // Broadcast to UI
          _presenceStreamController.add(payload.newRecord ?? {});
        },
      )
      .subscribe();
      
    AppLogger.info('Subscribed to presence for $currentSlotId', tags: ['realtime']);
  }

  void _handleScheduleChange(Map<String, dynamic> record) {
     AppLogger.info('Schedule change received: ${record['id']}', tags: ['realtime']);
     try {
       final actionStart = DateTime.now();
       // Create generic action item
       final item = ActionItem(
         itemId: 'action_${DateTime.now().millisecondsSinceEpoch}',
         type: ActionItemType.scheduleChange,
         title: 'Schedule Update',
         body: 'Changes detected for ${record['course_code']}',
         createdAt: actionStart,
         payload: {'modification_id': record['id']},
       );
       _actionItemRepository.save(item);
     } catch (e) {
       AppLogger.error('Failed to handle schedule change', error: e, tags: ['realtime']);
     }
  }

  void _handleNewWork(Map<String, dynamic> record) {
    AppLogger.info('New course work received: ${record['work_id']}', tags: ['realtime']);
    try {
       final item = ActionItem(
         itemId: 'action_work_${record['work_id']}',
         type: ActionItemType.assignmentDue,
         title: 'New Assignment: ${record['title']}',
         body: 'Due: ${record['due_date']}',
         createdAt: DateTime.now(),
         payload: {'work_id': record['work_id']},
       );
       _actionItemRepository.save(item);
    } catch (e) {
      AppLogger.error('Failed to handle new work', error: e, tags: ['realtime']);
    }
  }

  void dispose() {
    for (final channel in _activeChannels) {
      channel.unsubscribe();
    }
    _presenceChannel?.unsubscribe();
    _presenceStreamController.close();
  }
}
