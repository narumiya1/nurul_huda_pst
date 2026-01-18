import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/akademik_pondok_controller.dart';

class AkademikPondokView extends GetView<AkademikPondokController> {
  const AkademikPondokView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMain = controller.selectedIndex.value == -1;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isMain
              ? 'Akademik & Pondok'
              : _getPageTitle(controller.selectedIndex.value)),
          centerTitle: true,
          leading: isMain
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back())
              : IconButton(
                  icon: const Icon(Icons.grid_view_rounded),
                  onPressed: () => controller.selectedIndex.value = -1),
          actions: [
            if (!isMain)
              IconButton(
                icon: const Icon(Icons.filter_list_rounded,
                    color: AppColors.primary),
                onPressed: () => _showFilterBottomSheet(context),
              ),
          ],
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : isMain
                ? _buildGridMenu()
                : _buildPageContent(controller.selectedIndex.value),
      );
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (controller.selectedIndex.value == 0 ||
                controller.selectedIndex.value == 3 ||
                controller.selectedIndex.value == 4) ...[
              const Text('Tingkat / Kelas',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'VII', 'VIII', 'IX']
                        .map((t) => ChoiceChip(
                              label: Text(t),
                              selected: controller.selectedTingkat.value == t,
                              onSelected: (val) {
                                controller.selectedTingkat.value = t;
                                controller.applyFilters();
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 20),
            ],
            if (controller.selectedIndex.value == 3) ...[
              const Text('Periode Absensi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Hari Ini', 'Bulan Ini']
                        .map((p) => ChoiceChip(
                              label: Text(p),
                              selected:
                                  controller.selectedAbsensiPeriod.value == p,
                              onSelected: (val) {
                                controller.selectedAbsensiPeriod.value = p;
                                controller.applyFilters();
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 20),
            ],
            if (controller.selectedIndex.value == 1) ...[
              const Text('Kategori Agenda',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'Ibadah', 'Sekolah', 'Pondok']
                        .map((c) => ChoiceChip(
                              label: Text(c),
                              selected: controller.selectedCategory.value == c,
                              onSelected: (val) {
                                controller.selectedCategory.value = c;
                                controller.applyFilters();
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 20),
            ],
            if (controller.selectedIndex.value == 2) ...[
              const Text('Kategori Kelompok',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'Pemula', 'Menengah', 'Lanjutan']
                        .map((c) => ChoiceChip(
                              label: Text(c),
                              selected:
                                  controller.selectedTahfidzGroup.value == c,
                              onSelected: (val) {
                                controller.selectedTahfidzGroup.value = c;
                                controller.applyFilters();
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 20),
            ],
            if (controller.selectedIndex.value == 4) ...[
              const Text('Kategori Mapel',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'Diniyah', 'Umum']
                        .map((c) => ChoiceChip(
                              label: Text(c),
                              selected:
                                  controller.selectedCurriculumType.value == c,
                              onSelected: (val) {
                                controller.selectedCurriculumType.value = c;
                                controller.applyFilters();
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 20),
            ],
            const Text('Periode Semester',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedSemester.value,
                  items: ['Ganjil 2025/2026', 'Genap 2024/2025']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedSemester.value = val;
                      controller.applyFilters();
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.resetFilters();
                      Get.back();
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Terapkan',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Rekap Nilai';
      case 1:
        return 'Agenda Kegiatan';
      case 2:
        return 'Progress Tahfidz';
      case 3:
        return 'Laporan Absensi';
      case 4:
        return 'Data Kurikulum';
      default:
        return 'Detail';
    }
  }

  Widget _buildGridMenu() {
    final menus = [
      {
        'title': 'Rekap Nilai',
        'icon': Icons.grade_rounded,
        'color': AppColors.primary
      },
      {
        'title': 'Agenda',
        'icon': Icons.event_note_rounded,
        'color': AppColors.accentBlue
      },
      {
        'title': 'Tahfidz',
        'icon': Icons.menu_book_rounded,
        'color': AppColors.success
      },
      {
        'title': 'Absensi',
        'icon': Icons.assignment_turned_in_rounded,
        'color': AppColors.accentOrange
      },
      {
        'title': 'Kurikulum',
        'icon': Icons.library_books_rounded,
        'color': AppColors.accentPurple
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return InkWell(
          onTap: () => controller.selectedIndex.value = index,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (menu['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(menu['icon'] as IconData,
                      color: menu['color'] as Color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  menu['title'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return _buildGradeRecap();
      case 1:
        return _buildAgenda();
      case 2:
        return _buildTahfidzProgress();
      case 3:
        return _buildAttendanceReport();
      case 4:
        return _buildCurriculumData();
      default:
        return const SizedBox.shrink();
    }
  }

  // Reuse existing sub-features but wrapped in SingleChildScrollView if needed
  Widget _buildGradeRecap() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredRekapNilai.length,
          itemBuilder: (context, index) {
            final item = controller.filteredRekapNilai[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tingkat ${item['tingkat']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCol('Rata-rata', '${item['rata_rata']}',
                            AppColors.primary),
                        _buildStatCol('Tertinggi', '${item['tertinggi']}',
                            AppColors.success),
                        _buildStatCol(
                            'Terendah', '${item['terendah']}', AppColors.error),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildAgenda() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredAgenda.length,
          itemBuilder: (context, index) {
            final item = controller.filteredAgenda[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.cardShadow,
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(item['time'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentBlue)),
                ),
                title: Text(item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['location']),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['category'] ?? '',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget _buildTahfidzProgress() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredTahfidz.length,
          itemBuilder: (context, index) {
            final item = controller.filteredTahfidz[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nama'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(item['type'] ?? '',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('${item['achieved']}/${item['target']} Juz',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: item['percent'],
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    color: AppColors.primary,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildAttendanceReport() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: controller.filteredLaporanAbsensi.map((item) {
              Color color = AppColors.primary;
              if (item['color'] == 'green') color = AppColors.success;
              if (item['color'] == 'red') color = AppColors.error;
              if (item['color'] == 'blue') color = AppColors.accentBlue;
              if (item['color'] == 'orange') color = AppColors.accentOrange;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: color, width: 4)),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['label'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${item['value']} Siswa',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildCurriculumData() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredKurikulum.length,
          itemBuilder: (context, index) {
            final item = controller.filteredKurikulum[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item['mapel'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['type'] ?? '',
                          style: const TextStyle(
                              color: AppColors.accentPurple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Pengajar: ${item['pengajar']}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.book,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Kitab: ${item['kitab']}',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }
}
