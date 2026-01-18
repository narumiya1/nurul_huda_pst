import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class RoisApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<dynamic> getSantri() async {
    final uri = ApiHelper.buildUri(endpoint: 'rois/santri');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getAbsensiKamar() async {
    final uri = ApiHelper.buildUri(endpoint: 'rois/absensi-kamar');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> submitAbsensiKamar(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'rois/absensi-kamar');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getPelanggaran() async {
    final uri = ApiHelper.buildUri(endpoint: 'rois/pelanggaran');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getPerizinan() async {
    final uri = ApiHelper.buildUri(endpoint: 'rois/perizinan');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> verifyPerizinan(int id) async {
    final uri = ApiHelper.buildUri(endpoint: 'rois/perizinan/$id/verify');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
