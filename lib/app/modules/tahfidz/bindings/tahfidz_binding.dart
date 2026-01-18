import 'package:get/get.dart';
import '../controllers/tahfidz_controller.dart';

class TahfidzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TahfidzController>(() => TahfidzController());
  }
}
