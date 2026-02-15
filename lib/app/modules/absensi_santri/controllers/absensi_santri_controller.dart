import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class AbsensiSantriController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SantriRepository _santriRepository;

  AbsensiSantriController(this._santriRepository);

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
  final penjemputController = TextEditingController();
  final selectedJenisIzin = 'Sakit'.obs;
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    // Check for initial tab argument
    if (Get.arguments is Map && Get.arguments['initialTab'] != null) {
      final initialTab = Get.arguments['initialTab'] as int;
      if (initialTab >= 0 && initialTab < 2) {
        tabController.index = initialTab;
        currentTabIndex.value = initialTab;
      }
    }

    // Initial load
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
    penjemputController.dispose();
    super.onClose();
  }

  String get userRole {
    final user = LocalStorage.getUser();
    final role = user?['role'];
    if (role == null) return 'netizen';
    if (role is String) return role.toLowerCase();
    if (role is Map) {
      return (role['role_name'] ?? 'netizen').toString().toLowerCase();
    }
    return 'netizen';
  }

  Future<void> fetchAbsensi() async {
    try {
      isLoading.value = true;
      // Use backend filtering by passing tipe parameter
      final data = await _santriRepository.getMyAbsensi(tipe: 'Pesantren');

      // Filter only Santri (Pondok) attendance
      // Backend returns 'Pesantren' for AbsensiSantri
      absensiList.assignAll(data.where((e) {
        final map = e as Map<String, dynamic>;
        return map['tipe'] == 'Pesantren';
      }).map((e) {
        final map = e as Map<String, dynamic>;
        return {
          'date': map['tanggal'] ?? '-',
          'status': map['status'] ?? 'hadir',
          'keterangan': map['keterangan'] ?? '-',
          'detail': map['detail'] ?? '-',
          'tipe': map['tipe'] ?? 'Pondok'
        };
      }).toList());
    } catch (e) {
      debugPrint('Error fetching santri attendance: $e');
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
      debugPrint('Error fetching perizinan: $e');
    }
  }

  Future<void> submitPerizinan() async {
    if (alasanController.text.isEmpty ||
        tanggalKeluarController.text.isEmpty ||
        tanggalKembaliController.text.isEmpty) {
      Get.snackbar('Error', 'Harap lengkapi semua field yang diperlukan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      await _santriRepository.submitPerizinan({
        'jenis_izin': selectedJenisIzin.value,
        'alasan': alasanController.text,
        'tanggal_keluar': tanggalKeluarController.text,
        'tanggal_kembali': tanggalKembaliController.text,
        'penjemput': penjemputController.text,
      });

      Get.back();
      Get.snackbar('Sukses', 'Perizinan berhasil diajukan',
          backgroundColor: Colors.green, colorText: Colors.white);

      // Clear form
      alasanController.clear();
      tanggalKeluarController.clear();
      tanggalKembaliController.clear();
      penjemputController.clear();

      // Refresh data
      fetchPerizinan();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengajukan perizinan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void changeMonth(int delta) {
    int newMonth = selectedMonth.value + delta;
    int newYear = selectedYear.value;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    selectedMonth.value = newMonth;
    selectedYear.value = newYear;
  }
}
