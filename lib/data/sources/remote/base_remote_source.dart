
import 'package:adsum/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract base class for remote data sources interacting with Supabase.
/// 
/// [T] is the domain model type.
/// [D] is the raw data type (usually Map<String, dynamic>).
abstract class SupabaseDataSource<T> {

  SupabaseDataSource(this.client, {required this.tableName})
      : tags = ['remote', tableName];
  final SupabaseClient client;
  final String tableName;
  final List<String> tags;

  /// Convert raw JSON to domain model
  T fromJson(Map<String, dynamic> json);

  /// Fetch all records, optionally filtered by `updated_at > since`
  Future<List<T>> fetchAll({DateTime? since}) async {
    try {
      var query = client.from(tableName).select();
      
      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }

      final response = await query;
      final data = response as List;
      
      AppLogger.info(
        'Fetched ${data.length} records from $tableName', 
        tags: tags,
        context: {'since': since?.toIso8601String()}
      );
      
      return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      AppLogger.error(
        'Failed to fetch from $tableName', 
        error: e, 
        stackTrace: stack,
        tags: tags
      );
      throw _handleError(e);
    }
  }

  /// Fetch single record by ID
  Future<T?> fetchById(String id, {String idColumn = 'id'}) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq(idColumn, id)
          .maybeSingle();
          
      if (response == null) return null;
      
      return fromJson(response);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch $id from $tableName', error: e, stackTrace: stack, tags: tags);
      throw _handleError(e);
    }
  }

  /// Watch for realtime updates
  /// 
  /// Note: RLS policies must allow subscription
  Stream<List<T>> watch() {
    return client
        .from(tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data.map(fromJson).toList());
  }
  
  Exception _handleError(dynamic e) {
    if (e is PostgrestException) {
      return Exception('Supabase Error [${e.code}]: ${e.message}');
    }
    return Exception('Unknown remote error: $e');
  }
}
