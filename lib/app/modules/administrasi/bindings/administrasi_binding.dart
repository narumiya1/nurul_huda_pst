import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:get/get.dart';
import '../controllers/administrasi_controller.dart';

class AdministrasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdministrasiController>(
        () => AdministrasiController(PimpinanRepository(PimpinanApi())));
  }
}
