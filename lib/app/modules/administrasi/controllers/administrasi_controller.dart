import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';
import '../../../helpers/file_helper.dart';

class AdministrasiController extends GetxController {
  final PimpinanRepository _pimpinanRepository;
  final isLoading = false.obs;
  final archiveList = <Map<String, dynamic>>[].obs;
  final filteredArchives = <Map<String, dynamic>>[].obs;
  final userRole = 'netizen'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  AdministrasiController(this._pimpinanRepository);

  // Filter States
  final selectedType =
      'Semua'.obs; // Semua, Surat Masuk, Surat Keluar, Proposal
  final selectedStatus = 'Semua'.obs; // Semua, Arsip, Proses, Selesai

  final tabIndex = 0.obs; // 0: Arsip, 1: Unduhan
  final downloadedFiles = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchAdministrasiData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadUserRole() {
    final user = LocalStorage.getUser();
    if (user != null) {
      final role = user['role'];
      if (role is String) {
        userRole.value = role.toLowerCase();
      } else if (role is Map) {
        userRole.value =
            (role['role_name'] ?? 'netizen').toString().toLowerCase();
      }
    }
  }

  bool get canManage =>
      userRole.value == 'staff_pesantren' || userRole.value == 'staff_keuangan';
  bool get canApprove =>
      userRole.value == 'pimpinan' || userRole.value == 'superadmin';

  Future<void> fetchAdministrasiData() async {
    try {
      isLoading.value = true;

      // Fetch real data from persuratan/surat
      final response = await _pimpinanRepository.getPersuratanSurat(
        search: searchQuery.value,
        status: selectedStatus.value == 'Semua'
            ? null
            : selectedStatus.value.toLowerCase(),
      );

      if (response['data'] != null) {
        final List mailData = response['data'] is List
            ? response['data']
            : (response['data']['data'] ?? []);
        archiveList.assignAll(mailData.map((item) {
          return {
            'id': item['id'],
            'title': item['perihal'] ?? 'Tanpa Perihal',
            'type': item['tipe'] == 'masuk' ? 'Surat Masuk' : 'Surat Keluar',
            'number': item['nomor_surat'] ?? 'No Number',
            'date': item['created_at']?.split('T')[0] ?? '',
            'status': item['status'] ?? 'Draft',
            'sender': item['pembuat']?['details']?['full_name'] ?? 'System',
            'recipient': item['penerima_name'] ?? 'Internal',
            'content': item['perihal'] ?? 'Tidak ada detil isi berkas.',
            'attachment': item['file_path'],
            'raw': item, // Store raw data for details
          };
        }).toList());

        _applyClientFilters();
        return;
      }

      // Fallback or Initial Mock Data (Optional, but kept for safety if API fails)
      archiveList.assignAll([
        {
          'title': 'Surat Masuk: Pengajuan Dana Bos',
          'type': 'Surat Masuk',
          'number': '201/ADM/2026',
          'date': '2026-01-18',
          'status': 'Approved',
          'sender': 'Kemenag Pusat',
          'recipient': 'Kepala Pesantren',
          'content': 'Sehubungan dengan program bantuan operasional sekolah...',
          'attachment': 'dana_bos_2026.pdf'
        },
      ]);
      filteredArchives.assignAll(archiveList);
    } catch (e) {
      debugPrint('Error fetching administrasi data: $e');
      Get.snackbar('Error', 'Gagal memuat data administrasi');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyClientFilters() {
    String q = searchQuery.value;
    var result = archiveList.where((a) {
      bool matchSearch = q.isEmpty ||
          a['title'].toLowerCase().contains(q.toLowerCase()) ||
          a['number'].contains(q);
      bool matchType =
          selectedType.value == 'Semua' || a['type'] == selectedType.value;
      bool matchStatus = selectedStatus.value == 'Semua' ||
          a['status'].toString().toLowerCase() ==
              selectedStatus.value.toLowerCase();
      return matchSearch && matchType && matchStatus;
    }).toList();

    filteredArchives.assignAll(result);
  }

  void searchArchive(String query) {
    searchQuery.value = query;
    _applyClientFilters();
  }

  void applyFilters({String? search, String? type, String? status}) {
    if (type != null) selectedType.value = type;
    if (status != null) selectedStatus.value = status;
    _applyClientFilters();
  }

  Future<void> approveSurat(String id) async {
    try {
      isLoading.value = true;
      await _pimpinanRepository.approvePersuratanSurat(id);
      Get.snackbar('Berhasil', 'Surat berhasil disetujui');
      fetchAdministrasiData();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menyetujui surat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectSurat(String id) async {
    try {
      isLoading.value = true;
      await _pimpinanRepository.rejectPersuratanSurat(id);
      Get.snackbar('Berhasil', 'Surat berhasil ditolak');
      fetchAdministrasiData();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menonaktifkan surat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitSurat(String id) async {
    try {
      isLoading.value = true;
      await _pimpinanRepository.submitPersuratanSurat(id);
      Get.snackbar('Berhasil', 'Surat berhasil diajukan');
      fetchAdministrasiData();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengajukan surat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    selectedType.value = 'Semua';
    selectedStatus.value = 'Semua';
    searchQuery.value = '';
    searchController.clear();
    applyFilters();
  }

  Future<void> downloadFile(String path, {String? filename}) async {
    await FileHelper.downloadAndOpenFile(path, filename: filename);

    // Track downloads
    if (!downloadedFiles.any(
        (file) => file['fileName'] == (filename ?? path.split('/').last))) {
      downloadedFiles.add({
        'fileName': filename ?? path.split('/').last,
        'downloadDate': DateTime.now().toString().split('.')[0],
        'size': 'Unknown',
      });
    }
  }
}
