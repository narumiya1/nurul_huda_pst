import 'package:get/get.dart';

class WelcomeController extends GetxController {
  //TODO: Implement WelcomeController

  final count = 0.obs;

  void toLogin() {
    Get.toNamed('/login');
    // Get.offAllNamed('/login');
    // Get.offAllNamed('/kelurahan');
  }

  void toRegister() {
    Get.toNamed('/register');
  }



  void increment() => count.value++;
}
