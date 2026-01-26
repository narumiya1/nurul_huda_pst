import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
      if (jawaban.isEmpty && selectedAssignmentFiles.isEmpty) {
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

      // Handle multiple files if repository supports it, or zip them, or send first one for now if repo not updated
      // Assuming we update repo to support 'files' list
      final success = await _santriRepository.submitTugas(fields,
          files: selectedAssignmentFiles); // Updated argument name

      if (success) {
        Get.snackbar('Sukses', 'Tugas berhasil dikirim!',
            backgroundColor: Colors.green, colorText: Colors.white);
        clearAssignmentFiles();

        // Update local state to reflect submission
        final index = tugasList.indexWhere((t) => t['id'] == tugasId);
        if (index != -1) {
          final updatedTask = Map<String, dynamic>.from(tugasList[index]);
          updatedTask['status'] = 'Selesai';
          updatedTask['is_submitted'] = true;
          tugasList[index] = updatedTask;

          // Also update filtered list if necessary, but filtered is usually bound or re-filtered
          applyFilters();
        }
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

      // Fetch all data in parallel for better performance
      await Future.wait([
        _fetchTugasSekolah(),
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

  Future<void> _fetchTugasSekolah() async {
    try {
      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        final data = await _santriRepository.getTugasSekolah();
        tugasList.assignAll(data.map((e) {
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
            'judul': map['judul'] ?? 'Tugas',
            'mapel': {'nama_mapel': mapelName},
            'deadline': map['deadline']?.toString().split(' ')[0] ?? '-',
            'status': isSubmitted ? 'Selesai' : 'Pending',
            'description': map['deskripsi'] ?? map['description'] ?? '',
            'is_submitted': isSubmitted,
            'submission_id': map['my_submission']?['id'],
            'file_path': map['file_path'] // Add this line
          };
        }).toList());
      } else {
        // Fallback or empty for other roles for now, or implement pimpinan view
        tugasList.clear();
      }
    } catch (e) {
      debugPrint('Error fetching tugas sekolah: $e');
      // Keep fallback just in case
      tugasList.assignAll([
        {
          'id': '1',
          'judul': 'Contoh Tugas (Offline)',
          'mapel': {'nama_mapel': 'Bahasa Indonesia'},
          'deadline': '2026-01-30',
          'status': 'Pending',
          'description': 'Silakan hubungkan internet.'
        }
      ]);
    }
  }

  Future<void> _fetchKurikulum() async {
    try {
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
      // Fallback only if error (keep existing fallback logic or clear)
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
      debugPrint('Role processed: $role, Selected: ${selectedSemester.value}');

      if (role == 'santri' || role == 'siswa') {
        final rawNilai = await _santriRepository.getNilaiSekolah(
            semester: semester, tahun: tahun);
        debugPrint('Fetched Nilai count for student: ${rawNilai.length}');
        if (rawNilai.isNotEmpty) {
          _processMappedNilai(rawNilai);
        } else {
          debugPrint('Filtered nilia empty, trying fetch without filters...');
          final allNilai = await _santriRepository.getNilaiSekolah();
          if (allNilai.isNotEmpty) {
            _processMappedNilai(allNilai);
          } else {
            rekapNilai.clear();
            groupedRekapNilai.clear();
          }
        }
      } else {
        // ... rest of pimpinan logic remains same
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
          },
          {
            'is_personal': true,
            'mapel': 'Bahasa Arab',
            'nilai': 90,
            'tingkat': 'VII',
            'semester': 'Ganjil',
            'tahun': '2025/2026',
            'jenis': 'UAS',
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

    // Grouping by mapel
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
    if (query.length < 3) {
      searchSiswaResults.clear();
      return;
    }

    try {
      isSearchingSiswa.value = true;
      // Search for student first
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
  }

  Future<void> _fetchTahfidz() async {
    try {
      final role = userRole.value.toLowerCase().trim();
      if (role == 'santri' || role == 'siswa') {
        final progress = await _santriRepository.getMyTahfidz();
        if (progress.isNotEmpty) {
          final List<Map<String, dynamic>> items = [];

          // Add overall progress item
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

          // Add some recent history as items
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
        {
          'nama': 'Kelompok Umar',
          'target': 30,
          'achieved': 18.2,
          'percent': 0.61,
          'type': 'Menengah'
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
        {'label': 'Izin', 'value': 12, 'color': 'blue'},
        {'label': 'Sakit', 'value': 5, 'color': 'orange'},
        {'label': 'Alpa', 'value': 2, 'color': 'red'},
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
    // Reload Absensi if filters relevant to it change (Index 3)
    if (selectedIndex.value == 3) {
      await fetchLaporanAbsensi();
    }

    // Reload Rekap Nilai if filters relevant to it change (Index 0)
    if (selectedIndex.value == 0) {
      await _fetchRekapNilai();
    }

    // Filter Rekap Nilai
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

    // Filter Tugas
    if (selectedTugasStatus.value == 'Semua') {
      filteredTugas.assignAll(tugasList);
    } else {
      filteredTugas.assignAll(tugasList
          .where((item) => item['status'] == selectedTugasStatus.value)
          .toList());
    }
  }

  void resetFilters() {
    selectedTingkat.value = 'Semua';
    selectedSemester.value = 'Ganjil 2025/2026';
    selectedTugasStatus.value = 'Semua';
    applyFilters();
  }
}
