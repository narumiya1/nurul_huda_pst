import 'pimpinan_api.dart';

class PimpinanRepository {
  final PimpinanApi _pimpinanApi;

  PimpinanRepository(this._pimpinanApi);

  Future<Map<String, dynamic>> getFinancing({
    String filter = 'bulanan',
    String? search,
    String? type,
  }) async {
    try {
      final response = await _pimpinanApi.getFinancing(
        filter: filter,
        search: search,
        type: type,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMails({
    required String filter,
    String? search,
  }) async {
    try {
      final response = await _pimpinanApi.getMails(
        filter: filter,
        search: search,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      return await _pimpinanApi.getDashboardStats();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getKurikulum() async {
    try {
      return await _pimpinanApi.getKurikulum();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRekapNilai() async {
    try {
      return await _pimpinanApi.getRekapNilai();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAgenda({String filter = 'harian'}) async {
    try {
      return await _pimpinanApi.getAgenda(filter: filter);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTahfidz() async {
    try {
      return await _pimpinanApi.getTahfidz();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLaporanAbsensi({
    String? startDate,
    String? endDate,
    String? tingkatId,
  }) async {
    try {
      return await _pimpinanApi.getLaporanAbsensi(
        startDate: startDate,
        endDate: endDate,
        tingkatId: tingkatId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUsersByType(String type,
      {String? search, int? perPage, int? page}) async {
    try {
      return await _pimpinanApi.getUsersByType(type,
          search: search, perPage: perPage, page: page);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPondokBlok() async {
    try {
      return await _pimpinanApi.getPondokBlok();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPondokKamar({String? blokId}) async {
    try {
      return await _pimpinanApi.getPondokKamar(blokId: blokId);
    } catch (e) {
      rethrow;
    }
  }
}
