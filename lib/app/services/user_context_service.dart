import 'package:get/get.dart';
import 'package:epesantren_mob/app/core/user_context.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

/// Service to manage user context across the application
/// Provides reactive user type detection and mode switching for dual-role users
class UserContextService extends GetxService {
  /// Current user context (observable)
  final Rx<UserContext?> context = Rx<UserContext?>(null);

  /// Current active mode for dual-role users
  final Rx<ActiveMode> activeMode = ActiveMode.pondok.obs;

  /// Storage key for persisting active mode
  static const String _activeModeKey = 'user_active_mode';

  @override
  void onInit() {
    super.onInit();
    _loadPersistedMode();
    _initFromStoredUser();
  }

  /// Initialize from stored user data if available
  void _initFromStoredUser() {
    final userData = LocalStorage.getUser();
    if (userData != null) {
      setFromUserData(userData);
    }
  }

  /// Load persisted active mode from storage
  void _loadPersistedMode() {
    final storedMode = LocalStorage.read(_activeModeKey);
    if (storedMode == 'sekolah') {
      activeMode.value = ActiveMode.sekolah;
    } else {
      activeMode.value = ActiveMode.pondok;
    }
  }

  /// Set user context from API user data
  void setFromUserData(Map<String, dynamic> userData) {
    final newContext = UserContext.fromUserData(userData);

    // Restore persisted mode if user is dual-role
    if (newContext.isDualRole) {
      newContext.activeMode = activeMode.value;
    }

    context.value = newContext;
  }

  /// Toggle active mode for dual-role users
  void toggleMode() {
    if (!isDualRole) return;

    if (activeMode.value == ActiveMode.pondok) {
      activeMode.value = ActiveMode.sekolah;
    } else {
      activeMode.value = ActiveMode.pondok;
    }

    // Persist the mode
    LocalStorage.write(_activeModeKey,
        activeMode.value == ActiveMode.sekolah ? 'sekolah' : 'pondok');

    // Update context
    if (context.value != null) {
      context.value = context.value!.copyWith(activeMode: activeMode.value);
    }
  }

  /// Set specific mode
  void setMode(ActiveMode mode) {
    if (!isDualRole) return;

    activeMode.value = mode;
    LocalStorage.write(
        _activeModeKey, mode == ActiveMode.sekolah ? 'sekolah' : 'pondok');

    if (context.value != null) {
      context.value = context.value!.copyWith(activeMode: mode);
    }
  }

  /// Clear context on logout
  void clear() {
    context.value = null;
    activeMode.value = ActiveMode.pondok;
    LocalStorage.write(_activeModeKey, 'pondok');
  }

  // ============ Convenience getters ============

  /// Check if user can access pondok features
  bool get canAccessPondok => context.value?.hasSantriAccess ?? false;

  /// Check if user can access sekolah features
  bool get canAccessSekolah => context.value?.hasSiswaAccess ?? false;

  /// Check if user is dual-role
  bool get isDualRole => context.value?.isDualRole ?? false;

  /// Check if user is rois
  bool get isRois => context.value?.isRois ?? false;

  /// Get current user type
  UserType get userType => context.value?.userType ?? UserType.other;

  /// Get santri data
  Map<String, dynamic>? get santriData => context.value?.santriData;

  /// Get siswa data
  Map<String, dynamic>? get siswaData => context.value?.siswaData;

  /// Check if active mode is pondok
  bool get isPondokMode => activeMode.value == ActiveMode.pondok;

  /// Check if active mode is sekolah
  bool get isSekolahMode => activeMode.value == ActiveMode.sekolah;

  /// Get role label for current mode (for display)
  String get activeModeLabel => isPondokMode ? 'Pondok' : 'Sekolah';

  /// Get primary role string
  String get role => context.value?.role ?? 'netizen';
}
