import 'dart:io';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class SantriRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<List<dynamic>> getPerizinan() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'my-perizinan');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitPerizinan(Map<String, dynamic> data) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'my-perizinan');
      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: data,
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getPelanggaran() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kedisiplinan/pelanggaran');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            final raw = data['data'];
            if (raw is List) return raw;
            if (raw is Map && raw['data'] is List) return raw['data'];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitPelanggaran(Map<String, dynamic> data) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kedisiplinan/pelanggaran');
      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: data,
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getSantriList(
      {String? search, int? kelasId, int? kamarId}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (kelasId != null) queryParams['kelas_id'] = kelasId.toString();
      if (kamarId != null) queryParams['kamar_id'] = kamarId.toString();

      final uri = ApiHelper.buildUri(endpoint: 'santri', params: queryParams);
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            final raw = data['data'];
            if (raw is List) return raw;
            if (raw is Map && raw['data'] is List) return raw['data'];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getTugasSekolah() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'sekolah/tugas');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map &&
              data['data'] != null &&
              data['data']['data'] is List) {
            return data['data']['data'];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitTugas(Map<String, String> fields, {File? file}) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'sekolah/tugas/submit');
      if (file != null) {
        final response = await _apiHelper.postImageData(
          uri: uri,
          fields: fields,
          files: {'file': file},
          builder: (data) => data,
          header: _getAuthHeader(),
        );
        return response['success'] == true;
      } else {
        final response = await _apiHelper.postData(
          uri: uri,
          jsonBody: fields,
          builder: (data) => data,
          header: _getAuthHeader(),
        );
        return response['success'] == true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'me');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data is Map ? data['data'] : null,
        header: _getAuthHeader(),
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getMyBills() async {
    return [];
  }

  Future<List<dynamic>> getKelasList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kelas');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMyKelasList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'guru/my-kelas');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getKamarList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'pondok/kamar');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getNilaiSekolah({
    String? semester,
    String? tahun,
    int? siswaId,
    String? tahunAjaran,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (semester != null) queryParams['semester'] = semester.toLowerCase();
      if (tahun != null) queryParams['tahun_ajaran'] = tahun;
      if (siswaId != null) queryParams['siswa_id'] = siswaId.toString();
      if (tahunAjaran != null) queryParams['tahun_ajaran'] = tahunAjaran;

      final uri =
          ApiHelper.buildUri(endpoint: 'sekolah/nilai', params: queryParams);
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] is List) {
            return data['data'];
          }
          return data is List ? data : [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }
}
