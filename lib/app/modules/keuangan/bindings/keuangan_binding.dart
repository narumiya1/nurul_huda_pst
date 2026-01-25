import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:get/get.dart';
import '../controllers/keuangan_controller.dart';

class KeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeuanganController>(
      () => KeuanganController(
        PimpinanRepository(PimpinanApi()),
        SantriRepository(),
        OrangtuaRepository(OrangtuaApi()),
      ),
    );
  }
}
