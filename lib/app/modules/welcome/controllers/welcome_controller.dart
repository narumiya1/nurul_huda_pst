import 'package:get/get.dart';

class WelcomeController extends GetxController {
  //TODO: Implement WelcomeController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  void toLogin() {
    Get.toNamed('/login');
    // Get.offAllNamed('/login');
    // Get.offAllNamed('/kelurahan');
  }

  void toRegister() {
    Get.toNamed('/register');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
