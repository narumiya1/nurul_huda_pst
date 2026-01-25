import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:epesantren_mob/app/routes/app_pages.dart';
import 'package:epesantren_mob/app/modules/profil/controllers/profil_controller.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context),
            _buildInfoSection(),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (Navigator.canPop(context))
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
              else
                const SizedBox(width: 48),
              const Text(
                'Profil Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 3),
            ),
            child: Obx(() {
              final photoUrl =
                  controller.userData.value?['details']?['photo_url'];
              return CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: photoUrl != null
                    ? NetworkImage(
                        photoUrl.toString().startsWith('http')
                            ? photoUrl.toString()
                            : ApiHelper.buildUri(endpoint: '')
                                    .toString()
                                    .replaceAll('/v1/api/', '') +
                                (photoUrl.toString().startsWith('/')
                                    ? photoUrl.toString()
                                    : '/$photoUrl'),
                      )
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 56, color: Colors.white)
                    : null,
              );
            }),
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() => Text(
                  controller.userRole,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                _buildInfoRow(
                    Icons.email_outlined, 'Email', controller.userEmail),
                const Divider(height: 32),
                _buildInfoRow(
                    Icons.phone_outlined, 'Telepon', controller.userPhone),
                if (controller.claimCode != '-') ...[
                  const Divider(height: 32),
                  _buildInfoRow(
                      Icons.qr_code, 'Kode Claim', controller.claimCode),
                ],
              ],
            ),
          )),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Obx(() => Column(
            children: [
              _buildMenuItem(Icons.person_outline, 'Edit Profil',
                  () => _showEditProfileDialog()),
              _buildMenuItem(Icons.lock_outline, 'Ubah Password',
                  () => _showChangePasswordDialog()),
              if (!controller.isPimpinan)
                _buildMenuItem(Icons.rule, 'Catatan Pelanggaran',
                    () => Get.toNamed(Routes.pelanggaran)),
              _buildMenuItem(
                  Icons.help_outline, 'Bantuan', () => _showHelpDialog()),
              _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi',
                  () => _showAboutDialog()),
              const SizedBox(height: 12),
              _buildMenuItem(Icons.logout, 'Keluar', () => controller.logout(),
                  isLogout: true),
            ],
          )),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isLogout ? AppColors.error : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: isLogout ? AppColors.error : AppColors.primary,
                      size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Edit Profil',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: controller.fullNameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.addressController,
                label: 'Alamat',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Perubahan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showChangePasswordDialog() {
    // Clear password fields
    controller.oldPasswordController.clear();
    controller.newPasswordController.clear();
    controller.confirmPasswordController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Ubah Password',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => _buildTextField(
                    controller: controller.oldPasswordController,
                    label: 'Password Lama',
                    icon: Icons.lock_outline,
                    obscureText: controller.obscureOld.value,
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscureOld.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => controller.obscureOld.value =
                          !controller.obscureOld.value,
                    ),
                  )),
              const SizedBox(height: 16),
              Obx(() => _buildTextField(
                    controller: controller.newPasswordController,
                    label: 'Password Baru',
                    icon: Icons.lock,
                    obscureText: controller.obscureNew.value,
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscureNew.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => controller.obscureNew.value =
                          !controller.obscureNew.value,
                    ),
                  )),
              const SizedBox(height: 16),
              Obx(() => _buildTextField(
                    controller: controller.confirmPasswordController,
                    label: 'Konfirmasi Password Baru',
                    icon: Icons.lock,
                    obscureText: controller.obscureConfirm.value,
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscureConfirm.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => controller.obscureConfirm.value =
                          !controller.obscureConfirm.value,
                    ),
                  )),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Ubah Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Bantuan'),
          ],
        ),
        content: Obx(() {
          final s = controller.settings.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s?['contact_description'] ??
                  'Jika Anda membutuhkan bantuan, silakan hubungi:'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(s?['contact_phone'] ?? '(021) 123-4567'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(s?['contact_email'] ?? 'admin@pesantren.id')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s?['contact_address'] ?? 'Alamat Pesantren',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Tentang Aplikasi'),
          ],
        ),
        content: Obx(() {
          final s = controller.settings.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: s?['logo'] != null
                    ? Image.network(
                        ApiHelper.buildUri(endpoint: '').toString() +
                            s!['logo'].toString().replaceFirst('/', ''),
                        height: 64,
                        width: 64,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.business,
                                size: 48, color: AppColors.primary),
                      )
                    : const Icon(Icons.business,
                        size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                s?['nama_website'] ?? 'e-Pesantren',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                s?['deskripsi_singkat'] ??
                    'Aplikasi manajemen pesantren terintegrasi untuk memudahkan pengelolaan santri, absensi, keuangan, dan aktivitas pesantren.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              if (s?['coppyright_footer'] != null) ...[
                const SizedBox(height: 24),
                Text(
                  s!['coppyright_footer'],
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
