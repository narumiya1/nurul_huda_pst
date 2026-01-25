import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/absensi_controller.dart';

class AbsensiView extends GetView<AbsensiController> {
  const AbsensiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kehadiran & Izin',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: controller.tabController,
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
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildAbsensiTab(),
          _buildPerizinanTab(context),
        ],
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
              if (controller.userRole == 'orangtua') ...[
                _buildChildSelectorContent(),
                const SizedBox(height: 20),
              ],
              _buildSummaryCardsContent(),
              const SizedBox(height: 24),
              const Text(
                'Riwayat Kehadiran Lengkap',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildAbsensiListContent(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChildSelectorContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.softShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedChildKey.value,
          isExpanded: true,
          hint: const Text("Pilih Anak"),
          items: controller.children.map((child) {
            final key = '${child['tipe']}_${child['id']}';
            final tipe = child['tipe'] ?? '';
            return DropdownMenuItem<String>(
              value: key,
              child: Text('${child['nama'] ?? 'Tanpa Nama'} ($tipe)'),
            );
          }).toList(),
          onChanged: controller.onChildKeyChanged,
        ),
      ),
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
                          '${item['tanggal_keluar']} s/d ${item['tanggal_kembali']}', // Adjust fields based on API
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (item['penjemput'] != null &&
                            item['penjemput'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'Penjemput: ${item['penjemput']}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '"${item['alasan'] ?? ''}"',
                          style: const TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    });
  }

  void _showPermissionForm(BuildContext context) {
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
              const Text('Form Pengajuan Izin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              if (controller.userRole == 'orangtua') ...[
                const Text('Pilih Anak',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildChildSelectorContent(),
                const SizedBox(height: 16),
              ],

              // Jenis Izin
              const Text('Jenis Izin',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Sakit', 'Pulang', 'Keluar'].map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: controller.selectedJenisIzin.value == type,
                        onSelected: (val) =>
                            controller.selectedJenisIzin.value = type,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                            color: controller.selectedJenisIzin.value == type
                                ? AppColors.primary
                                : Colors.black),
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 16),

              if (controller.selectedJenisIzin.value == 'Pulang') ...[
                TextField(
                  controller: controller.penjemputController,
                  decoration: InputDecoration(
                    labelText: 'Nama Penjemput',
                    hintText: 'Siapa yang menjemput?',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: controller.tanggalKeluarController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    controller.tanggalKeluarController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tanggal Mulai',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller.tanggalKembaliController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    controller.tanggalKembaliController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tanggal Selesai (Rencana)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller.alasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alasan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.submitIzin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajukan Sekarang',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSummaryCardsContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Hadir', controller.totalHadir,
                  AppColors.success, Icons.check_circle),
              _buildSummaryItem('Izin', controller.totalIzin, AppColors.primary,
                  Icons.info_outline),
              _buildSummaryItem('Sakit', controller.totalSakit,
                  AppColors.warning, Icons.medical_services_outlined),
              _buildSummaryItem('Alpha', controller.totalAlpha, AppColors.error,
                  Icons.cancel_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiListContent() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.absensiList.length,
      itemBuilder: (context, index) {
        final item = controller.absensiList[index];
        final status = (item['status'] ?? 'hadir') as String;
        final date = (item['date'] ?? '-') as String;
        final keterangan = (item['keterangan'] ?? '-') as String;
        final detail = (item['detail'] ?? '-') as String;
        final tipe = (item['tipe'] ?? '-') as String;
        final color = _getStatusColor(status.toLowerCase());

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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getStatusIcon(status.toLowerCase()), color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("$detail ($tipe)",
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    if (keterangan != '-' && keterangan.isNotEmpty)
                      Text("Ket: $keterangan",
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hadir':
        return AppColors.success;
      case 'izin':
        return AppColors.accentBlue;
      case 'sakit':
        return AppColors.accentOrange;
      case 'alpha':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  Color _getPermissionStatusColor(String status) {
    switch (status) {
      case 'disetujui':
        return AppColors.success;
      case 'menunggu':
        return AppColors.warning;
      case 'diajukan':
        return AppColors.warning;
      case 'ditolak':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'hadir':
        return Icons.check_circle_outline;
      case 'izin':
        return Icons.event_available_outlined;
      case 'sakit':
        return Icons.local_hospital_outlined;
      case 'alpha':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
