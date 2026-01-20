import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../helpers/local_storage.dart';

class ManajemenSdmController extends GetxController {
  final PimpinanRepository _repository;
  ManajemenSdmController(this._repository);

  // Scroll Controller
  final ScrollController scrollController = ScrollController();

  final isLoading = false.obs;
  final isMoreLoading = false.obs; // For infinite scroll
  final users = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;
  final selectedRole = 'Semua'.obs;
  final currentUserRole = 'netizen'.obs;

  // Pagination State
  int currentPage = 1;
  int lastPage = 1;
  final int itemsPerPage = 5; // Reduced to prevent large response issues
  String currentSearchQuery = '';

  final List<String> roles = [
    // 'Semua', // Remove 'Semua' to simplify pagination logic (each tab has different endpoint)
    'Pimpinan',
    'Guru',
    'Staff',
    'Orang Tua',
    'Santri',
    'Siswa'
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    filterByRole('Pimpinan');

    // Infinite Scroll Listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoading.value &&
            !isMoreLoading.value &&
            currentPage < lastPage) {
          loadNextPage();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _loadUserRole() {
    final user = LocalStorage.getUser();
    if (user != null) {
      final role = user['role'];
      if (role is String) {
        currentUserRole.value = role.toLowerCase();
      } else if (role is Map) {
        currentUserRole.value =
            (role['role_name'] ?? 'netizen').toString().toLowerCase();
      }
    }
  }

  // Pimpinan is View Only, Staff Pesantren might manage
  bool get canManage => currentUserRole.value == 'staff_pesantren';

  Future<void> fetchUsers(String role, {bool refresh = false}) async {
    if (refresh) {
      isLoading.value = true;
      currentPage = 1;
      users.clear();
      filteredUsers.clear();
    } else {
      isMoreLoading.value = true;
    }

    try {
      if (role == 'Semua') {
        // 'Semua' mode is complex for infinite scroll, assuming separated tabs now
        // If 'Semua' is kept, we might disable pagination or handle it differently
        isLoading.value = false;
        isMoreLoading.value = false;
        return;
      }

      String type = role.toLowerCase().replaceAll(' ', '');
      if (role == 'Orang Tua') type = 'orangtua';

      // Pass perPage and current search query
      final response = await _repository.getUsersByType(type,
          perPage: itemsPerPage,
          search: currentSearchQuery,
          page: refresh ? 1 : currentPage + 1 // Request next page or first page
          );

      // Handle Metadata for Pagination
      if (response['meta'] != null) {
        currentPage = response['meta']['current_page'];
        lastPage = response['meta']['last_page'];
      }

      List<Map<String, dynamic>> newItems = _mapResponse(response, role);

      if (refresh) {
        users.assignAll(newItems);
      } else {
        users.addAll(newItems);
      }

      // Update filtered list (if no local search, they are same)
      // Since we do server-side search, filteredUsers == users
      filteredUsers.assignAll(users);
    } catch (e) {
      debugPrint('Error fetching $role: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void loadNextPage() {
    if (!isMoreLoading.value && currentPage < lastPage) {
      fetchUsers(selectedRole.value, refresh: false);
    }
  }

  // RE-WRITE to include page param support via dynamic params or update API next.
  // For now I will write the controller assuming API supports page or I will add page to params map if possible.
  // Actually PimpinanApi.getUsersByType takes `search` and `perPage`. I need to add `page`.

  // Let's implement fetch with page param support via a workaround or plan to update API.
  // I will update PimpinanApi in NEXT step. Here I implement logic.

  void fetchNextPage() {
    loadNextPage();
  }

  List<Map<String, dynamic>> _mapResponse(dynamic response, String roleLabel) {
    List list = [];
    if (response is Map && response['data'] != null) {
      if (response['data'] is List) list = response['data'];
    } else if (response is List) {
      list = response;
    }

    return list.map((item) {
      String name = 'No Name';
      String email = '-';
      String status = 'Non-Aktif';

      if (item is Map) {
        Map userObj = item;
        if (item['user'] != null && item['user'] is Map) {
          userObj = item['user'] as Map;
        }

        // Safe string extraction
        final details = userObj['details'];
        if (details != null && details is Map && details['full_name'] != null) {
          name = details['full_name'].toString();
        } else if (userObj['name'] != null) {
          name = userObj['name'].toString();
        } else if (item['full_name'] != null) {
          name = item['full_name'].toString();
        }

        if (userObj['email'] != null) {
          email = userObj['email'].toString();
        }

        if (item['is_active'] == 1 ||
            item['is_active'] == true ||
            userObj['is_active'] == 1 ||
            userObj['is_active'] == true ||
            item['status'] == 'aktif') {
          status = 'Aktif';
        }
      }

      return {
        'name': name,
        'role': roleLabel,
        'email': email,
        'status': status,
        'original': item
      };
    }).toList();
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    currentSearchQuery = ''; // Reset search logic on tab change
    fetchUsers(role, refresh: true);
  }

  void searchUser(String query) {
    // Debounce search ideally
    currentSearchQuery = query;
    fetchUsers(selectedRole.value, refresh: true);
  }

  Future<void> addSantri(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      Get.back(); // Close bottom sheet if open

      await _repository.createSantri(data);

      Get.snackbar(
        'Sukses',
        'Data Santri berhasil ditambahkan',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // Refresh list if current tab is Santri or Semua
      if (selectedRole.value == 'Santri' || selectedRole.value == 'Semua') {
        fetchUsers(selectedRole.value, refresh: true);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menambahkan santri: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStaff(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      Get.back(); // Close bottom sheet if open

      await _repository.createStaff(data);

      Get.snackbar(
        'Sukses',
        'Data Staff berhasil ditambahkan',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // Refresh list if current tab is Staff or Semua
      if (selectedRole.value == 'Staff' || selectedRole.value == 'Semua') {
        fetchUsers(selectedRole.value, refresh: true);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menambahkan staff: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> fetchSekolahList() async {
    try {
      return await _repository.getSekolahList();
    } catch (e) {
      debugPrint('Failed to fetch sekolah: $e');
      return [];
    }
  }

  Future<void> addSiswa(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      Get.back(); // Close bottom sheet if open

      await _repository.createSiswa(data);

      Get.snackbar(
        'Sukses',
        'Data Siswa berhasil ditambahkan',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // Refresh list if current tab is Siswa or Semua
      if (selectedRole.value == 'Siswa' || selectedRole.value == 'Semua') {
        fetchUsers(selectedRole.value, refresh: true);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menambahkan siswa: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
