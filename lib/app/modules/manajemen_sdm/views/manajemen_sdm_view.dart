import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';
import '../controllers/manajemen_sdm_controller.dart';

class ManajemenSdmView extends GetView<ManajemenSdmController> {
  const ManajemenSdmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen SDM'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 80,
                          color: AppColors.textLight.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return _buildUserCard(user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => controller.searchUser(value),
            decoration: InputDecoration(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.roles.length,
              itemBuilder: (context, index) {
                final role = controller.roles[index];
                return Obx(() {
                  final isSelected = controller.selectedRole.value == role;
                  return GestureDetector(
                    onTap: () => controller.filterByRole(role),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(
                                color:
                                    AppColors.textLight.withValues(alpha: 0.2)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String role = user['role'] ?? '';
    final String status = user['status'] ?? '';

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.manajemenSdmDetail, arguments: user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(role),
                color: _getRoleColor(role),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Aktif'
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: status == 'Aktif'
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() => controller.canManage
                ? const SizedBox.shrink() // Removed "More" button
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Pimpinan':
        return AppColors.accentPurple;
      case 'Guru':
        return AppColors.accentBlue;
      case 'Staff':
        return AppColors.accentOrange;
      case 'Orang Tua':
        return AppColors.primary;
      case 'Santri':
        return const Color(0xFF00B894);
      case 'Siswa':
        return const Color(0xFF6C5CE7);
      default:
        return AppColors.textLight;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Pimpinan':
        return Icons.account_balance_outlined;
      case 'Guru':
        return Icons.school_outlined;
      case 'Staff':
        return Icons.work_outline;
      case 'Orang Tua':
        return Icons.family_restroom_outlined;
      case 'Santri':
        return Icons.face_outlined;
      case 'Siswa':
        return Icons.child_care_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
