import 'package:epesantren_mob/app/api/rois/rois_api.dart';

class RoisRepository {
  final RoisApi _roisApi;

  RoisRepository(this._roisApi);

  Future<List<dynamic>> getSantri() async {
    try {
      final response = await _roisApi.getSantri();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAbsensiKamar() async {
    try {
      final response = await _roisApi.getAbsensiKamar();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitAbsensiKamar(Map<String, dynamic> data) async {
    try {
      final response = await _roisApi.submitAbsensiKamar(data);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getPelanggaran() async {
    try {
      final response = await _roisApi.getPelanggaran();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getPerizinan() async {
    try {
      final response = await _roisApi.getPerizinan();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPerizinan(int id) async {
    try {
      final response = await _roisApi.verifyPerizinan(id);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
