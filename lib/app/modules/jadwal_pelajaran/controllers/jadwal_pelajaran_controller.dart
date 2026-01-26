import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/guru/guru_api.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class JadwalPelajaranController extends GetxController {
  final GuruRepository _guruRepository = GuruRepository(GuruApi());

  final isLoading = false.obs;
  final jadwalList = <dynamic>[].obs;

  // Grouped by day
  final groupedJadwal = <String, List<dynamic>>{}.obs;

  // Days order
  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Ahad'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    try {
      isLoading.value = true;
      final user = LocalStorage.getUser();
      String role = '';
      if (user != null) {
        if (user['role'] is String) {
          role = user['role'].toLowerCase();
        } else if (user['role'] is Map) {
          role = (user['role']['role_name'] ?? '').toString().toLowerCase();
        }
      }
      debugPrint('JadwalController: Detected role: $role');

      List<dynamic> data = [];
      if (role == 'santri' || role == 'siswa') {
        // Use Santri repository (lazy load or just new instance here since not injected yet)
        final santriRepo = SantriRepository();
        data = await santriRepo.getJadwalPelajaran();
      } else {
        // Default (Guru/Admin)
        data = await _guruRepository.getJadwalPelajaran();
      }

      jadwalList.assignAll(data);
      _groupJadwal();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _groupJadwal() {
    final Map<String, List<dynamic>> grouped = {};

    // Initialize empty lists for all days
    for (var day in days) {
      grouped[day] = [];
    }

    // Populate
    for (var item in jadwalList) {
      final hari = item['hari'] as String?;
      // Handle cases where 'hari' might have extra chars from previous issues if any
      // Assuming 'hari' is clean "Senin", "Selasa", etc.
      if (hari != null) {
        // Simple sanitization just in case
        String cleanHari =
            days.firstWhere((d) => hari.contains(d), orElse: () => '');

        if (cleanHari.isNotEmpty) {
          grouped[cleanHari]?.add(item);
        }
      }
    }

    groupedJadwal.value = grouped;
  }
}
