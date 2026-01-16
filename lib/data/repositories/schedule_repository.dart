import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/schedule.dart';
import 'package:uuid/uuid.dart';

/// Repository for schedule data 
/// (`custom_schedules.json` and `schedule_bindings.json`)
class ScheduleRepository {
  
  ScheduleRepository(this._jsonService);
  static const String _schedulesFile = 'custom_schedules.json';
  static const String _bindingsFile = 'schedule_bindings.json';
  
  final JsonFileService _jsonService;
  
  // ============ Custom Schedules ============
  
  /// Get all custom schedule slots
  Future<List<CustomScheduleSlot>> getCustomSlots() async {
    final data = await _jsonService.readJsonArray(_schedulesFile);
    if (data == null) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CustomScheduleSlot.fromJson)
        .toList();
  }
  
  /// Get slots for specific enrollment
  Future<List<CustomScheduleSlot>> getSlotsForEnrollment(String enrollmentId) async {
    final slots = await getCustomSlots();
    return slots.where((s) => s.enrollmentId == enrollmentId).toList();
  }
  
  /// Add custom slot
  Future<CustomScheduleSlot> addCustomSlot({
    required String enrollmentId,
    required DayOfWeek dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final slot = CustomScheduleSlot(
      ruleId: const Uuid().v4(),
      enrollmentId: enrollmentId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    
    await _jsonService.appendToJsonArray(_schedulesFile, slot.toJson());
    return slot;
  }
  
  /// Delete custom slot
  Future<bool> deleteCustomSlot(String ruleId) async {
    return _jsonService.removeFromJsonArray(
      _schedulesFile,
      keyField: 'rule_id',
      keyValue: ruleId,
    );
  }

  // ============ Schedule Bindings ============
  
  /// Get all bindings
  Future<List<ScheduleBinding>> getBindings() async {
    final data = await _jsonService.readJsonArray(_bindingsFile);
    if (data == null) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ScheduleBinding.fromJson)
        .toList();
  }
  
  /// Get bindings for enrollment's rules
  Future<List<ScheduleBinding>> getBindingsForRule(String ruleId) async {
    final bindings = await getBindings();
    return bindings.where((b) => b.ruleId == ruleId).toList();
  }
  
  /// Add binding
  Future<ScheduleBinding> addBinding({
    required String userId,
    required String ruleId,
    required ScheduleType scheduleType,
    String? locationName,
    double? locationLat,
    double? locationLong,
    String? wifiSsid,
  }) async {
    final binding = ScheduleBinding(
      bindingId: const Uuid().v4(),
      userId: userId,
      ruleId: ruleId,
      scheduleType: scheduleType,
      locationName: locationName,
      locationLat: locationLat,
      locationLong: locationLong,
      wifiSsid: wifiSsid,
    );
    
    await _jsonService.appendToJsonArray(_bindingsFile, binding.toJson());
    return binding;
  }
  
  /// Delete binding
  Future<bool> deleteBinding(String bindingId) async {
    return _jsonService.removeFromJsonArray(
      _bindingsFile,
      keyField: 'binding_id',
      keyValue: bindingId,
    );
  }
}
