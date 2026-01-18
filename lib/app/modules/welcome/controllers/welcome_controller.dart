import 'package:get/get.dart';

class WelcomeController extends GetxController {
  void toLogin() {
    Get.toNamed('/login');
    // Get.offAllNamed('/login');
    // Get.offAllNamed('/kelurahan');
  }

  void toRegister() {
    Get.toNamed('/register');
  }
}
