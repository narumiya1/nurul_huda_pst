import 'package:epesantren_mob/app/api/guru/guru_api.dart';

class GuruRepository {
  final GuruApi _guruApi;

  GuruRepository(this._guruApi);

  Future<dynamic> getDashboardStats() async {
    try {
      final response = await _guruApi.getDashboardStats();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyMapel() async {
    try {
      final response = await _guruApi.getMyMapel();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyKelas() async {
    try {
      final response = await _guruApi.getMyKelas();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createAbsensi(Map<String, dynamic> data) async {
    try {
      final response = await _guruApi.createAbsensi(data);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
