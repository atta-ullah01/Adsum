
import 'package:adsum/data/sources/remote/base_remote_source.dart';
import 'package:adsum/domain/models/mess.dart';

class MessRemoteSource extends SupabaseDataSource<MessMenu> {
  MessRemoteSource(super.client) : super(tableName: 'mess_menus');

  @override
  MessMenu fromJson(Map<String, dynamic> json) {
     final safeJson = Map<String, dynamic>.from(json);
    if (!safeJson.containsKey('id') && safeJson.containsKey('menu_id')) {
      safeJson['id'] = safeJson['menu_id'];
    }
    return MessMenu.fromJson(safeJson);
  }

  Future<List<MessMenu>> fetchMenusForHostel(String hostelId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('hostel_id', hostelId);
        
    final data = response as List;
    return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }
}
