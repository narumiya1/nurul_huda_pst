import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';
import '../../../routes/app_pages.dart';

class ProfilController extends GetxController {
  final isLoading = false.obs;
  final userData = Rxn<Map<String, dynamic>>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    userData.value = LocalStorage.getUser();
    if (userData.value != null) {
      fullNameController.text = userData.value?['details']?['full_name'] ?? '';
      phoneController.text = userData.value?['details']?['phone'] ?? '';
      addressController.text = userData.value?['details']?['address'] ?? '';
    }
  }

  String get userName =>
      userData.value?['details']?['full_name'] ??
      userData.value?['username'] ??
      'User';
  String get userRole => userData.value?['role']?['description'] ?? 'Pengguna';
  String get userEmail => userData.value?['email'] ?? '-';
  String get userPhone => userData.value?['details']?['phone'] ?? '-';

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
              Get.offAllNamed(Routes.WELCOME);
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
    super.onClose();
  }
}
