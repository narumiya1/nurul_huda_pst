import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/pondok_controller.dart';

class PondokView extends GetView<PondokController> {
  const PondokView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Pondok'),
        centerTitle: true,
        actions: [
          Obx(() => controller.canManage
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_business_outlined,
                      color: AppColors.primary),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPondokData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Asrama / Gedung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDormList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsGrid() {
    final stats = controller.dormStats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Total Asrama', stats['total_asrama']?.toString() ?? '0',
            AppColors.primary, Icons.apartment),
        _buildStatCard('Total Kamar', stats['total_kamar']?.toString() ?? '0',
            AppColors.accentBlue, Icons.meeting_room),
        _buildStatCard('Total Santri', stats['total_santri']?.toString() ?? '0',
            AppColors.success, Icons.people),
        _buildStatCard(
            'Kapasitas Sisa',
            stats['kapasitas_tersedia']?.toString() ?? '0',
            AppColors.accentOrange,
            Icons.event_seat),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDormList() {
    if (controller.dormList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow,
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.home_work_outlined,
                  size: 48, color: AppColors.textSecondary),
              SizedBox(height: 12),
              Text('Belum ada data asrama',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.dormList.length,
      itemBuilder: (context, index) {
        final dorm = controller.dormList[index];
        final isFull = dorm['status'] == 'Full';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isFull ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  color: isFull ? AppColors.error : AppColors.primary,
                ),
              ),
              title: Text(
                dorm['name'] ?? 'Blok',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                '${dorm['occupied_rooms']}/${dorm['total_rooms']} Kamar Terisi',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isFull ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (dorm['status'] ?? 'Available').toString().toUpperCase(),
                  style: TextStyle(
                    color: isFull ? AppColors.error : AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const Divider(),
                      _buildDormDetailRow('Lokasi', dorm['lokasi'] ?? '-'),
                      _buildDormDetailRow('Kapasitas Total',
                          '${dorm['kapasitas'] ?? 0} Santri'),
                      _buildDormDetailRow('Santri Terisi',
                          '${dorm['total_santri'] ?? 0} Orang'),
                      _buildDormDetailRow(
                          'Kepala Asrama / ROIS', dorm['rois'] ?? '-'),
                      const SizedBox(height: 12),
                      if (controller.canManage)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to room management
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Kelola Kamar',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDormDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Flexible(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
