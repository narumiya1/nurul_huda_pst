import 'package:epesantren_mob/app/api/news/news_model.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/rois/rois_repository.dart';
import 'package:epesantren_mob/app/api/sdm/sdm_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:epesantren_mob/app/services/user_context_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class DashboardController extends GetxController {
  final NewsRepository _newsRepository;
  final PimpinanRepository _pimpinanRepository;
  final GuruRepository _guruRepository;
  final SantriRepository _santriRepository;
  final OrangtuaRepository _orangtuaRepository;
  final RoisRepository _roisRepository;
  final AuthRepository _authRepository;

  DashboardController(
    this._newsRepository,
    this._pimpinanRepository,
    this._guruRepository,
    this._santriRepository,
    this._orangtuaRepository,
    this._roisRepository,
    this._authRepository,
    SdmRepository
        sdmRepository, // Keep it in constructor but don't save to field if unused
  );

  final beritaList = <BeritaModel>[].obs;
  final isLoadingBerita = false.obs;
  final isUploading = false.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final quickStats = <String, dynamic>{}.obs;
  final jadwalGuru = <Map<String, dynamic>>[].obs;
  final attendanceHistory = <Map<String, dynamic>>[].obs;
  final childrenList = <Map<String, dynamic>>[].obs;
  final nis = ''.obs;

  // Separate info sections for santri/siswa
  final sekolahInfo = <String, dynamic>{}.obs;
  final pondokInfo = <String, dynamic>{}.obs;
  final hasSiswaData = false.obs;
  final hasSantriData = false.obs;
  final pendingTasksCount = 0.obs;
  final hafalanInfo = ''.obs;

  // Pimpinan filter: 'all', 'santri', 'siswa'
  final pimpinanStatsFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchBerita();
    loadQuickStats();
    fetchJadwalGuru();
    registerFcmToken();

    // Listen to mode changes for dual-role users
    if (Get.isRegistered<UserContextService>()) {
      ever(Get.find<UserContextService>().activeMode, (_) {
        loadQuickStats();
        fetchBerita(); // Berita might also differ or just refresh
      });
    }
  }

  Future<void> fetchJadwalGuru() async {
    if (isGuru) {
      try {
        final data = await _guruRepository.getTodaySchedule();
        final mapped = data.map((item) {
          final mapel = item['mapel'];
          final kelas = item['kelas'];
          return {
            'jam':
                "${(item['jam_mulai']?.toString() ?? '??').padLeft(5, '0').substring(0, 5)} - ${(item['jam_selesai']?.toString() ?? '??').padLeft(5, '0').substring(0, 5)}",
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
        role == 'staff_sekolah' ||
        role == 'staff_keuangan') {
      try {
        final data = await _pimpinanRepository.getDashboardStats();
        final stats = data['data'] ?? data;

        if (role == 'pimpinan' || role == 'staff_keuangan') {
          try {
            final financeData =
                await _pimpinanRepository.getFinancing(filter: 'bulanan');
            final summary =
                financeData['data']?['summary'] ?? financeData['summary'];

            if (summary != null) {
              final formatter = NumberFormat.compactCurrency(
                symbol: 'Rp',
                decimalDigits: 0,
                locale: 'id_ID',
              );

              String saldo = formatter.format(summary['total_saldo'] ?? 0);
              String masuk =
                  formatter.format(summary['total_masuk_month'] ?? 0);

              quickStats.value = {
                'stat1': {
                  'label': 'Saldo Kas',
                  'value': saldo,
                  'icon': 'account_balance_wallet'
                },
                'stat2': {
                  'label': 'Masuk (Bln)',
                  'value': masuk,
                  'icon': 'trending_up'
                },
                'stat3': {
                  'label': 'Santri',
                  'value': stats['santri_count']?.toString() ?? '0',
                  'icon': 'people'
                },
              };
              return;
            }
          } catch (fe) {
            debugPrint('Error loading finance stats: $fe');
            // Fallback to standard stats if finance fails
          }
        }

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
        debugPrint('Error loading dashboard stats: $e');
      }
    } else if (isGuru) {
      try {
        final data = await _guruRepository.getDashboardStats();
        if (data != null) {
          if (isGuruPesantren &&
              !isGuruSekolah &&
              (data['total_kelas'] == 0 || data['total_kelas'] == null)) {
            // Stats for pesantren teacher
            quickStats.value = {
              'stat1': {
                'label': 'Total Santri',
                'value': data['total_santri']?.toString() ?? '0',
                'icon': 'people'
              },
              'stat2': {
                'label': 'Setoran Tahfidz',
                'value': data['tahfidz_today']?.toString() ?? '0',
                'icon': 'mic'
              },
              'stat3': {
                'label': 'Pelanggaran',
                'value': data['violations_today']?.toString() ?? '0',
                'icon': 'error_outline'
              },
            };
          } else {
            // Standard school teacher stats
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
          }
          return;
        }
      } catch (e) {
        // Handle error
      }
    } else if (role == 'santri' || role == 'siswa') {
      try {
        final profile = await _santriRepository.getMyProfile();
        // Fetch both school and pondok tasks
        final taskResults = await Future.wait([
          _santriRepository.getTugasSekolah(),
          _santriRepository.getTugasPondok(),
        ]);
        final allTasks = [...taskResults[0], ...taskResults[1]];
        final tahfidz = await _santriRepository.getMyTahfidz();

        if (profile != null) {
          // Extract NIS
          if (profile['santri'] != null && profile['santri']['nis'] != null) {
            nis.value = profile['santri']['nis'].toString();
          } else if (profile['siswa'] != null &&
              profile['siswa']['nis'] != null) {
            nis.value = profile['siswa']['nis'].toString();
          }

          // === SEKOLAH INFO ===
          if (profile['siswa'] != null) {
            hasSiswaData.value = true;
            final sw = profile['siswa'];
            String schoolClass = '-';
            String schoolName = '-';
            String schoolNIS = '-';
            String schoolTingkat = '-';

            final k = sw['kelas'];
            if (k is Map && k['nama_kelas'] != null) {
              schoolClass = k['nama_kelas'];
            }
            final s = sw['sekolah'];
            if (s != null && s['nama_sekolah'] != null) {
              schoolName = s['nama_sekolah'];
            }
            if (sw['nis'] != null) schoolNIS = sw['nis'].toString();
            if (sw['tingkat'] != null) {
              schoolTingkat = sw['tingkat'].toString();
            } else if (sw['kelas_tingkat'] != null) {
              schoolTingkat = sw['kelas_tingkat'].toString();
            }

            sekolahInfo.value = {
              'kelas': schoolClass,
              'sekolah': schoolName,
              'nis': schoolNIS,
              'tingkat': schoolTingkat,
            };
          } else {
            hasSiswaData.value = false;
            sekolahInfo.clear();
          }

          // === PONDOK INFO ===
          if (profile['santri'] != null) {
            hasSantriData.value = true;
            final s = profile['santri'];
            String pondokClass = '-';
            String kamarName = '-';
            String blokName = '-';
            String pondokTingkat = '-';
            String pondokNIS = '-';

            final kObj = s['kelas_obj'] ?? s['kelasObj'] ?? s['kelas'];
            if (kObj is Map && kObj['nama_kelas'] != null) {
              pondokClass = kObj['nama_kelas'];
            } else if (s['kelas'] is String) {
              pondokClass = s['kelas'];
            }

            final kamar = s['kamar'];
            if (kamar != null) {
              kamarName = kamar['nama_kamar'] ?? '-';
              final blok = kamar['blok'];
              if (blok != null) {
                blokName = blok['nama_blok'] ?? '-';
              }
            }

            final tingkat = s['tingkat'];
            if (tingkat is Map && tingkat['nama_tingkat'] != null) {
              pondokTingkat = tingkat['nama_tingkat'];
            } else if (tingkat is String) {
              pondokTingkat = tingkat;
            }

            if (s['nis'] != null) pondokNIS = s['nis'].toString();

            pondokInfo.value = {
              'kelas': pondokClass,
              'kamar': kamarName,
              'blok': blokName,
              'tingkat': pondokTingkat,
              'nis': pondokNIS,
            };
          } else {
            hasSantriData.value = false;
            pondokInfo.clear();
          }
        }

        // Count pending tasks
        int pendingCount = 0;
        if (allTasks.isNotEmpty) {
          pendingCount = allTasks.where((t) {
            final isSubmitted = t['my_submission'] != null ||
                (t['is_submitted'] == true) ||
                (t['status'] == 'Selesai');
            return !isSubmitted;
          }).length;
        }
        pendingTasksCount.value = pendingCount;

        // Tahfidz info
        if (tahfidz.isNotEmpty) {
          hafalanInfo.value = '${tahfidz['total_juz'] ?? 0} Juz';
        } else {
          hafalanInfo.value = '0 Juz';
        }

        // Keep quickStats for backward compatibility (used in KTP card etc.)
        String mainKelas = '-';
        if (hasSantriData.value) {
          mainKelas = pondokInfo['kelas'] ?? '-';
        } else if (hasSiswaData.value) {
          mainKelas = sekolahInfo['kelas'] ?? '-';
        }
        quickStats.value = {
          'stat1': {
            'label': 'Kelas',
            'value': mainKelas,
            'icon': hasSantriData.value ? 'room' : 'school'
          },
        };

        return;
      } catch (e) {
        debugPrint('Error loading stats: $e');
      }
    } else if (role == 'orangtua') {
      try {
        final children = await _orangtuaRepository.getMyChildren();
        childrenList
            .assignAll(children.map((e) => e as Map<String, dynamic>).toList());

        int totalUnpaidBills = 0;
        double totalAttendanceRate = 0;
        int childrenCount = children.length;

        if (childrenCount > 0) {
          // Fetch summaries in parallel for up to 3 children to avoid long waits
          final summariesToFetch = childrenCount > 3 ? 3 : childrenCount;
          final summaryFutures = <Future<dynamic>>[];

          for (int i = 0; i < summariesToFetch; i++) {
            final child = children[i];
            summaryFutures.add(_orangtuaRepository.getChildSummary(
              child['id'],
              tipe: child['tipe']?.toString().toLowerCase(),
            ));
          }

          final summaries = await Future.wait(summaryFutures);

          for (var summary in summaries) {
            if (summary != null && summary['stats'] != null) {
              totalUnpaidBills += int.tryParse(
                      summary['stats']['unpaid_bills']?.toString() ?? '0') ??
                  0;
              totalAttendanceRate += double.tryParse(
                      summary['stats']['attendance_rate']?.toString() ?? '0') ??
                  0;
            }
          }
        }

        quickStats.value = {
          'stat1': {
            'label': 'Anak',
            'value': children.length.toString(),
            'icon': 'family_restroom'
          },
          'stat2': {
            'label': 'Tagihan',
            'value': totalUnpaidBills > 0 ? '$totalUnpaidBills Item' : 'Lunas',
            'icon': 'payments'
          },
          'stat3': {
            'label': 'Kehadiran',
            'value': childrenCount > 0
                ? '${(totalAttendanceRate / (childrenCount > 3 ? 3 : childrenCount)).round()}%'
                : '-',
            'icon': 'description'
          },
        };
        return;
      } catch (e) {
        debugPrint('Error loading parent stats: $e');
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
    if (role is String) {
      String res = role.toLowerCase().replaceAll(' ', '_');
      return res == 'orang_tua' ? 'orangtua' : res;
    }
    if (role is Map) {
      String res = (role['role_name'] ?? 'netizen')
          .toString()
          .toLowerCase()
          .replaceAll(' ', '_');
      return res == 'orang_tua' ? 'orangtua' : res;
    }
    return 'netizen';
  }

  bool get isGuru => userRole == 'guru' || isGuruPesantren || isGuruSekolah;
  bool get isGuruPesantren => userRole == 'guru_pesantren';
  bool get isGuruSekolah => userRole == 'guru_sekolah';

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

  Future<void> registerFcmToken() async {
    try {
      String? token = LocalStorage.read('fcm_token');
      if (token != null) {
        await _authRepository.updateFcmToken(token);
      }
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  Future<void> refreshProfile() async {
    try {
      final data = await _authRepository.getUser();
      if (data != null && data['user'] != null) {
        final user = data['user'];
        LocalStorage.saveUser(user);
        userData.value = user;
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (image == null) return;

      isUploading.value = true;
      Get.dialog(
        const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        barrierDismissible: false,
      );

      final uri = ApiHelper.buildUri(endpoint: 'upload-avatar');
      final files = {'avatar': File(image.path)};

      // Use raw ApiHelper for multipart, similar to ProfilController
      final apiHelper = ApiHelper();
      final response = await apiHelper.postImageData(
        uri: uri,
        files: files,
        builder: (data) => data,
        header: ApiHelper.tokenHeaderMultipart(LocalStorage.getToken() ?? ''),
      );

      Get.back(); // Close loading dialog

      if (response['status'] == true || response['data'] != null) {
        await refreshProfile();
        Get.snackbar('Sukses', 'Foto profil berhasil diperbarui',
            backgroundColor: AppColors.success, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', response['message'] ?? 'Gagal mengunggah foto',
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isUploading.value = false;
    }
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () {
                    Get.back();
                    pickAndUploadImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onTap: () {
                    Get.back();
                    pickAndUploadImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
