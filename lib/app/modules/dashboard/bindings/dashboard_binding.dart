import 'package:epesantren_mob/app/api/news/news_api.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        NewsRepository(NewsApi()),
        PimpinanRepository(PimpinanApi()),
      ),
    );
  }
}
