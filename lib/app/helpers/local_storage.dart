import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final _box = GetStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  /// Save JWT Token
  static Future<void> saveToken(String token) async {
    await _box.write(_keyToken, token);
  }

  /// Get JWT Token
  static String? getToken() {
    return _box.read(_keyToken);
  }

  /// Delete JWT Token
  static Future<void> deleteToken() async {
    await _box.remove(_keyToken);
  }

  /// Save User Data (JSON)
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await _box.write(_keyUser, userData);
  }

  /// Get User Data
  static Map<String, dynamic>? getUser() {
    return _box.read(_keyUser);
  }

  /// Delete User Data
  static Future<void> deleteUser() async {
    await _box.remove(_keyUser);
  }

  /// Clear All Data
  static Future<void> clearAll() async {
    await _box.erase();
  }
}
