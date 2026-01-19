import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';

class PelanggaranController extends GetxController {
  final SantriRepository _repository = SantriRepository(); // Simple injection
  final isLoading = false.obs;
  final pelanggaranList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPelanggaran();
  }

  Future<void> fetchPelanggaran() async {
    try {
      isLoading.value = true;
      final data = await _repository.getPelanggaran();
      pelanggaranList.assignAll(data);
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
