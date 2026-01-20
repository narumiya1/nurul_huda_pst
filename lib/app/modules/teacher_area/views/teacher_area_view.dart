import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/teacher_area_controller.dart';

class TeacherAreaView extends GetView<TeacherAreaController> {
  const TeacherAreaView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Jadwal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbsensiTab(),
            _buildTahfidzTab(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
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
                          }

                          final nis = s['nis'] ?? '-';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'S',
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
                              controller.selectedSantriId.value =
                                  s['user_id'] ?? s['id'];
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
                          border: Border(
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
