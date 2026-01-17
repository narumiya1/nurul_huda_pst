import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository(this._authApi);

  Future<bool> login(String email, String password) async {
    try {
      final response = await _authApi.login(email, password);

      // Standard response from Laravel API our project: {status, data, message, code}
      // data might contain token and user info
      if (response['status'] == true) {
        final data = response['data'];
        final token = data['token'];
        final user = data['user'];

        if (token != null) {
          await LocalStorage.saveToken(token);
        }
        if (user != null) {
          await LocalStorage.saveUser(user);
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
}
