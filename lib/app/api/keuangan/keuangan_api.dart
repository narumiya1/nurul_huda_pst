import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class KeuanganApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<dynamic> getLaporanPembayaran() async {
    final uri = ApiHelper.buildUri(endpoint: 'laporan-pembayaran');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> verifyPayment(int id) async {
    final uri = ApiHelper.buildUri(endpoint: 'laporan-pembayaran/$id/verify');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> rejectPayment(int id, String reason) async {
    final uri = ApiHelper.buildUri(endpoint: 'laporan-pembayaran/$id/reject');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: {'reason': reason},
      header: _getAuthHeader(),
    );
  }
}
