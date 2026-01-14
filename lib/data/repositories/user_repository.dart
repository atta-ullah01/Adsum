import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/user_profile.dart';

/// Repository for user profile data (user.json)
class UserRepository {
  static const String _filename = 'user.json';

  final JsonFileService _jsonService;

  UserRepository(this._jsonService);

  /// Get current user profile
  Future<UserProfile?> getUser() async {
    final data = await _jsonService.readJsonObject(_filename);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  /// Save user profile
  Future<void> saveUser(UserProfile user) async {
    await _jsonService.writeJson(_filename, user.toJson());
  }

  /// Update user settings
  Future<void> updateSettings(UserSettings settings) async {
    final user = await getUser();
    if (user == null) return;
    await saveUser(user.copyWith(settings: settings));
  }

  /// Delete user data (logout)
  Future<void> deleteUser() async {
    await _jsonService.delete(_filename, includeBackup: true);
  }

  /// Check if user exists
  Future<bool> hasUser() => _jsonService.exists(_filename);
}
