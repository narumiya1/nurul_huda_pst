import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/administrasi_controller.dart';

class AdministrasiView extends GetView<AdministrasiController> {
  const AdministrasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administrasi & Arsip'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
          ),
          Obx(() => controller.canManage
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.note_add_outlined,
                      color: AppColors.primary),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabSwitcher(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.tabIndex.value == 0) {
                return _buildArchiveList();
              } else {
                return _buildDownloadList();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Obx(() => Row(
            children: [
              _buildTabItem(0, 'Arsip Surat', Icons.inventory_2_outlined),
              _buildTabItem(1, 'File Unduhan', Icons.download_done_rounded),
            ],
          )),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = controller.tabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.tabIndex.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveList() {
    if (controller.filteredArchives.isEmpty) {
      return const Center(child: Text('Tidak ada arsip ditemukan'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.filteredArchives.length,
      itemBuilder: (context, index) {
        final item = controller.filteredArchives[index];
        return InkWell(
          onTap: () => _showDetailDialog(context, item),
          borderRadius: BorderRadius.circular(16),
          child: _buildArchiveCard(item),
        );
      },
    );
  }

  Widget _buildDownloadList() {
    if (controller.downloadedFiles.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_for_offline_outlined,
              size: 64, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Belum ada file yang diunduh',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.downloadedFiles.length,
      itemBuilder: (context, index) {
        final file = controller.downloadedFiles[index];
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file['fileName'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${file['downloadDate']} • ${file['size']}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 20, color: AppColors.primary),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Administrasi',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () {
                      controller.resetFilters();
                      Get.back();
                    },
                    child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Tipe Dokumen',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  children: ['Semua', 'Surat Masuk', 'Surat Keluar', 'Proposal']
                      .map((t) {
                    final isSelected = controller.selectedType.value == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (val) => controller.applyFilters(type: t),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 12),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 20),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  children: ['Semua', 'Arsip', 'Proses', 'Selesai'].map((s) {
                    final isSelected = controller.selectedStatus.value == s;
                    return ChoiceChip(
                      label: Text(s),
                      selected: isSelected,
                      onSelected: (val) => controller.applyFilters(status: s),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 12),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Terapkan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['type'],
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        Text(item['title'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 32),
              _buildDetailInfo('Nomor Surat', item['number']),
              _buildDetailInfo('Tanggal', item['date']),
              _buildDetailInfo('Pengirim', item['sender'] ?? '-'),
              _buildDetailInfo('Penerima', item['recipient'] ?? '-'),
              const SizedBox(height: 16),
              const Text('Isi Singkat / Perihal:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(item['content'] ?? 'Tidak ada deskripsi berkas.',
                  style: const TextStyle(height: 1.5)),
              const SizedBox(height: 24),
              if (item['attachment'] != null)
                InkWell(
                  onTap: () => controller.downloadFile(item['attachment']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.textLight.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item['attachment'],
                              style: const TextStyle(fontSize: 12)),
                        ),
                        const Icon(Icons.download,
                            size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          const Text(': ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.searchQuery.value = value,
        onSubmitted: (value) => controller.searchArchive(value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari judul atau nomor surat...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.searchQuery.value.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textLight, size: 20),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                        controller.searchArchive('');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.primary, size: 20),
                    onPressed: () =>
                        controller.searchArchive(controller.searchQuery.value),
                  ),
                ],
              )),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  item['number'],
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(item['type'], AppColors.accentBlue),
                    const SizedBox(width: 8),
                    _buildBadge(item['status'], AppColors.success),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['date'],
                style:
                    const TextStyle(color: AppColors.textLight, fontSize: 11),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
