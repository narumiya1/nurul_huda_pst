import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/jadwal_pelajaran_controller.dart';

class JadwalPelajaranView extends GetView<JadwalPelajaranController> {
  const JadwalPelajaranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
            onRefresh: controller.fetchJadwal,
            child: DefaultTabController(
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
                      tabs:
                          controller.days.map((day) => Tab(text: day)).toList(),
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
                            // Backend Santri response uses 'mata_pelajaran' and 'pengajar'
                            final mataPelajaran = item['mata_pelajaran'];
                            final pengajar = item['pengajar'];

                            // Backend Guru response uses 'mapel' (object) and 'kelas' (object)
                            final mapel = item['mapel'];
                            final kelas = item['kelas'];

                            // Safe name extraction
                            String mapelName = '-';
                            if (mataPelajaran != null) {
                              mapelName = mataPelajaran.toString();
                            } else if (mapel != null) {
                              if (mapel is Map) {
                                mapelName =
                                    mapel['nama_mapel'] ?? mapel['nama'] ?? '-';
                              } else {
                                mapelName = mapel.toString();
                              }
                            }

                            String kelasName = '-';
                            if (kelas != null) {
                              if (kelas is Map) {
                                kelasName =
                                    kelas['nama_kelas'] ?? kelas['nama'] ?? '-';
                              } else {
                                kelasName = kelas.toString();
                              }
                            }

                            final ruang =
                                item['ruang'] ?? '-'; // Guru might have room

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
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              pengajar != null
                                                  ? "Pengajar: $pengajar"
                                                  : "$kelasName • $ruang",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13),
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
            ));
      }),
    );
  }
}
