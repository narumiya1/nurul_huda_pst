import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/pelanggaran_controller.dart';

class PelanggaranView extends GetView<PelanggaranController> {
  const PelanggaranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catatan Pelanggaran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pelanggaranList.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.pelanggaranList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Alhamdulillah, Bersih!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tidak ada catatan pelanggaran.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchPelanggaran(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.pelanggaranList.length,
            itemBuilder: (context, index) {
              final item = controller.pelanggaranList[index];
              final poin = item['poin'] ?? 0;
              final severityColor = _getSeverityColor(poin);
              final santriName = item['santri']?['details']?['full_name'] ??
                  item['santri']?['username'] ??
                  'Santri';

              return GestureDetector(
                onTap: () => _showDetailPelanggaran(context, item),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.cardShadow,
                    border: Border(
                        left: BorderSide(color: severityColor, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.isTeacher)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            santriName,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['judul_pelanggaran'] ?? 'Pelanggaran',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$poin Poin',
                              style: TextStyle(
                                  color: severityColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            item['tanggal_kejadian'] ?? '-',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.warning_amber_rounded,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            item['kategori'] ?? '-',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (item['tindakan'] != null)
                        Text(
                          'Tindakan: ${item['tindakan']}',
                          style: const TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: controller.isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => _showAddViolationForm(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Catat Pelanggaran',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  void _showAddViolationForm(BuildContext context) {
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
              const Text('Catat Pelanggaran Santri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Santri Selector with Search
              const Text('Cari & Pilih Santri',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<int>(
                          value: controller.selectedKelasId.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Kelas',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                                value: null, child: Text("Semua Kelas")),
                            ...controller.kelasList.map((k) =>
                                DropdownMenuItem<int>(
                                    value: k['id'],
                                    child: Text(k['name'] ?? 'Kelas')))
                          ],
                          onChanged: (val) {
                            controller.selectedKelasId.value = val;
                            controller.fetchSantriList(
                                query: controller.searchController.text);
                          },
                        )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<int>(
                          value: controller.selectedKamarId.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Kamar',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                                value: null, child: Text("Semua Kamar")),
                            ...controller.kamarList.map((k) =>
                                DropdownMenuItem<int>(
                                    value: k['id'],
                                    child: Text(k['name'] ?? 'Kamar')))
                          ],
                          onChanged: (val) {
                            controller.selectedKamarId.value = val;
                            controller.fetchSantriList(
                                query: controller.searchController.text);
                          },
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Ketik nama atau NIS...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: Obx(() => controller.isLoadingSantri.value
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(12),
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        )
                      : const SizedBox.shrink()),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: controller.santriList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text('Tidak ada santri ditemukan',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: controller.santriList.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (context, index) {
                              final s = controller.santriList[index];
                              final isSelected =
                                  controller.selectedSantriId.value ==
                                      (s['user_id'] ?? s['id']);
                              String name = 'Santri';
                              if (s['user'] != null &&
                                  s['user']['details'] != null) {
                                name = s['user']['details']['full_name'] ??
                                    s['user']['username'] ??
                                    name;
                              } else if (s['details'] != null) {
                                name = s['details']['full_name'] ??
                                    s['username'] ??
                                    name;
                              } else if (s['full_name'] != null) {
                                name = s['full_name'];
                              } else {
                                name = s['username'] ?? name;
                              }
                              final nis = s['nis'] ?? '-';

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary
                                          .withValues(alpha: 0.1),
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'S',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    )),
                                subtitle: Text('NIS: $nis',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: AppColors.primary)
                                    : null,
                                onTap: () {
                                  controller.selectedSantriId.value =
                                      s['user_id'] ?? s['id'];
                                  controller.searchController.text = name;
                                },
                              );
                            },
                          ),
                  )),

              const SizedBox(height: 16),
              TextField(
                controller: controller.judulController,
                decoration: InputDecoration(
                  labelText: 'Judul Pelanggaran',
                  hintText: 'Contoh: Terlambat Berjamaah',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Kategori Pelanggaran',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Ringan', 'Sedang', 'Berat'].map((k) {
                      return ChoiceChip(
                        label: Text(k),
                        selected: controller.selectedKategori.value == k,
                        onSelected: (_) =>
                            controller.selectedKategori.value = k,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 16),
              TextField(
                controller: controller.poinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Poin Pelanggaran',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: controller.tindakanController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Tindakan/Sanksi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.submitPelanggaran(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Data',
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

  Color _getSeverityColor(int poin) {
    if (poin < 10) return Colors.green;
    if (poin < 30) return Colors.orange;
    return Colors.red;
  }

  void _showDetailPelanggaran(BuildContext context, Map<String, dynamic> item) {
    final poin = item['poin'] ?? 0;
    final severityColor = _getSeverityColor(poin);
    final santriName = item['santri']?['details']?['full_name'] ??
        item['santri']?['username'] ??
        'Santri';
    final pelaporName = item['pelapor']?['details']?['full_name'] ??
        item['pelapor']?['username'] ??
        'Admin';

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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['judul_pelanggaran'] ?? 'Detail Pelanggaran',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (controller.isTeacher) ...[
                          const SizedBox(height: 4),
                          Text(
                            santriName,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: severityColor),
                    ),
                    child: Text(
                      '$poin Poin',
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(Icons.calendar_today, 'Tanggal Kejadian',
                  item['tanggal_kejadian'] ?? '-'),
              _buildDetailItem(Icons.warning_amber_rounded, 'Kategori',
                  item['kategori'] ?? '-'),
              _buildDetailItem(Icons.gavel, 'Tindakan / Sanksi',
                  item['tindakan'] ?? 'Belum ada tindakan'),
              _buildDetailItem(Icons.person_outline, 'Pelapor', pelaporName),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
