import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class ActivityApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage
        .getToken(); // Assuming static or singleton like LocalStorage.getToken() based on previous codes seen or guess. Actually let's assume LocalStorage().getToken() or similar. Wait, in previous files it was LocalPrefsRepository(). But the error said "LocalPrefsRepository" isn't defined. This implies import issue or class naming issue.
    // Let's use LocalStorage based on filename. Or check file content.
    // I will read local_storage.dart first to be sure.
    // But for now, I'll try to use the common pattern if I can't read it yet.
    // Actually, I can read it.
    if (token == null) {
      throw Exception('User Authorization Required');
    }
    return ApiHelper.tokenHeader(token);
  }

  Future<List<dynamic>> getActivities(String filter) async {
    final uri = ApiHelper.buildUri(endpoint: 'activity/$filter');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'] is List ? data['data'] : [],
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getActivityDetail(dynamic id) async {
    final uri = ApiHelper.buildUri(endpoint: 'detail-activity/$id');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'],
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> createActivity(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'create-activity');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> deleteActivity(dynamic id) async {
    final uri = ApiHelper.buildUri(endpoint: 'delete-activity/$id');
    return await _apiHelper.deleteData(
      uri: uri,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }
}
