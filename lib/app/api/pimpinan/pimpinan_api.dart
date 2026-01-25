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
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': []};
      },
      header: _getAuthHeader(),
    );
  }

  /// Fetch Rekap Nilai (Raw Data for Aggregation)
  Future<List<dynamic>> getRekapNilai() async {
    final uri = ApiHelper.buildUri(endpoint: 'sekolah/nilai');
    // We expect a list here based on controller analysis
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return data is List ? data : [];
      },
      header: _getAuthHeader(),
    );
  }

  /// Fetch Agenda (Activity)
  Future<Map<String, dynamic>> getAgenda({String filter = 'harian'}) async {
    final uri = ApiHelper.buildUri(endpoint: 'activity/$filter');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': []};
      },
      header: _getAuthHeader(),
    );
  }

  /// Fetch Tahfidz Data
  Future<Map<String, dynamic>> getTahfidz() async {
    final uri = ApiHelper.buildUri(endpoint: 'tahfidz/hafalan');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': []};
      },
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
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': {}};
      },
      header: _getAuthHeader(),
    );
  }

  /// Fetch Master Data Users (General Sdm)
  /// Types: santri, guru, staff, orangtua, pimpinan, rois, siswa
  Future<Map<String, dynamic>> getUsersByType(String type,
      {String? search, int? perPage, int? page}) async {
    String endpoint;
    if (type == 'siswa') {
      endpoint = 'siswa';
    } else {
      endpoint = 'users/$type';
    }

    final Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;

    // Add per_page to reduce response size for ALL user types
    // This is now supported by all backend endpoints (pimpinan, guru, staff, orangtua, rois, santri, siswa)
    params['per_page'] = (perPage ?? 10).toString();

    // Add page parameter for pagination
    if (page != null) {
      params['page'] = page.toString();
    }

    final uri = ApiHelper.buildUri(
      endpoint: endpoint,
      params: params,
    );

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': []};
      },
      header: _getAuthHeader(),
    );
  }

  /// Fetch Pondok Blok (Dormitory Buildings)
  Future<Map<String, dynamic>> getPondokBlok() async {
    final uri = ApiHelper.buildUri(endpoint: 'pondok/blok');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': []};
      },
      header: _getAuthHeader(),
    );
  }

  /// Fetch Pondok Kamar (Dormitory Rooms)
  Future<Map<String, dynamic>> getPondokKamar({String? blokId}) async {
    final Map<String, String> params = {};
    if (blokId != null) params['blok_id'] = blokId;

    final uri = ApiHelper.buildUri(endpoint: 'pondok/kamar', params: params);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        if (data is Map<String, dynamic>) return data;
        if (data is List) return {'data': data};
        return {'data': []};
      },
      header: _getAuthHeader(),
    );
  }

  /// Get Santri List for dropdown (direct from /santri endpoint)
  Future<List<dynamic>> getSantriList({String? search}) async {
    final Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = ApiHelper.buildUri(endpoint: 'santri', params: params);
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'] is List ? data['data'] : [],
      header: _getAuthHeader(),
    );
  }

  /// Create New Santri (Add to Master Data)
  Future<dynamic> createSantri(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'santri');

    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Create New Staff (Add to Master Data)
  Future<dynamic> createStaff(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'users/staff');

    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Get Sekolah List for dropdown
  Future<List<dynamic>> getSekolahList() async {
    final uri = ApiHelper.buildUri(endpoint: 'sekolah');

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'] is List ? data['data'] : [],
      header: _getAuthHeader(),
    );
  }

  /// Create New Siswa
  Future<dynamic> createSiswa(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'siswa');

    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Create New Pondok Blok
  Future<dynamic> createPondokBlok(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'pondok/blok');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Create New Pondok Kamar
  Future<dynamic> createPondokKamar(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'pondok/kamar');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Assign Santri to Kamar
  Future<dynamic> assignSantriToKamar(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'pondok/assign-santri');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Create New Pimpinan
  Future<dynamic> createPimpinan(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'users/pimpinan');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Create New Guru
  Future<dynamic> createGuru(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'users/guru');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Create New Orangtua
  Future<dynamic> createOrangtua(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'users/orangtua');
    return await _apiHelper.postData(
      uri: uri,
      jsonBody: data,
      builder: (res) => res,
      header: _getAuthHeader(),
    );
  }

  /// Get Mapel List for dropdown
  Future<List<dynamic>> getMapelList() async {
    final uri = ApiHelper.buildUri(endpoint: 'mapel');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'] is List ? data['data'] : [],
      header: _getAuthHeader(),
    );
  }

  /// Get Tingkat Santri List for dropdown
  Future<List<dynamic>> getTingkatSantriList() async {
    final uri = ApiHelper.buildUri(endpoint: 'tingkat-santri');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'] is List ? data['data'] : [],
      header: _getAuthHeader(),
    );
  }

  /// Get Kelas Santri List for dropdown
  Future<List<dynamic>> getKelasSantriList() async {
    final uri = ApiHelper.buildUri(endpoint: 'kelas');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data'] is List ? data['data'] : [],
      header: _getAuthHeader(),
    );
  }

  Future<List<dynamic>> findSiswa(String search) async {
    final uri =
        ApiHelper.buildUri(endpoint: 'siswa', params: {'search': search});
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data['data']['data'] is List
          ? data['data']['data']
          : (data['data'] is List ? data['data'] : []),
      header: _getAuthHeader(),
    );
  }
}
