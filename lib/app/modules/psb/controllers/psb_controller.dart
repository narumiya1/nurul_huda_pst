import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';

class PsbController extends GetxController {
  final isLoading = false.obs;
  final registrants = <Map<String, dynamic>>[].obs;
  final filteredRegistrants = <Map<String, dynamic>>[].obs;
  final stats = <String, dynamic>{}.obs;
  final userRole = 'netizen'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchPsbData();
    debounce(searchQuery, (_) => searchRegistrant(searchQuery.value),
        time: const Duration(milliseconds: 500));
  }

  void _loadUserRole() {
    final user = LocalStorage.getUser();
    if (user != null) {
      final role = user['role'];
      if (role is String) {
        userRole.value = role.toLowerCase();
      } else if (role is Map) {
        userRole.value =
            (role['role_name'] ?? 'netizen').toString().toLowerCase();
      }
    }
  }

  bool get canManage => userRole.value == 'staff_pesantren';

  Future<void> fetchPsbData() async {
    try {
      isLoading.value = true;
      // Simulation of API call
      await Future.delayed(const Duration(seconds: 1));

      stats.value = {
        'total': 150,
        'verified': 85,
        'pending': 45,
        'rejected': 20,
      };

      registrants.assignAll([
        {
          'name': 'Muhammad Al-Fatih',
          'nisn': '0012345678',
          'status': 'Verified',
          'date': '2026-01-15',
          'school': 'SDN Corcordia 01',
        },
        {
          'name': 'Siti Khadijah',
          'nisn': '0098765432',
          'status': 'Pending',
          'date': '2026-01-16',
          'school': 'MI Al-Ikhlas',
        },
        {
          'name': 'Ahmad Dahlan',
          'nisn': '0022334455',
          'status': 'Verified',
          'date': '2026-01-17',
          'school': 'SD Sukamaju',
        },
        {
          'name': 'Raina Putri',
          'nisn': '0055667788',
          'status': 'Rejected',
          'date': '2026-01-14',
          'school': 'SDN Merdeka',
        },
      ]);

      filteredRegistrants.assignAll(registrants);
    } finally {
      isLoading.value = false;
    }
  }

  void filterStatus(String? status) {
    if (status == null || status == 'Semua') {
      filteredRegistrants.assignAll(registrants);
    } else {
      filteredRegistrants.assignAll(
        registrants.where((r) => r['status'] == status).toList(),
      );
    }
  }

  void searchRegistrant(String query) {
    if (query.isEmpty) {
      filteredRegistrants.assignAll(registrants);
    } else {
      filteredRegistrants.assignAll(
        registrants
            .where((r) =>
                r['name'].toLowerCase().contains(query.toLowerCase()) ||
                r['nisn'].contains(query))
            .toList(),
      );
    }
  }
}
