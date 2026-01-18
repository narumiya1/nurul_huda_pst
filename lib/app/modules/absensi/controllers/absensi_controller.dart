import 'package:get/get.dart';

class AbsensiController extends GetxController {
  final isLoading = false.obs;
  final absensiList = <Map<String, dynamic>>[].obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAbsensi();
  }

  Future<void> fetchAbsensi() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data
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

  int get totalHadir => absensiList.where((a) => a['status'] == 'hadir').length;
  int get totalIzin => absensiList.where((a) => a['status'] == 'izin').length;
  int get totalSakit => absensiList.where((a) => a['status'] == 'sakit').length;
  int get totalAlpha => absensiList.where((a) => a['status'] == 'alpha').length;
}
