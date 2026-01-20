import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';
import '../../../api/pimpinan/pimpinan_api.dart';
import '../../../api/pimpinan/pimpinan_repository.dart';

class PondokController extends GetxController {
  final PimpinanRepository _repository = PimpinanRepository(PimpinanApi());

  final isLoading = false.obs;
  final dormStats = <String, dynamic>{}.obs;
  final dormList = <Map<String, dynamic>>[].obs;
  final userRole = 'netizen'.obs;

  final selectedBlok = Rxn<Map<String, dynamic>>();
  final roomList = <dynamic>[].obs;
  final isRoomLoading = false.obs;

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

  bool get canManage =>
      ['staff_pesantren', 'rois', 'superadmin'].contains(userRole.value);
  bool get isPimpinan => userRole.value == 'pimpinan';

  Future<void> fetchPondokData() async {
    try {
      isLoading.value = true;

      final response = await _repository.getPondokBlok();

      if (response['success'] == true && response['data'] != null) {
        final List blokList = response['data'] as List;

        // Calculate stats
        int totalAsrama = blokList.length;
        int totalKamar = 0;
        int totalSantri = 0;
        int totalKapasitas = 0;

        List<Map<String, dynamic>> formattedList = [];

        for (var blok in blokList) {
          final List kamarList = blok['kamar'] ?? [];
          int blokKamar = kamarList.length;
          int blokSantri = 0;
          int blokKapasitas = 0;
          int occupiedRooms = 0;

          for (var kamar in kamarList) {
            int kapasitas = kamar['kapasitas'] ?? 0;
            int santriCount = kamar['santri_count'] ?? 0;
            blokSantri += santriCount;
            blokKapasitas += kapasitas;
            if (santriCount >= kapasitas && kapasitas > 0) {
              occupiedRooms++;
            }
          }

          totalKamar += blokKamar;
          totalSantri += blokSantri;
          totalKapasitas += blokKapasitas;

          // Get rois name
          String roisName = '-';
          if (blok['rois'] != null && blok['rois']['details'] != null) {
            roisName = blok['rois']['details']['full_name'] ?? '-';
          }

          formattedList.add({
            'id': blok['id'],
            'name': blok['nama_blok'] ?? 'Blok',
            'lokasi': blok['lokasi'] ?? '-',
            'deskripsi': blok['deskripsi'] ?? '-',
            'total_rooms': blokKamar,
            'occupied_rooms': occupiedRooms,
            'total_santri': blokSantri,
            'kapasitas': blokKapasitas,
            'rois': roisName,
            'status': blokSantri >= blokKapasitas && blokKapasitas > 0
                ? 'Full'
                : 'Available',
          });
        }

        dormStats.value = {
          'total_asrama': totalAsrama,
          'total_kamar': totalKamar,
          'total_santri': totalSantri,
          'kapasitas_tersedia': totalKapasitas - totalSantri,
        };

        dormList.assignAll(formattedList);
      } else {
        // Fallback to mock data
        _loadMockData();
      }
    } catch (e) {
      // Fallback to mock data on error
      _loadMockData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRooms(String blokId) async {
    try {
      isRoomLoading.value = true;
      final response = await _repository.getPondokKamar(blokId: blokId);
      if (response['success'] == true) {
        roomList.assignAll(response['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar kamar: $e');
    } finally {
      isRoomLoading.value = false;
    }
  }

  Future<void> addBlok(String name, String lokasi) async {
    try {
      isLoading.value = true;
      await _repository.createPondokBlok({
        'nama_blok': name,
        'lokasi': lokasi,
      });
      Get.back();
      Get.snackbar('Sukses', 'Berhasil menambah asrama');
      fetchPondokData();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menambah asrama: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addKamar(int blokId, String name, int kapasitas) async {
    try {
      isLoading.value = true;
      await _repository.createPondokKamar({
        'blok_id': blokId,
        'nama_kamar': name,
        'kapasitas': kapasitas,
      });
      Get.back();
      Get.snackbar('Sukses', 'Berhasil menambah kamar');
      fetchRooms(blokId.toString());
      fetchPondokData();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menambah kamar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignSantri(int santriId, int kamarId) async {
    try {
      isLoading.value = true;
      final response = await _repository.assignSantriToKamar({
        'santri_id': santriId,
        'kamar_id': kamarId,
      });
      if (response['success'] == true) {
        Get.back();
        Get.snackbar('Sukses', 'Santri berhasil ditempatkan');
        if (selectedBlok.value != null) {
          fetchRooms(selectedBlok.value!['id'].toString());
        }
        fetchPondokData();
      } else {
        Get.snackbar(
            'Gagal', response['message'] ?? 'Gagal menempatkan santri');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menempatkan santri: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockData() {
    dormStats.value = {
      'total_asrama': 2,
      'total_kamar': 5,
      'total_santri': 50,
      'kapasitas_tersedia': 10,
    };

    dormList.assignAll([
      {
        'id': 1,
        'name': 'Blok A (Abu Bakar)',
        'lokasi': 'Timur Masjid',
        'total_rooms': 3,
        'occupied_rooms': 2,
        'total_santri': 28,
        'kapasitas': 30,
        'rois': '-',
        'status': 'Available',
      },
      {
        'id': 2,
        'name': 'Blok B (Umar Bin Khattab)',
        'lokasi': 'Selatan Masjid',
        'total_rooms': 2,
        'occupied_rooms': 2,
        'total_santri': 24,
        'kapasitas': 24,
        'rois': '-',
        'status': 'Full',
      },
    ]);
  }
}
