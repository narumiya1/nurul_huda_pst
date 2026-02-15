import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:epesantren_mob/app/services/user_context_service.dart';

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository(this._authApi);

  Future<bool> login(String login, String password) async {
    try {
      final response = await _authApi.login(login, password);

      if (response['status'] == true) {
        final data = response['data'];
        final token = data['token'];
        final user = data['user'];

        if (token != null) {
          await LocalStorage.saveToken(token);
        }
        if (user != null) {
          await LocalStorage.saveUser(user);
          // Initialize user context for dual-role detection
          if (Get.isRegistered<UserContextService>()) {
            Get.find<UserContextService>().setFromUserData(user);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final response = await _authApi.register(data);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  bool isLoggedIn() {
    return LocalStorage.getToken() != null;
  }

  Future<void> logout() async {
    await LocalStorage.clearAll();
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final token = LocalStorage.getToken();
      if (token != null) {
        await _authApi.updateFcmToken(fcmToken, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final token = LocalStorage.getToken();
      if (token == null) return null;

      final response = await _authApi.getUser(token);
      if (response['status'] == true || response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
