import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';

class ClaimChildController extends GetxController {
  final codeController = TextEditingController();
  final selectedHubungan = 'Ayah'.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final OrangtuaApi _api = OrangtuaApi();

  final List<String> hubunganOptions = ['Ayah', 'Ibu', 'Wali'];

  Future<void> claimChild() async {
    if (codeController.text.length != 8) {
      errorMessage.value = 'Kode harus 8 karakter';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await _api.claimChild(
        code: codeController.text.toUpperCase(),
        hubungan: selectedHubungan.value,
      );

      if (response['status'] == true) {
        Get.back();
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Berhasil menautkan anak',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        errorMessage.value = response['message'] ?? 'Gagal menautkan anak';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}

class ClaimChildView extends GetView<ClaimChildController> {
  const ClaimChildView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Tambah Anak'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Masukkan kode yang diberikan oleh pihak pesantren/sekolah untuk menautkan akun Anda dengan anak.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Code Input
            const Text(
              'Kode Klaim',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'XXXXXXXX',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 24,
                  letterSpacing: 4,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hubungan Dropdown
            const Text(
              'Hubungan dengan Anak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedHubungan.value,
                      isExpanded: true,
                      items: controller.hubunganOptions.map((h) {
                        return DropdownMenuItem(value: h, child: Text(h));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedHubungan.value = v;
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // Error Message
            Obx(() {
              if (controller.errorMessage.value != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.claimChild,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Tautkan Anak',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class ClaimChildBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimChildController>(() => ClaimChildController());
  }
}
