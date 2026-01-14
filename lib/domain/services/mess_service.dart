import 'package:adsum/data/repositories/mess_repository.dart';
import 'package:adsum/domain/models/mess.dart';

/// Service for mess menu management
class MessService {
  final MessRepository _repository;

  MessService(this._repository);

  // ============ Menu Queries ============

  /// Get menus for a specific day
  Future<List<MessMenu>> getMenusForDay(MessDayOfWeek day, {String? hostelId}) async {
    final cache = await _repository.getCache();
    return cache.menus.where((m) {
      if (hostelId != null && m.hostelId != hostelId) return false;
      return m.dayOfWeek == day;
    }).toList()
      ..sort((a, b) => _mealOrder(a.mealType).compareTo(_mealOrder(b.mealType)));
  }

  /// Get menus for today
  Future<List<MessMenu>> getTodayMenus({String? hostelId}) async {
    final today = MessDayOfWeek.fromDateTime(DateTime.now());
    return getMenusForDay(today, hostelId: hostelId);
  }

  /// Get current hostel menus for today
  Future<List<MessMenu>> getCurrentHostelTodayMenus() async {
    final cache = await _repository.getCache();
    if (cache.currentHostelId == null) return [];
    return getTodayMenus(hostelId: cache.currentHostelId);
  }

  int _mealOrder(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 0;
      case MealType.lunch:
        return 1;
      case MealType.snacks:
        return 2;
      case MealType.dinner:
        return 3;
    }
  }

  // ============ Local Edits ============

  /// Update a menu item locally (marks as modified)
  Future<void> updateLocalMenu(MessMenu menu) async {
    final cache = await _repository.getCache();
    final menus = cache.menus.toList();
    
    final index = menus.indexWhere((m) => m.menuId == menu.menuId);
    if (index >= 0) {
      menus[index] = menu.copyWith(isModified: true);
    } else {
      menus.add(menu.copyWith(isModified: true));
    }
    
    await _repository.saveCache(cache.copyWith(menus: menus));
  }

  /// Reset a menu to global (remove modifications)
  Future<void> resetToGlobal(String menuId) async {
    final cache = await _repository.getCache();
    final menus = cache.menus.toList();
    
    final index = menus.indexWhere((m) => m.menuId == menuId);
    if (index >= 0) {
      menus[index] = menus[index].copyWith(isModified: false);
      await _repository.saveCache(cache.copyWith(menus: menus));
    }
  }

  /// Get modified menus count
  Future<int> getModifiedCount() async {
    final cache = await _repository.getCache();
    return cache.menus.where((m) => m.isModified).length;
  }

  // ============ Hostel Selection ============

  /// Get current selected hostel ID
  Future<String?> getCurrentHostelId() async {
    final cache = await _repository.getCache();
    return cache.currentHostelId;
  }

  /// Set current hostel
  Future<void> setCurrentHostelId(String hostelId) async {
    final cache = await _repository.getCache();
    await _repository.saveCache(cache.copyWith(currentHostelId: hostelId));
  }

  /// Set menus for a hostel (from sync)
  Future<void> setMenusForHostel(String hostelId, List<MessMenu> menus) async {
    final cache = await _repository.getCache();
    
    // Remove existing menus for this hostel
    final otherMenus = cache.menus.where((m) => m.hostelId != hostelId).toList();
    
    // Add new menus
    final updatedMenus = [...otherMenus, ...menus];
    
    await _repository.saveCache(cache.copyWith(
      menus: updatedMenus,
      lastSyncedAt: DateTime.now(),
    ));
  }
}
