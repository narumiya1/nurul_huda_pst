import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import '../controllers/absensi_santri_controller.dart';

class AbsensiSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbsensiSantriController>(
      () => AbsensiSantriController(Get.find<SantriRepository>()),
    );
  }
}
