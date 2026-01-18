import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class OrangtuaApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<dynamic> getMyChildren() async {
    final uri = ApiHelper.buildUri(endpoint: 'orangtua/my-children');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildSummary(int santriId) async {
    final uri =
        ApiHelper.buildUri(endpoint: 'orangtua/child-summary/$santriId');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildProfile(int santriId) async {
    final uri =
        ApiHelper.buildUri(endpoint: 'orangtua/child-profile/$santriId');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildSchedule(int santriId) async {
    final uri =
        ApiHelper.buildUri(endpoint: 'orangtua/child-schedule/$santriId');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildScores(int santriId) async {
    final uri = ApiHelper.buildUri(endpoint: 'orangtua/child-scores/$santriId');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildBills(int santriId) async {
    final uri = ApiHelper.buildUri(endpoint: 'orangtua/child-bills/$santriId');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
