import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:get/get.dart';
import '../../../helpers/file_helper.dart';
import '../../../helpers/local_storage.dart';

class AkademikPondokController extends GetxController {
  final PimpinanRepository _pimpinanRepository;
  final SantriRepository _santriRepository;
  final isLoading = false.obs;
  final userRole = 'netizen'.obs;
  final menuType = 'ALL'.obs; // SCHOOL, PONDOK, ALL

  AkademikPondokController({
    required PimpinanRepository pimpinanRepository,
    SantriRepository? santriRepository,
  })  : _pimpinanRepository = pimpinanRepository,
        _santriRepository = santriRepository ?? SantriRepository();

  // Data for Pimpinan
  final rekapNilai = <Map<String, dynamic>>[].obs;
  final agendaKegiatan = <Map<String, dynamic>>[].obs;
  final progressTahfidz = <Map<String, dynamic>>[].obs;
  final laporanAbsensi = <Map<String, dynamic>>[].obs;
  final dataKurikulum = <Map<String, dynamic>>[].obs;
  final tugasList = <Map<String, dynamic>>[].obs;

  // Filtered Data
  final filteredRekapNilai = <Map<String, dynamic>>[].obs;
  final groupedRekapNilai = <String, List<Map<String, dynamic>>>{}.obs;
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
  final selectedTugasStatus = 'Semua'.obs;

  final selectedIndex = (-1).obs; // -1 for main grid menu
  final searchSiswaQuery = ''.obs;
  final searchSiswaResults = <Map<String, dynamic>>[].obs;
  final isSearchingSiswa = false.obs;
  final selectedSiswaForDetail = Rxn<Map<String, dynamic>>();
  final siswaNilaiDetail = <Map<String, dynamic>>[].obs;

