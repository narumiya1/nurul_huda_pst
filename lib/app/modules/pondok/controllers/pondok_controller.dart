import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';

class PondokController extends GetxController {
  final isLoading = false.obs;
  final dormStats = <String, dynamic>{}.obs;
  final dormList = <Map<String, dynamic>>[].obs;
  final userRole = 'netizen'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchPondokData();
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

  bool get canManage => ['staff_pesantren', 'rois'].contains(userRole.value);
  bool get isPimpinan => userRole.value == 'pimpinan';

  Future<void> fetchPondokData() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      dormStats.value = {
        'total_asrama': 5,
        'total_kamar': 40,
        'total_santri': 450,
        'kapasitas_tersedia': 50,
      };

      dormList.assignAll([
        {
          'name': 'Gedung Abu Bakar',
          'total_rooms': 10,
          'occupied_rooms': 10,
          'total_santri': 100,
          'status': 'Full',
        },
        {
          'name': 'Gedung Umar Bin Khattab',
          'total_rooms': 10,
          'occupied_rooms': 8,
          'total_santri': 85,
          'status': 'Available',
        },
        {
          'name': 'Gedung Utsman Bin Affan',
          'total_rooms': 10,
          'occupied_rooms': 9,
          'total_santri': 92,
          'status': 'Available',
        },
        {
          'name': 'Gedung Ali Bin Abi Thalib',
          'total_rooms': 10,
          'occupied_rooms': 10,
          'total_santri': 110,
          'status': 'Full',
        },
      ]);
    } finally {
      isLoading.value = false;
    }
  }
}
