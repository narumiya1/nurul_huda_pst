import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/guru/guru_api.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class TeacherAreaController extends GetxController {
  final GuruRepository _guruRepository = GuruRepository(GuruApi());
  final ApiHelper _apiHelper = ApiHelper();

  final isLoading = false.obs;
  final kelasList = <Map<String, dynamic>>[].obs;
  final siswaList = <Map<String, dynamic>>[].obs;
  final selectedKelas = Rxn<Map<String, dynamic>>();
  final attendanceData = <int, String>{}.obs; // siswa_id -> status

  // Tahfidz
  final santriList = <Map<String, dynamic>>[].obs;
  final selectedSantri = Rxn<Map<String, dynamic>>();

  // Form fields for Tahfidz
  final surahController = TextEditingController();
  final ayatController = TextEditingController();
  final catatanController = TextEditingController();
  final selectedJuz = Rxn<int>();
  final selectedKualitas = 'lancar'.obs;

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  @override
  void onInit() {
    super.onInit();
    fetchKelasList();
    fetchSantriList();
  }

  @override
  void onClose() {
    surahController.dispose();
    ayatController.dispose();
    catatanController.dispose();
    super.onClose();
  }

  Future<void> fetchKelasList() async {
    try {
      isLoading.value = true;
      final data = await _guruRepository.getMyKelas();
      kelasList.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      // Fallback mock
      kelasList.assignAll([
        {
          'id': 1,
          'nama_kelas': 'VII A',
          'tingkat': {'nama_tingkat': 'VII'}
        },
        {
          'id': 2,
          'nama_kelas': 'VIII B',
          'tingkat': {'nama_tingkat': 'VIII'}
        },
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSiswaByKelas(int kelasId) async {
    try {
      isLoading.value = true;
      siswaList.clear();
      attendanceData.clear();

      final uri = ApiHelper.buildUri(
          endpoint: 'siswa', params: {'kelas_id': kelasId.toString()});
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response != null && response['data'] != null) {
        final List rawList = response['data'] is List
            ? response['data']
            : (response['data']['data'] ?? []);
        siswaList
            .assignAll(rawList.map((e) => e as Map<String, dynamic>).toList());
        // Initialize all as 'hadir'
        for (var siswa in siswaList) {
          attendanceData[siswa['id']] = 'hadir';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar siswa: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateAttendance(int siswaId, String status) {
    attendanceData[siswaId] = status;
  }

  Future<void> submitAttendance() async {
    if (selectedKelas.value == null) {
      Get.snackbar('Peringatan', 'Pilih kelas terlebih dahulu');
      return;
    }

    try {
      isLoading.value = true;

      final students = attendanceData.entries
          .map((e) => {
                'siswa_id': e.key,
                'status': e.value,
              })
          .toList();

      final data = {
        'sekolah_id': selectedKelas.value!['sekolah_id'] ?? 1,
        'kelas_id': selectedKelas.value!['id'],
        'tanggal': DateTime.now().toString().split(' ')[0],
        'students': students,
      };

      final success = await _guruRepository.createAbsensi(data);

      if (success) {
        Get.snackbar('Sukses', 'Absensi berhasil disimpan!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', 'Gagal menyimpan absensi',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== TAHFIDZ ==========
  Future<void> fetchSantriList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response != null && response['data'] != null) {
        final List rawList = response['data'] is List
            ? response['data']
            : (response['data']['data'] ?? []);
        santriList
            .assignAll(rawList.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (e) {
      // Silent fail or mock
      santriList.assignAll([
        {
          'id': 1,
          'details': {'full_name': 'Ahmad Fauzi'}
        },
        {
          'id': 2,
          'details': {'full_name': 'Siti Aminah'}
        },
      ]);
    }
  }

  Future<void> submitTahfidz() async {
    if (selectedSantri.value == null) {
      Get.snackbar('Peringatan', 'Pilih santri terlebih dahulu');
      return;
    }
    if (surahController.text.isEmpty || ayatController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Isi surah dan ayat');
      return;
    }

    try {
      isLoading.value = true;

      final uri = ApiHelper.buildUri(endpoint: 'tahfidz/hafalan');
      final body = {
        'santri_id': selectedSantri.value!['id'],
        'juz': selectedJuz.value,
        'surah': surahController.text,
        'ayat_range': ayatController.text,
        'kualitas': selectedKualitas.value,
        'tanggal_setoran': DateTime.now().toString().split(' ')[0],
        'catatan': catatanController.text,
      };

      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: body,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response['success'] == true) {
        Get.snackbar('Sukses', 'Setoran tahfidz berhasil dicatat!',
            backgroundColor: Colors.green, colorText: Colors.white);
        // Reset form
        surahController.clear();
        ayatController.clear();
        catatanController.clear();
        selectedJuz.value = null;
        selectedSantri.value = null;
        Get.back();
      } else {
        Get.snackbar('Gagal', response['message'] ?? 'Gagal menyimpan',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
