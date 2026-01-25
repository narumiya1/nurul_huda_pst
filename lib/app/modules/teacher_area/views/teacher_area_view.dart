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
      length: 4,
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
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.fact_check_outlined), text: 'Absensi'),
              Tab(icon: Icon(Icons.menu_book_outlined), text: 'Tahfidz'),
              Tab(icon: Icon(Icons.grade_outlined), text: 'Nilai'),
              Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Jadwal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbsensiTab(),
            _buildTahfidzTab(),
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
}
