import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../controllers/psb_controller.dart';

class PsbCekStatusView extends GetView<PsbController> {
  const PsbCekStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cek Status Pendaftaran'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Form cek status
            _buildCekStatusForm(),
            const SizedBox(height: 24),

            // Result
            Obx(() {
              if (controller.isCheckingStatus.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (controller.statusResult.value != null) {
                return _buildStatusResult(controller.statusResult.value!);
              }

              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cek Status',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Masukkan nomor pendaftaran dan tanggal lahir untuk melihat status pendaftaran Anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCekStatusForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: controller.noPendaftaranController,
            labelText: 'Nomor Pendaftaran',
            hintText: 'Contoh: PSB-202601-0001',
            prefixIcon: Icons.confirmation_number_outlined,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => controller.selectTanggalLahirCek(Get.context!),
            child: AbsorbPointer(
              child: CustomTextField(
                controller: controller.tglLahirCekController,
                labelText: 'Tanggal Lahir',
                hintText: 'Klik untuk memilih tanggal',
                prefixIcon: Icons.calendar_today_outlined,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => PrimaryButton(
                text: 'Cek Status',
                icon: Icons.search,
                isLoading: controller.isCheckingStatus.value,
                onPressed: controller.cekStatusPendaftaran,
              )),
        ],
      ),
    );
  }

  Widget _buildStatusResult(Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final statusLabel = data['status_label'] ?? 'Menunggu';
    final timeline = data['timeline'] as List? ?? [];
    final documents = data['documents'] as Map<String, dynamic>? ?? {};
    final credentials = data['credentials'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(20),
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
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    radius: 28,
                    child: Text(
                      (data['nama_lengkap'] ?? 'N')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nama_lengkap'] ?? '-',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          data['no_pendaftaran'] ?? '-',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status, statusLabel),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildInfoRow('Asal Sekolah', data['asal_sekolah'] ?? '-'),
              _buildInfoRow('Tanggal Daftar', data['tanggal_daftar'] ?? '-'),
              if (data['catatan_admin'] != null &&
                  data['catatan_admin'].toString().isNotEmpty)
                _buildInfoRow('Catatan Admin', data['catatan_admin']),
            ],
          ),
        ),

        // Login Credentials for Accepted status
        if (status == 'accepted') ...[
          const SizedBox(height: 24),
          _buildLoginCredentials(data, credentials),
        ],

        const SizedBox(height: 24),

        // Timeline
        if (timeline.isNotEmpty) ...[
          const Text(
            'Timeline Pendaftaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value as Map<String, dynamic>;
                final isLast = index == timeline.length - 1;
                return _buildTimelineItem(item, isLast);
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Documents status
        const Text(
          'Status Dokumen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDocumentsStatus(documents),
      ],
    );
  }

  Widget _buildLoginCredentials(
      Map<String, dynamic> data, Map<String, dynamic>? credentials) {
    // Get credentials from response or generate default
    final username = credentials?['username'] ??
        data['username'] ??
        'santri_${data['no_pendaftaran']?.replaceAll('-', '_').toLowerCase() ?? ''}';
    final email = credentials?['email'] ??
        data['email_santri'] ??
        data['email_ortu'] ??
        '-';
    final password =
        credentials?['password'] ?? data['password_default'] ?? 'DDMMYYYY';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat! Anda Diterima 🎉',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Berikut informasi akun login Anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.success),
          const SizedBox(height: 16),

          // Username
          _buildCredentialRow(
            'Username',
            username,
            Icons.person,
          ),
          const SizedBox(height: 12),

          // Email
          _buildCredentialRow(
            'Email',
            email,
            Icons.email,
          ),
          const SizedBox(height: 12),

          // Password
          _buildCredentialRow(
            'Password',
            password,
            Icons.lock,
            isPassword: true,
          ),

          const SizedBox(height: 20),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Password default adalah tanggal lahir (DDMMYYYY). Segera ubah password setelah login pertama.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(
    String label,
    String value,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPassword ? '●●●●●●●● (Tanggal Lahir)' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.copyToClipboard(value),
            icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
            tooltip: 'Salin',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color color;
    IconData icon;

    switch (status) {
      case 'accepted':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'verified':
        color = Colors.blue;
        icon = Icons.verified;
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    final status = item['status'] ?? 'pending';
    Color color;

    switch (status) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Icon(
                status == 'completed'
                    ? Icons.check
                    : (status == 'rejected' ? Icons.close : Icons.circle),
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: color.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['date'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsStatus(Map<String, dynamic> docs) {
    final docList = [
      {'key': 'kk', 'label': 'Kartu Keluarga', 'icon': Icons.family_restroom},
      {'key': 'akta', 'label': 'Akta Kelahiran', 'icon': Icons.article},
      {'key': 'ijazah', 'label': 'Ijazah/SKL', 'icon': Icons.school},
      {'key': 'foto', 'label': 'Pas Foto', 'icon': Icons.photo},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: docList.map((doc) {
          final isUploaded = docs[doc['key']] == true;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    doc['icon'] as IconData,
                    size: 20,
                    color: isUploaded ? AppColors.success : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    doc['label'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUploaded ? Icons.check_circle : Icons.pending,
                        size: 14,
                        color: isUploaded ? AppColors.success : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isUploaded ? 'Lengkap' : 'Belum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUploaded ? AppColors.success : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
