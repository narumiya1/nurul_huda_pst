import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';

class AbsensiController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SantriRepository _santriRepository =
      SantriRepository(); // Simple injection for now

  late TabController tabController;

  final isLoading = false.obs;
  final absensiList = <Map<String, dynamic>>[].obs;
  final perizinanList = <Map<String, dynamic>>[].obs;

  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  // Form Controllers
  final jenisIzinController = TextEditingController();
  final alasanController = TextEditingController();
  final tanggalKeluarController = TextEditingController();
  final tanggalKembaliController = TextEditingController();
  final selectedJenisIzin = 'Sakit'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchAbsensi();
    fetchPerizinan();
  }

  @override
  void onClose() {
    tabController.dispose();
    jenisIzinController.dispose();
    alasanController.dispose();
    tanggalKeluarController.dispose();
    tanggalKembaliController.dispose();
    super.onClose();
  }

  Future<void> fetchAbsensi() async {
    try {
      isLoading.value = true;
      // Simulate API call for Absensi (or implement real API later)
      await Future.delayed(const Duration(milliseconds: 500));

      absensiList.assignAll([
        {'date': '2026-01-18', 'status': 'hadir', 'keterangan': '-'},
        {'date': '2026-01-17', 'status': 'hadir', 'keterangan': '-'},
        {
          'date': '2026-01-16',
          'status': 'izin',
          'keterangan': 'Acara keluarga'
        },
        {'date': '2026-01-15', 'status': 'hadir', 'keterangan': '-'},
        {'date': '2026-01-14', 'status': 'sakit', 'keterangan': 'Demam'},
        {'date': '2026-01-13', 'status': 'hadir', 'keterangan': '-'},
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPerizinan() async {
    try {
      final data = await _santriRepository.getPerizinan();
      perizinanList
          .assignAll(data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      print('Error fetching perizinan: $e');
    }
  }

  Future<void> submitIzin() async {
    if (alasanController.text.isEmpty || tanggalKeluarController.text.isEmpty) {
      Get.snackbar('Error', 'Mohon lengkapi data',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final success = await _santriRepository.submitPerizinan({
        'jenis_izin': selectedJenisIzin.value,
        'tanggal_keluar': tanggalKeluarController.text, // Format: YYYY-MM-DD
        'tanggal_kembali': tanggalKembaliController.text.isNotEmpty
            ? tanggalKembaliController.text
            : tanggalKeluarController.text,
        'alasan': alasanController.text
      });

      if (success) {
        Get.back(); // Close modal
        Get.snackbar('Sukses', 'Perizinan berhasil diajukan',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchPerizinan();
        _resetForm();
      } else {
        Get.snackbar('Gagal', 'Perizinan gagal diajukan',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    selectedJenisIzin.value = 'Sakit';
    alasanController.clear();
    tanggalKeluarController.clear();
    tanggalKembaliController.clear();
  }

  int get totalHadir => absensiList.where((a) => a['status'] == 'hadir').length;
  int get totalIzin => absensiList.where((a) => a['status'] == 'izin').length;
  int get totalSakit => absensiList.where((a) => a['status'] == 'sakit').length;
  int get totalAlpha => absensiList.where((a) => a['status'] == 'alpha').length;
}
