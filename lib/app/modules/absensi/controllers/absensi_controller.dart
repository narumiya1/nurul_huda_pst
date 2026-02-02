import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class AbsensiController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SantriRepository _santriRepository;
  final OrangtuaRepository _orangtuaRepository;

  AbsensiController(this._santriRepository, this._orangtuaRepository);

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

  // Selected child for parents
  final selectedChildId = RxnInt();
  final selectedChildTipe = RxnString(); // 'Santri' or 'Siswa'
  final selectedChildKey = RxnString(); // Format: 'Santri_1' or 'Siswa_51'
  final children = <Map<String, dynamic>>[].obs;

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final role = userRole;
    if (role == 'orangtua') {
      await fetchChildren();
      if (children.isNotEmpty) {
        final first = children[0];
        selectedChildId.value = first['id'];
        selectedChildTipe.value = first['tipe'];
        selectedChildKey.value = '${first['tipe']}_${first['id']}';
      }
    }
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

  Future<void> fetchChildren() async {
    try {
      final data = await _orangtuaRepository.getMyChildren();
      children.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      debugPrint('Error fetching children: $e');
    }
  }

  Future<void> fetchAbsensi() async {
    try {
      isLoading.value = true;
      final role = userRole;

      List<dynamic> data = [];
      if (role == 'santri' || role == 'siswa') {
        data = await _santriRepository.getMyAbsensi();
      } else if (role == 'orangtua' && selectedChildId.value != null) {
        data = await _orangtuaRepository.getChildAbsensi(
          selectedChildId.value!,
          tipe: selectedChildTipe.value,
        );
      }

      absensiList.assignAll(data.map((e) {
        final map = e as Map<String, dynamic>;
        // Map backend fields to UI fields if necessary
        return {
          'date': map['tanggal'] ?? '-',
          'status': map['status'] ?? 'hadir',
          'keterangan': map['keterangan'] ?? '-',
          'detail': map['detail'] ?? '-',
          'tipe': map['tipe'] ?? '-'
        };
      }).toList());
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPerizinan() async {
    try {
      final role = userRole;
      List<dynamic> data = [];

      if (role == 'santri' || role == 'siswa') {
        data = await _santriRepository.getPerizinan();
      } else if (role == 'orangtua' && selectedChildId.value != null) {
        data = await _orangtuaRepository.getChildPerizinan(
            selectedChildId.value!,
            tipe: selectedChildTipe.value);
      }

      perizinanList
          .assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      debugPrint('DEBUG: Fetched ${perizinanList.length} perizinan items');
    } catch (e) {
      debugPrint('Error fetching perizinan: $e');
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
      final Map<String, dynamic> payload = {
        'jenis_izin': selectedJenisIzin.value,
        'tanggal_keluar': tanggalKeluarController.text, // Format: YYYY-MM-DD
        'tanggal_kembali': tanggalKembaliController.text.isNotEmpty
            ? tanggalKembaliController.text
            : tanggalKeluarController.text,
        'alasan': alasanController.text,
        'penjemput': penjemputController.text,
      };

      if (userRole == 'orangtua' && selectedChildId.value != null) {
        payload['santri_id'] = selectedChildId.value;
      }

      final success = await _santriRepository.submitPerizinan(payload);

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
    penjemputController.clear();
  }

  int get totalHadir => absensiList.where((a) => a['status'] == 'hadir').length;
  int get totalIzin => absensiList.where((a) => a['status'] == 'izin').length;
  int get totalSakit => absensiList.where((a) => a['status'] == 'sakit').length;
  int get totalAlpha => absensiList.where((a) => a['status'] == 'alpha').length;

  void onChildChanged(int? childId) {
    if (childId != null) {
      selectedChildId.value = childId;
      fetchAbsensi();
      fetchPerizinan();
    }
  }

  void onChildKeyChanged(String? key) {
    if (key == null) return;
    // Parse key format: 'Santri_1' or 'Siswa_51'
    final parts = key.split('_');
    if (parts.length == 2) {
      selectedChildTipe.value = parts[0];
      selectedChildId.value = int.tryParse(parts[1]);
      selectedChildKey.value = key;
      fetchAbsensi();
      fetchPerizinan();
    }
  }
}
