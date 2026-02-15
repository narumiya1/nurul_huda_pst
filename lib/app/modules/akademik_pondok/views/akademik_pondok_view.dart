import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';
import '../controllers/akademik_pondok_controller.dart';

class AkademikPondokView extends GetView<AkademikPondokController> {
  const AkademikPondokView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMain = controller.selectedIndex.value == -1;

      return PopScope(
        canPop: isMain, // Only allow system back if we're on main grid
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && !isMain) {
            // If we're in a sub-feature, go back to grid instead of popping
            controller.selectedIndex.value = -1;
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(isMain
                ? _getMainTitle()
                : _getPageTitle(controller.selectedIndex.value)),
            centerTitle: true,
            leading: isMain
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back())
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
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
          body: RefreshIndicator(
            onRefresh: () async => await controller.fetchAllData(),
            child: Column(
              children: [
                if (controller.userRole.value == 'orangtua')
                  _buildChildSelectorHeader(),
                Expanded(
                  child: isMain
                      ? _buildGridMenu()
                      : Obx(() => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : _buildPageContent(controller.selectedIndex.value)),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildChildSelectorHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.softShadow,
      ),
      child: Obx(() => DropdownButtonHideUnderline(
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
          )),
    );
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
            if ((controller.selectedIndex.value == 0 ||
                    controller.selectedIndex.value == 3 ||
                    controller.selectedIndex.value == 4) &&
                controller.userRole.value != 'santri' &&
                controller.userRole.value != 'siswa') ...[
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
            if (controller.selectedIndex.value == 5) ...[
              const Text('Status Tugas',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'Pending', 'Selesai']
                        .map((s) => ChoiceChip(
                              label: Text(s),
                              selected:
                                  controller.selectedTugasStatus.value == s,
                              onSelected: (val) {
                                controller.selectedTugasStatus.value = s;
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
                  initialValue: controller.selectedSemester.value,
                  items: [
                    'Ganjil 2025/2026',
                    'Genap 2025/2026',
                    'Ganjil 2024/2025',
                    'Genap 2024/2025'
                  ]
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

  String _getMainTitle() {
    if (controller.userRole.value == 'pimpinan') {
      return 'Akademik & Pondok';
    }

    // Determine title based on menuType
    if (controller.menuType.value == 'PONDOK') {
      return 'Area Pondok';
    } else if (controller.menuType.value == 'SCHOOL') {
      return 'Area Akademik';
    }
    return 'Akademik & Pondok'; // Default for 'ALL'
  }

  String _getPageTitle(int index) {
    if (controller.selectedIndex.value == -1) {
      if (controller.menuType.value == 'SCHOOL') return 'Area Sekolah';
      if (controller.menuType.value == 'PONDOK') return 'Area Pondok';
      return 'Area Akademik';
    }

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
        return controller.userRole.value == 'pimpinan'
            ? 'Data Kurikulum'
            : 'Materi Pelajaran';
      case 5:
        return 'Tugas Sekolah';
      case 6:
        return 'Jadwal Pelajaran';
      case 7:
        return 'Jadwal Aktivitas';
      default:
        return 'Detail';
    }
  }

  Widget _buildGridMenu() {
    final allMenus = [
      {
        'index': 0,
        'title': 'Rekap Nilai',
        'icon': Icons.grade_rounded,
        'color': AppColors.primary,
        'roles': [
          'pimpinan',
          'santri',
          'siswa',
          'guru',
          'staff_pesantren',
          'orangtua'
        ],
        'category': 'SCHOOL',
      },
      {
        'index': 3,
        'title': 'Absensi', // Riwayat Absensi
        'icon': Icons.assignment_turned_in_rounded,
        'color': AppColors.accentOrange,
        'roles': ['pimpinan', 'santri', 'siswa', 'staff_pesantren'],
        'category': 'ALL',
      },
      {
        'index': 6,
        'title': 'Jadwal',
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFF6C5CE7),
        'roles': ['santri', 'siswa', 'guru'],
        'category': 'SCHOOL',
      },
      {
        'index': 5,
        'title': 'Tugas',
        'icon': Icons.assignment_rounded,
        'color': Colors.blueGrey,
        'roles': [
          'pimpinan',
          'santri',
          'siswa',
          'guru',
          'staff_pesantren',
          'orangtua'
        ],
        'category': 'ALL',
      },
      {
        'index': 2,
        'title': 'Tahfidz',
        'icon': Icons.menu_book_rounded,
        'color': AppColors.success,
        'roles': [
          'pimpinan',
          'santri',
          'siswa',
          'guru',
          'staff_pesantren',
          'orangtua'
        ],
        'category': 'PONDOK',
      },
      {
        'index': 7,
        'title': 'Aktivitas',
        'icon': Icons.today_rounded,
        'color': const Color(0xFF00B894),
        'roles': ['santri', 'siswa', 'guru', 'staff_pesantren'],
        'category': 'PONDOK',
      },
      {
        'index': 8,
        'title': 'Kedisiplinan',
        'icon': Icons.gavel_rounded,
        'color': AppColors.error,
        'roles': ['santri', 'siswa', 'guru', 'staff_pesantren'],
        'category': 'PONDOK',
      },
      {
        'index': 9,
        'title': 'Perizinan',
        'icon': Icons.fact_check_rounded,
        'color': Colors.teal,
        'roles': ['santri', 'siswa', 'guru', 'staff_pesantren'],
        'category': 'PONDOK',
      },
    ];

    final menus = allMenus.where((menu) {
      final roles = menu['roles'] as List<String>;
      final isRoleAllowed = roles.contains(controller.userRole.value);
      if (!isRoleAllowed) return false;

      final category = menu['category'] as String;
      if (controller.menuType.value == 'ALL') return true;
      if (category == 'ALL') return true;
      return category == controller.menuType.value;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const AlwaysScrollableScrollPhysics(),
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
          onTap: () {
            final targetIndex = menu['index'] as int;
            final role = controller.userRole.value.toLowerCase().trim();
            final isSantri = role == 'santri';
            final isSiswa = role == 'siswa';

            if (targetIndex == 6) {
              Get.toNamed(Routes.jadwalPelajaran);
            } else if (targetIndex == 7) {
              Get.toNamed(Routes.aktivitas);
            } else if (targetIndex == 8) {
              Get.toNamed(Routes.pelanggaran);
            } else if (targetIndex == 9) {
              // Perizinan - use role-specific route
              if (isSantri) {
                Get.toNamed(Routes.absensiSantri, arguments: {'initialTab': 1});
              } else if (isSiswa) {
                Get.toNamed(Routes.absensiSiswa, arguments: {'initialTab': 1});
              } else {
                Get.toNamed(Routes.absensi, arguments: {'initialTab': 1});
              }
            } else if (targetIndex == 3 && (isSantri || isSiswa)) {
              // Absensi - use role-specific route
              if (isSantri) {
                Get.toNamed(Routes.absensiSantri, arguments: {'initialTab': 0});
              } else {
                Get.toNamed(Routes.absensiSiswa, arguments: {'initialTab': 0});
              }
            } else {
              controller.selectedIndex.value = targetIndex;
              controller.applyFilters();
            }
          },
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
                    color: (menu['color'] as Color).withValues(alpha: 0.1),
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
      case 2:
        return _buildTahfidzProgress();
      case 3:
        return _buildAttendanceReport();
      case 5:
        return _buildTugasSekolah();
      default:
        return const SizedBox.shrink();
    }
  }

  // Reuse existing sub-features but wrapped in SingleChildScrollView if needed
  Widget _buildGradeRecap() {
    return Obx(() {
      final role = controller.userRole.value.toLowerCase().trim();
      final isStaff = [
        'pimpinan',
        'superadmin',
        'admin',
        'guru',
        'staff_pesantren'
      ].contains(role);

      if (isStaff) {
        if (controller.selectedSiswaForDetail.value != null) {
          return _buildSiswaDetailNilai();
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (val) => controller.searchSiswaGrades(val),
                decoration: InputDecoration(
                  hintText: 'Cari siswa (Nama/NIS)...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.isSearchingSiswa.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            if (controller.searchSiswaResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.searchSiswaResults.length,
                  itemBuilder: (context, index) {
                    final siswa = controller.searchSiswaResults[index];
                    final name = siswa['user']?['details']?['full_name'] ??
                        siswa['nama'] ??
                        'Siswa';
                    final nis = siswa['nis'] ?? '-';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(name),
                        subtitle: Text('NIS: $nis'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          controller.selectedSiswaForDetail.value = siswa;
                          controller.fetchSiswaDetailNilai(siswa['id']);
                        },
                      ),
                    );
                  },
                ),
              )
            else if (controller.searchSiswaQuery.value.isNotEmpty)
              const Expanded(
                child: Center(child: Text('Siswa tidak ditemukan')),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                _buildStatCol('Rata-rata',
                                    '${item['rata_rata']}', AppColors.primary),
                                _buildStatCol('Tertinggi',
                                    '${item['tertinggi']}', AppColors.success),
                                _buildStatCol('Terendah', '${item['terendah']}',
                                    AppColors.error),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      }

      // Personal view for students - Grouped by Subject
      final groupedData = controller.groupedRekapNilai;
      final totalItems = controller.rekapNilai.length;

      debugPrint(
          'UI: Grouped Data size: ${groupedData.length}, Total raw items: $totalItems');
      if (groupedData.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                  'DEBUG: Role: ${controller.userRole.value} | Raw: ${controller.rekapNilai.length} | Grouped: ${controller.groupedRekapNilai.length}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Tidak ada data nilai'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.fetchAllData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang Data'),
              ),
            ],
          ),
        );
      }

      final subjects = groupedData.keys.toList();

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final grades = groupedData[subject]!;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary)),
                subtitle: Text('${grades.length} Penilaian',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppColors.primary, size: 24),
                ),
                children: [
                  const Divider(height: 1),
                  ...grades.map((grade) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        title: Text(grade['jenis'] ?? '-',
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text('${grade['semester']} ${grade['tahun']}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${grade['nilai']}',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildSiswaDetailNilai() {
    final siswa = controller.selectedSiswaForDetail.value!;
    final name =
        siswa['user']?['details']?['full_name'] ?? siswa['nama'] ?? 'Siswa';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.selectedSiswaForDetail.value = null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Detail Nilai Siswa',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.siswaNilaiDetail.isEmpty
                  ? const Center(child: Text('Tidak ada data nilai'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.siswaNilaiDetail.length,
                      itemBuilder: (context, index) {
                        final item = controller.siswaNilaiDetail[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppShadows.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['mapel'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${item['jenis']} • ${item['semester']}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text(
                                '${item['nilai']}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
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

  Widget _buildTahfidzProgress() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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

  Widget _buildTugasSekolah() {
    return Obx(() {
      if (controller.filteredTugas.isEmpty) {
        return const Center(
            child: Text("Tidak ada tugas saat ini.",
                style: TextStyle(color: Colors.grey)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.filteredTugas.length,
        itemBuilder: (context, index) {
          final item = controller.filteredTugas[index];
          final isDone = item['status'] == 'Selesai';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.cardShadow,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['judul'] ?? 'Tugas',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (item['source'] == 'Sekolah'
                                        ? Colors.blue
                                        : Colors.teal)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['source'] ?? '-',
                                style: TextStyle(
                                  color: item['source'] == 'Sekolah'
                                      ? Colors.blue
                                      : Colors.teal,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isDone
                                        ? AppColors.success
                                        : AppColors.accentOrange)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['status'] ?? 'Pending',
                                style: TextStyle(
                                  color: isDone
                                      ? AppColors.success
                                      : AppColors.accentOrange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(item['mapel'] is Map
                        ? item['mapel']['nama_mapel'] ??
                            item['mapel']['nama'] ??
                            '-'
                        : 'Mapel Lain'),
                    const SizedBox(height: 4),
                    Text('Deadline: ${item['deadline'] ?? '-'}',
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(item['description'] ?? item['deskripsi'] ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (item['file_path'] != null) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => controller.downloadFile(item['file_path']),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description,
                                size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text('Unduh Soal (PDF/Word)',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      )
                    ]
                  ]),
              trailing: (controller.userRole.value == 'santri' ||
                      controller.userRole.value == 'siswa')
                  ? ElevatedButton(
                      onPressed: isDone
                          ? null
                          : () => _showSubmissionForm(context, item),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDone ? Colors.grey : AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8)),
                      child: Text(isDone ? 'Sudah Kirim' : 'Kirim',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDone ? Colors.white70 : Colors.white)),
                    )
                  : OutlinedButton(
                      onPressed: () => _showSubmissionsList(context, item),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Lihat Jawaban',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    ),
            ),
          );
        },
      );
    });
  }

  void _showSubmissionsList(BuildContext context, Map<String, dynamic> task) {
    controller.fetchSubmissions(task['id'].toString());
    Get.to(() => Scaffold(
          appBar: AppBar(title: Text('Jawaban: ${task['judul']}')),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.submissionsList.isEmpty) {
              return const Center(child: Text('Belum ada jawaban terkumpul.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.submissionsList.length,
              itemBuilder: (context, index) {
                final sub = controller.submissionsList[index];
                final name =
                    sub['siswa']?['user']?['details']?['full_name'] ?? 'Siswa';
                final grade = sub['nilai'];
                final date = sub['created_at']?.toString().split('T')[0] ?? '-';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dikirim: $date'),
                        if (sub['text_submission'] != null)
                          Text('Jawaban: ${sub['text_submission']}',
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (grade != null)
                          Text('$grade',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary))
                        else
                          const Text('Belum Dinilai',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.orange)),
                        const Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                    onTap: () => _showGradingDialog(context, sub),
                  ),
                );
              },
            );
          }),
        ));
  }

  void _showGradingDialog(
      BuildContext context, Map<String, dynamic> submission) {
    final gradeController =
        TextEditingController(text: submission['nilai']?.toString() ?? '');
    final notesController =
        TextEditingController(text: submission['catatan_guru'] ?? '');
    final name =
        submission['siswa']?['user']?['details']?['full_name'] ?? 'Siswa';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Penilaian: $name',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (submission['text_submission'] != null) ...[
                const Text('Jawaban Siswa:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(submission['text_submission']),
                ),
                const SizedBox(height: 16),
              ],
              if (submission['files'] != null &&
                  (submission['files'] as List).isNotEmpty) ...[
                const Text('Lampiran:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ...(submission['files'] as List).map((f) => ListTile(
                      leading: const Icon(Icons.attach_file, size: 16),
                      title: Text(f['file_path']?.split('/').last ?? 'File',
                          style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.download,
                          size: 16, color: AppColors.primary),
                      onTap: () => controller.downloadFile(f['file_path']),
                    )),
                const SizedBox(height: 16),
              ],
              const Text('Nilai (0-100)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '85.5',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              const Text('Catatan Guru',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText: 'Kerja bagus!',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final grade = double.tryParse(gradeController.text);
                    if (grade == null) {
                      Get.snackbar(
                          'Kesalahan', 'Mohon masukkan nilai yang valid');
                      return;
                    }
                    controller.submitGrade(submission['id'].toString(), grade,
                        notesController.text);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Simpan Penilaian',
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

  void _showSubmissionForm(BuildContext context, Map<String, dynamic> task) {
    controller.clearAssignmentFiles();
    final textController = TextEditingController();

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
                Text('Kirim Tugas: ${task['judul']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Jawaban / Catatan'),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tulis jawaban atau link tugas di sini...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final files = controller.selectedAssignmentFiles;
                  return Column(
                    children: [
                      if (files.isNotEmpty)
                        ...files.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.description,
                                    color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(file.path.split('/').last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis)),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () =>
                                      controller.removeAssignmentFile(index),
                                )
                              ],
                            ),
                          );
                        }),
                      OutlinedButton.icon(
                        onPressed: controller.pickAssignmentFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Tambah File (maks 5)'),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                controller.submitTugas(
                                    task['id']?.toString() ?? '',
                                    textController.text);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Kirim Jawaban',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      )),
                )
              ]))),
      isScrollControlled: true,
    );
  }
}
