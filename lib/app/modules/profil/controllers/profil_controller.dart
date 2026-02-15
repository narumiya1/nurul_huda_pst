import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:epesantren_mob/app/routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilController extends GetxController {
  final ApiHelper _apiHelper;

  ProfilController({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  final isLoading = false.obs;
  final isUploading = false.obs;
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

  // Santri Data
  String get santriTingkat =>
      userData.value?['santri']?['tingkat']?['nama_tingkat'] ?? '-';
  String get santriKelas =>
      userData.value?['santri']?['kelas_obj']?['nama_kelas'] ?? '-';
  String get santriKamar =>
      userData.value?['santri']?['kamar']?['nama_kamar'] ?? '-';
  String get santriBlok =>
      userData.value?['santri']?['kamar']?['blok']?['nama_blok'] ?? '-';

  // Siswa Data
  String get siswaSekolah =>
      userData.value?['siswa']?['sekolah']?['nama_sekolah'] ?? '-';
  String get siswaTingkat =>
      userData.value?['siswa']?['kelas']?['tingkat']?.toString() ?? '-';
  String get siswaKelas =>
      userData.value?['siswa']?['kelas']?['nama_kelas'] ?? '-';

  bool get hasSantriData => userData.value?['santri'] != null;
  bool get hasSiswaData => userData.value?['siswa'] != null;

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

      final response = await _apiHelper.postImageData(
        uri: uri,
        files: files,
        builder: (data) => data,
        header: ApiHelper.tokenHeaderMultipart(LocalStorage.getToken() ?? ''),
      );

      Get.back(); // Close loading dialog

      if (response['status'] == true || response['data'] != null) {
        // Refresh profile to get latest photo_url
        await fetchUserProfile();
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
