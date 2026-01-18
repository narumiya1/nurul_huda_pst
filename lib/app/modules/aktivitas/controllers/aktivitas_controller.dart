import 'package:get/get.dart';

class AktivitasController extends GetxController {
  final isLoading = false.obs;
  final aktivitasList = <Map<String, dynamic>>[].obs;
  final selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAktivitas();
  }

  Future<void> fetchAktivitas() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      aktivitasList.assignAll([
        {
          'time': '04:30',
          'title': 'Shalat Subuh Berjamaah',
          'location': 'Masjid Utama',
          'type': 'ibadah',
        },
        {
          'time': '05:00',
          'title': 'Tahfidz Pagi',
          'location': 'Aula Santri',
          'type': 'akademik',
        },
        {
          'time': '07:00',
          'title': 'Sarapan',
          'location': 'Kantin',
          'type': 'makan',
        },
        {
          'time': '08:00',
          'title': 'Kelas Fiqih',
          'location': 'Ruang Kelas A',
          'type': 'akademik',
        },
        {
          'time': '10:00',
          'title': 'Kelas Bahasa Arab',
          'location': 'Ruang Kelas B',
          'type': 'akademik',
        },
        {
          'time': '12:00',
          'title': 'Shalat Dzuhur Berjamaah',
          'location': 'Masjid Utama',
          'type': 'ibadah',
        },
        {
          'time': '13:00',
          'title': 'Makan Siang',
          'location': 'Kantin',
          'type': 'makan',
        },
        {
          'time': '14:00',
          'title': 'Kelas Hadits',
          'location': 'Ruang Kelas C',
          'type': 'akademik',
        },
        {
          'time': '15:30',
          'title': 'Shalat Ashar Berjamaah',
          'location': 'Masjid Utama',
          'type': 'ibadah',
        },
        {
          'time': '16:00',
          'title': 'Kegiatan Ekstrakurikuler',
          'location': 'Lapangan',
          'type': 'ekskul',
        },
      ]);
    } finally {
      isLoading.value = false;
    }
  }
}
