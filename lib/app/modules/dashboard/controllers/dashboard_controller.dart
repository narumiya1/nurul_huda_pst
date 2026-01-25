import 'package:flutter/foundation.dart';
import 'package:epesantren_mob/app/api/news/news_model.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/rois/rois_repository.dart';
import 'package:epesantren_mob/app/api/sdm/sdm_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final NewsRepository _newsRepository;
  final PimpinanRepository _pimpinanRepository;
  final GuruRepository _guruRepository;
  final SantriRepository _santriRepository;
  final OrangtuaRepository _orangtuaRepository;
  final RoisRepository _roisRepository;

  DashboardController(
    this._newsRepository,
    this._pimpinanRepository,
    this._guruRepository,
    this._santriRepository,
    this._orangtuaRepository,
    this._roisRepository,
    SdmRepository
        sdmRepository, // Keep it in constructor but don't save to field if unused
  );

  final beritaList = <BeritaModel>[].obs;
  final isLoadingBerita = false.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final quickStats = <String, dynamic>{}.obs;
  final jadwalGuru = <Map<String, dynamic>>[].obs; // Add this
  final attendanceHistory = <Map<String, dynamic>>[].obs; // Add this
  final childrenList = <Map<String, dynamic>>[].obs; // Add this
  final nis = ''.obs; // Add this

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchBerita();
    loadQuickStats();
    fetchJadwalGuru();
  }

  Future<void> fetchJadwalGuru() async {
    if (userRole == 'guru') {
      try {
        final data = await _guruRepository.getTodaySchedule();
        final mapped = data.map((item) {
          final mapel = item['mapel'];
          final kelas = item['kelas'];
          return {
            'jam':
                "${item['jam_mulai']?.toString().substring(0, 5) ?? '??'} - ${item['jam_selesai']?.toString().substring(0, 5) ?? '??'}",
            'mapel': (mapel is Map ? mapel['nama'] : mapel) ?? '-',
            'kelas': (kelas is Map ? kelas['nama_kelas'] : kelas) ?? '-',
            'ruang': item['ruang'] ?? '-',
            'jam_mulai': item['jam_mulai'],
            'jam_selesai': item['jam_selesai'],
          };
        }).toList();
        jadwalGuru.assignAll(mapped);
      } catch (e) {
        debugPrint('Error fetching today schedule: $e');
      }
    }
  }

  Future<void> loadQuickStats() async {
    final role = userRole;

    if (role == 'superadmin' ||
        role == 'pimpinan' ||
        role == 'staff_pesantren' ||
        role == 'staff_keuangan') {
      try {
        final data = await _pimpinanRepository.getDashboardStats();
        final stats = data['data'] ?? data;
        quickStats.value = {
          'stat1': {
            'label': 'Santri',
            'value': stats['santri_count']?.toString() ?? '0',
            'icon': 'people'
          },
          'stat2': {
            'label': 'Guru',
            'value': stats['guru_count']?.toString() ?? '0',
            'icon': 'school'
          },
          'stat3': {
            'label': 'Alumni',
            'value': stats['alumni_count']?.toString() ?? '0',
            'icon': 'workspace_premium'
          },
        };
        return;
      } catch (e) {
        // Handle error silently or with a proper logger
      }
    } else if (role == 'guru') {
      try {
        final data = await _guruRepository.getDashboardStats();
        if (data != null) {
          quickStats.value = {
            'stat1': {
              'label': 'Total Kelas',
              'value': data['total_kelas']?.toString() ?? '0',
              'icon': 'room'
            },
            'stat2': {
              'label': 'Total Mapel',
              'value': data['total_mapel']?.toString() ?? '0',
              'icon': 'assignment'
            },
            'stat3': {
              'label': 'Siswa Diampu',
              'value': data['total_siswa']?.toString() ?? '0',
              'icon': 'groups'
            },
          };
          return;
        }
      } catch (e) {
        // Handle error
      }
    } else if (role == 'santri' || role == 'siswa') {
      try {
        final profile = await _santriRepository.getMyProfile();
        final tugas = await _santriRepository.getTugasSekolah();
        final tahfidz = await _santriRepository.getMyTahfidz();

        String kelasName = '-';

        if (profile != null) {
          // Extract NIS
          if (profile['santri'] != null && profile['santri']['nis'] != null) {
            nis.value = profile['santri']['nis'].toString();
          } else if (profile['siswa'] != null &&
              profile['siswa']['nis'] != null) {
            nis.value = profile['siswa']['nis'].toString();
          } else if (profile['details'] != null &&
              profile['details']['identifier_number'] != null) {
            nis.value = profile['details']['identifier_number'].toString();
          }

          // Try to find class name in relations
          if (profile['santri'] != null) {
            final s = profile['santri'];
            // Check various potential keys for class relation
            final kObj = s['kelas_obj'] ?? s['kelasObj'] ?? s['kelas'];
            if (kObj is Map && kObj['nama_kelas'] != null) {
              kelasName = kObj['nama_kelas'];
            } else if (s['kelas'] is String) {
              kelasName = s['kelas']; // Fallback if just string
            }
          }

          if (kelasName == '-' &&
              profile['siswa'] != null &&
              profile['siswa']['kelas'] != null) {
            final k = profile['siswa']['kelas'];
            if (k is Map && k['nama_kelas'] != null) {
              kelasName = k['nama_kelas'];
            }
          }
        }

        // Count pending tasks
        int pendingTasks = 0;
        if (tugas.isNotEmpty) {
          pendingTasks = tugas.where((t) {
            final isSubmitted =
                t['my_submission'] != null || (t['is_submitted'] == true);
            return !isSubmitted;
          }).length;
        }

        // Tahfidz info
        String hafalanInfo = '0 Juz';
        if (tahfidz.isNotEmpty) {
          hafalanInfo = '${tahfidz['total_juz'] ?? 0} Juz';
        }

        quickStats.value = {
          'stat1': {'label': 'Kelas', 'value': kelasName, 'icon': 'room'},
          'stat2': {
            'label': 'Tugas Pending',
            'value': pendingTasks.toString(),
            'icon': 'assignment'
          },
          'stat3': {
            'label': 'Hafalan',
            'value': hafalanInfo,
            'icon': 'auto_stories'
          },
        };
        return;
      } catch (e) {
        // Handle error
        print('Error loading stats: $e');
      }
    } else if (role == 'orangtua') {
      try {
        final children = await _orangtuaRepository.getMyChildren();
        childrenList
            .assignAll(children.map((e) => e as Map<String, dynamic>).toList());
        quickStats.value = {
          'stat1': {
            'label': 'Anak',
            'value': children.length.toString(),
            'icon': 'family_restroom'
          },
          'stat2': {'label': 'Tagihan', 'value': 'Cek', 'icon': 'payments'},
          'stat3': {
            'label': 'Laporan',
            'value': 'Tersedia',
            'icon': 'description'
          },
        };
        return;
      } catch (e) {
        // Handle error
      }
    } else if (role == 'roissantri') {
      try {
        final santri = await _roisRepository.getSantri();
        final perizinan = await _roisRepository.getPerizinan();
        quickStats.value = {
          'stat1': {
            'label': 'Santri Kamar',
            'value': santri.length.toString(),
            'icon': 'people'
          },
          'stat2': {
            'label': 'Perizinan',
            'value': perizinan.length.toString(),
            'icon': 'assignment'
          },
          'stat3': {'label': 'Absensi', 'value': 'Cek', 'icon': 'check_circle'},
        };
        return;
      } catch (e) {
        // Handle error
      }
    }

    // Default Fallback
    quickStats.value = {
      'stat1': {'label': 'Santri', 'value': '...', 'icon': 'people'},
      'stat2': {'label': 'Guru', 'value': '...', 'icon': 'school'},
      'stat3': {'label': 'Alumni', 'value': '...', 'icon': 'workspace_premium'},
    };
  }

  void loadUserData() {
    userData.value = LocalStorage.getUser();
  }

  String get userRole {
    final role = userData.value?['role'];
    if (role == null) return 'netizen';
    if (role is String) return role.toLowerCase();
    if (role is Map) {
      return (role['role_name'] ?? 'netizen').toString().toLowerCase();
    }
    return 'netizen';
  }

  String get userName {
    final details = userData.value?['details'];
    if (details != null && details['full_name'] != null) {
      return details['full_name'];
    }
    return userData.value?['username'] ?? 'User';
  }

  String get userRoleLabel {
    final role = userData.value?['role'];
    if (role == null) return 'Pengguna';
    if (role is String) return role;
    if (role is Map) {
      return role['description'] ?? role['role_name'] ?? 'Pengguna';
    }
    return 'Pengguna';
  }

  Future<void> fetchBerita() async {
    try {
      isLoadingBerita.value = true;
      final data = await _newsRepository.getAllNews();
      beritaList.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat berita: $e");
    } finally {
      isLoadingBerita.value = false;
    }
  }

  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final selectedBeritaIndex = 0.obs;
  final bottomIndex = 0.obs;

  void changeBerita(int index) {
    selectedBeritaIndex.value = index;
  }

  Future<void> fetchAttendanceHistory() async {
    final role = userRole;
    if (role == 'santri' || role == 'siswa') {
      try {
        final data = await _santriRepository.getMyAbsensi();
        attendanceHistory
            .assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      } catch (e) {
        debugPrint('Error fetching attendance history: $e');
      }
    } else if (role == 'orangtua') {
      try {
        final children = await _orangtuaRepository.getMyChildren();
        if (children.isNotEmpty) {
          // By default show first child's attendance on dashboard
          final firstChildId = children[0]['id'];
          final firstChildTipe = children[0]['tipe'];
          final data = await _orangtuaRepository.getChildAbsensi(firstChildId,
              tipe: firstChildTipe);
          attendanceHistory
              .assignAll(data.map((e) => e as Map<String, dynamic>).toList());
        }
      } catch (e) {
        debugPrint('Error fetching child attendance history: $e');
      }
    }
  }
}
