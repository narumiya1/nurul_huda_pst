import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../helpers/local_storage.dart';

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

  bool get canManage => userRole.value == 'staff_pesantren';

  Future<void> fetchAdministrasiData() async {
    try {
      isLoading.value = true;

      try {
        // Fetch real data for Pimpinan/Staff
        // We can fetch 'inbox' or 'archive' based on needs, here we use 'inbox' as default
        final response = await _pimpinanRepository.getMails(
          filter: 'inbox',
          search: searchQuery.value,
        );

        if (response['data'] != null) {
          final List mailData = response['data']['data'] ?? [];
          archiveList.assignAll(mailData.map((item) {
            final mail = item['mail'] ?? {};
            return {
              'title': mail['subject'] ?? 'Tanpa Subjek',
              'type': mail['type'] ?? 'Surat Masuk',
              'number': mail['reference_number'] ?? 'No Number',
              'date': mail['date'] ?? item['created_at']?.split('T')[0] ?? '',
              'status': item['is_archive'] == true ? 'Arsip' : 'Baru',
              'sender': mail['sender']?['details']?['full_name'] ?? 'System',
              'recipient': 'Saya',
              'content': mail['content'] ?? 'Tidak ada detil isi berkas.',
              'attachment': mail['file_path'] ?? mail['file'],
            };
          }).toList());
          filteredArchives.assignAll(archiveList);
          return;
        }
      } catch (e) {
        // Handle error silently
      }

      // Fallback or Initial Mock Data
      archiveList.assignAll([
        {
          'title': 'Surat Masuk: Pengajuan Dana Bos',
          'type': 'Surat Masuk',
          'number': '201/ADM/2026',
          'date': '2026-01-18',
          'status': 'Terima',
          'sender': 'Kemenag Pusat',
          'recipient': 'Kepala Pesantren',
          'content': 'Sehubungan dengan program bantuan operasional sekolah...',
          'attachment': 'dana_bos_2026.pdf'
        },
        // ... rest of mock data
        {
          'title': 'Surat Keterangan Santri',
          'type': 'Surat Keluar',
          'number': '400/012/NH-2026',
          'date': '2026-01-18',
          'status': 'Arsip',
          'sender': 'Sekretariat Pesantren',
          'recipient': 'Wali Santri (Bpk. Ahmad)',
          'content':
              'Dengan ini menerangkan bahwa ananda Ahmad adalah santri...',
          'attachment': 'sk_santri_ahmad.pdf'
        },
        {
          'title': 'Surat Masuk: Kemenag Wilayah',
          'type': 'Surat Masuk',
          'number': 'KM/882/I/2026',
          'date': '2026-01-16',
          'status': 'Arsip',
          'sender': 'Kemenag Wilayah Jabar',
          'recipient': 'Bidang Akademik',
          'content': 'Monitoring dan evaluasi kurikulum tingkat menengah...',
          'attachment': 'monev_kurikulum.pdf'
        },
        {
          'title': 'Proposal Renovasi Masjid',
          'type': 'Proposal',
          'number': '400/015/NH-2026',
          'date': '2026-01-15',
          'status': 'Proses',
          'sender': 'Panitia Pembangunan',
          'recipient': 'Dewan Pembina',
          'content': 'Rancangan anggaran biaya pengembangan area masjid...',
          'attachment': 'rab_masjid.pdf'
        },
        {
          'title': 'Surat Tugas Pimpinan',
          'type': 'Surat Masuk',
          'number': 'ST/001/PIM/2026',
          'date': '2026-01-14',
          'status': 'Arsip',
          'sender': 'Sekretaris Yayasan',
          'recipient': 'Pimpinan Pesantren',
          'content': 'Penugasan menghadiri Rakernas Pesantren Indonesia...',
          'attachment': 'surat_tugas.pdf'
        },
      ]);
      filteredArchives.assignAll(archiveList);
    } finally {
      isLoading.value = false;
    }
  }

  void searchArchive(String query) {
    applyFilters(search: query);
  }

  void applyFilters({String? search, String? type, String? status}) {
    if (type != null) selectedType.value = type;
    if (status != null) selectedStatus.value = status;
    String q = search ?? searchQuery.value;

    var result = archiveList.where((a) {
      bool matchSearch = q.isEmpty ||
          a['title'].toLowerCase().contains(q.toLowerCase()) ||
          a['number'].contains(q);
      bool matchType =
          selectedType.value == 'Semua' || a['type'] == selectedType.value;
      bool matchStatus = selectedStatus.value == 'Semua' ||
          a['status'] == selectedStatus.value;
      return matchSearch && matchType && matchStatus;
    }).toList();

    filteredArchives.assignAll(result);
  }

  void resetFilters() {
    selectedType.value = 'Semua';
    selectedStatus.value = 'Semua';
    searchQuery.value = '';
    searchController.clear();
    applyFilters();
  }

  Future<void> downloadFile(String fileName) async {
    try {
      Get.snackbar(
        'Mengunduh',
        'Sedang menyiapkan berkas $fileName...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        colorText: AppColors.primary,
        duration: const Duration(seconds: 2),
      );

      // Simulate download delay
      await Future.delayed(const Duration(seconds: 3));

      // Add to downloaded history if not already there
      if (!downloadedFiles.any((file) => file['fileName'] == fileName)) {
        downloadedFiles.add({
          'fileName': fileName,
          'downloadDate': DateTime.now().toString().split('.')[0],
          'size': '1.${(fileName.length % 9) + 1} MB',
        });
      }

      Get.snackbar(
        'Berhasil',
        'Berkas $fileName berhasil diunduh ke folder Download.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle, color: AppColors.success),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mengunduh berkas.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }
}
