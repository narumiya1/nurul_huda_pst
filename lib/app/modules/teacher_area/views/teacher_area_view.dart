import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/teacher_area_controller.dart';

class TeacherAreaView extends GetView<TeacherAreaController> {
  const TeacherAreaView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Area Guru'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.fact_check), text: 'Input Absensi'),
              Tab(icon: Icon(Icons.menu_book), text: 'Setoran Tahfidz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbsensiTab(),
            _buildTahfidzTab(),
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
                    itemCount: controller.siswaList.length,
                    itemBuilder: (context, index) {
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
                                  name[0].toUpperCase(),
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
          // Santri Selector
          const Text('Pilih Santri',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                initialValue: controller.selectedSantri.value,
                decoration: InputDecoration(
                  hintText: 'Pilih santri...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: controller.santriList.map((santri) {
                  return DropdownMenuItem(
                    value: santri,
                    child: Text(santri['details']?['full_name'] ??
                        santri['username'] ??
                        'Santri'),
                  );
                }).toList(),
                onChanged: (val) => controller.selectedSantri.value = val,
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
}
