import 'dart:io';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class PsbApi {
  final ApiHelper _apiHelper = ApiHelper();

  /// Register new santri (Public endpoint - no auth required)
  Future<dynamic> register(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'psb/register');

    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: ApiHelper.header(),
    );
  }

  /// Register with file uploads
  Future<dynamic> registerWithFiles({
    required Map<String, String> fields,
    Map<String, File?>? files,
  }) async {
    final uri = ApiHelper.buildUri(endpoint: 'psb/register');

    return await _apiHelper.postImageData(
      uri: uri,
      files: files ?? {},
      builder: (data) => data,
      fields: fields,
      header: ApiHelper.header(),
    );
  }

  /// Check registration status (Public endpoint)
  Future<dynamic> cekStatus({
    required String noPendaftaran,
    required String tanggalLahir,
  }) async {
    final uri = ApiHelper.buildUri(endpoint: 'psb/cek-status');

    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: {
        'no_pendaftaran': noPendaftaran,
        'tanggal_lahir': tanggalLahir,
      },
      header: ApiHelper.header(),
    );
  }

  /// Get all registrations (Admin only)
  Future<dynamic> getRegistrations({
    int page = 1,
    int perPage = 15,
    String? status,
    String? search,
    String tahunAjaran = '2025/2026',
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'tahun_ajaran': tahunAjaran,
    };

    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final uri =
        ApiHelper.buildUri(endpoint: 'psb/registrations', params: params);
    final token = LocalStorage.getToken();

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: ApiHelper.tokenHeader(token ?? ''),
    );
  }

  /// Get registration statistics (Admin only)
  Future<dynamic> getStatistics({String tahunAjaran = '2025/2026'}) async {
    final uri = ApiHelper.buildUri(
      endpoint: 'psb/statistics',
      params: {'tahun_ajaran': tahunAjaran},
    );
    final token = LocalStorage.getToken();

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: ApiHelper.tokenHeader(token ?? ''),
    );
  }

  /// Get single registration detail (Admin only)
  Future<dynamic> getRegistrationDetail(int id) async {
    final uri = ApiHelper.buildUri(endpoint: 'psb/registrations/$id');
    final token = LocalStorage.getToken();

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: ApiHelper.tokenHeader(token ?? ''),
    );
  }

  /// Update registration status (Admin only)
  Future<dynamic> updateStatus({
    required int id,
    required String status,
    String? catatanAdmin,
  }) async {
    final uri = ApiHelper.buildUri(endpoint: 'psb/registrations/$id/status');
    final token = LocalStorage.getToken();

    final body = <String, dynamic>{
      'status': status,
    };
    if (catatanAdmin != null) {
      body['catatan_admin'] = catatanAdmin;
    }

    // Using PATCH via custom method, but our API uses PUT
    return await _apiHelper.patchData(
      uri: uri,
      builder: (data) => data,
      jsonBody: body,
      header: ApiHelper.tokenHeader(token ?? ''),
    );
  }
}
