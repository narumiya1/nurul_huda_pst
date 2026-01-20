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
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          // Custom App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Manajemen SDM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.accentPurple.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Role Filter Grid
          SliverToBoxAdapter(
            child: _buildRoleFilterGrid(),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),

          // User List
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (controller.filteredUsers.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.textLight.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 60,
                          color: AppColors.textLight.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih kategori di atas untuk melihat data',
                        style: TextStyle(
                          color: AppColors.textLight.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Check if it's the last item and we are loading more
                    if (index == controller.filteredUsers.length) {
                      return Obx(() => controller.isMoreLoading.value
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const SizedBox.shrink());
                    }

                    final user = controller.filteredUsers[index];
                    return _buildUserCard(user);
                  },
                  // Add +1 to item count for the loading indicator
                  childCount: controller.filteredUsers.length + 1,
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() => controller.canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showAddOptions(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Data',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : const SizedBox.shrink()),
    );
  }

  void _showAddOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Data Baru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildAddOptionItem(
              icon: Icons.school_outlined,
              color: const Color(0xFF3498DB),
              title: 'Tambah Siswa',
              subtitle: 'Input data siswa sekolah',
              onTap: () {
                Get.back();
                _showAddSiswaForm(context);
              },
            ),
            const SizedBox(height: 16),
            _buildAddOptionItem(
              icon: Icons.face_outlined,
              color: const Color(0xFF00B894),
              title: 'Tambah Santri',
              subtitle: 'Input data santri baru',
              onTap: () {
                Get.back();
                _showAddSantriForm(context);
              },
            ),
            const SizedBox(height: 16),
            _buildAddOptionItem(
              icon: Icons.badge_outlined,
              color: const Color(0xFFE17055),
              title: 'Tambah Staff',
              subtitle: 'Input data staff baru',
              onTap: () {
                Get.back();
                _showAddStaffForm(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOptionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textLight.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textLight.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterGrid() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kategori SDM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.roles.length,
            itemBuilder: (context, index) {
              final role = controller.roles[index];
              return _buildRoleGridItem(role, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleGridItem(String role, int index) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == role;
      final color = _getRoleColor(role);
      final icon = _getRoleIcon(role);

      return GestureDetector(
        onTap: () => controller.filterByRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getShortRoleName(role),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getShortRoleName(String role) {
    switch (role) {
      case 'Orang Tua':
        return 'Ortu';
      default:
        return role;
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => controller.searchUser(value),
          decoration: InputDecoration(
            hintText: 'Cari nama atau email...',
            hintStyle: TextStyle(
              color: AppColors.textLight.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textLight.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String role = user['role'] ?? '';
    final String status = user['status'] ?? '';
    final Color roleColor = _getRoleColor(role);

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.manajemenSdmDetail, arguments: user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              roleColor,
                              roleColor.withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: roleColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(user['name'] ?? ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email'] ?? '',
                              style: TextStyle(
                                color:
                                    AppColors.textLight.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildTag(
                                  role,
                                  roleColor.withValues(alpha: 0.1),
                                  roleColor,
                                ),
                                _buildTag(
                                  status,
                                  status == 'Aktif'
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.error.withValues(alpha: 0.1),
                                  status == 'Aktif'
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textLight.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Semua':
        return AppColors.primary;
      case 'Pimpinan':
        return const Color(0xFF9B59B6);
      case 'Guru':
        return const Color(0xFF3498DB);
      case 'Staff':
        return const Color(0xFFE67E22);
      case 'Orang Tua':
        return const Color(0xFF1ABC9C);
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
      case 'Semua':
        return Icons.groups_outlined;
      case 'Pimpinan':
        return Icons.account_balance_outlined;
      case 'Guru':
        return Icons.school_outlined;
      case 'Staff':
        return Icons.work_outline;
      case 'Orang Tua':
        return Icons.family_restroom_outlined;
      case 'Santri':
        return Icons.menu_book_outlined;
      case 'Siswa':
        return Icons.backpack_outlined;
      default:
        return Icons.person_outline;
    }
  }

  void _showAddSantriForm(BuildContext context) {
    final nameController = TextEditingController();
    final nisController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final gender = 'L'.obs;
    final dobController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Santri Baru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nisController,
                decoration: const InputDecoration(labelText: 'NIS'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'No. HP / WA'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: gender.value,
                    decoration:
                        const InputDecoration(labelText: 'Jenis Kelamin'),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (val) => gender.value = val!,
                  )),
              const SizedBox(height: 12),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365 * 10)),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dobController.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        nisController.text.isEmpty ||
                        emailController.text.isEmpty) {
                      Get.snackbar('Error', 'Mohon lengkapi data wajib',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white);
                      return;
                    }

                    controller.addSantri({
                      'full_name': nameController.text,
                      'nis': nisController.text,
                      'email': emailController.text,
                      'no_hp': phoneController.text,
                      'alamat': addressController.text,
                      'jenis_kelamin': gender.value,
                      'tanggal_lahir': dobController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Data',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddStaffForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final roleName = 'staff_pesantren'.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Staff Baru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Konfirmasi Password'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: roleName.value,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(
                          value: 'staff_pesantren',
                          child: Text('Staff Pesantren')),
                      DropdownMenuItem(
                          value: 'staff_keuangan',
                          child: Text('Staff Keuangan')),
                    ],
                    onChanged: (val) => roleName.value = val!,
                  )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      Get.snackbar('Error', 'Mohon lengkapi data wajib',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white);
                      return;
                    }

                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      Get.snackbar('Error', 'Password konfirmasi tidak cocok',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white);
                      return;
                    }

                    controller.addStaff({
                      'full_name': nameController.text,
                      'email': emailController.text,
                      'password': passwordController.text,
                      'password_confirmation': confirmPasswordController.text,
                      'role_name': roleName.value,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Data',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddSiswaForm(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final nisController = TextEditingController();
    final nisnController = TextEditingController();
    final tahunMasukController =
        TextEditingController(text: DateTime.now().year.toString());
    final phoneController = TextEditingController();

    final selectedSekolah = Rxn<int>();
    final sekolahList = <dynamic>[].obs;
    final isLoadingSekolah = true.obs;

    final isJugaSantri = false.obs;
    final nisSantriController = TextEditingController();

    // Fetch sekolah list
    try {
      final res = await controller.fetchSekolahList();
      sekolahList.value = res;
    } finally {
      isLoadingSekolah.value = false;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Siswa Baru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // --- Data Utama ---
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: 'Email (untuk login)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nisController,
                      decoration:
                          const InputDecoration(labelText: 'NIS (Sekolah)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: nisnController,
                      decoration: const InputDecoration(labelText: 'NISN'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Sekolah Dropdown ---
              Obx(() => isLoadingSekolah.value
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      initialValue: selectedSekolah.value,
                      decoration: const InputDecoration(labelText: 'Sekolah'),
                      items: sekolahList
                          .map((s) => DropdownMenuItem<int>(
                                value: s['id'],
                                child: Text(
                                    s['nama_sekolah'] ?? 'Sekolah #${s['id']}'),
                              ))
                          .toList(),
                      onChanged: (val) => selectedSekolah.value = val,
                    )),

              const SizedBox(height: 12),
              TextField(
                controller: tahunMasukController,
                decoration: const InputDecoration(labelText: 'Tahun Masuk'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration:
                    const InputDecoration(labelText: 'No. HP (Opsional)'),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),
              const Divider(),

              // --- Opsi Santri ---
              Obx(() => CheckboxListTile(
                    title: const Text('Juga Terdaftar sebagai Santri?'),
                    value: isJugaSantri.value,
                    onChanged: (val) => isJugaSantri.value = val ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),

              Obx(() => isJugaSantri.value
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: nisSantriController,
                        decoration: const InputDecoration(
                          labelText: 'NIS Santri (Opsional)',
                          helperText:
                              'Jika kosong, akan digenerate otomatis S-[NIS]',
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        nisController.text.isEmpty ||
                        selectedSekolah.value == null) {
                      Get.snackbar('Error',
                          'Mohon lengkapi data wajib (Nama, Email, NIS, Sekolah)',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white);
                      return;
                    }

                    final data = {
                      'full_name': nameController.text,
                      'email': emailController.text,
                      'nis': nisController.text,
                      'nisn': nisnController.text,
                      'sekolah_id': selectedSekolah.value,
                      'tahun_masuk': int.tryParse(tahunMasukController.text) ??
                          DateTime.now().year,
                      'phone': phoneController.text,
                      'juga_santri': isJugaSantri.value,
                    };

                    if (isJugaSantri.value &&
                        nisSantriController.text.isNotEmpty) {
                      data['nis_santri'] = nisSantriController.text;
                    }

                    controller.addSiswa(data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Data Siswa',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
