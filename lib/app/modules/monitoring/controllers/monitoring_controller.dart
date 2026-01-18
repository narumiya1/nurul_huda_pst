import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';

class MonitoringController extends GetxController {
  final isLoading = false.obs;
  final userRole = 'netizen'.obs;

  // Stats for Pimpinan
  final psbStats = <String, dynamic>{}.obs;
  final academicStats = <String, dynamic>{}.obs;
  final financeSummary = <String, dynamic>{}.obs;
  final tahfidzProgress = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchMonitoringData();
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

  Future<void> fetchMonitoringData() async {
    try {
      isLoading.value = true;
      // Simulation of deep monitoring API call
      await Future.delayed(const Duration(seconds: 1));

      psbStats.value = {
        'total_pendaftar': 150,
        'terverifikasi': 85,
        'menunggu': 45,
        'ditolak': 20,
        'target': 200,
        'persentase': 0.75,
      };

      academicStats.value = {
        'rata_rata_nilai': 82.5,
        'absensi_siswa': '94%',
        'total_kelas': 12,
        'jumlah_siswa': 324,
      };

      financeSummary.value = {
        'total_pendapatan': 1250000000,
        'total_pengeluaran': 850000000,
        'surplus': 400000000,
        'piutang_spp': 240000000,
      };

      tahfidzProgress.assignAll([
        {'grade': 'Kelas 7', 'avg_juz': '2.5 Juz', 'progress': 0.6},
        {'grade': 'Kelas 8', 'avg_juz': '4.2 Juz', 'progress': 0.8},
        {'grade': 'Kelas 9', 'avg_juz': '6.8 Juz', 'progress': 0.9},
      ]);
    } finally {
      isLoading.value = false;
    }
  }
}
