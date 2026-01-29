import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:epesantren_mob/app/routes/app_pages.dart';

class ProfilController extends GetxController {
  final ApiHelper _apiHelper;

  ProfilController({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  final isLoading = false.obs;
  final userData = Rxn<Map<String, dynamic>>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final settings = Rxn<Map<String, dynamic>>();

  // Password fields
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchUserProfile(); // Refresh data to get latest updates like kode_claim
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'settings');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data['data'],
      );
      settings.value = response;
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'user/my-profile');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response['status'] == true ||
          (response['data'] != null && response['data']['user'] != null)) {
        final user = response['data']['user'];
        LocalStorage.saveUser(user);
        userData.value = user;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  void loadUserData() {
    userData.value = LocalStorage.getUser();
    if (userData.value != null) {
      fullNameController.text = userData.value?['details']?['full_name'] ?? '';
      phoneController.text = userData.value?['details']?['phone'] ?? '';
      addressController.text = userData.value?['details']?['address'] ?? '';
      emailController.text = userData.value?['email'] ?? '';
    }
  }

  String get userName =>
      userData.value?['details']?['full_name'] ??
      userData.value?['username'] ??
      'User';
  String get userRole => userData.value?['role']?['description'] ?? 'Pengguna';
  String get userEmail => userData.value?['email'] ?? '-';
  String get userPhone => userData.value?['details']?['phone'] ?? '-';

  String get claimCode {
    final santri = userData.value?['santri'];
    final siswa = userData.value?['siswa'];
    return santri?['kode_claim'] ?? siswa?['kode_claim'] ?? '-';
  }

  bool get isPimpinan {
    final role = userData.value?['role'];
    if (role == null) return false;
    if (role is String) return role.toLowerCase() == 'pimpinan';
    if (role is Map) {
      return (role['role_name'] ?? '').toString().toLowerCase() == 'pimpinan';
    }
    return false;
  }

  Future<void> updateProfile() async {
    if (fullNameController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Nama lengkap tidak boleh kosong',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final uri = ApiHelper.buildUri(endpoint: 'user/update-profile');
      final body = {
        'full_name': fullNameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'email': emailController.text,
      };

      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: body,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response['data'] != null && response['data']['user'] != null) {
        final user = response['data']['user'];
        // Update local storage
        LocalStorage.saveUser(user);
        userData.value = user;

        Get.back();
        Get.snackbar('Sukses', 'Profil berhasil diperbarui',
            backgroundColor: AppColors.success, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', response['message'] ?? 'Gagal memperbarui profil',
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Semua field harus diisi',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar('Peringatan', 'Password baru minimal 6 karakter',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Peringatan', 'Konfirmasi password tidak cocok',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final uri = ApiHelper.buildUri(endpoint: 'user/change-password');
      final body = {
        'old_password': oldPasswordController.text,
        'new_password': newPasswordController.text,
        'new_password_confirmation': confirmPasswordController.text,
      };

      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: body,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response['status'] == true || response['success'] == true) {
        // Clear password fields
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        Get.back();
        Get.snackbar('Sukses', 'Password berhasil diubah',
            backgroundColor: AppColors.success, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', response['message'] ?? 'Gagal mengubah password',
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorage.clearAll();
              Get.offAllNamed(Routes.welcome);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
