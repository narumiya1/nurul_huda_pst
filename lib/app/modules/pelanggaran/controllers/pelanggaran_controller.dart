import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class PelanggaranController extends GetxController {
  final SantriRepository _repository;

  PelanggaranController({SantriRepository? repository})
      : _repository = repository ?? SantriRepository();

  final isLoading = false.obs;
  final pelanggaranList = <dynamic>[].obs;
  final santriList = <dynamic>[].obs;
  final kelasList = <dynamic>[].obs;
  final kamarList = <dynamic>[].obs;
  final isLoadingSantri = false.obs;

  final userData = Rxn<Map<String, dynamic>>();

  // Form observability
  final selectedSantriId = Rxn<int>();
  final selectedKelasId = Rxn<int?>();
  final selectedKamarId = Rxn<int?>();
  final judulController = TextEditingController();
  final poinController = TextEditingController();
  final tindakanController = TextEditingController();
  final searchController = TextEditingController();
  final selectedKategori = 'Ringan'.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    userData.value = LocalStorage.getUser();
    fetchPelanggaran();
    if (isTeacher) {
      fetchFilterData();
      // Initial load of some santri or wait for user input
      fetchSantriList();
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSantriList(query: query);
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    judulController.dispose();
    poinController.dispose();
    tindakanController.dispose();
    searchController.dispose();
    super.onClose();
  }

  bool get isTeacher {
    final role = userData.value?['role'];
    String roleName = '';
    if (role is String) roleName = role;
    if (role is Map) roleName = role['role_name'] ?? '';
    return ['superadmin', 'pimpinan', 'guru', 'staff_pesantren', 'roissantri']
        .contains(roleName.toLowerCase());
  }

  Future<void> fetchPelanggaran() async {
    try {
      isLoading.value = true;
      final data = await _repository.getPelanggaran();
      pelanggaranList.assignAll(data);
    } catch (e) {
      // Error handled silently
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFilterData() async {
    try {
      // Determine if we should fetch all classes or just guru's classes
      final role = userData.value?['role'];
      String roleName = '';
      if (role is String) roleName = role;
      if (role is Map) roleName = role['role_name'] ?? '';

      final bool onlyShowMyKelas = roleName.toLowerCase() == 'guru';

      final rawKelas = onlyShowMyKelas
          ? await _repository.getMyKelasList()
          : await _repository.getKelasList();

      final List<Map<String, dynamic>> normalizedKelas = [];
      final Set<int> seenKelasIds = {};

      for (var k in rawKelas) {
        if (k is Map) {
          int? id;
          String? name;
          if (k.containsKey('kelas') && k['kelas'] is Map) {
            id = k['kelas']['id'];
            name = k['kelas']['nama_kelas'];
          } else {
            id = k['id'];
            name = k['nama_kelas'];
          }

          if (id != null && !seenKelasIds.contains(id)) {
            seenKelasIds.add(id);
            normalizedKelas.add({'id': id, 'name': name ?? 'Kelas $id'});
          }
        }
      }
      kelasList.assignAll(normalizedKelas);

      // Normalize Kamar data
      final rawKamar = await _repository.getKamarList();
      final List<Map<String, dynamic>> normalizedKamar = [];
      final Set<int> seenKamarIds = {};

      for (var k in rawKamar) {
        if (k is Map && k['id'] != null) {
          final int id = k['id'];
          if (!seenKamarIds.contains(id)) {
            seenKamarIds.add(id);
            normalizedKamar.add({'id': id, 'name': k['nama_kamar'] ?? 'Kamar'});
          }
        }
      }
      kamarList.assignAll(normalizedKamar);
    } catch (e) {
      // Error handled
    }
  }

  Future<void> fetchSantriList({String? query}) async {
    // If no search query and no filters, maybe limit the fetch
    // But for now, we send whatever is selected
    try {
      isLoadingSantri.value = true;
      final data = await _repository.getSantriList(
        search: query ?? searchController.text,
        kelasId: selectedKelasId.value,
        kamarId: selectedKamarId.value,
      );
      santriList.assignAll(data);
    } catch (e) {
      // Error handled
    } finally {
      isLoadingSantri.value = false;
    }
  }

  Future<void> submitPelanggaran() async {
    if (selectedSantriId.value == null || judulController.text.isEmpty) {
      Get.snackbar('Error', 'Lengkapi data pelanggaran');
      return;
    }

    try {
      isLoading.value = true;
      final success = await _repository.submitPelanggaran({
        'santri_id': selectedSantriId.value,
        'judul_pelanggaran': judulController.text,
        'kategori': selectedKategori.value,
        'poin': int.tryParse(poinController.text) ?? 0,
        'tindakan': tindakanController.text,
        'tanggal_kejadian': DateTime.now().toString().split(' ')[0],
      });

      if (success) {
        Get.back();
        Get.snackbar('Sukses', 'Pelanggaran berhasil dicatat',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchPelanggaran();
        _resetForm();
      } else {
        Get.snackbar('Gagal', 'Gagal mencatat pelanggaran');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    selectedSantriId.value = null;
    selectedKelasId.value = null;
    selectedKamarId.value = null;
    judulController.clear();
    poinController.clear();
    tindakanController.clear();
    searchController.clear();
    selectedKategori.value = 'Ringan';
    fetchSantriList();
  }
}
