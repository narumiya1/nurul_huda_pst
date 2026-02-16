import 'package:qr_flutter/qr_flutter.dart';
import 'package:epesantren_mob/app/widgets/custom_bottom.dart';
import 'package:epesantren_mob/app/services/user_context_service.dart';
import 'package:epesantren_mob/app/core/user_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../helpers/api_helpers.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadQuickStats();
          await controller.fetchBerita();
          await controller.fetchJadwalGuru();
          await controller.fetchAttendanceHistory();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    _buildModeToggle(), // Mode toggle for dual-role users
                    _buildJadwalGuru(),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                    _buildChildrenList(),
                    const SizedBox(height: 28),
                    _buildSectionTitle("Menu Utama", onSeeAll: () {}),
                    const SizedBox(height: 16),
                    _buildMenuGrid(),
                    const SizedBox(height: 28),
                    _buildSectionTitle("Berita Terbaru", onSeeAll: () {}),
                    const SizedBox(height: 16),
                    _buildNewsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    return Obx(() {
      if (controller.userRole != 'orangtua' ||
          controller.childrenList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text("Anak Saya",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          SizedBox(
              height: 100,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.childrenList.length,
                  itemBuilder: (context, index) {
                    final child = controller.childrenList[index];
                    return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16, bottom: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.cardShadow),
                        child: Row(children: [
                          CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: child['foto'] != null
                                  ? NetworkImage(child['foto'])
                                  : null,
                              child: child['foto'] == null
                                  ? const Icon(Icons.person,
                                      color: AppColors.primary)
                                  : null),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Text(child['nama'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (child['tipe'] == 'Santri'
                                                ? AppColors.primary
                                                : Colors.blue)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        child['tipe'] ?? '-',
                                        style: TextStyle(
                                          color: (child['tipe'] == 'Santri'
                                              ? AppColors.primary
                                              : Colors.blue),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(child['kelas'] ?? '-',
                                          style: const TextStyle(
                                              color: AppColors.textLight,
                                              fontSize: 11),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ]))
                        ]));
                  }))
        ],
      );
    });
  }

  /// Mode toggle for dual-role users (Santri+Siswa)
  Widget _buildModeToggle() {
    // Get UserContextService
    if (!Get.isRegistered<UserContextService>()) {
      return const SizedBox.shrink();
    }

    final ucs = Get.find<UserContextService>();

    return Obx(() {
      // Only show for dual-role users
      if (!ucs.isDualRole) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildModeTab(
                'Pondok',
                Icons.home_work_outlined,
                ActiveMode.pondok,
                AppColors.primary,
                ucs,
              ),
              _buildModeTab(
                'Sekolah',
                Icons.school_outlined,
                ActiveMode.sekolah,
                Colors.blue,
                ucs,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildModeTab(
    String label,
    IconData icon,
    ActiveMode mode,
    Color color,
    UserContextService ucs,
  ) {
    final isActive = ucs.activeMode.value == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => ucs.setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? color : AppColors.textLight,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? color : AppColors.textLight,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
              ],
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D7C5F), Color(0xFF1AAA37)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Background Shapes
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Obx(() {
                  final photoUrl =
                      controller.userData.value?['details']?['photo_url'];
                  return CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl.toString().startsWith('http')
                            ? photoUrl.toString()
                            : ApiHelper.buildUri(endpoint: '')
                                    .toString()
                                    .replaceAll('/v1/api/', '') +
                                (photoUrl.toString().startsWith('/')
                                    ? photoUrl.toString()
                                    : '/$photoUrl'))
                        : null,
                    child: photoUrl == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 34,
                          )
                        : null,
                  );
                }),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assalamu'alaikum! 👋",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => Text(
                          controller.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        )),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1),
                      ),
                      child: Obx(() => Text(
                            controller.userRoleLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.userRole == 'santri' ||
                    controller.userRole == 'siswa') {
                  return GestureDetector(
                    onTap: () => _showIdCard(controller),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showIdCard(DashboardController controller) {
    final isSiswa = controller.userRole == 'siswa';
    final title = isSiswa ? 'KARTU TANDA SISWA' : 'KARTU TANDA SANTRI';
    final schoolName =
        isSiswa ? 'SEKOLAH NURUL HUDA' : 'PONDOK PESANTREN NURUL HUDA';

    // Premium Gradients
    final gradientColors = isSiswa
        ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)] // Deep Blue
        : [const Color(0xFF0D7C5F), const Color(0xFF1AA37A)]; // Deep Green

    final photoUrl = controller.userData.value?['details']?['photo_url'];

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Micro-pattern Background
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: CustomPaint(
                          painter: CardPatternPainter(),
                        ),
                      ),
                    ),

                    // Glassy Watermark Logo
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset('assets/logos.png', height: 180),
                      ),
                    ),

                    // Top Decorative Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset('assets/logos.png',
                                    height: 24, width: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      schoolName,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.verified_user,
                                  color: Colors.white70, size: 20),
                            ],
                          ),

                          const Spacer(),

                          // Content
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Photo with Premium Border
                              Stack(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 110,
                                    decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.5),
                                            width: 2),
                                        image: photoUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(photoUrl
                                                        .toString()
                                                        .startsWith('http')
                                                    ? photoUrl.toString()
                                                    : ApiHelper.buildUri(
                                                                endpoint: '')
                                                            .toString()
                                                            .replaceAll(
                                                                '/v1/api/',
                                                                '') +
                                                        (photoUrl
                                                                .toString()
                                                                .startsWith('/')
                                                            ? photoUrl
                                                                .toString()
                                                            : '/$photoUrl')),
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                    child: photoUrl == null
                                        ? const Center(
                                            child: Icon(Icons.person,
                                                color: Colors.white70,
                                                size: 48))
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: -8,
                                    right: -8,
                                    child: IconButton(
                                      onPressed: () =>
                                          controller.showImageSourceDialog(),
                                      icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.camera_alt,
                                            size: 14,
                                            color: isSiswa
                                                ? const Color(0xFF1E3C72)
                                                : const Color(0xFF0D7C5F)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() => Text(
                                          controller.userName.toUpperCase(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: -0.5,
                                          ),
                                        )),
                                    const SizedBox(height: 6),
                                    Obx(() => Text(
                                          "NIS: ${controller.userData.value?['username'] ?? '-'}",
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'SFPro'),
                                        )),
                                    const SizedBox(height: 4),
                                    Obx(() {
                                      final stat1 =
                                          controller.quickStats['stat1'];
                                      final kelas =
                                          stat1?['value']?.toString() ?? '-';
                                      return Text(
                                        "KELAS: $kelas",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Obx(() => Text(
                                            controller.userRoleLabel
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: isSiswa
                                                    ? const Color(0xFF1E3C72)
                                                    : const Color(0xFF0D7C5F),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10),
                                          )),
                                    )
                                  ],
                                ),
                              ),

                              // Small QR at bottom right of data
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6)),
                                child: QrImageView(
                                  data:
                                      controller.userData.value?['username'] ??
                                          controller.userName,
                                  version: QrVersions.auto,
                                  size: 40.0,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 32),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            )
          ],
        ),
      ),
      barrierColor: Colors.black87,
    );
  }

  Widget _buildJadwalGuru() {
    return Obx(() {
      // Only show for guru
      if (!controller.isGuru) return const SizedBox.shrink();

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

      final stats = controller.quickStats;
      final keys = stats.keys.toList()..sort();
      final colors = [
        AppColors.accentBlue,
        AppColors.accentPurple,
        AppColors.accentOrange,
      ];

      return Row(
        children: List.generate(keys.length, (index) {
          final key = keys[index];
          final stat = stats[key];
          final color = colors[index % colors.length];

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index == keys.length - 1 ? 0 : 12),
              child: _buildStatCard(
                icon: _getIconData(stat?['icon']),
                value: stat?['value'] ?? "0",
                label: stat?['label'] ?? "",
                subValue: stat?['sub_value'],
                color: color,
              ),
            ),
          );
        }),
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
      case 'auto_stories':
        return Icons.auto_stories_outlined;
      case 'room':
        return Icons.room_outlined;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String? subValue,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subValue != null && subValue.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subValue,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              "Lihat Semua",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.beritaList.length,
          itemBuilder: (context, index) {
            final berita = controller.beritaList[index];
            return GestureDetector(
              onTap: () => Get.toNamed(Routes.beritaDetail, arguments: berita),
              child: Container(
                width: 300,
                margin: EdgeInsets.only(
                    right: 20, bottom: 10, left: index == 0 ? 0 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Background Image with Gradient Overlay
                      Positioned.fill(
                        child: berita.imageUrl != null
                            ? Image.network(
                                berita.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.broken_image,
                                      color: AppColors.primary, size: 30),
                                ),
                              )
                            : Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.image,
                                    color: AppColors.primary, size: 40),
                              ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (berita.category ?? "News").toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              berita.title ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  berita.publishedAt ?? "Baru saja",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMenuGrid() {
    // Menu items with optional 'modeRelevant' for dual-role filtering
    // 'modeRelevant': null means visible in all modes
    // 'modeRelevant': 'pondok' means only visible in Pondok mode
    // 'modeRelevant': 'sekolah' means only visible in Sekolah mode
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
        'title': 'Sekolah',
        'icon': Icons.school_outlined,
        'color': AppColors.accentBlue,
        'roles': [
          'pimpinan',
          'staff_pesantren',
          'guru',
          'guru_sekolah',
          'santri',
          'siswa'
        ],
        'modeRelevant': 'sekolah', // Only in Sekolah mode for dual-role
      },
      {
        'title': 'Pondok',
        'icon': Icons.home_work_outlined,
        'color': const Color(0xFF6C5CE7),
        'roles': [
          'pimpinan',
          'staff_pesantren',
          'guru',
          'guru_pesantren',
          'santri',
          'siswa',
          'rois'
        ],
        'modeRelevant': 'pondok', // Only in Pondok mode for dual-role
      },
      {
        'title': 'Keuangan',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.primary,
        'roles': ['pimpinan', 'staff_keuangan', 'santri', 'siswa', 'orangtua']
        // No modeRelevant - visible in all modes
      },
      {
        'title': 'Administrasi',
        'icon': Icons.assignment_outlined,
        'color': const Color(0xFFE17055),
        'roles': ['pimpinan', 'staff_pesantren', 'staff_keuangan']
      },
      {
        'title': 'Kedisiplinan',
        'icon': Icons.gavel_outlined,
        'color': AppColors.error,
        'roles': ['guru', 'guru_pesantren', 'guru_sekolah', 'rois']
      },
      {
        'title': 'Absensi',
        'icon': Icons.how_to_reg_outlined,
        'color': AppColors.primary,
        'roles': ['orangtua']
        // No modeRelevant - visible in all modes (content changes based on mode)
      },
      {
        'title': 'Tambah Anak',
        'icon': Icons.person_add_outlined,
        'color': AppColors.accentOrange,
        'roles': ['orangtua']
      },
      {
        'title': 'Area Guru',
        'icon': Icons.edit_note,
        'color': AppColors.success,
        'roles': [
          'guru',
          'guru_pesantren',
          'guru_sekolah',
          'rois',
          'staff_pesantren'
        ]
      },
    ];

    // Get UserContextService for dual-role filtering
    UserContextService? ucs;
    if (Get.isRegistered<UserContextService>()) {
      ucs = Get.find<UserContextService>();
    }

    return Obx(() {
      final role = controller.userRole.toLowerCase();

      // Current active mode for filtering
      final currentMode = ucs?.isPondokMode == true ? 'pondok' : 'sekolah';
      final isDualRole = ucs?.isDualRole ?? false;

      // Filter items based on role AND active mode for dual-role users
      final filteredItems = allMenuItems.where((item) {
        final roles = item['roles'];
        if (roles == null) return true;
        if (roles is! List) return true;
        final allowedRoles = List<String>.from(roles);

        // First check role permission
        if (!allowedRoles.contains(role)) return false;

        // For dual-role users, also filter by mode
        if (isDualRole && item['modeRelevant'] != null) {
          final modeRelevant = item['modeRelevant'] as String;
          if (modeRelevant != currentMode) return false;
        }

        return true;
      }).toList();

      // If no menu items match, show all items (for debugging or unrecognized roles)
      final displayItems = filteredItems.isEmpty ? allMenuItems : filteredItems;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = displayItems[index];
            final color = (item['color'] is Color
                ? item['color'] as Color
                : AppColors.primary);

            return InkWell(
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
                    case 'Sekolah':
                      Get.toNamed(Routes.akademikPondok,
                          arguments: {'type': 'SCHOOL'});
                      break;
                    case 'Pondok':
                      if (role == 'santri' || role == 'siswa') {
                        Get.toNamed(Routes.akademikPondok,
                            arguments: {'type': 'PONDOK'});
                      } else {
                        Get.toNamed(Routes.pondok);
                      }
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
                    case 'Tambah Anak':
                      Get.toNamed(Routes.claimChild);
                      break;
                    default:
                      Get.toNamed(Routes.featurePlaceholder, arguments: title);
                  }
                } catch (e) {
                  // Navigation error
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'] is IconData
                            ? item['icon'] as IconData
                            : Icons.help_outline,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['title']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: color.withValues(alpha: 0.5),
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
}

// Custom Painter for decorative patterns
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    for (var i = 0; i < size.width; i += 20) {
      for (var j = 0; j < size.height; j += 20) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
