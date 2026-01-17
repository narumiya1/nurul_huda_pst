import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(AuthRepository(AuthApi())),
    );
  }
}
