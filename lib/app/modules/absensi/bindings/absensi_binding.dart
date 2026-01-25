import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:get/get.dart';
import '../controllers/absensi_controller.dart';

class AbsensiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbsensiController>(
      () => AbsensiController(
        SantriRepository(),
        OrangtuaRepository(OrangtuaApi()),
      ),
    );
  }
}
