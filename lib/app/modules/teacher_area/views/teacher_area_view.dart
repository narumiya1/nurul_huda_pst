import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/teacher_area_controller.dart';

class TeacherAreaView extends GetView<TeacherAreaController> {
  const TeacherAreaView({super.key});

  // Helper method to capitalize each word in a string
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Area Guru',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorWeight: 3,
            isScrollable: true,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: [
              Tab(
                  icon: Icon(Icons.fact_check_outlined, size: 20),
                  text: 'Absensi'),
              Tab(
                  icon: Icon(Icons.menu_book_outlined, size: 20),
                  text: 'Tahfidz'),
              Tab(
                  icon: Icon(Icons.assignment_outlined, size: 20),
                  text: 'Tugas'),
              Tab(icon: Icon(Icons.grade_outlined, size: 20), text: 'Nilai'),
              Tab(
                  icon: Icon(Icons.calendar_today_outlined, size: 20),
                  text: 'Jadwal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbsensiTab(),
            _buildTahfidzTab(),
            _buildTugasSantriTab(),
            _buildNilaiTab(),
            _buildJadwalTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsensiTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.siswaList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Kelas Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Kelas',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                      initialValue: controller.selectedKelas.value,
                      decoration: InputDecoration(
                        hintText: 'Pilih kelas...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: controller.kelasList.map((kelas) {
                        return DropdownMenuItem(
                          value: kelas,
                          child: Text(kelas['nama_kelas'] ?? 'Kelas'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedKelas.value = val;
                        if (val != null) {
                          controller.fetchSiswaByKelas(val['id']);
                        }
                      },
                    )),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: controller.siswaList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          controller.selectedKelas.value == null
                              ? 'Pilih kelas untuk melihat daftar siswa'
                              : 'Tidak ada siswa di kelas ini',
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.siswaList.length +
                        (controller.currentPage.value <
                                controller.lastPage.value
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.siswaList.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: controller.isLoadingMore.value
                                ? const CircularProgressIndicator()
                                : TextButton(
                                    onPressed: controller.loadMoreSiswa,
                                    child: const Text("Muat Lebih Banyak"),
                                  ),
                          ),
                        );
                      }
                      final siswa = controller.siswaList[index];
                      final siswaId = siswa['id'] as int;
                      final name = siswa['details']?['full_name'] ??
                          siswa['username'] ??
                          'Siswa ${index + 1}';

