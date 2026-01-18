import 'package:get/get.dart';
import '../controllers/psb_controller.dart';

class PsbBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PsbController>(() => PsbController());
  }
}
