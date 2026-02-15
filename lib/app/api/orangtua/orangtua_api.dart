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

  Future<dynamic> getChildSummary(int santriId, {String? tipe}) async {
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-summary/$santriId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildProfile(int santriId, {String? tipe}) async {
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-profile/$santriId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildSchedule(int santriId, {String? tipe}) async {
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-schedule/$santriId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildScores(int santriId, {String? tipe}) async {
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-scores/$santriId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildBills(int santriId, {String? tipe}) async {
    // Current implementation of childBills in backend doesn't support type yet,
    // but we can pass it for future compatibility
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-bills/$santriId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildAbsensi(int childId, {String? tipe}) async {
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-absensi/$childId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildPerizinan(int santriId, {String? tipe}) async {
    final Map<String, String> params = {};
    if (tipe != null) params['type'] = tipe;

    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-perizinan/$santriId',
        params: params.isNotEmpty ? params : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getChildTasks(int santriId, {String? tipe}) async {
    final uri = ApiHelper.buildUri(
        endpoint: 'orangtua/child-tasks/$santriId',
        params: tipe != null ? {'tipe': tipe} : null);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> claimChild(
      {required String code, required String hubungan}) async {
    final uri = ApiHelper.buildUri(endpoint: 'orangtua/claim-child');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: {'code': code, 'hubungan': hubungan},
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyLinks() async {
    final uri = ApiHelper.buildUri(endpoint: 'orangtua/my-links');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
