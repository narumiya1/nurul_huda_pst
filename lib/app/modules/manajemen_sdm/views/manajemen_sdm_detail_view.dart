import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class ManajemenSdmDetailView extends StatelessWidget {
  const ManajemenSdmDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.arguments as Map<String, dynamic>;
    final original = user['original'] ?? {};
    final String role = user['role'] ?? 'User';
    final String status = user['status'] ?? 'Non-Aktif';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(user, role, status),
            const SizedBox(height: 24),
            _buildDetailSection(role, original),
            const SizedBox(height: 24),
            if (role == 'Santri' && original['santri'] != null)
              _buildAcademicInfo(original['santri']),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      Map<String, dynamic> user, String role, String status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage:
                  (user['original']?['details']?['photo_url'] != null)
                      ? NetworkImage(user['original']['details']['photo_url']!)
                      : null,
              child: (user['original']?['details']?['photo_url'] == null)
                  ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user['name'] ?? 'No Name',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user['email'] ?? '-',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(role, AppColors.accentBlue),
              const SizedBox(width: 12),
              _buildBadge(status,
                  status == 'Aktif' ? AppColors.success : AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailSection(String role, Map<String, dynamic> original) {
    final details = original['details'] ?? {};
    final staff = original['staff'] ?? {};
    final santri = original['santri'] ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pribadi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Jenis Kelamin', details['gender'] ?? '-'),
          _buildInfoRow('Telepon', details['phone'] ?? '-'),
          _buildInfoRow('Alamat', details['address'] ?? '-'),
          if (role == 'Guru' || role == 'Staff' || role == 'Pimpinan') ...[
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            const Text('Informasi Kepegawaian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('NIP/NIG', staff['nip'] ?? '-'),
            _buildInfoRow('Jabatan', staff['jabatan'] ?? '-'),
            if (role == 'Guru')
              _buildInfoRow('Bidang Studi', staff['bidang_studi'] ?? '-'),
          ],
          if (role == 'Santri') ...[
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            const Text('Informasi Santri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('NIS', santri['nis'] ?? '-'),
            _buildInfoRow('NISN', santri['nisn'] ?? '-'),
          ]
        ],
      ),
    );
  }

  Widget _buildAcademicInfo(Map<String, dynamic> santri) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akademik & Pondok',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tingkat', santri['tingkat']?['nama_tingkat'] ?? '-'),
          _buildInfoRow('Kelas', santri['kelas_obj']?['nama_kelas'] ?? '-'),
          _buildInfoRow('Kamar', santri['kamar']?['nama_kamar'] ?? '-'),
          _buildInfoRow('Wali Kamar', santri['kamar']?['wali_kamar'] ?? '-'),
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
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
