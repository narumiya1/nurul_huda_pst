import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:get/get.dart';
import '../controllers/akademik_pondok_controller.dart';

class AkademikPondokBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AkademikPondokController>(
      () => AkademikPondokController(
          pimpinanRepository: PimpinanRepository(PimpinanApi()),
          orangtuaRepository: OrangtuaRepository(OrangtuaApi())),
    );
  }
}
