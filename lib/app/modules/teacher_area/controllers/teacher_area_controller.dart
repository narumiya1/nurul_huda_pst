import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/guru/guru_api.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class TeacherAreaController extends GetxController {
  final GuruRepository _guruRepository = GuruRepository(GuruApi());
  final SantriRepository _santriRepository = SantriRepository();
  final ApiHelper _apiHelper = ApiHelper();

  final isLoading = false.obs;
  final kelasList = <Map<String, dynamic>>[].obs;
  final siswaList = <Map<String, dynamic>>[].obs;
  final selectedKelas = Rxn<Map<String, dynamic>>();
  final attendanceData = <int, String>{}.obs; // siswa_id -> status
  final stats = <String, dynamic>{}.obs; // Dashboard stats
  final jadwalHariIni = <Map<String, dynamic>>[].obs; // Today's schedule
  final userDetails = Rxn<Map<String, dynamic>>(); // User profile for welcome

  // Input Nilai
  final mapelList = <Map<String, dynamic>>[].obs;
  final selectedMapel = Rxn<Map<String, dynamic>>();
  final selectedSemesterNilai = 'ganjil'.obs;
  final selectedTahunAjaran = '2025/2026'.obs;
  final selectedJenisPenilaian = 'Tugas'.obs;
  final nilaiData =
      <int, TextEditingController>{}.obs; // siswa_id -> controller
  final isLoadingNilai = false.obs;
  final siswaNilaiList = <Map<String, dynamic>>[].obs;

  // Tahfidz
  final santriList = <dynamic>[].obs;
  final selectedSantriId = Rxn<int>();
  final selectedKelasTahfidz = Rxn<Map<String, dynamic>>();
  final isLoadingSantri = false.obs;
  final searchController = TextEditingController();
  final selectedSantriName = Rxn<String>(); // Handle name display
  Timer? _debounce;

  // Hafalan List (recent submissions)
  final hafalanList = <dynamic>[].obs;
  final isLoadingHafalan = false.obs;
  final selectedKelasRiwayat =
      Rxn<Map<String, dynamic>>(); // Filter for riwayat

  // Form fields for Tahfidz
  final surahController = TextEditingController();
  final ayatController = TextEditingController();
  final catatanController = TextEditingController();
  final selectedJuz = Rxn<int>();
  final selectedKualitas = 'lancar'.obs;

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    fetchMapelList();
    fetchTugasSantriList();
    fetchTugasSantriDropdowns();
  }

  Future<void> loadDashboard() async {
    userDetails.value = LocalStorage.getUser();
    fetchKelasList();
    // fetchSantriList(); // Removed to enforce class filter first
    fetchHafalanList(); // Load recent tahfidz submissions
    fetchJadwalHariIni();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final data = await _guruRepository.getDashboardStats();
      if (data != null) {
        stats.value = Map<String, dynamic>.from(data);
      }
    } catch (e) {
      // Ignore
    }
  }

  // Jadwal Full
  final groupedJadwal = <String, List<dynamic>>{}.obs;
  final isLoadingJadwal = false.obs;
  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Ahad'
  ];

  Future<void> fetchJadwalHariIni() async {
    // Keep for legacy compatibility if dashboard still uses it, but we can also populate it from full schedule
    await fetchFullSchedule();
  }

  Future<void> fetchFullSchedule() async {
    try {
      isLoadingJadwal.value = true;
      final data = await _guruRepository.getJadwalPelajaran();
      _groupJadwal(data);

      // Also update hari ini from the full schedule to be real
      // (Optional logic if we still use 'jadwalHariIni' for a widget somewhere)
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal: $e');
    } finally {
      isLoadingJadwal.value = false;
    }
  }

  void _groupJadwal(List<dynamic> list) {
    final Map<String, List<dynamic>> grouped = {};
    for (var day in days) {
      grouped[day] = [];
    }

    for (var item in list) {
      final hari = item['hari'] as String?;
      if (hari != null) {
        String cleanHari =
            days.firstWhere((d) => hari.contains(d), orElse: () => '');
        if (cleanHari.isNotEmpty) {
          grouped[cleanHari]?.add(item);
        }
      }
    }
    groupedJadwal.value = grouped;
  }

  @override
  void onClose() {
    surahController.dispose();
    ayatController.dispose();
    catatanController.dispose();
    searchController.dispose();
    tugasJudulController.dispose();
    tugasDeskripsiController.dispose();
    nilaiTugasController.dispose();
    catatanGuruController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSantriList(query: query);
    });
  }

  Future<void> fetchKelasList() async {
    try {
      isLoading.value = true;
      debugPrint('DEBUG: Fetching kelas list...');
      final data = await _guruRepository.getMyKelas();
      debugPrint('DEBUG: Kelas list response: $data');

      if (data.isEmpty) {
        debugPrint('DEBUG: Kelas list is empty, using fallback mock');
        kelasList.assignAll([
          {
            'id': 1,
            'nama_kelas': 'VII A (Demo)',
            'tingkat': {'nama_tingkat': 'VII'}
          },
          {
            'id': 2,
            'nama_kelas': 'VIII B (Demo)',
            'tingkat': {'nama_tingkat': 'VIII'}
          },
        ]);
      } else {
        // Handle nested 'kelas' object from API
        final normalized = data.map((e) {
          final map = e as Map<String, dynamic>;
          if (map['kelas'] != null && map['kelas'] is Map) {
            return map['kelas'] as Map<String, dynamic>;
          }
          return map;
        }).toList();
        debugPrint('DEBUG: Normalized kelas list: $normalized');
        kelasList.assignAll(normalized);
      }
    } catch (e) {
      debugPrint('DEBUG: Error fetching kelas list: $e');
      // Fallback
      kelasList.clear();
      // Ensure fallback shows even on error for debugging
      kelasList.assignAll([
        {
          'id': 1,
          'nama_kelas': 'VII A (Fallback)',
          'tingkat': {'nama_tingkat': 'VII'}
        },
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSiswaByKelas(int kelasId, {bool refresh = true}) async {
    try {
      if (refresh) {
        isLoading.value = true;
        currentPage.value = 1;
        lastPage.value = 1;
        siswaList.clear();
        attendanceData.clear();
      } else {
        isLoadingMore.value = true;
      }

      debugPrint(
          'DEBUG: Fetching siswa for kelasId: $kelasId, Page: ${currentPage.value}');
      final uri = ApiHelper.buildUri(
        endpoint: 'siswa',
        params: {
          'kelas_id': kelasId.toString(),
          'per_page':
              '5', // Reduced to 5 to avoid truncated response on emulator
          'page': currentPage.value.toString(),
        },
      );
      debugPrint('DEBUG: URI: $uri');

      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      debugPrint('DEBUG: Response received (truncated)');

      if (response != null && response['data'] != null) {
        // Handle pagination meta
        if (response['meta'] != null) {
          currentPage.value = response['meta']['current_page'];
          lastPage.value = response['meta']['last_page'];
        }

        final List rawList = response['data'] is List
            ? response['data']
            : (response['data']['data'] ?? []);

        debugPrint('DEBUG: Raw List length: ${rawList.length}');

        List<Map<String, dynamic>> mappedList = [];

        if (rawList.isEmpty && refresh) {
          debugPrint('DEBUG: List empty, using fallback demo data');
          // Demo data only on refresh/first load if empty
          mappedList = [
            {
              'id': 101,
              'details': {'full_name': 'Siswa Demo 1'},
              'username': 'siswa1'
            },
            {
              'id': 102,
              'details': {'full_name': 'Siswa Demo 2'},
              'username': 'siswa2'
            },
            {
              'id': 103,
              'details': {'full_name': 'Siswa Demo 3'},
              'username': 'siswa3'
            },
          ];
        } else {
          mappedList = rawList.map((e) => e as Map<String, dynamic>).toList();
        }

        if (refresh) {
          siswaList.assignAll(mappedList);

          // FETCH EXISTING ATTENDANCE
          try {
            final existingAttendance = await _guruRepository.getAbsensi(
              sekolahId: selectedKelas.value?['sekolah_id'] ?? 1,
              kelasId: kelasId,
              tanggal: DateTime.now().toString().split(' ')[0],
            );

            // Map existing attendance to local state
            for (var item in existingAttendance) {
              final sId = item['siswa_id']; // Usually this is an int
              final status = item['status'];
              if (sId != null && status != null) {
                attendanceData[sId] = status;
              }
            }
          } catch (e) {
            debugPrint('Error fetching existing attendance: $e');
          }
        } else {
          siswaList.addAll(mappedList);
        }

        // Initialize 'hadir' only for new items that don't have status yet
        for (var siswa in siswaList) {
          if (!attendanceData.containsKey(siswa['id'])) {
            attendanceData[siswa['id']] = 'hadir';
          }
        }
      } else {
        debugPrint('DEBUG: Response data is null');
      }
    } catch (e) {
      debugPrint('DEBUG: Error fetching siswa: $e');
      Get.snackbar('Error', 'Gagal memuat daftar siswa: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMoreSiswa() {
    if (currentPage.value < lastPage.value &&
        !isLoading.value &&
        !isLoadingMore.value) {
      currentPage.value++;
      if (selectedKelas.value != null) {
        fetchSiswaByKelas(selectedKelas.value!['id'], refresh: false);
      }
    }
  }

  void updateAttendance(int siswaId, String status) {
    attendanceData[siswaId] = status;
  }

  Future<void> submitAttendance() async {
    if (selectedKelas.value == null) {
      Get.snackbar('Peringatan', 'Pilih kelas terlebih dahulu');
      return;
    }

    try {
      isLoading.value = true;

      final students = attendanceData.entries
          .map((e) => {
                'siswa_id': e.key,
                'status': e.value,
              })
          .toList();

      final data = {
        'sekolah_id': selectedKelas.value!['sekolah_id'] ?? 1,
        'kelas_id': selectedKelas.value!['id'],
        'tanggal': DateTime.now().toString().split(' ')[0],
        'students': students,
      };

      final success = await _guruRepository.createAbsensi(data);

      if (success) {
        Get.snackbar('Sukses', 'Absensi berhasil disimpan!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', 'Gagal menyimpan absensi',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== TAHFIDZ ==========
  Future<void> fetchHafalanList() async {
    try {
      isLoadingHafalan.value = true;

      final params = <String, String>{'per_page': '20'};
      if (selectedKelasRiwayat.value != null) {
        params['kelas_id'] = selectedKelasRiwayat.value!['id'].toString();
      }

      final uri = ApiHelper.buildUri(
        endpoint: 'tahfidz/hafalan',
        params: params,
      );
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response != null && response['data'] != null) {
        final rawData = response['data'];
        if (rawData is Map && rawData['data'] is List) {
          hafalanList.assignAll(rawData['data']);
        } else if (rawData is List) {
          hafalanList.assignAll(rawData);
        }
      }
      debugPrint('DEBUG: Fetched ${hafalanList.length} hafalan records');
    } catch (e) {
      debugPrint('DEBUG: Error fetching hafalan list: $e');
      hafalanList.clear();
    } finally {
      isLoadingHafalan.value = false;
    }
  }

  Future<void> fetchSantriList({String? query}) async {
    try {
      isLoadingSantri.value = true;
      final data = await _santriRepository.getSantriList(
        search: query,
        kelasId: selectedKelasTahfidz.value?['id'],
      );
      santriList.assignAll(data);
    } catch (e) {
      santriList.clear();
    } finally {
      isLoadingSantri.value = false;
    }
  }

  Future<void> submitTahfidz() async {
    if (selectedSantriId.value == null) {
      Get.snackbar(
        'Peringatan',
        'Pilih santri terlebih dahulu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    if (surahController.text.isEmpty || ayatController.text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Isi surah dan ayat',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;

      final uri = ApiHelper.buildUri(endpoint: 'tahfidz/hafalan');
      final body = {
        'santri_id': selectedSantriId.value,
        'juz': selectedJuz.value,
        'surah': surahController.text,
        'ayat_range': ayatController.text,
        'kualitas': selectedKualitas.value,
        'tanggal_setoran': DateTime.now().toString().split(' ')[0],
        'catatan': catatanController.text,
      };

      debugPrint('DEBUG: Submitting tahfidz with body: $body');

      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: body,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      debugPrint('DEBUG: Tahfidz response: $response');

      if (response['success'] == true) {
        // Reset form first
        surahController.clear();
        ayatController.clear();
        catatanController.clear();
        selectedJuz.value = null;
        selectedSantriId.value = null;
        selectedSantriName.value = null;
        searchController.clear();
        selectedKelasTahfidz.value = null;
        santriList.clear();

        Get.snackbar(
          'Sukses',
          'Setoran tahfidz berhasil dicatat!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Refresh hafalan list
        fetchHafalanList();
      } else {
        Get.snackbar(
          'Gagal',
          response['message'] ?? 'Gagal menyimpan setoran',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Tahfidz error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== NILAI SEKOLAH ==========
  Future<void> fetchMapelList() async {
    try {
      final data = await _guruRepository.getMyMapel();
      mapelList.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      debugPrint('Error fetching mapel list: $e');
    }
  }

  Future<void> fetchSiswaForNilai(int kelasId) async {
    try {
      isLoadingNilai.value = true;
      siswaNilaiList.clear();
      nilaiData.clear();

      final uri = ApiHelper.buildUri(
        endpoint: 'siswa',
        params: {
          'kelas_id': kelasId.toString(),
          'per_page': '100', // Load all for grading convenience
        },
      );

      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response != null && response['data'] != null) {
        final List rawList = response['data'] is List
            ? response['data']
            : (response['data']['data'] ?? []);

        siswaNilaiList.assignAll(rawList.map((e) {
          final s = e as Map<String, dynamic>;
          nilaiData[s['id']] = TextEditingController();
          return s;
        }).toList());

        // Also fetch existing grades if mapel is selected
        if (selectedMapel.value != null) {
          await _fetchExistingGrades();
        }
      }
    } catch (e) {
      debugPrint('Error fetching siswa for nilai: $e');
    } finally {
      isLoadingNilai.value = false;
    }
  }

  Future<void> _fetchExistingGrades() async {
    if (selectedKelas.value == null || selectedMapel.value == null) return;

    try {
      final grades = await _guruRepository.getNilai(
        kelasId: selectedKelas.value!['id'],
        mapelId: selectedMapel.value!['id'],
      );

      for (var grade in grades) {
        final siswaId = grade['siswa_id'];
        if (nilaiData.containsKey(siswaId)) {
          // Find if this grade matches current semester/year/type filter
          if (grade['semester'] == selectedSemesterNilai.value &&
              grade['tahun_ajaran'] == selectedTahunAjaran.value &&
              grade['jenis_penilaian'] == selectedJenisPenilaian.value) {
            nilaiData[siswaId]!.text = grade['nilai'].toString();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching existing grades: $e');
    }
  }

  Future<void> submitNilaiBulk() async {
    if (selectedKelas.value == null || selectedMapel.value == null) {
      Get.snackbar('Peringatan', 'Pilih kelas dan mata pelajaran',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final dataList = <Map<String, dynamic>>[];
      nilaiData.forEach((siswaId, controller) {
        if (controller.text.isNotEmpty) {
          dataList.add({
            'siswa_id': siswaId,
            'mapel_id': selectedMapel.value!['id'],
            'sekolah_kelas_id': selectedKelas.value!['id'],
            'semester': selectedSemesterNilai.value,
            'tahun_ajaran': selectedTahunAjaran.value,
            'jenis_penilaian': selectedJenisPenilaian.value,
            'nilai': double.tryParse(controller.text) ?? 0.0,
          });
        }
      });

      if (dataList.isEmpty) {
        Get.snackbar('Peringatan', 'Tidak ada nilai yang diinputkan');
        return;
      }

      final success =
          await _guruRepository.createNilaiBulk({'nilai_data': dataList});

      if (success) {
        Get.snackbar('Sukses', 'Nilai berhasil disimpan!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', 'Gagal menyimpan nilai',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onNilaiFilterChanged() {
    _fetchExistingGrades();
  }

  // ========== TUGAS SANTRI ==========

  final tugasSantriList = <dynamic>[].obs;
  final isLoadingTugasSantri = false.obs;
  final selectedTugasSantri = Rxn<Map<String, dynamic>>();

  // Form fields for create/edit tugas
  final tugasJudulController = TextEditingController();
  final tugasDeskripsiController = TextEditingController();
  final selectedTingkatSantri = Rxn<Map<String, dynamic>>();
  final selectedKelasSantri = Rxn<Map<String, dynamic>>();
  final selectedMapelPondok = Rxn<Map<String, dynamic>>();
  final selectedTanggalMulai = Rxn<DateTime>();
  final selectedDeadline = Rxn<DateTime>();

  // Lists for dropdowns
  final tingkatSantriList = <dynamic>[].obs;
  final kelasSantriList = <dynamic>[].obs;
  final mapelPondokList = <dynamic>[].obs;

  // Grading
  final nilaiTugasController = TextEditingController();
  final catatanGuruController = TextEditingController();
  final selectedSubmission = Rxn<Map<String, dynamic>>();

  Future<void> fetchTugasSantriList() async {
    try {
      isLoadingTugasSantri.value = true;
      final data = await _guruRepository.getTugasSantriList();
      tugasSantriList.assignAll(data);
    } catch (e) {
      debugPrint('Error fetching tugas santri: $e');
    } finally {
      isLoadingTugasSantri.value = false;
    }
  }

  Future<void> fetchTugasSantriDropdowns() async {
    try {
      // Fetch tingkat santri
      final tingkatData = await _guruRepository.getTingkatSantri();
      tingkatSantriList.assignAll(tingkatData);

      // Fetch mapel pondok
      final mapelData = await _guruRepository.getMapelPondok();
      mapelPondokList.assignAll(mapelData);
    } catch (e) {
      debugPrint('Error fetching dropdowns: $e');
    }
  }

  Future<void> fetchKelasSantriByTingkat(int tingkatId) async {
    try {
      final data = await _guruRepository.getKelasSantri(tingkatId: tingkatId);
      kelasSantriList.assignAll(data);
    } catch (e) {
      debugPrint('Error fetching kelas santri: $e');
    }
  }

  Future<void> createTugasSantri() async {
    if (tugasJudulController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Judul tugas wajib diisi',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedTingkatSantri.value == null ||
        selectedKelasSantri.value == null) {
      Get.snackbar('Peringatan', 'Pilih tingkat dan kelas',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedMapelPondok.value == null) {
      Get.snackbar('Peringatan', 'Pilih mata pelajaran',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedTanggalMulai.value == null || selectedDeadline.value == null) {
      Get.snackbar('Peringatan', 'Pilih tanggal mulai dan deadline',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final data = {
        'judul': tugasJudulController.text,
        'deskripsi': tugasDeskripsiController.text,
        'tingkat_id': selectedTingkatSantri.value!['id'],
        'kelas_id': selectedKelasSantri.value!['id'],
        'mapel_id': selectedMapelPondok.value!['id'],
        'tanggal_mulai':
            selectedTanggalMulai.value!.toIso8601String().split('T')[0],
        'deadline': selectedDeadline.value!.toIso8601String().split('T')[0],
      };

      final success = await _guruRepository.createTugasSantri(data);

      if (success) {
        Get.snackbar('Sukses', 'Tugas berhasil dibuat!',
            backgroundColor: Colors.green, colorText: Colors.white);
        _resetTugasForm();
        fetchTugasSantriList();
        Get.back();
      } else {
        Get.snackbar('Gagal', 'Gagal membuat tugas',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTugasSantri(int id) async {
    try {
      isLoading.value = true;
      final success = await _guruRepository.deleteTugasSantri(id);

      if (success) {
        Get.snackbar('Sukses', 'Tugas berhasil dihapus!',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchTugasSantriList();
      } else {
        Get.snackbar('Gagal', 'Gagal menghapus tugas',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> gradeTugasSantriSubmission() async {
    if (selectedSubmission.value == null) {
      Get.snackbar('Peringatan', 'Pilih submission terlebih dahulu',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (nilaiTugasController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Masukkan nilai',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final nilai = double.tryParse(nilaiTugasController.text);
    if (nilai == null || nilai < 0 || nilai > 100) {
      Get.snackbar('Peringatan', 'Nilai harus antara 0-100',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final success = await _guruRepository.gradeTugasSantri(
        submissionId: selectedSubmission.value!['id'],
        nilai: nilai,
        catatan: catatanGuruController.text.isNotEmpty
            ? catatanGuruController.text
            : null,
      );

      if (success) {
        Get.snackbar('Sukses', 'Nilai berhasil disimpan!',
            backgroundColor: Colors.green, colorText: Colors.white);
        nilaiTugasController.clear();
        catatanGuruController.clear();
        selectedSubmission.value = null;
        fetchTugasSantriList(); // Refresh to show updated grade
        Get.back();
      } else {
        Get.snackbar('Gagal', 'Gagal menyimpan nilai',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetTugasForm() {
    tugasJudulController.clear();
    tugasDeskripsiController.clear();
    selectedTingkatSantri.value = null;
    selectedKelasSantri.value = null;
    selectedMapelPondok.value = null;
    selectedTanggalMulai.value = null;
    selectedDeadline.value = null;
    kelasSantriList.clear();
  }
}
