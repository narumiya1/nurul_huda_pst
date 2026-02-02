import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/psb_controller.dart';

class PsbView extends GetView<PsbController> {
  const PsbView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Penerimaan Santri Baru'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        // Show different UI based on user role
        if (controller.canManage) {
          return _buildAdminView();
        } else {
          return _buildPublicView();
        }
      }),
    );
  }

  /// Public/Netizen View - Show registration and check status options
  Widget _buildPublicView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          const SizedBox(height: 32),

          // Action Cards
          _buildActionCard(
            icon: Icons.app_registration,
            title: 'Daftar Sekarang',
            subtitle: 'Daftarkan putra/putri Anda sebagai calon santri baru',
            color: AppColors.primary,
            onTap: () => Get.toNamed('/psb/form'),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.search,
            title: 'Cek Status Pendaftaran',
            subtitle: 'Lihat status pendaftaran dengan nomor pendaftaran',
            color: Colors.blue,
            onTap: () => Get.toNamed('/psb/cek-status'),
          ),

          const SizedBox(height: 32),

          // Info Section
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pendaftaran Santri Baru',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tahun Ajaran 2025/2026',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderStat('Kuota', '200'),
              Container(
                width: 1,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white24,
              ),
              _buildHeaderStat('Pendaftaran', 'Dibuka'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Pendaftaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.list_alt,
          title: 'Persyaratan',
          items: [
            'Kartu Keluarga (KK)',
            'Akta Kelahiran',
            'Ijazah/Surat Keterangan Lulus',
            'Pas Foto terbaru',
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.timeline,
          title: 'Alur Pendaftaran',
          items: [
            '1. Isi formulir pendaftaran online',
            '2. Simpan nomor pendaftaran',
            '3. Tunggu verifikasi admin',
            '4. Cek status pendaftaran secara berkala',
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Admin View - Show statistics and registrant list
  Widget _buildAdminView() {
    return RefreshIndicator(
      onRefresh: controller.fetchPsbData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildSearchAndFilter(),
            const SizedBox(height: 24),
            const Text(
              'Daftar Pendaftar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildRegistrantList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = controller.stats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Total Daftar', stats['total']?.toString() ?? '0',
            AppColors.primary),
        _buildStatCard('Diterima', stats['accepted']?.toString() ?? '0',
            AppColors.success),
        _buildStatCard(
            'Menunggu', stats['pending']?.toString() ?? '0', AppColors.warning),
        _buildStatCard(
            'Ditolak', stats['rejected']?.toString() ?? '0', AppColors.error),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Cari nama/NISN...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String?>(
            onSelected: controller.filterByStatus,
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Semua')),
              const PopupMenuItem(value: 'pending', child: Text('Menunggu')),
              const PopupMenuItem(
                  value: 'verified', child: Text('Terverifikasi')),
              const PopupMenuItem(value: 'accepted', child: Text('Diterima')),
              const PopupMenuItem(value: 'rejected', child: Text('Ditolak')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrantList() {
    if (controller.filteredRegistrants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('Tidak ada data pendaftar'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredRegistrants.length,
      itemBuilder: (context, index) {
        final item = controller.filteredRegistrants[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (item['nama_lengkap'] ?? 'N')[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama_lengkap'] ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'No: ${item['no_pendaftaran'] ?? '-'}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      item['asal_sekolah'] ?? '-',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(item['status'] ?? 'pending'),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item['created_at']),
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 10),
                  ),
                ],
              ),
              if (controller.canManage) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (status) => controller.updateRegistrationStatus(
                    item['id'],
                    status,
                  ),
                  icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'verified', child: Text('Verifikasi')),
                    const PopupMenuItem(
                        value: 'accepted', child: Text('Terima')),
                    const PopupMenuItem(
                        value: 'rejected', child: Text('Tolak')),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'verified':
        color = Colors.blue;
        label = 'VERIFIED';
        break;
      case 'accepted':
        color = AppColors.success;
        label = 'DITERIMA';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'DITOLAK';
        break;
      default:
        color = AppColors.warning;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date.toString();
    }
  }
}