                      return Obx(() {
                        final status =
                            controller.attendanceData[siswaId] ?? 'hadir';
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
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                  style:
                                      const TextStyle(color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ),
                              _buildStatusChip('H', 'hadir', status, siswaId),
                              _buildStatusChip('I', 'izin', status, siswaId),
                              _buildStatusChip('S', 'sakit', status, siswaId),
                              _buildStatusChip('A', 'alpha', status, siswaId),
                            ],
                          ),
                        );
                      });
                    },
                  ),
          ),

          // Submit Button
          if (controller.siswaList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.submitAttendance,
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
                          : const Text('Simpan Absensi',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  )),
            ),
        ],
      );
    });
  }

  Widget _buildStatusChip(
      String label, String status, String currentStatus, int siswaId) {
    final isSelected = currentStatus == status;
    Color bgColor;
    switch (status) {
      case 'hadir':
        bgColor = Colors.green;
        break;
      case 'izin':
        bgColor = Colors.blue;
        break;
      case 'sakit':
        bgColor = Colors.orange;
        break;
      case 'alpha':
        bgColor = Colors.red;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: () => controller.updateAttendance(siswaId, status),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? bgColor : bgColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : bgColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTahfidzTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Sub-tabs for Tahfidz
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 18),
                      SizedBox(width: 8),
                      Text('Riwayat'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Input Setoran'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildRiwayatSetoranTab(),
                _buildInputSetoranTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab Riwayat Setoran
  Widget _buildRiwayatSetoranTab() {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                      initialValue: controller.selectedKelasRiwayat.value,
                      decoration: InputDecoration(
                        hintText: 'Semua Kelas',
                        prefixIcon: const Icon(Icons.filter_list, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<Map<String, dynamic>>(
                          value: null,
                          child: Text('Semua Kelas'),
                        ),
                        ...controller.kelasList.map((kelas) {
                          return DropdownMenuItem(
                            value: kelas,
                            child: Text(kelas['nama_kelas'] ?? 'Kelas'),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        controller.selectedKelasRiwayat.value = val;
                        controller.fetchHafalanList();
                      },
                    )),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchHafalanList,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Obx(() {
            if (controller.isLoadingHafalan.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.hafalanList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      controller.selectedKelasRiwayat.value != null
                          ? 'Belum ada setoran untuk kelas ini'
                          : 'Belum ada setoran tahfidz',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchHafalanList,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.hafalanList.length,
                itemBuilder: (context, index) {
                  final hafalan = controller.hafalanList[index];

                  // Parse santri name - handle nested structure
                  String santriName = 'Santri';
                  if (hafalan['santri'] != null) {
                    if (hafalan['santri']['details'] != null) {
                      santriName = hafalan['santri']['details']['full_name'] ??
                          santriName;
                    } else if (hafalan['santri']['user'] != null &&
                        hafalan['santri']['user']['details'] != null) {
                      santriName = hafalan['santri']['user']['details']
                              ['full_name'] ??
                          santriName;
                    }
                  }

                  final surah = hafalan['surah'] ?? '-';
                  final ayatRange = hafalan['ayat_range'] ?? '-';
                  final tanggal = hafalan['tanggal_setoran'] ?? '-';
                  final kualitas = hafalan['kualitas'] ?? 'lancar';
                  final juz = hafalan['juz'];

                  Color kualitasColor;
                  IconData kualitasIcon;
                  switch (kualitas) {
                    case 'lancar':
                      kualitasColor = Colors.green;
                      kualitasIcon = Icons.check_circle;
                      break;
                    case 'cukup_lancar':
                      kualitasColor = Colors.orange;
                      kualitasIcon = Icons.check_circle_outline;
                      break;
                    default:
                      kualitasColor = Colors.red;
                      kualitasIcon = Icons.refresh;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          santriName.isNotEmpty
                              ? santriName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        santriName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.book,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '$surah: $ayatRange',
                                style: const TextStyle(fontSize: 13),
                              ),
                              if (juz != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Juz $juz',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                tanggal,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kualitasColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(kualitasIcon, size: 16, color: kualitasColor),
                            const SizedBox(width: 4),
                            Text(
                              _capitalizeWords(kualitas.replaceAll('_', ' ')),
                              style: TextStyle(
                                color: kualitasColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
          }),
        ),
      ],
    );
  }

  // Tab Input Setoran
  Widget _buildInputSetoranTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kelas Selector
          const Text('Pilih Kelas',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                initialValue: controller.selectedKelasTahfidz.value,
                decoration: InputDecoration(
                  hintText: 'Pilih kelas...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: controller.kelasList.map((kelas) {
                  return DropdownMenuItem(
                    value: kelas,
                    child: Text(kelas['nama_kelas'] ?? 'Kelas'),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedKelasTahfidz.value = val;
                  controller.fetchSantriList();
                },
              )),
          const SizedBox(height: 20),

          // Santri Selector with Search
          const Text('Pilih Santri',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Ketik nama santri...',
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
                child: controller.selectedKelasTahfidz.value == null
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('Pilih kelas terlebih dahulu',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : controller.santriList.isEmpty &&
                            !controller.isLoadingSantri.value
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
                                  controller.selectedSantriId.value == s['id'];

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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                selected: isSelected,
                                selectedTileColor:
                                    AppColors.primary.withValues(alpha: 0.05),
                                onTap: () {
                                  // Use santri.id, not user_id
                                  controller.selectedSantriId.value = s['id'];
                                  controller.searchController.text = name;
                                  controller.selectedSantriName.value = name;
                                },
                              );
                            },
                          ),
              )),
          const SizedBox(height: 20),

          // Juz
          const Text('Juz (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<int>(
                initialValue: controller.selectedJuz.value,
                decoration: InputDecoration(
                  hintText: 'Pilih juz...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: List.generate(30, (i) => i + 1).map((juz) {
                  return DropdownMenuItem(
                    value: juz,
                    child: Text('Juz $juz'),
                  );
                }).toList(),
                onChanged: (val) => controller.selectedJuz.value = val,
              )),
          const SizedBox(height: 20),

          // Surah
          const Text('Surah', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller.surahController,
            decoration: InputDecoration(
              hintText: 'Contoh: Al-Baqarah',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Ayat Range
          const Text('Ayat', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller.ayatController,
            decoration: InputDecoration(
              hintText: 'Contoh: 1-10',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Kualitas
          const Text('Kualitas Bacaan',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                children: ['lancar', 'cukup_lancar', 'kurang_lancar']
                    .map((k) => ChoiceChip(
                          label: Text(k.replaceAll('_', ' ').capitalize!),
                          selected: controller.selectedKualitas.value == k,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          onSelected: (_) =>
                              controller.selectedKualitas.value = k,
                        ))
                    .toList(),
              )),
          const SizedBox(height: 20),

          // Catatan
          const Text('Catatan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller.catatanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Catatan tambahan...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitTahfidz,
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
                      : const Text('Simpan Setoran',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNilaiTab() {
    return Obx(() {
      return Column(
        children: [
          // Grade Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: controller.selectedKelas.value,
                        decoration: InputDecoration(
                          hintText: 'Kelas...',
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: controller.kelasList.map((kelas) {
                          return DropdownMenuItem(
                            value: kelas,
                            child: Text(kelas['nama_kelas'] ?? 'Kelas',
                                style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.selectedKelas.value = val;
                          if (val != null) {
                            controller.fetchSiswaForNilai(val['id']);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: controller.selectedMapel.value,
                        decoration: InputDecoration(
                          hintText: 'Mapel...',
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: controller.mapelList.map((mapel) {
                          return DropdownMenuItem(
                            value: mapel,
                            child: Text(mapel['name'] ?? 'Mapel',
                                style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.selectedMapel.value = val;
                          controller.onNilaiFilterChanged();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.selectedSemesterNilai.value,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['ganjil', 'genap'].map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.capitalizeFirst!,
                                style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.selectedSemesterNilai.value = val!;
                          controller.onNilaiFilterChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.selectedJenisPenilaian.value,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['Tugas', 'UTS', 'UAS', 'Harian'].map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child:
                                Text(s, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.selectedJenisPenilaian.value = val!;
                          controller.onNilaiFilterChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Student List for Nilai
          Expanded(
            child: controller.isLoadingNilai.value
                ? const Center(child: CircularProgressIndicator())
                : controller.siswaNilaiList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('Pilih kelas untuk menginput nilai',
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.siswaNilaiList.length,
                        itemBuilder: (context, index) {
                          final siswa = controller.siswaNilaiList[index];
                          final name = siswa['details']?['full_name'] ??
                              siswa['username'] ??
                              'Siswa';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller:
                                        controller.nilaiData[siswa['id']],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 8),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Submit Button
          if (controller.siswaNilaiList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitNilaiBulk,
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
                      : const Text('Simpan Nilai',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildJadwalTab() {
    return Obx(() {
      if (controller.isLoadingJadwal.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      return DefaultTabController(
        length: controller.days.length,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: controller.days.map((day) => Tab(text: day)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: controller.days.map((day) {
                  final items = controller.groupedJadwal[day] ?? [];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada jadwal",
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final mapel = item['mapel'];
                      final kelas = item['kelas'];
                      final mapelName =
                          (mapel is Map ? mapel['nama'] : mapel) ?? '-';
                      final kelasName =
                          (kelas is Map ? kelas['nama_kelas'] : kelas) ?? '-';
                      final ruang = item['ruang'] ?? '-';
                      final jamMulai = item['jam_mulai'] != null
                          ? item['jam_mulai'].toString().substring(0, 5)
                          : '-';
                      final jamSelesai = item['jam_selesai'] != null
                          ? item['jam_selesai'].toString().substring(0, 5)
                          : '-';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.cardShadow,
                          border: const Border(
                              left: BorderSide(
                                  color: AppColors.primary, width: 4)),
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
                                "$jamMulai - $jamSelesai",
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
                                    mapelName,
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
                                        "$kelasName • $ruang",
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
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ========== TUGAS SANTRI TAB ==========
  Widget _buildTugasSantriTab() {
    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Tugas Santri',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateTugasDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Buat Tugas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tugas List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingTugasSantri.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.tugasSantriList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada tugas santri',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _showCreateTugasDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Tugas Baru'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchTugasSantriList,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.tugasSantriList.length,
                itemBuilder: (context, index) {
                  final tugas = controller.tugasSantriList[index];
                  return _buildTugasCard(tugas);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTugasCard(dynamic tugas) {
    final judul = tugas['judul'] ?? 'Tugas';
    final deskripsi = tugas['deskripsi'] ?? '-';
    final deadline = tugas['deadline'] ?? '-';
    final mapelName = tugas['mapel']?['nama_mapel'] ??
        tugas['mapel']?['nama'] ??
        'Mata Pelajaran';
    final kelasName = tugas['kelas']?['nama_kelas'] ?? 'Kelas';
    final tingkatName =
        tugas['tingkat']?['nama_tingkat'] ?? tugas['tingkat']?['nama'] ?? '';
    final submissions = tugas['submissions'] as List? ?? [];
    final submissionCount = submissions.length;

    // Check if deadline passed
    bool isOverdue = false;
    try {
      final deadlineDate = DateTime.parse(deadline);
      isOverdue = DateTime.now().isAfter(deadlineDate);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment, color: AppColors.primary),
            ),
            title: Text(
              judul,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              mapelName,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(tugas['id']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deskripsi.isNotEmpty && deskripsi != '-')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      deskripsi,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$tingkatName - $kelasName',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today,
                        size: 14, color: isOverdue ? Colors.red : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      deadline,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontWeight: isOverdue ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Submissions Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengumpulan ($submissionCount)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (submissions.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            _showSubmissionsDialog(tugas, submissions),
                        child: const Text('Lihat Semua'),
                      ),
                  ],
                ),
                if (submissions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, color: Colors.grey, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Belum ada pengumpulan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  // Show first few submissions
                  ...submissions.take(2).map((sub) {
                    final santriName = sub['santri']?['user']?['details']
                            ?['full_name'] ??
                        sub['santri']?['details']?['full_name'] ??
                        'Santri';
                    final nilai = sub['nilai'];
                    final isGraded = nilai != null;

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              santriName.isNotEmpty
                                  ? santriName[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              santriName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          if (isGraded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Nilai: $nilai',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () => _showGradeDialog(sub),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('Beri Nilai',
                                  style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTugasDialog() {
    controller.fetchTugasSantriDropdowns();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.assignment_add, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Buat Tugas Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      const Text('Judul Tugas *',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.tugasJudulController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan judul tugas',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      const Text('Deskripsi',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.tugasDeskripsiController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Deskripsi tugas (opsional)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tingkat
                      const Text('Tingkat *',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                            value: controller.selectedTingkatSantri.value,
                            decoration: InputDecoration(
                              hintText: 'Pilih tingkat',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            items: controller.tingkatSantriList.map((t) {
                              final tingkat = t as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: tingkat,
                                child: Text(tingkat['nama_tingkat'] ??
                                    tingkat['nama'] ??
                                    'Tingkat'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              controller.selectedTingkatSantri.value = val;
                              controller.selectedKelasSantri.value = null;
                              if (val != null) {
                                controller.fetchKelasSantriByTingkat(val['id']);
                              }
                            },
                          )),
                      const SizedBox(height: 16),

                      // Kelas
                      const Text('Kelas *',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                            value: controller.selectedKelasSantri.value,
                            decoration: InputDecoration(
                              hintText:
                                  controller.selectedTingkatSantri.value == null
                                      ? 'Pilih tingkat terlebih dahulu'
                                      : 'Pilih kelas',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            items: controller.kelasSantriList.map((k) {
                              final kelas = k as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: kelas,
                                child: Text(kelas['nama_kelas'] ?? 'Kelas'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              controller.selectedKelasSantri.value = val;
                            },
                          )),
                      const SizedBox(height: 16),

                      // Mapel
                      const Text('Mata Pelajaran *',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                            value: controller.selectedMapelPondok.value,
                            decoration: InputDecoration(
                              hintText: 'Pilih mata pelajaran',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            items: controller.mapelPondokList.map((m) {
                              final mapel = m as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: mapel,
                                child: Text(mapel['nama_mapel'] ??
                                    mapel['nama'] ??
                                    'Mapel'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              controller.selectedMapelPondok.value = val;
                            },
                          )),
                      const SizedBox(height: 16),

                      // Tanggal Mulai
                      const Text('Tanggal Mulai *',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: Get.context!,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                controller.selectedTanggalMulai.value = date;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedTanggalMulai.value !=
                                            null
                                        ? controller.selectedTanggalMulai.value!
                                            .toIso8601String()
                                            .split('T')[0]
                                        : 'Pilih tanggal',
                                    style: TextStyle(
                                      color: controller
                                                  .selectedTanggalMulai.value !=
                                              null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),

                      // Deadline
                      const Text('Deadline *',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: Get.context!,
                                initialDate:
                                    controller.selectedTanggalMulai.value ??
                                        DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                controller.selectedDeadline.value = date;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedDeadline.value != null
                                        ? controller.selectedDeadline.value!
                                            .toIso8601String()
                                            .split('T')[0]
                                        : 'Pilih deadline',
                                    style: TextStyle(
                                      color:
                                          controller.selectedDeadline.value !=
                                                  null
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.createTugasSantri,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Simpan'),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmissionsDialog(dynamic tugas, List submissions) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pengumpulan: ${tugas['judul']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // List
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final santriName = sub['santri']?['user']?['details']
                            ?['full_name'] ??
                        sub['santri']?['details']?['full_name'] ??
                        'Santri';
                    final nilai = sub['nilai'];
                    final isGraded = nilai != null;
                    final submittedAt = sub['submitted_at'] ?? '-';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              santriName.isNotEmpty
                                  ? santriName[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  santriName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dikumpulkan: $submittedAt',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          if (isGraded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$nilai',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                _showGradeDialog(sub);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Beri Nilai'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGradeDialog(dynamic submission) {
    controller.selectedSubmission.value = submission as Map<String, dynamic>;
    controller.nilaiTugasController.clear();
    controller.catatanGuruController.clear();

    final santriName = submission['santri']?['user']?['details']
            ?['full_name'] ??
        submission['santri']?['details']?['full_name'] ??
        'Santri';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.grade, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Beri Nilai',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          santriName,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nilai
              const Text('Nilai (0-100) *',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nilaiTugasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan nilai',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan
              const Text('Catatan (opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.catatanGuruController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Catatan untuk santri',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.gradeTugasSantriSubmission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Simpan'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Hapus Tugas'),
          ],
        ),
        content: const Text(
            'Apakah Anda yakin ingin menghapus tugas ini? Semua pengumpulan akan ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteTugasSantri(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
