import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/action_item.dart';
import 'package:uuid/uuid.dart';

/// Repository for action items (action_items.json)
class ActionItemRepository {

  ActionItemRepository(this._jsonService);
  static const String _filename = 'action_items.json';

  final JsonFileService _jsonService;

  /// Get all action items
  Future<List<ActionItem>> getAll() async {
    final data = await _jsonService.readJsonArray(_filename);
    if (data == null) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ActionItem.fromJson)
        .toList();
  }

  /// Get pending items only
  Future<List<ActionItem>> getPending() async {
    final items = await getAll();
    return items.where((i) => i.isPending).toList();
  }

  /// Get items by type
  Future<List<ActionItem>> getByType(ActionItemType type) async {
    final items = await getAll();
    return items.where((i) => i.type == type).toList();
  }

  /// Get pending count
  Future<int> getPendingCount() async {
    final pending = await getPending();
    return pending.length;
  }

  /// Add action item
  Future<ActionItem> add({
    required ActionItemType type,
    required String title,
    required String body,
    int? bgColorValue,
    int? accentColorValue,
    Map<String, dynamic> payload = const {},
  }) async {
    final item = ActionItem(
      itemId: const Uuid().v4(),
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      payload: payload,
    );

    await _jsonService.appendToJsonArray(_filename, item.toJson());
    return item;
  }

  /// Save existing or new item object
  Future<void> save(ActionItem item) async {
    // Check if exists to update or append?
    // For simplicity, append if not exists or update.
    // RealtimeService creates NEW items.
    
    // Check if ID exists (expensive? or just append?)
    // RealtimeService uses unique IDs.
    await _jsonService.appendToJsonArray(_filename, item.toJson());
  }

  /// Resolve action item
  Future<bool> resolve(String itemId, Resolution resolution) async {
    final item = await getById(itemId);
    if (item == null) return false;

    return _jsonService.updateInJsonArray(
      _filename,
      keyField: 'item_id',
      keyValue: itemId,
      updates: item.resolve(resolution).toJson(),
    );
  }

  /// Delete item
  Future<bool> delete(String itemId) async {
    return _jsonService.removeFromJsonArray(
      _filename,
      keyField: 'item_id',
      keyValue: itemId,
    );
  }

  /// Get by ID
  Future<ActionItem?> getById(String itemId) async {
    final items = await getAll();
    try {
      return items.firstWhere((i) => i.itemId == itemId);
    } catch (_) {
      return null;
    }
  }

  /// Clear resolved items
  Future<void> clearResolved() async {
    final items = await getAll();
    final pending = items.where((i) => i.isPending).toList();
    await _jsonService.writeJson(
      _filename,
      pending.map((i) => i.toJson()).toList(),
    );
  }
}
