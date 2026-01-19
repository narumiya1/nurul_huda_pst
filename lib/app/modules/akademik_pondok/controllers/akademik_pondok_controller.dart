import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';

class AkademikPondokController extends GetxController {
  final PimpinanRepository _pimpinanRepository;
  final SantriRepository _santriRepository = SantriRepository();
  final isLoading = false.obs;
  final userRole = 'netizen'.obs;

  AkademikPondokController(this._pimpinanRepository);

  // Data for Pimpinan
  final rekapNilai = <Map<String, dynamic>>[].obs;
  final agendaKegiatan = <Map<String, dynamic>>[].obs;
  final progressTahfidz = <Map<String, dynamic>>[].obs;
  final laporanAbsensi = <Map<String, dynamic>>[].obs;
  final dataKurikulum = <Map<String, dynamic>>[].obs;
  final tugasList = <Map<String, dynamic>>[].obs;

  // Filtered Data
  final filteredRekapNilai = <Map<String, dynamic>>[].obs;
  final filteredAgenda = <Map<String, dynamic>>[].obs;
  final filteredTahfidz = <Map<String, dynamic>>[].obs;
  final filteredLaporanAbsensi = <Map<String, dynamic>>[].obs;
  final filteredKurikulum = <Map<String, dynamic>>[].obs;
  final filteredTugas = <Map<String, dynamic>>[].obs;

  // Filter States
  final selectedTingkat = 'Semua'.obs;
  final selectedSemester = 'Ganjil 2025/2026'.obs;
  final selectedCategory = 'Semua'.obs;
  final selectedTahfidzGroup = 'Semua'.obs;
  final selectedCurriculumType = 'Semua'.obs;
  final selectedAbsensiTingkat = 'Semua'.obs;
  final selectedAbsensiPeriod = 'Hari Ini'.obs;

  final selectedIndex = (-1).obs; // -1 for main grid menu

  // Assignment Logic
  final selectedAssignmentFile = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchAllData();
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

  Future<void> pickAssignmentFile() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedAssignmentFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  void clearAssignmentFile() {
    selectedAssignmentFile.value = null;
  }

