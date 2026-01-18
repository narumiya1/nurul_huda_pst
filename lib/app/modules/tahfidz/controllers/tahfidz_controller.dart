import 'package:get/get.dart';

class TahfidzController extends GetxController {
  final isLoading = false.obs;
  final hafalanList = <Map<String, dynamic>>[].obs;
  final targetJuz = 30.obs;
  final currentJuz = 5.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHafalan();
  }

  Future<void> fetchHafalan() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      hafalanList.assignAll([
        {
          'date': '2026-01-18',
          'surah': 'Al-Baqarah',
          'ayat': '1-10',
          'nilai': 'A',
          'keterangan': 'Sangat Baik'
        },
        {
          'date': '2026-01-17',
          'surah': 'Al-Fatihah',
          'ayat': '1-7',
          'nilai': 'A',
          'keterangan': 'Sempurna'
        },
        {
          'date': '2026-01-16',
          'surah': 'An-Nas',
          'ayat': '1-6',
          'nilai': 'B+',
          'keterangan': 'Baik'
        },
        {
          'date': '2026-01-15',
          'surah': 'Al-Falaq',
          'ayat': '1-5',
          'nilai': 'A',
          'keterangan': 'Sangat Baik'
        },
        {
          'date': '2026-01-14',
          'surah': 'Al-Ikhlas',
          'ayat': '1-4',
          'nilai': 'A',
          'keterangan': 'Sempurna'
        },
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  double get progressPercentage => (currentJuz.value / targetJuz.value) * 100;
}
