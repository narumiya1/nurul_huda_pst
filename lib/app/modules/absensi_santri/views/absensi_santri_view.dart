import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../api/santri/santri_repository.dart';
import '../controllers/absensi_santri_controller.dart';

class AbsensiSantriView extends GetView<AbsensiSantriController> {
  const AbsensiSantriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kehadiran Pondok',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: GetBuilder<AbsensiSantriController>(
            init: AbsensiSantriController(SantriRepository()),
            builder: (ctrl) => TabBar(
              controller: ctrl.tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Absensi'),
                Tab(text: 'Perizinan'),
              ],
            ),
          ),
        ),
      ),
      body: GetBuilder<AbsensiSantriController>(
        builder: (ctrl) => TabBarView(
          controller: ctrl.tabController,
          children: [
            _buildAbsensiTab(),
            _buildPerizinanTab(context),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.currentTabIndex.value == 1) {
          return FloatingActionButton.extended(
            onPressed: () => _showPermissionForm(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_task),
            label: const Text('Ajukan Izin'),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildAbsensiTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchAbsensi(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              const Text(
                'Riwayat Kehadiran Pondok',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildAbsensiList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCards() {
    final hadir = controller.absensiList
        .where((e) => e['status']?.toString().toLowerCase() == 'hadir')
        .length;
    final izin = controller.absensiList
        .where((e) => e['status']?.toString().toLowerCase() == 'izin')
        .length;
    final sakit = controller.absensiList
        .where((e) => e['status']?.toString().toLowerCase() == 'sakit')
        .length;
    final alpha = controller.absensiList
        .where((e) => e['status']?.toString().toLowerCase() == 'alpha')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Hadir', hadir.toString(), AppColors.success),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Izin', izin.toString(), AppColors.info),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Sakit', sakit.toString(), AppColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Alpha', alpha.toString(), AppColors.error),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiList() {
    if (controller.absensiList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.calendar_today_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Belum ada riwayat kehadiran',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.absensiList.length,
      itemBuilder: (context, index) {
        final item = controller.absensiList[index];
        final status = item['status']?.toString().toLowerCase() ?? 'hadir';
        final color = _getStatusColor(status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.cardShadow,
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(item['date'] ?? '-'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['detail'] ?? item['keterangan'] ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerizinanTab(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async => controller.fetchPerizinan(),
        color: AppColors.primary,
        child: controller.perizinanList.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('Belum ada riwayat perizinan',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.perizinanList.length,
                itemBuilder: (context, index) {
                  final item = controller.perizinanList[index];
                  final status = item['status'] ?? 'diajukan';
                  final color = _getPermissionStatusColor(status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.cardShadow,
                      border: Border(left: BorderSide(color: color, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['jenis_izin'] ?? 'Izin',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toString().toUpperCase(),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item['tanggal_keluar']} s/d ${item['tanggal_kembali']}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (item['alasan'] != null &&
                            item['alasan'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            item['alasan'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      );
    });
  }

  void _showPermissionForm(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajukan Perizinan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: controller.selectedJenisIzin.value,
                      decoration: InputDecoration(
                        labelText: 'Jenis Izin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Sakit', 'Pulang', 'Lainnya']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedJenisIzin.value = val;
                        }
                      },
                    )),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.alasanController,
                  decoration: InputDecoration(
                    labelText: 'Alasan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.tanggalKeluarController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Keluar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      controller.tanggalKeluarController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.tanggalKembaliController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Kembali',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      controller.tanggalKembaliController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.penjemputController,
                  decoration: InputDecoration(
                    labelText: 'Penjemput (Opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.submitPerizinan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Ajukan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppColors.success;
      case 'izin':
        return AppColors.info;
      case 'sakit':
        return AppColors.warning;
      case 'alpha':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'izin':
        return Icons.info;
      case 'sakit':
        return Icons.local_hospital;
      case 'alpha':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getPermissionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return AppColors.success;
      case 'ditolak':
        return AppColors.error;
      case 'diajukan':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