  Future<void> submitTugas(String tugasId, String jawaban) async {
    try {
      if (jawaban.isEmpty && selectedAssignmentFile.value == null) {
        Get.snackbar('Peringatan', 'Mohon isi jawaban atau upload file.',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError);
        return;
      }

      isLoading.value = true;
      Get.back();
      Get.snackbar('Info', 'Sedang mengirim tugas...',
          showProgressIndicator: true);

      final fields = {
        'tugas_sekolah_id': tugasId,
        'text_submission': jawaban,
      };

      final success = await _santriRepository.submitTugas(fields,
          file: selectedAssignmentFile.value);

      if (success) {
        Get.snackbar('Sukses', 'Tugas berhasil dikirim!',
            backgroundColor: Colors.green, colorText: Colors.white);
        clearAssignmentFile();
      } else {
        Get.snackbar('Gagal', 'Gagal mengirim tugas',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLaporanAbsensi() async {
    try {
      String? startDate;
      String? endDate;
      final now = DateTime.now();

      if (selectedAbsensiPeriod.value == 'Hari Ini') {
        startDate = now.toString().split(' ')[0];
        endDate = startDate;
      } else if (selectedAbsensiPeriod.value == 'Bulan Ini') {
        startDate = DateTime(now.year, now.month, 1).toString().split(' ')[0];
        endDate = DateTime(now.year, now.month + 1, 0).toString().split(' ')[0];
      }

      String? tingkatId;
      if (selectedTingkat.value == 'VII') {
        tingkatId = '1';
      } else if (selectedTingkat.value == 'VIII') {
        tingkatId = '2';
      } else if (selectedTingkat.value == 'IX') {
        tingkatId = '3';
      }

      final response = await _pimpinanRepository.getLaporanAbsensi(
          startDate: startDate, endDate: endDate, tingkatId: tingkatId);

      if (response['summary'] != null) {
        final s = response['summary'];
        laporanAbsensi.assignAll([
          {'label': 'Hadir', 'value': s['total_hadir'] ?? 0, 'color': 'green'},
          {'label': 'Izin', 'value': s['total_izin'] ?? 0, 'color': 'blue'},
          {'label': 'Sakit', 'value': s['total_sakit'] ?? 0, 'color': 'orange'},
          {'label': 'Alpa', 'value': s['total_alpha'] ?? 0, 'color': 'red'},
        ]);
        filteredLaporanAbsensi.assignAll(laporanAbsensi);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      await fetchLaporanAbsensi();

      // Tugas Sekolah (1.B)
      try {
        final data = await _santriRepository.getTugasSekolah();
        tugasList
            .assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      } catch (e) {
        // Fallback for demo if API fails
        tugasList.assignAll([
          {
            'id': '1',
            'judul': 'Latihan Fiqih Bab 1',
            'mapel': {'nama_mapel': 'Fiqih'},
            'deadline': '2025-01-20',
            'description': 'Kerjakan halaman 10-12 di buku paket.'
          }
        ]);
      }

      // Try fetching real Kurikulum data
      try {
        final response = await _pimpinanRepository.getKurikulum();
        if (response['data'] != null) {
          final List kurikulumData = response['data'] ?? [];
          dataKurikulum.assignAll(kurikulumData.map((item) {
            return {
              'mapel': item['name'] ?? 'Tanpa Nama',
              'pengajar': '-', // Not provided in basic list
              'kitab': '-',
              'tingkat': item['tingkat']?.toString() ?? '-',
              'type': item['category'] ?? 'Umum',
            };
          }).toList());
        }
      } catch (e) {
        // Fallback or Initial Mock Data
        dataKurikulum.assignAll([
          {
            'mapel': 'Fiqih Wadlih',
            'pengajar': 'Ustadz Mansur',
            'kitab': 'Al-Fiqh al-Manhaji',
            'tingkat': 'VII',
            'type': 'Diniyah'
          },
          {
            'mapel': 'Nahwu Shorof',
            'pengajar': 'Ustadzah Aminah',
            'kitab': 'Al-Jurumiyah',
            'tingkat': 'VIII',
            'type': 'Diniyah'
          },
          {
            'mapel': 'Bahasa Arab',
            'pengajar': 'Ustadz Fauzi',
            'kitab': 'Durusul Lughah',
            'tingkat': 'IX',
            'type': 'Umum'
          },
          {
            'mapel': 'Matematika',
            'pengajar': 'Ibu Ratna',
            'kitab': 'Buku Paket Kemendikbud',
            'tingkat': 'VII',
            'type': 'Umum'
          },
        ]);
      }

      // 1. Rekap Nilai
      try {
        final rawNilai = await _pimpinanRepository.getRekapNilai();
        if (rawNilai.isNotEmpty) {
          // Group by Kelas -> Tingkat
          final Map<String, List<double>> groupedScores = {};

          for (var item in rawNilai) {
            String kelasName = 'Umum';
            double score = 0;
            if (item is Map) {
              if (item['kelas'] != null && item['kelas'] is Map) {
                kelasName = item['kelas']['nama_kelas'] ?? 'Umum';
              }
              if (item['nilai_akhir'] != null) {
                score = double.tryParse(item['nilai_akhir'].toString()) ?? 0;
              } else if (item['nilai'] != null) {
                score = double.tryParse(item['nilai'].toString()) ?? 0;
              }
            }

            if (!groupedScores.containsKey(kelasName)) {
              groupedScores[kelasName] = [];
            }
            groupedScores[kelasName]!.add(score);
          }

          rekapNilai.assignAll(groupedScores.entries.map((entry) {
            final scores = entry.value;
            if (scores.isEmpty) {
              return {
                'tingkat': entry.key,
                'rata_rata': 0.0,
                'tertinggi': 0.0,
                'terendah': 0.0
              };
            }
            final avg = scores.reduce((a, b) => a + b) / scores.length;
            final max = scores.reduce((a, b) => a > b ? a : b);
            final min = scores.reduce((a, b) => a < b ? a : b);

            return {
              'tingkat': entry.key,
              'rata_rata': double.parse(avg.toStringAsFixed(1)),
              'tertinggi': max,
              'terendah': min
            };
          }).toList());
        }
      } catch (e) {
        rekapNilai.assignAll([
          {
            'tingkat': 'VII',
            'rata_rata': 84.5,
            'tertinggi': 98.0,
            'terendah': 65.0
          },
          {
            'tingkat': 'VIII',
            'rata_rata': 82.2,
            'tertinggi': 97.0,
            'terendah': 60.0
          },
          {
            'tingkat': 'IX',
            'rata_rata': 86.8,
            'tertinggi': 99.0,
            'terendah': 70.0
          },
        ]);
      }

      // 2. Agenda Kegiatan
      try {
        final response = await _pimpinanRepository.getAgenda();
        if (response['data'] != null) {
          final List list = response['data'] is List ? response['data'] : [];
          if (list.isNotEmpty) {
            agendaKegiatan.assignAll(list.map((item) {
              return {
                'time': item['jam_mulai'] ?? '00:00',
                'title': item['nama_aktivitas'] ?? 'Kegiatan',
                'location': item['tempat'] ?? '-',
                'category': item['tipe'] ?? 'Umum'
              };
            }).toList());
          } else {}
        }
      } catch (e) {
        agendaKegiatan.assignAll([
          {
            'time': '04:30',
            'title': 'Shalat Subuh',
            'location': 'Masjid',
            'category': 'Ibadah'
          },
          {
            'time': '08:00',
            'title': 'KBM Sekolah',
            'location': 'Gedung A',
            'category': 'Sekolah'
          },
          {
            'time': '20:00',
            'title': 'Mudarasah',
            'location': 'Kamar',
            'category': 'Pondok'
          },
        ]);
      }

      // 3. Progress Tahfidz (Using latest 5 entries as progress log instead of group summary)
      try {
        final response = await _pimpinanRepository.getTahfidz();
        List rawTahfidz = [];
        if (response['data'] != null) {
          if (response['data'] is List) {
            rawTahfidz = response['data'];
          } else if (response['data']['data'] is List) {
            rawTahfidz = response['data']['data'];
          }
        }

        if (rawTahfidz.isNotEmpty) {
          progressTahfidz.assignAll(rawTahfidz.take(5).map((item) {
            return {
              'nama': item['santri']?['details']?['full_name'] ?? 'Santri',
              'target': 30,
              // Using Juz or Halaman as proxy for 'achieved' visualization
              'achieved':
                  double.tryParse(item['juz']?.toString() ?? '1') ?? 1.0,
              'percent': 0.5, // Arbitrary for visualization
              'type': 'Setoran Hafalan'
            };
          }).toList());
        }
      } catch (e) {
        progressTahfidz.assignAll([
          {
            'nama': 'Kelompok Abu Bakar',
            'target': 30,
            'achieved': 12.5,
            'percent': 0.42,
            'type': 'Pemula'
          },
          {
            'nama': 'Kelompok Umar',
            'target': 30,
            'achieved': 18.2,
            'percent': 0.61,
            'type': 'Menengah'
          },
        ]);
      }

      // 4. Laporan Absensi
      try {
        final response = await _pimpinanRepository.getLaporanAbsensi();
        if (response['summary'] != null) {
          final s = response['summary'];
          laporanAbsensi.assignAll([
            {
              'label': 'Hadir',
              'value': s['total_hadir'] ?? 0,
              'color': 'green'
            },
            {'label': 'Izin', 'value': s['total_izin'] ?? 0, 'color': 'blue'},
            {
              'label': 'Sakit',
              'value': s['total_sakit'] ?? 0,
              'color': 'orange'
            },
            {'label': 'Alpa', 'value': s['total_alpha'] ?? 0, 'color': 'red'},
          ]);
        }
      } catch (e) {
        laporanAbsensi.assignAll([
          {'label': 'Hadir', 'value': 280, 'color': 'green'},
          {'label': 'Izin', 'value': 12, 'color': 'blue'},
          {'label': 'Sakit', 'value': 5, 'color': 'orange'},
          {'label': 'Alpa', 'value': 2, 'color': 'red'},
        ]);
      }

      _applyInitialFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyInitialFilters() {
    filteredRekapNilai.assignAll(rekapNilai);
    filteredAgenda.assignAll(agendaKegiatan);
    filteredTahfidz.assignAll(progressTahfidz);
    filteredLaporanAbsensi.assignAll(laporanAbsensi);
    filteredKurikulum.assignAll(dataKurikulum);
    filteredTugas.assignAll(tugasList);
  }

  void applyFilters() {
    // Reload Absensi if filters relevant to it change (Index 3)
    if (selectedIndex.value == 3) {
      fetchLaporanAbsensi();
    }

    // Filter Rekap Nilai
    if (selectedTingkat.value == 'Semua') {
      filteredRekapNilai.assignAll(rekapNilai);
    } else {
      filteredRekapNilai.assignAll(rekapNilai
          .where((item) => item['tingkat'] == selectedTingkat.value)
          .toList());
    }

    // Filter Agenda
    if (selectedCategory.value == 'Semua') {
      filteredAgenda.assignAll(agendaKegiatan);
    } else {
      filteredAgenda.assignAll(agendaKegiatan
          .where((item) => item['category'] == selectedCategory.value)
          .toList());
    }

    // Filter Tahfidz
    if (selectedTahfidzGroup.value == 'Semua') {
      filteredTahfidz.assignAll(progressTahfidz);
    } else {
      filteredTahfidz.assignAll(progressTahfidz
          .where((item) => item['type'] == selectedTahfidzGroup.value)
          .toList());
    }

    // Filter Kurikulum
    var tempKurikulum = dataKurikulum.toList();

    if (selectedTingkat.value != 'Semua') {
      tempKurikulum = tempKurikulum
          .where((item) => item['tingkat'] == selectedTingkat.value)
          .toList();
    }

    if (selectedCurriculumType.value != 'Semua') {
      tempKurikulum = tempKurikulum
          .where((item) => item['type'] == selectedCurriculumType.value)
          .toList();
    }

    filteredKurikulum.assignAll(tempKurikulum);

    // Filter Tugas (Currently no filter impl, just copy)
    filteredTugas.assignAll(tugasList);
  }

  void resetFilters() {
    selectedTingkat.value = 'Semua';
    selectedSemester.value = 'Ganjil 2025/2026';
    applyFilters();
  }
}
