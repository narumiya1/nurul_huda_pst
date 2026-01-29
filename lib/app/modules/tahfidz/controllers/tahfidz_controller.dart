import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';

class TahfidzController extends GetxController {
  final SantriRepository _repository;

  TahfidzController({SantriRepository? repository})
      : _repository = repository ?? SantriRepository();

  final isLoading = false.obs;
  final hafalanList = <Map<String, dynamic>>[].obs;
  final targetJuz = 30.obs;
  final currentJuz = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHafalan();
  }

  Future<void> fetchHafalan() async {
    try {
      isLoading.value = true;
      final response = await _repository.getMyTahfidz();

      if (response.isNotEmpty) {
        currentJuz.value =
            int.tryParse(response['total_juz']?.toString() ?? '0') ?? 0;

        final progressPerc =
            double.tryParse(response['pencapaian']?.toString() ?? '0') ?? 0.0;
        // targetJuz is calculated based on progress if not provided,
        // but here we can estimate target if total_juz > 0 and pencapaian > 0
        if (currentJuz.value > 0 && progressPerc > 0) {
          targetJuz.value = (currentJuz.value * 100 / progressPerc).round();
        } else {
          targetJuz.value = 30; // fallback
        }

        final riwayat = response['riwayat'] as List?;
        if (riwayat != null) {
          hafalanList.assignAll(riwayat
              .map((e) => {
                    'date': e['tanggal'] ?? '-',
                    'surah': e['surah'] ?? '-',
                    'ayat': '${e['ayat_awal'] ?? 1}-${e['ayat_akhir'] ?? 1}',
                    'nilai': e['nilai']?.toString() ?? '-',
                    'keterangan': e['status'] ?? '-'
                  })
              .toList());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data tahfidz: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get progressPercentage {
    if (targetJuz.value == 0) return 0;
    return (currentJuz.value / targetJuz.value) * 100;
  }
}
