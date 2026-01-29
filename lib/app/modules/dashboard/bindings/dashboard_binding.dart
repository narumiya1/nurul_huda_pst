import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:epesantren_mob/app/api/news/news_api.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/guru/guru_api.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/rois/rois_api.dart';
import 'package:epesantren_mob/app/api/rois/rois_repository.dart';
import 'package:epesantren_mob/app/api/sdm/sdm_api.dart';
import 'package:epesantren_mob/app/api/sdm/sdm_repository.dart';
import 'package:epesantren_mob/app/modules/profil/controllers/profil_controller.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        NewsRepository(NewsApi()),
        PimpinanRepository(PimpinanApi()),
        GuruRepository(GuruApi()),
        SantriRepository(),
        OrangtuaRepository(OrangtuaApi()),
        RoisRepository(RoisApi()),
        AuthRepository(AuthApi()),
        SdmRepository(SdmApi()),
      ),
    );
    Get.lazyPut<ProfilController>(() => ProfilController());
  }
}
