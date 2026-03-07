import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import '../controllers/absensi_siswa_controller.dart';

class AbsensiSiswaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbsensiSiswaController>(
      () => AbsensiSiswaController(
        SantriRepository(),
        OrangtuaRepository(OrangtuaApi()),
      ),
    );
  }
}
