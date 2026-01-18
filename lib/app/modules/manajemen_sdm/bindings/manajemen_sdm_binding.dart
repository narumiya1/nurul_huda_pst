import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:get/get.dart';
import '../controllers/manajemen_sdm_controller.dart';

class ManajemenSdmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PimpinanApi>(() => PimpinanApi());
    Get.lazyPut<PimpinanRepository>(
        () => PimpinanRepository(Get.find<PimpinanApi>()));
    Get.lazyPut<ManajemenSdmController>(
      () => ManajemenSdmController(Get.find<PimpinanRepository>()),
    );
  }
}
