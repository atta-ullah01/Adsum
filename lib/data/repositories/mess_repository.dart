import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/mess.dart';

/// Repository for mess menu management
/// 
/// Manages `/data/menu_cache.json` - local cache of mess menus
class MessRepository {

  MessRepository(this._jsonService);
  static const String _cacheFile = 'menu_cache.json';

  final JsonFileService _jsonService;

  // ============ Cache Management ============

  /// Get the full menu cache
  Future<MenuCache> getCache() async {
    final data = await _jsonService.readJsonObject(_cacheFile);
    if (data == null) return const MenuCache();
    return MenuCache.fromJson(data);
  }

  /// Save the full menu cache
  Future<void> saveCache(MenuCache cache) async {
    await _jsonService.writeJson(_cacheFile, cache.toJson());
  }
}
