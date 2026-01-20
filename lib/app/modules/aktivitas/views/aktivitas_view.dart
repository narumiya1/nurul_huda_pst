import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/aktivitas_controller.dart';

class AktivitasView extends GetView<AktivitasController> {
  const AktivitasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal Aktivitas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateCard(),
              const SizedBox(height: 20),
              _buildFilterSelector(),
              const SizedBox(height: 24),
              Obx(() => Text(
                    'Jadwal ${controller.selectedFilter.value.capitalizeFirst}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )),
              const SizedBox(height: 16),
              _buildScheduleTimeline(),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() => controller.canManage.value
          ? FloatingActionButton(
              onPressed: () => _showAddActivityForm(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildFilterSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterItem('harian', 'Harian', Icons.today),
          const SizedBox(width: 12),
          _buildFilterItem('mingguan', 'Mingguan', Icons.view_week),
          const SizedBox(width: 12),
          _buildFilterItem('bulanan', 'Bulanan', Icons.calendar_view_month),
          const SizedBox(width: 12),
          _buildFilterItem('tahunan', 'Tahunan', Icons.event_note),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String value, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return InkWell(
        onTap: () => controller.changeFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textLight.withValues(alpha: 0.1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showActivityDetail(Map<String, dynamic> initialData) {
    // Fetch fresh detail (to get items etc)
    controller.fetchActivityDetail(initialData['id']);

    Get.bottomSheet(
      Obx(() {
        if (controller.isDetailLoading.value) {
          return Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = controller.selectedActivity.value ?? initialData;
        final type = data['tipe']?.toString() ?? 'akademik';
        final items = data['items'] is List ? (data['items'] as List) : [];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['judul']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeLabel(type).toUpperCase(),
                            style: TextStyle(
                              color: _getTypeColor(type),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailInfoRow(Icons.access_time, 'Waktu',
                  '${data['jam_mulai']?.toString().substring(0, 5) ?? '-'} - ${data['jam_selesai']?.toString().substring(0, 5) ?? '-'}'),
              _buildDetailInfoRow(Icons.location_on_outlined, 'Lokasi',
                  data['lokasi']?.toString() ?? '-'),
              _buildDetailInfoRow(Icons.person_outline, 'Penanggung Jawab',
                  data['penanggung_jawab']?.toString() ?? '-'),
              if (data['hari'] != null && data['hari'].toString().isNotEmpty)
                _buildDetailInfoRow(Icons.calendar_today, 'Rutinitas',
                    'Setiap hari ${data['hari']}'),
              if (data['tanggal_fixed'] != null &&
                  data['tanggal_fixed'].toString().isNotEmpty)
                _buildDetailInfoRow(Icons.event, 'Rutinitas',
                    'Setiap tanggal ${data['tanggal_fixed']}'),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Daftar Kegiatan / Item:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: Get.height * 0.3),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['nama_item']?.toString() ?? '-',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddActivityForm(BuildContext context) {
    final titleController = TextEditingController();
    final lokasiController = TextEditingController();
    final penanggungJawabController = TextEditingController();
    final tanggalFixedController =
        TextEditingController(); // for bulanan/tahunan

    // Tipe: harian, mingguan, bulanan, tahunan
    final selectedTipe = controller.selectedFilter.value.obs;
    final selectedHari = 'Senin'.obs;

    // Time pickers
    final jamMulai = const TimeOfDay(hour: 8, minute: 0).obs;
    final jamSelesai = const TimeOfDay(hour: 9, minute: 0).obs;

    final hariList = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Ahad'
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tambah Aktivitas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Aktivitas'),
              ),
              const SizedBox(height: 12),

              Obx(() => DropdownButtonFormField<String>(
                    initialValue: selectedTipe.value,
                    items: ['harian', 'mingguan', 'bulanan', 'tahunan']
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.capitalizeFirst!)))
                        .toList(),
                    onChanged: (v) => selectedTipe.value = v!,
                    decoration:
                        const InputDecoration(labelText: 'Tipe Rutinitas'),
                  )),

              const SizedBox(height: 12),

              // Conditional fields based on Tipe
              Obx(() {
                if (selectedTipe.value == 'mingguan') {
                  return DropdownButtonFormField<String>(
                    initialValue: selectedHari.value,
                    items: hariList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => selectedHari.value = v!,
                    decoration: const InputDecoration(labelText: 'Hari'),
                  );
                } else if (selectedTipe.value == 'bulanan') {
                  return TextField(
                    controller: tanggalFixedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Tanggal (1-31)', hintText: 'Contoh: 15'),
                  );
                } else if (selectedTipe.value == 'tahunan') {
                  return TextField(
                    controller: tanggalFixedController,
                    decoration: const InputDecoration(
                        labelText: 'Tanggal & Bulan',
                        hintText: 'Contoh: 17 Agustus'),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 12),
              TextField(
                controller: penanggungJawabController,
                decoration:
                    const InputDecoration(labelText: 'Penanggung Jawab (Nama)'),
              ),

              const SizedBox(height: 12),
              // Time Pickers Row
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ListTile(
                          title: const Text('Jam Mulai'),
                          subtitle: Text(jamMulai.value.format(context)),
                          onTap: () async {
                            final t = await showTimePicker(
                                context: context, initialTime: jamMulai.value);
                            if (t != null) jamMulai.value = t;
                          },
                        )),
                  ),
                  Expanded(
                    child: Obx(() => ListTile(
                          title: const Text('Jam Selesai'),
                          subtitle: Text(jamSelesai.value.format(context)),
                          onTap: () async {
                            final t = await showTimePicker(
                                context: context,
                                initialTime: jamSelesai.value);
                            if (t != null) jamSelesai.value = t;
                          },
                        )),
                  ),
                ],
              ),

              TextField(
                controller: lokasiController,
                decoration:
                    const InputDecoration(labelText: 'Lokasi (Opsional)'),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) {
                      Get.snackbar('Error', 'Judul wajib diisi',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white);
                      return;
                    }

                    // Format TimeOfDay to H:i:s
                    final start =
                        '${jamMulai.value.hour.toString().padLeft(2, '0')}:${jamMulai.value.minute.toString().padLeft(2, '0')}:00';
                    final end =
                        '${jamSelesai.value.hour.toString().padLeft(2, '0')}:${jamSelesai.value.minute.toString().padLeft(2, '0')}:00';

                    final data = {
                      'judul': titleController.text,
                      'tipe': selectedTipe.value,
                      'penanggung_jawab': penanggungJawabController.text.isEmpty
                          ? 'Staff'
                          : penanggungJawabController.text,
                      'penanggung_jawab_id': controller.currentUserId.value == 0
                          ? null
                          : controller.currentUserId.value,
                      'jam_mulai': start,
                      'jam_selesai': end,
                      'lokasi': lokasiController.text,
                      'lingkup_peserta': 'global',
                      'gender': 'A',
                      'is_active': 1,
                      if (selectedTipe.value == 'mingguan')
                        'hari': selectedHari.value,
                      if (['bulanan', 'tahunan'].contains(selectedTipe.value))
                        'tanggal_fixed': tanggalFixedController.text,
                    };
                    controller.addActivity(data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Aktivitas',
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

  Widget _buildDateCard() {
    final now = DateTime.now();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${now.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  months[now.month - 1],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days[now.weekday - 1],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      '${controller.aktivitasList.length} kegiatan hari ini',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),
          const Icon(Icons.calendar_today, color: Colors.white70, size: 32),
        ],
      ),
    );
  }

  Widget _buildScheduleTimeline() {
    return Obx(() {
      if (controller.aktivitasList.isEmpty) {
        return const Center(child: Text("Tidak ada aktivitas"));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.aktivitasList.length,
        itemBuilder: (context, index) {
          final item = controller.aktivitasList[index];
          final isLast = index == controller.aktivitasList.length - 1;
          // Map keys from backend (or dummy if not running)
          // Backend fields: judul, items, jam_mulai, lokasi, tipe, hari, tanggal_fixed
          final time = item['jam_mulai']?.toString().substring(0, 5) ?? '-';
          final endTime = item['jam_selesai']?.toString().substring(0, 5) ?? '';
          final type =
              item['tipe']?.toString() ?? 'akademik'; // Use backend 'tipe'
          final title = item['judul']?.toString() ?? '-';
          final location = item['lokasi']?.toString() ?? '-';
          final hari = item['hari']?.toString() ?? '';
          final tglFixed = item['tanggal_fixed']?.toString() ?? '';

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (endTime.isNotEmpty)
                        Text(
                          endTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                // Line & Dot
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.textLight.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Card
                Expanded(
                  child: InkWell(
                    onTap: () => _showActivityDetail(item),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(type)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getTypeLabel(type),
                                  style: TextStyle(
                                    color: _getTypeColor(type),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (controller.canManage.value)
                                InkWell(
                                  onTap: () {
                                    // Optional: Confirm delete
                                    Get.defaultDialog(
                                      title: 'Hapus?',
                                      middleText: 'Yakin hapus aktivitas ini?',
                                      textConfirm: 'Ya',
                                      textCancel: 'Batal',
                                      buttonColor: AppColors.primary,
                                      confirmTextColor: Colors.white,
                                      cancelTextColor: AppColors.primary,
                                      onConfirm: () =>
                                          controller.deleteActivity(item['id']),
                                    );
                                  },
                                  child: const Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.error),
                                )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (hari.isNotEmpty || tglFixed.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                hari.isNotEmpty
                                    ? 'Setiap hari $hari'
                                    : 'Setiap tanggal $tglFixed',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ibadah':
        return AppColors.success;
      case 'harian':
      case 'akademik':
        return AppColors.accentBlue;
      case 'makan':
        return AppColors.accentOrange;
      case 'mingguan':
      case 'ekskul':
        return AppColors.accentPurple;
      case 'bulanan':
      case 'tahunan':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'ibadah':
        return 'IBADAH';
      case 'akademik':
        return 'AKADEMIK';
      case 'makan':
        return 'MAKAN';
      case 'ekskul':
        return 'EKSKUL';
      default:
        return type.toUpperCase();
    }
  }
}
