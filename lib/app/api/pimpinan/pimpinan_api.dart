import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class PimpinanApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  /// Fetch Financing (Keuangan) data
  Future<Map<String, dynamic>> getFinancing({
    String filter = 'bulanan',
    String? search,
    String? type,
  }) async {
    final Map<String, String> params = {'filter': filter};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (type != null && type != 'Semua') {
      params['type'] = type == 'Masuk' ? 'masuk' : 'keluar';
    }

    final uri = ApiHelper.buildUri(
      endpoint: 'financing/$filter',
      params: params,
    );

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Mail (Administrasi) data
  Future<Map<String, dynamic>> getMails({
    required String filter, // inbox, sent, archive, copy, forward
    String? search,
  }) async {
    final Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = ApiHelper.buildUri(
      endpoint: 'dokumen/surat/$filter',
      params: params,
    );

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Dashboard stats for Pimpinan
  Future<Map<String, dynamic>> getDashboardStats() async {
    final uri = ApiHelper.buildUri(endpoint: 'dashboard-stats');

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Kurikulum data
  Future<Map<String, dynamic>> getKurikulum() async {
    final uri = ApiHelper.buildUri(endpoint: 'kurikulum');

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Rekap Nilai (Raw Data for Aggregation)
  Future<List<dynamic>> getRekapNilai() async {
    final uri = ApiHelper.buildUri(endpoint: 'sekolah/nilai');
    // We expect a list here based on controller analysis
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data is List ? data : [],
      header: _getAuthHeader(),
    );
  }

  /// Fetch Agenda (Activity)
  Future<Map<String, dynamic>> getAgenda({String filter = 'harian'}) async {
    final uri = ApiHelper.buildUri(endpoint: 'activity/$filter');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Tahfidz Data
  Future<Map<String, dynamic>> getTahfidz() async {
    final uri = ApiHelper.buildUri(endpoint: 'tahfidz/hafalan');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Laporan Absensi Summary
  Future<Map<String, dynamic>> getLaporanAbsensi({
    String? startDate,
    String? endDate,
    String? tingkatId,
    String? kelasId,
  }) async {
    final Map<String, String> params = {};
    if (startDate != null) params['tanggal_mulai'] = startDate;
    if (endDate != null) params['tanggal_akhir'] = endDate;
    if (tingkatId != null) params['tingkat_id'] = tingkatId;
    if (kelasId != null) params['kelas_id'] = kelasId;

    final uri = ApiHelper.buildUri(
      endpoint: 'laporan/absensi-santri',
      params: params,
    );
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  /// Fetch Master Data Users (General Sdm)
  /// Types: santri, guru, staff, orangtua, pimpinan, rois, siswa
  Future<Map<String, dynamic>> getUsersByType(String type,
      {String? search}) async {
    String endpoint;
    if (type == 'siswa') {
      endpoint = 'siswa';
    } else {
      endpoint = 'users/$type';
    }

    final Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = ApiHelper.buildUri(
      endpoint: endpoint,
      params: params,
    );

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }
}
