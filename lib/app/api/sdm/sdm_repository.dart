import 'package:epesantren_mob/app/api/sdm/sdm_api.dart';

class SdmRepository {
  final SdmApi _sdmApi;

  SdmRepository(this._sdmApi);

  Future<List<dynamic>> getUsers(String filter) async {
    try {
      final response = await _sdmApi.getUsers(filter);
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStaff() async {
    try {
      final response = await _sdmApi.getStaff();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getPimpinan() async {
    try {
      final response = await _sdmApi.getPimpinan();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getGuru() async {
    try {
      final response = await _sdmApi.getGuru();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getSantri() async {
    try {
      final response = await _sdmApi.getSantri();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
