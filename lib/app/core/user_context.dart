// User Context Model
// Manages user type differentiation for Santri, Siswa, and dual-role users

/// User type enumeration for role differentiation
enum UserType {
  santriOnly, // Santri pondok tanpa sekolah formal
  siswaOnly, // Siswa sekolah (bukan pondok)
  santriSiswa, // Dual-role: tinggal di pondok + sekolah formal
  roisSantri, // Rois yang juga santri saja
  roisSiswa, // Rois yang juga siswa saja
  roisSantriSiswa, // Rois dengan dual-role lengkap
  other // Role lain (guru, pimpinan, staff, orangtua, dll)
}

/// Active mode for dual-role users
enum ActiveMode { pondok, sekolah }

/// User context with access flags and data
class UserContext {
  final String role;
  final UserType userType;
  final bool hasSantriAccess;
  final bool hasSiswaAccess;
  final bool isRois;
  final Map<String, dynamic>? santriData;
  final Map<String, dynamic>? siswaData;
  ActiveMode activeMode;

  UserContext({
    required this.role,
    required this.userType,
    required this.hasSantriAccess,
    required this.hasSiswaAccess,
    this.isRois = false,
    this.santriData,
    this.siswaData,
    this.activeMode = ActiveMode.pondok,
  });

  /// Check if user is dual-role (has both santri and siswa access)
  bool get isDualRole => hasSantriAccess && hasSiswaAccess;

  /// Check if current mode is pondok
  bool get isPondokMode => activeMode == ActiveMode.pondok;

  /// Check if current mode is sekolah
  bool get isSekolahMode => activeMode == ActiveMode.sekolah;

  /// Factory to create UserContext from API user data
  factory UserContext.fromUserData(Map<String, dynamic> userData) {
    final role = _extractRole(userData);
    final roleLower = role.toLowerCase();

    // Check santri data
    final santriData = userData['santri'] as Map<String, dynamic>?;
    final hasSantri = santriData != null && santriData.isNotEmpty;

    // Check siswa data
    final siswaData = userData['siswa'] as Map<String, dynamic>?;
    final hasSiswa = siswaData != null && siswaData.isNotEmpty;

    // Check is_siswa_juga flag from santri data
    final isSiswaJuga = santriData?['is_siswa_juga'] == true;

    // Check is_santri_juga flag from siswa data
    final isSantriJuga = siswaData?['is_santri_juga'] == true;

    // Determine if user is rois
    final isRois = roleLower == 'rois' ||
        roleLower == 'roissantri' ||
        roleLower == 'rois_santri';

    // Determine user type
    UserType userType;
    bool hasSantriAccess = false;
    bool hasSiswaAccess = false;

    if (isRois) {
      // Rois variants
      if (hasSantri && (hasSiswa || isSiswaJuga)) {
        userType = UserType.roisSantriSiswa;
        hasSantriAccess = true;
        hasSiswaAccess = true;
      } else if (hasSiswa || isSiswaJuga) {
        userType = UserType.roisSiswa;
        hasSiswaAccess = true;
      } else {
        userType = UserType.roisSantri;
        hasSantriAccess = true;
      }
    } else if (roleLower == 'santri') {
      if (hasSiswa || isSiswaJuga) {
        userType = UserType.santriSiswa;
        hasSantriAccess = true;
        hasSiswaAccess = true;
      } else {
        userType = UserType.santriOnly;
        hasSantriAccess = true;
      }
    } else if (roleLower == 'siswa') {
      if (hasSantri || isSantriJuga) {
        userType = UserType.santriSiswa;
        hasSantriAccess = true;
        hasSiswaAccess = true;
      } else {
        userType = UserType.siswaOnly;
        hasSiswaAccess = true;
      }
    } else {
      userType = UserType.other;
    }

    return UserContext(
      role: role,
      userType: userType,
      hasSantriAccess: hasSantriAccess,
      hasSiswaAccess: hasSiswaAccess,
      isRois: isRois,
      santriData: santriData,
      siswaData: siswaData,
      activeMode: hasSantriAccess ? ActiveMode.pondok : ActiveMode.sekolah,
    );
  }

  /// Extract role name from user data (handles string or map format)
  static String _extractRole(Map<String, dynamic> userData) {
    final role = userData['role'];
    if (role == null) return 'netizen';
    if (role is String) return role;
    if (role is Map) {
      return (role['role_name'] ?? 'netizen').toString();
    }
    return 'netizen';
  }

  /// Create a copy with updated active mode
  UserContext copyWith({ActiveMode? activeMode}) {
    return UserContext(
      role: role,
      userType: userType,
      hasSantriAccess: hasSantriAccess,
      hasSiswaAccess: hasSiswaAccess,
      isRois: isRois,
      santriData: santriData,
      siswaData: siswaData,
      activeMode: activeMode ?? this.activeMode,
    );
  }
}
