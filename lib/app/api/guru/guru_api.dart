import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class GuruApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<dynamic> getDashboardStats() async {
    final uri = ApiHelper.buildUri(endpoint: 'guru/dashboard-stats');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyMapel() async {
    final uri = ApiHelper.buildUri(endpoint: 'guru/my-mapel');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyKelas() async {
    final uri = ApiHelper.buildUri(endpoint: 'guru/my-kelas');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getJadwalPelajaran({Map<String, String>? params}) async {
    final uri =
        ApiHelper.buildUri(endpoint: 'jadwal-pelajaran', params: params);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> createAbsensi(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'absensi-siswa');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getAbsensi({
    required int sekolahId,
    required int kelasId,
    required String tanggal,
  }) async {
    final uri = ApiHelper.buildUri(
      endpoint: 'absensi-siswa',
      params: {
        'sekolah_id': sekolahId.toString(),
        'kelas_id': kelasId.toString(),
        'tanggal': tanggal,
      },
    );
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
