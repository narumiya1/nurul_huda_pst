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

  Future<dynamic> createNilaiBulk(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'sekolah/nilai/bulk');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getNilai({int? kelasId, int? mapelId}) async {
    final params = <String, String>{};
    if (kelasId != null) params['sekolah_kelas_id'] = kelasId.toString();
    if (mapelId != null) params['mapel_id'] = mapelId.toString();

    final uri = ApiHelper.buildUri(endpoint: 'sekolah/nilai', params: params);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  // ========== TUGAS SANTRI ==========

  /// Get list of tugas santri (created by this guru)
  Future<dynamic> getTugasSantriList() async {
    final uri = ApiHelper.buildUri(endpoint: 'tugas-santri');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Get detail of a tugas santri
  Future<dynamic> getTugasSantriDetail(int id) async {
    final uri = ApiHelper.buildUri(endpoint: 'tugas-santri/$id');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Create new tugas santri
  Future<dynamic> createTugasSantri(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'tugas-santri');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }

  /// Update tugas santri
  Future<dynamic> updateTugasSantri(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'tugas-santri');
    return await _apiHelper.patchData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }

  /// Delete tugas santri
  Future<dynamic> deleteTugasSantri(int id) async {
    final uri = ApiHelper.buildUri(endpoint: 'tugas-santri/$id');
    return await _apiHelper.deleteData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Grade a tugas santri submission
  Future<dynamic> gradeTugasSantri(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'tugas-santri/grade');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }

  /// Get tingkat santri list
  Future<dynamic> getTingkatSantri() async {
    final uri = ApiHelper.buildUri(endpoint: 'tingkat-santri');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Get kelas santri by tingkat
  Future<dynamic> getKelasSantri({int? tingkatId}) async {
    final params = <String, String>{};
    if (tingkatId != null) params['tingkat_id'] = tingkatId.toString();
    final uri = ApiHelper.buildUri(endpoint: 'kelas', params: params);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Get mapel pondok list
  Future<dynamic> getMapelPondok() async {
    final uri = ApiHelper.buildUri(endpoint: 'mapels');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
