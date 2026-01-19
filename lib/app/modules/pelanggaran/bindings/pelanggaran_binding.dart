import 'package:get/get.dart';
import '../controllers/pelanggaran_controller.dart';

class PelanggaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PelanggaranController>(
      () => PelanggaranController(),
    );
  }
}
