import 'package:epesantren_mob/app/api/keuangan/keuangan_api.dart';

class KeuanganRepository {
  final KeuanganApi _keuanganApi;

  KeuanganRepository(this._keuanganApi);

  Future<List<dynamic>> getLaporanPembayaran() async {
    try {
      final response = await _keuanganApi.getLaporanPembayaran();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPayment(int id) async {
    try {
      final response = await _keuanganApi.verifyPayment(id);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rejectPayment(int id, String reason) async {
    try {
      final response = await _keuanganApi.rejectPayment(id, reason);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
