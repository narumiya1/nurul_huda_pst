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

  Future<List<dynamic>> getAbsensi({
    required int sekolahId,
    required int kelasId,
    required String tanggal,
  }) async {
    try {
      final response = await _guruApi.getAbsensi(
        sekolahId: sekolahId,
        kelasId: kelasId,
        tanggal: tanggal,
      );
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      // Return empty list on error (or rethrow if critical)
      return [];
    }
  }

  Future<List<dynamic>> getJadwalPelajaran(
      {Map<String, String>? params}) async {
    try {
      final response = await _guruApi.getJadwalPelajaran(params: params);
      if (response['success'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTodaySchedule() async {
    final now = DateTime.now();
    final dayNames = [
      'Ahad',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    final hari = dayNames[now.weekday % 7];

    return await getJadwalPelajaran(params: {'hari': hari});
  }

  Future<bool> createNilaiBulk(Map<String, dynamic> data) async {
    try {
      final response = await _guruApi.createNilaiBulk(data);
      return response['message'] == 'Bulk update success' ||
          response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getNilai({int? kelasId, int? mapelId}) async {
    try {
      final response =
          await _guruApi.getNilai(kelasId: kelasId, mapelId: mapelId);
      return response is List ? response : [];
    } catch (e) {
      return [];
    }
  }

  // ========== TUGAS SANTRI ==========

  /// Get list of tugas santri created by this guru
  Future<List<dynamic>> getTugasSantriList() async {
    try {
      final response = await _guruApi.getTugasSantriList();
      if (response['success'] == true || response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get detail tugas santri
  Future<Map<String, dynamic>?> getTugasSantriDetail(int id) async {
    try {
      final response = await _guruApi.getTugasSantriDetail(id);
      if (response['success'] == true || response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create new tugas santri
  Future<bool> createTugasSantri(Map<String, dynamic> data) async {
    try {
      final response = await _guruApi.createTugasSantri(data);
      return response['success'] == true || response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Update tugas santri
  Future<bool> updateTugasSantri(Map<String, dynamic> data) async {
    try {
      final response = await _guruApi.updateTugasSantri(data);
      return response['success'] == true || response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete tugas santri
  Future<bool> deleteTugasSantri(int id) async {
    try {
      final response = await _guruApi.deleteTugasSantri(id);
      return response['success'] == true || response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Grade tugas santri submission
  Future<bool> gradeTugasSantri({
    required int submissionId,
    required double nilai,
    String? catatan,
  }) async {
    try {
      final response = await _guruApi.gradeTugasSantri({
        'submission_id': submissionId,
        'nilai': nilai,
        'catatan': catatan,
      });
      return response['success'] == true || response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get tingkat santri list
  Future<List<dynamic>> getTingkatSantri() async {
    try {
      final response = await _guruApi.getTingkatSantri();
      if (response['success'] == true || response['status'] == true) {
        return response['data'] ?? [];
      }
      // Handle direct array response
      if (response is List) return response;
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get kelas santri by tingkat
  Future<List<dynamic>> getKelasSantri({int? tingkatId}) async {
    try {
      final response = await _guruApi.getKelasSantri(tingkatId: tingkatId);
      if (response['success'] == true || response['status'] == true) {
        return response['data'] ?? [];
      }
      if (response is List) return response;
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get mapel pondok list
  Future<List<dynamic>> getMapelPondok() async {
    try {
      final response = await _guruApi.getMapelPondok();
      if (response['success'] == true || response['status'] == true) {
        return response['data'] ?? [];
      }
      if (response is List) return response;
      return [];
    } catch (e) {
      return [];
    }
  }
}