  // Assignment Logic
  final selectedAssignmentFiles = <File>[].obs;
  final submissionsList = <Map<String, dynamic>>[].obs;
  final selectedTugasId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map && Get.arguments['type'] != null) {
      menuType.value = Get.arguments['type'];
    }
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
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
        allowMultiple: true,
      );

      if (result != null) {
        final newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
        selectedAssignmentFiles.addAll(newFiles);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil file: $e');
    }
  }

  void clearAssignmentFiles() {
    selectedAssignmentFiles.clear();
  }

  void removeAssignmentFile(int index) {
    if (index >= 0 && index < selectedAssignmentFiles.length) {
      selectedAssignmentFiles.removeAt(index);
    }
  }

  Future<void> submitTugas(String tugasId, String jawaban) async {
    try {
      if (tugasId.isEmpty) return;

      if (jawaban.isEmpty && selectedAssignmentFiles.isEmpty) {
        Get.snackbar('Peringatan', 'Mohon isi jawaban atau upload file.',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError);
        return;
      }

      isLoading.value = true;

      final fields = {
        'tugas_sekolah_id': tugasId,
        'text_submission': jawaban,
      };

      // Check if it's school or pondok task
      final task = tugasList.firstWhereOrNull((t) => t['id'] == tugasId);
      final isPondok = task?['source'] == 'Pondok';

      final bool success;
      if (isPondok) {
        success = await _santriRepository.submitTugasPondok({
          'tugas_santri_id': tugasId,
          'jawaban_teks': jawaban,
        });
      } else {
        success = await _santriRepository.submitTugas(
          fields,
          files: selectedAssignmentFiles,
        );
      }

      if (success) {
        Get.back(); // close bottomsheet
        Get.snackbar(
          'Sukses',
          'Tugas berhasil dikirim.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh tugas list
        await _fetchTugas();
      } else {
        Get.snackbar('Gagal', 'Gagal mengirim tugas',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim tugas: $e');
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

      // Fetch all data in parallel for better performance
      await Future.wait([
        _fetchTugas(),
        _fetchKurikulum(),
        _fetchRekapNilai(),
        _fetchAgenda(),
        _fetchTahfidz(),
        _fetchLaporanAbsensiData(),
      ]);

      _applyInitialFilters();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchTugas() async {
    try {
      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        // Fetch both in parallel
        final List<Future<dynamic>> tugasFutures = [
          _santriRepository.getTugasSekolah(),
          _santriRepository.getTugasPondok(),
        ];
        final results = await Future.wait(tugasFutures);

        final schoolTasks = results[0];
        final pondokTasks = results[1];

        final List<Map<String, dynamic>> combined = [];

        // Map School Tasks
        combined.addAll(schoolTasks.map((e) {
          final map = e as Map<String, dynamic>;
          String mapelName = 'Mapel Lain';
          if (map['mapel'] != null && map['mapel'] is Map) {
            mapelName = map['mapel']['nama'] ??
                map['mapel']['nama_mapel'] ??
                'Mapel Lain';
          }
          final isSubmitted =
              map['my_submission'] != null || (map['is_submitted'] == true);
          return {
            'id': map['id']?.toString(),
            'judul': map['judul'] ?? 'Tugas Sekolah',
            'mapel': {'nama_mapel': mapelName},
            'deadline': map['deadline']?.toString().split(' ')[0] ?? '-',
            'status': isSubmitted ? 'Selesai' : 'Pending',
            'description': map['deskripsi'] ?? map['description'] ?? '',
            'is_submitted': isSubmitted,
            'source': 'Sekolah',
            'submission_id': map['my_submission']?['id'],
            'file_path': map['file_path']
          };
        }));

        // Map Pondok Tasks
        combined.addAll(pondokTasks.map((e) {
          final map = e as Map<String, dynamic>;
          String mapelName = 'Kegiatan Pondok';
          if (map['mapel'] != null && map['mapel'] is Map) {
            mapelName = map['mapel']['nama'] ??
                map['mapel']['nama_mapel'] ??
                'Kegiatan Pondok';
          }

          final isSubmitted =
              map['status'] == 'Selesai' || map['is_submitted'] == true;

          return {
            'id': map['id']?.toString(),
            'judul': map['judul'] ?? 'Tugas Pondok',
            'mapel': {'nama_mapel': mapelName},
            'deadline': map['deadline']?.toString().split(' ')[0] ?? '-',
            'status': map['status'] ?? (isSubmitted ? 'Selesai' : 'Pending'),
            'description': map['deskripsi'] ?? map['description'] ?? '',
            'is_submitted': isSubmitted,
            'source': 'Pondok',
            'submission_id': map['submissions'] is List &&
                    (map['submissions'] as List).isNotEmpty
                ? map['submissions'][0]['id']
                : null,
            'file_path': map['file_path']
          };
        }));

        tugasList.assignAll(combined);
      } else {
        tugasList.clear();
      }
    } catch (e) {
      debugPrint('Error fetching combined tugas: $e');
    }
  }

  Future<void> _fetchKurikulum() async {
    try {
      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        final data = await _santriRepository.getMateriList();
        dataKurikulum.assignAll(data.map((item) {
          final mapel = item['mapel'] ?? {};
          final kurikulum = item['kurikulum'] ?? {};

          return {
            'mapel': mapel['nama'] ?? 'Tanpa Nama',
            'pengajar':
                mapel['guru'] != null ? (mapel['guru']['nama'] ?? '-') : '-',
            'kitab': kurikulum['name'] ?? '-',
            'tingkat': kurikulum['tingkat']?.toString() ?? '-',
            'type': kurikulum['category'] ?? 'Umum',
            'files': item['files'] ?? []
          };
        }).toList());
        return;
      }

      final response = await _pimpinanRepository.getKurikulum();
      if (response['data'] != null) {
        final List kurikulumData = response['data'] ?? [];
        dataKurikulum.assignAll(kurikulumData.map((item) {
          return {
            'mapel': item['name'] ?? 'Tanpa Nama',
            'pengajar': '-',
            'kitab': '-',
            'tingkat': item['tingkat']?.toString() ?? '-',
            'type': item['category'] ?? 'Umum',
          };
        }).toList());
      }
    } catch (e) {
      debugPrint('Error fetching kurikulum: $e');
      if (dataKurikulum.isEmpty) {
        dataKurikulum.assignAll([
          {
            'mapel': 'Contoh Materi',
            'pengajar': '-',
            'kitab': 'Silakan muat ulang',
            'tingkat': '-',
            'type': 'Info'
          }
        ]);
      }
    }
  }

  Future<void> _fetchRekapNilai() async {
    try {
      final semesterParts = selectedSemester.value.split(' ');
      final semester = semesterParts.isNotEmpty ? semesterParts[0] : null;
      final tahun = semesterParts.length > 1 ? semesterParts[1] : null;

      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        final rawNilai = await _santriRepository.getNilaiSekolah(
            semester: semester, tahun: tahun);
        if (rawNilai.isNotEmpty) {
          _processMappedNilai(rawNilai);
        } else {
          final allNilai = await _santriRepository.getNilaiSekolah();
          if (allNilai.isNotEmpty) {
            _processMappedNilai(allNilai);
          } else {
            rekapNilai.clear();
            groupedRekapNilai.clear();
          }
        }
      } else {
        final rawNilai = await _pimpinanRepository.getRekapNilai();
        if (rawNilai.isNotEmpty) {
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
      }
      filteredRekapNilai.assignAll(rekapNilai);
    } catch (e) {
      debugPrint('Error fetching rekap nilai: $e');
      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        final dummy = [
          {
            'is_personal': true,
            'mapel': 'Fiqih',
            'nilai': 85,
            'tingkat': 'VII',
            'semester': 'Ganjil',
            'tahun': '2025/2026',
            'jenis': 'UTS',
          }
        ];
        _processMappedNilai(dummy);
      } else {
        rekapNilai.assignAll([
          {
            'tingkat': 'VII',
            'rata_rata': 84.5,
            'tertinggi': 98.0,
            'terendah': 65.0
          },
        ]);
        groupedRekapNilai.clear();
      }
      filteredRekapNilai.assignAll(rekapNilai);
    }
  }

  void _processMappedNilai(List<dynamic> rawNilai) {
    final List<Map<String, dynamic>> mapped = rawNilai.map((item) {
      String mapelName = '-';
      if (item['mapel'] != null) {
        mapelName = item['mapel']['nama'] ?? '-';
      }
      return {
        'is_personal': true,
        'mapel': mapelName,
        'nilai': item['nilai'] ?? '0',
        'tingkat': item['kelas'] != null
            ? (item['kelas']['nama_kelas'] ?? '-')
            : (item['sekolah_kelas_id']?.toString() ?? '-'),
        'semester': (item['semester']?.toString() ?? '-').capitalizeFirst,
        'tahun': item['tahun_ajaran'] ?? '-',
        'jenis': item['jenis_penilaian'] ?? '-',
      };
    }).toList();
    rekapNilai.assignAll(mapped);

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in mapped) {
      final mapel = item['mapel'] as String;
      if (!grouped.containsKey(mapel)) {
        grouped[mapel] = [];
      }
      grouped[mapel]!.add(item);
    }
    groupedRekapNilai.assignAll(grouped);
  }

  Future<void> searchSiswaGrades(String query) async {
    searchSiswaQuery.value = query;
    if (query.length < 3) {
      searchSiswaResults.clear();
      return;
    }
    try {
      isSearchingSiswa.value = true;
      final students = await _pimpinanRepository.findSiswa(query);
      searchSiswaResults
          .assignAll(students.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      debugPrint('Error searching siswa: $e');
    } finally {
      isSearchingSiswa.value = false;
    }
  }

  Future<void> fetchSiswaDetailNilai(int siswaId) async {
    try {
      isLoading.value = true;
      final semesterParts = selectedSemester.value.split(' ');
      final semester = semesterParts.isNotEmpty ? semesterParts[0] : null;
      final tahun = semesterParts.length > 1 ? semesterParts[1] : null;

      final response = await _santriRepository.getNilaiSekolah(
        siswaId: siswaId,
        semester: semester?.toLowerCase(),
        tahunAjaran: tahun,
      );

      siswaNilaiDetail.assignAll(response.map((item) {
        String mapelName = '-';
        if (item['mapel'] != null) {
          mapelName = item['mapel']['nama'] ?? '-';
        }
        return {
          'mapel': mapelName,
          'nilai': item['nilai'],
          'jenis': item['jenis_penilaian'] ?? '-',
          'semester': item['semester'] ?? '-',
          'tahun': item['tahun_ajaran'] ?? '-',
        };
      }).toList());
    } catch (e) {
      debugPrint('Error fetching siswa detail nilai: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAgenda() async {
    try {
      final response = await _pimpinanRepository.getAgenda();
      if (response['data'] != null) {
        final List list = response['data'] is List ? response['data'] : [];
        if (list.isNotEmpty) {
          agendaKegiatan.assignAll(list.map((item) {
            String category = 'Umum';
            final tipe = item['tipe']?.toString() ?? '';
            if (tipe == 'harian' || tipe == 'mingguan') category = 'Pondok';
            return {
              'time': item['jam_mulai'] ?? '00:00',
              'title': item['judul'] ?? 'Kegiatan',
              'location': item['lokasi'] ?? '-',
              'category': category,
              'description': item['deskripsi'] ?? '',
              'day': item['hari'] ?? '',
            };
          }).toList());
        }
      }
    } catch (e) {
      agendaKegiatan.assignAll([
        {
          'time': '04:30',
          'title': 'Shalat Subuh',
          'location': 'Masjid',
          'category': 'Ibadah'
        },
      ]);
    }
  }

  Future<void> _fetchTahfidz() async {
    try {
      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        final progress = await _santriRepository.getMyTahfidz();
        if (progress.isNotEmpty) {
          final List<Map<String, dynamic>> items = [];
          items.add({
            'nama': 'Total Hafalan',
            'target': 30,
            'achieved':
                double.tryParse(progress['total_juz']?.toString() ?? '0') ??
                    0.0,
            'percent':
                (double.tryParse(progress['pencapaian']?.toString() ?? '0') ??
                        0.0) /
                    100,
            'type': 'Progress Keseluruhan'
          });
          final riwayat = progress['riwayat'] as List?;
          if (riwayat != null && riwayat.isNotEmpty) {
            for (var item in riwayat.take(4)) {
              items.add({
                'nama': 'Surah ${item['surah']}',
                'target': 1,
                'achieved': 1,
                'percent': 1.0,
                'type': 'Setoran Baru: ${item['tanggal']}'
              });
            }
          }
          progressTahfidz.assignAll(items);
          return;
        }
      }

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
            'achieved': double.tryParse(item['juz']?.toString() ?? '1') ?? 1.0,
            'percent': 0.5,
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
      ]);
    }
  }

  Future<void> _fetchLaporanAbsensiData() async {
    try {
      final response = await _pimpinanRepository.getLaporanAbsensi();
      if (response['summary'] != null) {
        final s = response['summary'];
        laporanAbsensi.assignAll([
          {'label': 'Hadir', 'value': s['total_hadir'] ?? 0, 'color': 'green'},
          {'label': 'Izin', 'value': s['total_izin'] ?? 0, 'color': 'blue'},
          {'label': 'Sakit', 'value': s['total_sakit'] ?? 0, 'color': 'orange'},
          {'label': 'Alpa', 'value': s['total_alpha'] ?? 0, 'color': 'red'},
        ]);
      }
    } catch (e) {
      laporanAbsensi.assignAll([
        {'label': 'Hadir', 'value': 280, 'color': 'green'},
      ]);
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

  Future<void> applyFilters() async {
    if (selectedIndex.value == 3) await fetchLaporanAbsensi();
    if (selectedIndex.value == 0) await _fetchRekapNilai();

    final role = userRole.value.toLowerCase().trim();
    if (role == 'santri' || role == 'siswa') {
      filteredRekapNilai.assignAll(rekapNilai);
    } else {
      if (selectedTingkat.value == 'Semua') {
        filteredRekapNilai.assignAll(rekapNilai);
      } else {
        filteredRekapNilai.assignAll(rekapNilai
            .where((item) => item['tingkat'] == selectedTingkat.value)
            .toList());
      }
    }

    if (selectedCategory.value == 'Semua') {
      filteredAgenda.assignAll(agendaKegiatan);
    } else {
      filteredAgenda.assignAll(agendaKegiatan
          .where((item) => item['category'] == selectedCategory.value)
          .toList());
    }

    if (selectedTahfidzGroup.value == 'Semua') {
      filteredTahfidz.assignAll(progressTahfidz);
    } else {
      filteredTahfidz.assignAll(progressTahfidz
          .where((item) => item['type'] == selectedTahfidzGroup.value)
          .toList());
    }

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

    if (selectedTugasStatus.value == 'Semua') {
      filteredTugas.assignAll(tugasList);
    } else {
      filteredTugas.assignAll(tugasList
          .where((item) => item['status'] == selectedTugasStatus.value)
          .toList());
    }

    // Filter by menuType (SCHOOL / PONDOK)
    if (menuType.value == 'SCHOOL') {
      filteredTugas.assignAll(
          filteredTugas.where((item) => item['source'] == 'Sekolah').toList());
    } else if (menuType.value == 'PONDOK') {
      filteredTugas.assignAll(
          filteredTugas.where((item) => item['source'] == 'Pondok').toList());
    }
  }

  void resetFilters() {
    selectedTingkat.value = 'Semua';
    selectedSemester.value = 'Ganjil 2025/2026';
    selectedTugasStatus.value = 'Semua';
    applyFilters();
  }

  Future<void> downloadFile(String path, {String? filename}) async {
    await FileHelper.downloadAndOpenFile(path, filename: filename);
  }

  Future<void> fetchSubmissions(String tugasId) async {
    try {
      selectedTugasId.value = tugasId;
      isLoading.value = true;
      final response = await _santriRepository.getTugasSubmissions(tugasId);
      submissionsList
          .assignAll(response.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      debugPrint('Error fetching submissions: $e');
      Get.snackbar('Error', 'Gagal memuat daftar jawaban');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitGrade(
      String submissionId, double grade, String? notes) async {
    try {
      isLoading.value = true;
      final success = await _santriRepository.gradeTugasSubmission(
          submissionId, grade, notes);
      if (success) {
        Get.back(); // close grading modal
        Get.snackbar('Sukses', 'Penilaian berhasil disimpan',
            backgroundColor: Colors.green, colorText: Colors.white);
        if (selectedTugasId.value.isNotEmpty) {
          await fetchSubmissions(selectedTugasId.value);
        }
      } else {
        Get.snackbar('Gagal', 'Gagal menyimpan penilaian');
      }
    } catch (e) {
      debugPrint('Error grading: $e');
      Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan nilai');
    } finally {
      isLoading.value = false;
    }
  }
}
