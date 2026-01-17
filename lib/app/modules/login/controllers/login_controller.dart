import 'package:epesantren_mob/app/routes/app_pages.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  final username = ''.obs;
  final password = ''.obs;

  Future<void> loginProcess() async {
    // nanti isi logic API
    await Get.snackbar("Login", "Sukses");
    await Get.offAllNamed(Routes.DASHBOARD);
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
