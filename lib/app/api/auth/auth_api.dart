import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class AuthApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<dynamic> login(String login, String password) async {
    final uri = ApiHelper.buildUri(endpoint: 'login');
    final body = {
      'login': login,
      'password': password,
    };

    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: body,
      header: ApiHelper.header(),
    );
  }

  Future<dynamic> register(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'register');

    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: ApiHelper.header(),
    );
  }

  Future<dynamic> updateFcmToken(String fcmToken, String token) async {
    final uri = ApiHelper.buildUri(endpoint: 'user/update-fcm-token');
    final body = {'fcm_token': fcmToken};

    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: body,
      header: ApiHelper.tokenHeader(token),
    );
  }

  Future<dynamic> getUser(String token) async {
    final uri = ApiHelper.buildUri(endpoint: 'user/my-profile');

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: ApiHelper.tokenHeader(token),
    );
  }
}
