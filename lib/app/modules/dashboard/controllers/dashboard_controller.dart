import 'package:epesantren_mob/app/api/news/news_model.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final NewsRepository _newsRepository;
  final PimpinanRepository _pimpinanRepository;

  DashboardController(this._newsRepository, this._pimpinanRepository);

  final beritaList = <BeritaModel>[].obs;
  final isLoadingBerita = false.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final quickStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchBerita();
    loadQuickStats();
  }

  Future<void> loadQuickStats() async {
    // Mock data for quick stats initially or for other roles
    if (userRole == 'pimpinan') {
      try {
        final data = await _pimpinanRepository.getDashboardStats();
        // Assuming API returns { 'data': { 'stats': { 'santri': X, 'guru': Y, 'saldo': Z } } }
        // Adjust mapping based on actual API response
        if (data['data'] != null) {
          final stats = data['data'];
          quickStats.value = {
            'stat1': {
              'label': 'Santri',
              'value': stats['santri_count']?.toString() ?? '1,234',
              'icon': 'people'
            },
            'stat2': {
              'label': 'Guru',
              'value': stats['guru_count']?.toString() ?? '45',
              'icon': 'school'
            },
            'stat3': {
              'label': 'Alumni',
              'value': stats['alumni_count']?.toString() ?? '280',
              'icon': 'workspace_premium'
            },
          };
          return;
        }
      } catch (e) {
        print('Error loading stats from API: $e');
      }

      // Fallback to mock data if API fails
      quickStats.value = {
        'stat1': {'label': 'Santri', 'value': '1,234', 'icon': 'people'},
        'stat2': {'label': 'Guru', 'value': '45', 'icon': 'school'},
        'stat3': {
          'label': 'Saldo Kas',
          'value': '150M',
          'icon': 'account_balance_wallet'
        },
      };
    } else if (userRole == 'guru') {
      quickStats.value = {
        'stat1': {'label': 'Siswa', 'value': '32', 'icon': 'people'},
        'stat2': {'label': 'Tugas', 'value': '12', 'icon': 'assignment'},
        'stat3': {'label': 'Absensi', 'value': '98%', 'icon': 'check_circle'},
      };
    } else {
      quickStats.value = {
        'stat1': {'label': 'Santri', 'value': '1,234', 'icon': 'people'},
        'stat2': {'label': 'Guru', 'value': '45', 'icon': 'school'},
        'stat3': {
          'label': 'Alumni',
          'value': '280',
          'icon': 'workspace_premium'
        },
      };
    }
  }

  void loadUserData() {
    userData.value = LocalStorage.getUser();
    print('Loaded User Data: ${userData.value}');
  }

  String get userRole {
    final role = userData.value?['role'];
    if (role == null) return 'netizen';
    if (role is String) return role;
    if (role is Map) return role['role_name'] ?? 'netizen';
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
    if (role is Map)
      return role['description'] ?? role['role_name'] ?? 'Pengguna';
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
}
