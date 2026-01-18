import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/monitoring_controller.dart';

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Dashboard Monitoring'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Keseluruhan'),
              Tab(text: 'Akademik'),
              Tab(text: 'PSB'),
              Tab(text: 'Keuangan'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildOverviewTab(),
              _buildAcademicTab(),
              _buildPsbTab(),
              _buildFinanceTab(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Progress Tahfidz Per Tingkat'),
          const SizedBox(height: 16),
          _buildTahfidzList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Total Saldo Pesantren',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
                    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                .format(controller.financeSummary['total_pendapatan'] -
                    controller.financeSummary['total_pengeluaran']),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniSummary(
                  'Siswa', '${controller.academicStats['jumlah_siswa']}'),
              _buildMiniSummary(
                  'Pendaftar PSB', '${controller.psbStats['total_pendaftar']}'),
              _buildMiniSummary(
                  'Kehadiran', '${controller.academicStats['absensi_siswa']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummary(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
    );
  }

  Widget _buildTahfidzList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.tahfidzProgress.length,
      itemBuilder: (context, index) {
        final item = controller.tahfidzProgress[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['grade'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['avg_juz'],
                      style: const TextStyle(color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: item['progress'],
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAcademicTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoTile(
            'Rata-rata Nilai',
            '${controller.academicStats['rata_rata_nilai']}',
            Icons.grade_outlined,
            Colors.amber),
        _buildInfoTile(
            'Persentase Kehadiran',
            '${controller.academicStats['absensi_siswa']}',
            Icons.calendar_today_outlined,
            Colors.green),
        _buildInfoTile(
            'Total Kelas',
            '${controller.academicStats['total_kelas']}',
            Icons.class_outlined,
            Colors.blue),
        _buildInfoTile('Total Guru Aktif', '45 Orang', Icons.person_outline,
            Colors.purple),
      ],
    );
  }

  Widget _buildPsbTab() {
    final stats = controller.psbStats;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircularPercentIndicator(
          radius: 80,
          lineWidth: 12,
          percent: stats['persentase'],
          center: Text("${(stats['persentase'] * 100).toInt()}%",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          footer: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text("Progress Target Pendaftar",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          progressColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 30),
        _buildInfoTile('Total Pendaftar', '${stats['total_pendaftar']}',
            Icons.people_outline, Colors.blue),
        _buildInfoTile('Menunggu Verifikasi', '${stats['menunggu']}',
            Icons.hourglass_empty, Colors.orange),
        _buildInfoTile('Diterima', '${stats['terverifikasi']}',
            Icons.check_circle_outline, Colors.green),
        _buildInfoTile('Ditolak', '${stats['ditolak']}', Icons.cancel_outlined,
            Colors.red),
      ],
    );
  }

  Widget _buildFinanceTab() {
    final fin = controller.financeSummary;
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildFinanceCard('Total Pendapatan',
            currency.format(fin['total_pendapatan']), Colors.green),
        const SizedBox(height: 16),
        _buildFinanceCard('Total Pengeluaran',
            currency.format(fin['total_pengeluaran']), Colors.red),
        const SizedBox(height: 16),
        _buildFinanceCard(
            'Piutang SPP', currency.format(fin['piutang_spp']), Colors.orange),
      ],
    );
  }

  Widget _buildFinanceCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String label, String value, IconData icon, Color color) {
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
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

// Helper widget for circular indicator if not using a package, or just use a placeholder
class CircularPercentIndicator extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final Widget center;
  final Widget footer;
  final Color progressColor;
  final Color backgroundColor;
  final CircularStrokeCap circularStrokeCap;

  const CircularPercentIndicator({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.center,
    required this.footer,
    required this.progressColor,
    required this.backgroundColor,
    required this.circularStrokeCap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: lineWidth,
                    color: progressColor,
                    backgroundColor: backgroundColor,
                  ),
                ),
              ),
              Center(child: center),
            ],
          ),
        ),
        footer,
      ],
    );
  }
}

enum CircularStrokeCap { round, square }
