import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class SdmApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<dynamic> getUsers(String filter) async {
    final uri = ApiHelper.buildUri(endpoint: 'sdm/$filter');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getStaff() async {
    final uri = ApiHelper.buildUri(endpoint: 'users/staff');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getPimpinan() async {
    final uri = ApiHelper.buildUri(endpoint: 'users/pimpinan');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getGuru() async {
    final uri = ApiHelper.buildUri(endpoint: 'users/guru');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getOrangtua() async {
    final uri = ApiHelper.buildUri(endpoint: 'users/orangtua');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getSantri() async {
    final uri = ApiHelper.buildUri(endpoint: 'users/santri');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
