import 'package:get/get.dart';
import '../controllers/pondok_controller.dart';

class PondokBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PondokController>(() => PondokController());
  }
}
