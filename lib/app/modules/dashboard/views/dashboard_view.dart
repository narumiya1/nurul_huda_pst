import 'package:epesantren_mob/app/widgets/custom_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'package:epesantren_mob/app/modules/profil/views/profil_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const ChatPage();
      case 2:
        return const NotifikasiPage();
      case 3:
        return const ProfilView();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _buildPage(controller.selectedIndex.value),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(),
      ),
    );
  }
}

class HomePage extends GetView<DashboardController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  _buildJadwalGuru(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Berita Terbaru", onSeeAll: () {}),
                  const SizedBox(height: 16),
                  _buildNewsSection(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Menu Utama", onSeeAll: () {}),
                  const SizedBox(height: 16),
                  _buildMenuGrid(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.softShadow,
                ),
                child: Image.asset('assets/logos.png', height: 32, width: 32),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Sentral Nurulhuda",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Sistem Manajemen Pesantren",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.softShadow,
                ),
                child: const Badge(
                  smallSize: 8,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      "Assalamu'alaikum! 👋",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(() => Text(
                        controller.userRoleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalGuru() {
    return Obx(() {
      // Only show for guru
      if (controller.userRole != 'guru') return const SizedBox.shrink();

      // Only show if there is schedule data (currently we need to add schedule data to dashboard controller)
      // Since the user asked to put it here, we will mock it for now or fetch it if possible.
      // But wait, the controller doesn't have jadwal data yet. Let's assume we will add it.
      // For now, let's just make the UI and bind it to a new controller variable.
      if (controller.jadwalGuru.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSectionTitle("Jadwal Mengajar Hari Ini"),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.jadwalGuru.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.jadwalGuru[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.cardShadow,
                  border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['jam_mulai'] != null
                            ? "${item['jam_mulai']} - ${item['jam_selesai']}"
                            : (item['jam'] ?? '-'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item['mapel'] is Map
                                        ? item['mapel']['nama']
                                        : item['mapel'])
                                    ?.toString() ??
                                '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.room,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "${(item['kelas'] is Map ? item['kelas']['nama_kelas'] : item['kelas'])?.toString() ?? '-'} • ${item['ruang']?.toString() ?? '-'}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildQuickStats() {
    return Obx(() {
      if (controller.quickStats.isEmpty) return const SizedBox.shrink();

      return Row(
        children: [
          _buildStatCard(
            icon: _getIconData(controller.quickStats['stat1']?['icon']),
            value: controller.quickStats['stat1']?['value'] ?? "0",
            label: controller.quickStats['stat1']?['label'] ?? "",
            color: AppColors.accentBlue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: _getIconData(controller.quickStats['stat2']?['icon']),
            value: controller.quickStats['stat2']?['value'] ?? "0",
            label: controller.quickStats['stat2']?['label'] ?? "",
            color: AppColors.accentPurple,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: _getIconData(controller.quickStats['stat3']?['icon']),
            value: controller.quickStats['stat3']?['value'] ?? "0",
            label: controller.quickStats['stat3']?['label'] ?? "",
            color: AppColors.accentOrange,
          ),
        ],
      );
    });
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people_outline;
      case 'school':
        return Icons.school_outlined;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'check_circle':
        return Icons.check_circle_outline;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              "Lihat Semua",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Obx(() {
      if (controller.isLoadingBerita.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (controller.beritaList.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.cardShadow,
          ),
          child: const Row(
            children: [
              Icon(Icons.newspaper_outlined,
                  color: AppColors.textLight, size: 40),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Belum ada berita terbaru",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: controller.beritaList.length,
          itemBuilder: (context, index) {
            final berita = controller.beritaList[index];
            return GestureDetector(
              onTap: () => Get.toNamed(Routes.beritaDetail, arguments: berita),
              child: Container(
                width: 280,
                margin: EdgeInsets.only(
                    right: index < controller.beritaList.length - 1 ? 16 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20)),
                      child: berita.imageUrl != null
                          ? Image.network(
                              berita.imageUrl!,
                              width: 100,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 100,
                                height: 180,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.broken_image,
                                    color: AppColors.primary, size: 30),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 180,
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.image,
                                  color: AppColors.primary, size: 40),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                berita.category ?? "News",
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              berita.title ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 12, color: AppColors.textLight),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    berita.publishedAt ?? "2 jam lalu",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMenuGrid() {
    final allMenuItems = [
      {
        'title': 'Master Data',
        'icon': Icons.people_alt_outlined,
        'color': AppColors.accentBlue,
        'roles': ['pimpinan', 'staff_pesantren', 'staff_keuangan']
      },
      {
        'title': 'PSB',
        'icon': Icons.app_registration_rounded,
        'color': AppColors.accentPurple,
        'roles': ['pimpinan', 'staff_pesantren']
      },
      {
        'title': 'Akademik',
        'icon': Icons.school_outlined,
        'color': AppColors.accentBlue,
        'roles': ['pimpinan', 'staff_pesantren', 'guru', 'santri', 'siswa']
      },
      {
        'title': 'Pondok',
        'icon': Icons.home_work_outlined,
        'color': const Color(0xFF6C5CE7),
        'roles': ['staff_pesantren', 'guru', 'santri', 'rois']
      },
      {
        'title': 'Keuangan',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.primary,
        'roles': ['pimpinan', 'staff_keuangan', 'santri', 'siswa', 'orangtua']
      },
      {
        'title': 'Administrasi',
        'icon': Icons.assignment_outlined,
        'color': const Color(0xFFE17055),
        'roles': ['pimpinan', 'staff_pesantren']
      },
      {
        'title': 'Kedisiplinan',
        'icon': Icons.gavel_outlined,
        'color': AppColors.error,
        'roles': ['guru', 'rois']
      },
      {
        'title': 'Monitoring',
        'icon': Icons.analytics_outlined,
        'color': AppColors.accentOrange,
        'roles': ['orangtua']
      },
      {
        'title': 'Area Guru',
        'icon': Icons.edit_note,
        'color': AppColors.success,
        'roles': ['guru', 'rois', 'staff_pesantren']
      },
    ];

    return Obx(() {
      final role = controller.userRole.toLowerCase();

      // Filter items based on role
      final filteredItems = allMenuItems.where((item) {
        final roles = item['roles'];
        if (roles == null) return true; // Show if no roles defined
        if (roles is! List) return true;
        final allowedRoles = List<String>.from(roles);
        return allowedRoles.contains(role);
      }).toList();

      // If no menu items match, show all items (for debugging or unrecognized roles)
      final displayItems = filteredItems.isEmpty ? allMenuItems : filteredItems;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          return GestureDetector(
            onTap: () {
              try {
                final title = item['title']?.toString() ?? 'Fitur';

                switch (title) {
                  case 'Master Data':
                    Get.toNamed(Routes.manajemenSdm);
                    break;
                  case 'Keuangan':
                    Get.toNamed(Routes.keuangan);
                    break;
                  case 'PSB':
                    Get.toNamed(Routes.psb);
                    break;
                  case 'Akademik':
                    Get.toNamed(Routes.akademikPondok);
                    break;
                  case 'Pondok':
                    Get.toNamed(Routes.pondok);
                    break;
                  case 'Tahfidz':
                    Get.toNamed(Routes.tahfidz);
                    break;
                  case 'Administrasi':
                    Get.toNamed(Routes.administrasi);
                    break;
                  case 'Kedisiplinan':
                    Get.toNamed(Routes.pelanggaran);
                    break;
                  case 'Absensi':
                    Get.toNamed(Routes.absensi);
                    break;
                  case 'Monitoring':
                    Get.toNamed(Routes.monitoring);
                    break;
                  case 'Area Guru':
                    Get.toNamed(Routes.teacherArea);
                    break;
                  case 'Jadwal Pelajaran':
                    Get.toNamed(Routes.jadwalPelajaran);
                    break;
                  case 'Profil':
                    Get.toNamed(Routes.profil);
                    break;
                  default:
                    Get.toNamed(Routes.featurePlaceholder, arguments: title);
                }
              } catch (e) {
                // Navigation error
              }
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (item['color'] is Color
                            ? item['color'] as Color
                            : Colors.grey)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    item['icon'] is IconData
                        ? item['icon'] as IconData
                        : Icons.help_outline,
                    color: item['color'] is Color
                        ? item['color'] as Color
                        : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title']?.toString() ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class ChatPage extends GetView<DashboardController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pesan"),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Pesan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Fitur pesan akan segera tersedia",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class NotifikasiPage extends GetView<DashboardController> {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 64,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Notifikasi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tidak ada notifikasi baru",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
