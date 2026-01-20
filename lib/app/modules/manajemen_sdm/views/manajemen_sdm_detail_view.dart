import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class ManajemenSdmDetailView extends StatelessWidget {
  const ManajemenSdmDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Safe argument parsing
    final args = Get.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pengguna')),
        body: const Center(child: Text('Data tidak tersedia')),
      );
    }

    final user = args;
    final dynamic originalRaw = user['original'];
    final Map<String, dynamic> original =
        (originalRaw is Map) ? Map<String, dynamic>.from(originalRaw) : {};
    final String role = user['role']?.toString() ?? 'User';
    final String status = user['status']?.toString() ?? 'Non-Aktif';

    // For Siswa, the user data is nested inside 'user' key
    final bool isSiswa = role == 'Siswa';
    final dynamic userObjectRaw =
        isSiswa ? (original['user'] ?? original) : original;
    final Map<String, dynamic> userObject =
        (userObjectRaw is Map) ? Map<String, dynamic>.from(userObjectRaw) : {};
    final dynamic detailsRaw = userObject['details'];
    final Map<String, dynamic> details =
        (detailsRaw is Map) ? Map<String, dynamic>.from(detailsRaw) : {};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getRoleColor(role),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getRoleColor(role),
                      _getRoleColor(role).withValues(alpha: 0.8),
                      _getRoleColor(role).withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            backgroundImage: _getPhotoUrl(details) != null
                                ? NetworkImage(
                                    _getPhotoUrl(details)!.startsWith('http')
                                        ? _getPhotoUrl(details)!
                                        : 'http://10.0.2.2:8000${_getPhotoUrl(details)!.startsWith('/') ? _getPhotoUrl(details)! : '/${_getPhotoUrl(details)!}'}',
                                  )
                                : null,
                            child: _getPhotoUrl(details) == null
                                ? Text(
                                    _getInitials(
                                        user['name']?.toString() ?? ''),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Name
                        Text(
                          user['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Email
                        Text(
                          user['email'] ?? '-',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Status Badges
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(role, _getRoleColor(role)),
                  const SizedBox(width: 12),
                  _buildBadge(
                    status,
                    status == 'Aktif' ? AppColors.success : AppColors.error,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Personal Information
                  _buildDetailCard(
                    title: 'Informasi Pribadi',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow('Nama Lengkap',
                          details['full_name'] ?? user['name'] ?? '-'),
                      _buildInfoRow('Panggilan', details['nickname'] ?? '-'),
                      _buildInfoRow(
                          'Jenis Kelamin', _formatGender(details['gender'])),
                      _buildInfoRow('Telepon', details['phone'] ?? '-'),
                      _buildInfoRow('Alamat', details['address'] ?? '-'),
                      _buildInfoRow(
                          'Tempat Lahir', details['birth_place'] ?? '-'),
                      _buildInfoRow(
                          'Tanggal Lahir', details['birth_date'] ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Role-specific Information
                  if (isSiswa) ...[
                    _buildSiswaInfo(original),
                    const SizedBox(height: 16),
                  ],

                  if (role == 'Santri') ...[
                    _buildSantriInfo(original),
                    const SizedBox(height: 16),
                  ],

                  if (role == 'Guru') ...[
                    _buildGuruInfo(original),
                    const SizedBox(height: 16),
                  ],

                  if (role == 'Staff') ...[
                    _buildStaffInfo(original),
                    const SizedBox(height: 16),
                  ],

                  if (role == 'Pimpinan') ...[
                    _buildPimpinanInfo(original),
                    const SizedBox(height: 16),
                  ],

                  if (role == 'Orang Tua') ...[
                    _buildOrangTuaInfo(original),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Safe Map getter
  Map<String, dynamic> _safeMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  // Safe String getter
  String _safeStr(dynamic value, [String fallback = '-']) {
    if (value == null) return fallback;
    final str = value.toString();
    return str.isEmpty || str == 'null' ? fallback : str;
  }

  Widget _buildSiswaInfo(Map<String, dynamic> original) {
    final sekolah = _safeMap(original['sekolah']);
    final kelas = _safeMap(original['kelas']);
    final santri = original['santri'];

    return Column(
      children: [
        _buildDetailCard(
          title: 'Informasi Siswa',
          icon: Icons.school_outlined,
          children: [
            _buildInfoRow('NIS', _safeStr(original['nis'])),
            _buildInfoRow('NISN', _safeStr(original['nisn'])),
            _buildInfoRow('Sekolah', _safeStr(sekolah['nama_sekolah'])),
            _buildInfoRow(
                'Kelas',
                _safeStr(kelas['nama_kelas']) != '-'
                    ? _safeStr(kelas['nama_kelas'])
                    : _safeStr(original['kelas_sekolah'])),
            _buildInfoRow(
                'Status', _capitalizeFirst(_safeStr(original['status']))),
            _buildInfoRow(
                'Juga Santri',
                original['is_santri_juga'] == true ||
                        original['is_santri_juga'] == 1
                    ? 'Ya'
                    : 'Tidak'),
          ],
        ),
        if (santri != null && santri is Map) ...[
          const SizedBox(height: 16),
          _buildDetailCard(
            title: 'Informasi Pondok (Santri)',
            icon: Icons.mosque_outlined,
            children: [
              _buildInfoRow('NIS Santri', _safeStr(santri['nis'])),
              _buildInfoRow('Tingkat',
                  _safeStr(_safeMap(santri['tingkat'])['nama_tingkat'])),
              _buildInfoRow('Kelas Pondok',
                  _safeStr(_safeMap(santri['kelas_obj'])['nama_kelas'])),
              _buildInfoRow(
                  'Kamar', _safeStr(_safeMap(santri['kamar'])['nama_kamar'])),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSantriInfo(Map<String, dynamic> original) {
    // For Santri role, santri data is in original['santri']
    final santri = _safeMap(original['santri']);
    final tingkat = _safeMap(santri['tingkat']);
    final kelas = santri['kelas_obj'] != null
        ? _safeMap(santri['kelas_obj'])
        : _safeMap(santri['kelas']);
    final kamar = _safeMap(santri['kamar']);

    return _buildDetailCard(
      title: 'Informasi Santri',
      icon: Icons.mosque_outlined,
      children: [
        _buildInfoRow('NIS', _safeStr(santri['nis'])),
        _buildInfoRow('NISN', _safeStr(santri['nisn'])),
        _buildInfoRow('Tingkat', _safeStr(tingkat['nama_tingkat'])),
        _buildInfoRow('Kelas', _safeStr(kelas['nama_kelas'])),
        _buildInfoRow('Kamar', _safeStr(kamar['nama_kamar'])),
        _buildInfoRow('Wali Kamar', _safeStr(kamar['wali_kamar'])),
        _buildInfoRow('Status', _capitalizeFirst(_safeStr(santri['status']))),
        _buildInfoRow('Tanggal Masuk', _safeStr(santri['tanggal_masuk'])),
      ],
    );
  }

  Widget _buildGuruInfo(Map<String, dynamic> original) {
    final staff = _safeMap(original['staff']);
    final sekolah = _safeMap(staff['sekolah']);
    final mapelsRaw = original['mapels'];
    final List mapels = (mapelsRaw is List) ? mapelsRaw : [];

    // Format mapels to string
    String mapelStr = '-';
    if (mapels.isNotEmpty) {
      mapelStr = mapels
          .map((m) => _safeStr(m is Map ? (m['nama'] ?? m['kode']) : m))
          .where((s) => s != '-' && s.isNotEmpty)
          .join(', ');
      if (mapelStr.isEmpty) mapelStr = '-';
    }

    return _buildDetailCard(
      title: 'Informasi Guru',
      icon: Icons.school_outlined,
      children: [
        _buildInfoRow('NIP', _safeStr(staff['nip'])),
        _buildInfoRow('NIG', _safeStr(staff['nig'])),
        _buildInfoRow('NUPTK', _safeStr(staff['nuptk'])),
        _buildInfoRow('Jabatan', _safeStr(staff['jabatan'])),
        _buildInfoRow('Bidang Studi', _safeStr(staff['bidang_studi'])),
        _buildInfoRow('Mata Pelajaran', mapelStr),
        _buildInfoRow('Sekolah', _safeStr(sekolah['nama_sekolah'])),
        _buildInfoRow('Status', _capitalizeFirst(_safeStr(staff['status']))),
        _buildInfoRow(
            'Tanggal Bergabung', _safeStr(staff['tanggal_bergabung'])),
      ],
    );
  }

  Widget _buildStaffInfo(Map<String, dynamic> original) {
    final staff = _safeMap(original['staff']);
    final role = _safeMap(original['role']);

    return _buildDetailCard(
      title: 'Informasi Kepegawaian',
      icon: Icons.badge_outlined,
      children: [
        _buildInfoRow('NIP', _safeStr(staff['nip'])),
        _buildInfoRow('Jabatan', _safeStr(staff['jabatan'])),
        _buildInfoRow(
            'Tipe Staff',
            _safeStr(staff['staff_type']) != '-'
                ? _safeStr(staff['staff_type'])
                : _safeStr(role['role_name'])),
        _buildInfoRow('Status', _capitalizeFirst(_safeStr(staff['status']))),
        _buildInfoRow(
            'Tanggal Bergabung', _safeStr(staff['tanggal_bergabung'])),
      ],
    );
  }

  Widget _buildPimpinanInfo(Map<String, dynamic> original) {
    final staff = _safeMap(original['staff']);

    return _buildDetailCard(
      title: 'Informasi Pimpinan',
      icon: Icons.account_balance_outlined,
      children: [
        _buildInfoRow('NIP', _safeStr(staff['nip'])),
        _buildInfoRow('Jabatan', _safeStr(staff['jabatan'])),
        _buildInfoRow('Status', _capitalizeFirst(_safeStr(staff['status']))),
        _buildInfoRow(
            'Tanggal Bergabung', _safeStr(staff['tanggal_bergabung'])),
      ],
    );
  }

  Widget _buildOrangTuaInfo(Map<String, dynamic> original) {
    final orangtua = _safeMap(original['orangtua']);

    return _buildDetailCard(
      title: 'Informasi Orang Tua',
      icon: Icons.family_restroom_outlined,
      children: [
        _buildInfoRow('Hubungan', _safeStr(orangtua['hubungan'])),
        _buildInfoRow('Pekerjaan', _safeStr(orangtua['pekerjaan'])),
        _buildInfoRow('Penghasilan', _safeStr(orangtua['penghasilan'])),
        _buildInfoRow('Pendidikan', _safeStr(orangtua['pendidikan'])),
        _buildInfoRow('Jumlah Anak', _safeStr(orangtua['jumlah_anak'])),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
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
              style: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty || value == 'null' ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '-';
    switch (gender.toLowerCase()) {
      case 'l':
      case 'laki-laki':
      case 'male':
        return 'Laki-laki';
      case 'p':
      case 'perempuan':
      case 'female':
        return 'Perempuan';
      default:
        return gender;
    }
  }

  String _capitalizeFirst(String? text) {
    if (text == null || text.isEmpty || text == 'null') return '-';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String? _getPhotoUrl(Map? details) {
    if (details == null) return null;
    final url = details['photo_url'];
    if (url == null || url.toString().isEmpty) return null;
    return url.toString();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Pimpinan':
        return const Color(0xFF9B59B6);
      case 'Guru':
        return const Color(0xFF3498DB);
      case 'Staff':
        return const Color(0xFFE67E22);
      case 'Orang Tua':
        return const Color(0xFF1ABC9C);
      case 'Santri':
        return const Color(0xFF00B894);
      case 'Siswa':
        return const Color(0xFF6C5CE7);
      default:
        return AppColors.primary;
    }
  }
}
