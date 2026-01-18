import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';

class ManajemenSdmController extends GetxController {
  final PimpinanRepository _repository;
  ManajemenSdmController(this._repository);

  final isLoading = false.obs;
  final users = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;
  final selectedRole = 'Semua'.obs;
  final currentUserRole = 'netizen'.obs;

  final List<String> roles = [
    'Semua',
    'Pimpinan',
    'Guru',
    'Staff',
    'Orang Tua',
    'Santri',
    'Siswa'
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    filterByRole(
        'Pimpinan'); // Default to Pimpinan instead of Semua to be lighter
  }

  void _loadUserRole() {
    final user = LocalStorage.getUser();
    if (user != null) {
      final role = user['role'];
      if (role is String) {
        currentUserRole.value = role.toLowerCase();
      } else if (role is Map) {
        currentUserRole.value =
            (role['role_name'] ?? 'netizen').toString().toLowerCase();
      }
    }
  }

  bool get canManage =>
      currentUserRole.value == 'staff_pesantren' ||
      currentUserRole.value == 'pimpinan';

  void fetchUsers(String role) async {
    isLoading.value = true;
    users.clear();
    filteredUsers.clear(); // Clear immediately for feedback

    try {
      List<Map<String, dynamic>> results = [];

      if (role == 'Semua') {
        // Fetch Key Roles only to avoid overload
        final p = await _repository.getUsersByType('pimpinan');
        final g = await _repository.getUsersByType('guru');
        final s = await _repository.getUsersByType('staff');

        results.addAll(_mapResponse(p, 'Pimpinan'));
        results.addAll(_mapResponse(g, 'Guru'));
        results.addAll(_mapResponse(s, 'Staff'));
      } else {
        // Map UI Label to API endpoint type
        String type = role.toLowerCase().replaceAll(' ', '');
        // Exceptions
        if (role == 'Orang Tua') type = 'orangtua';

        final response = await _repository.getUsersByType(type);
        results.addAll(_mapResponse(response, role));
      }

      users.assignAll(results);
      filteredUsers.assignAll(users);
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _mapResponse(dynamic response, String roleLabel) {
    List list = [];
    if (response is Map && response['data'] != null) {
      if (response['data'] is List) list = response['data'];
    } else if (response is List) {
      list =
          response; // Santri might return list directly? No, controller says json structure.
    }

    return list.map((item) {
      String name = 'No Name';
      String email = '-';
      String status = 'Non-Aktif';

      if (item is Map) {
        // Support for nested User (like in Siswa record)
        Map? userObj = item;
        if (item['user'] != null && item['user'] is Map) {
          userObj = item['user'] as Map;
        }

        // Name
        if (userObj['details'] != null &&
            userObj['details'] is Map &&
            userObj['details']['full_name'] != null) {
          name = userObj['details']['full_name'];
        } else if (userObj['name'] != null) {
          name = userObj['name'];
        } else if (item['full_name'] != null) {
          name = item['full_name'];
        }

        // Email
        if (userObj['email'] != null) email = userObj['email'];

        // Status
        if (item['is_active'] == 1 ||
            item['is_active'] == true ||
            userObj['is_active'] == 1 ||
            userObj['is_active'] == true ||
            item['status'] == 'aktif') {
          status = 'Aktif';
        }
      }

      return {
        'name': name,
        'role': roleLabel,
        'email': email,
        'status': status,
        'original': item // Keep original if needed
      };
    }).toList();
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    fetchUsers(role);
  }

  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers.assignAll(users);
    } else {
      filteredUsers.assignAll(users
          .where((u) =>
              u['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              u['email'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }
}
