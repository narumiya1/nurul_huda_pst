import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:epesantren_mob/app/api/news/news_api.dart';
import 'package:epesantren_mob/app/api/news/news_model.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/guru/guru_api.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/rois/rois_repository.dart';
import 'package:epesantren_mob/app/api/rois/rois_api.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/api/sdm/sdm_repository.dart';
import 'package:epesantren_mob/app/api/sdm/sdm_api.dart';

// Mock APIs
class MockNewsApi extends NewsApi {}

class MockPimpinanApi extends PimpinanApi {}

class MockGuruApi extends GuruApi {}

class MockSantriApi extends SantriApi {}

class MockOrangtuaApi extends OrangtuaApi {}

class MockRoisApi extends RoisApi {}

class MockAuthApi extends AuthApi {}

class MockSdmApi extends SdmApi {}

// Mock Repositories
class MockNewsRepository extends NewsRepository {
  MockNewsRepository() : super(MockNewsApi());
  @override
  Future<List<BeritaModel>> getAllNews() async => [];
}

class MockPimpinanRepository extends PimpinanRepository {
  MockPimpinanRepository() : super(MockPimpinanApi());
}

class MockGuruRepository extends GuruRepository {
  MockGuruRepository() : super(MockGuruApi());
}

class MockSantriRepository extends SantriRepository {
  // SantriRepository has no explicit constructor with args
  MockSantriRepository();
}

class MockOrangtuaRepository extends OrangtuaRepository {
  MockOrangtuaRepository() : super(MockOrangtuaApi());
}

class MockRoisRepository extends RoisRepository {
  MockRoisRepository() : super(MockRoisApi());
}

class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super(MockAuthApi());
  @override
  Future<void> updateFcmToken(String token) async {}
}

class MockSdmRepository extends SdmRepository {
  MockSdmRepository() : super(MockSdmApi());
}

void main() {
  late DashboardController controller;

  setUp(() {
    Get.testMode = true;
    controller = DashboardController(
      MockNewsRepository(),
      MockPimpinanRepository(),
      MockGuruRepository(),
      MockSantriRepository(),
      MockOrangtuaRepository(),
      MockRoisRepository(),
      MockAuthRepository(),
      MockSdmRepository(),
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('DashboardController Test', () {
    test('Initial state', () {
      expect(controller.selectedIndex.value, 0);
      expect(controller.isLoadingBerita.value, false);
      expect(controller.beritaList.length, 0);
    });

    test('changeIndex updates selectedIndex', () {
      controller.changeIndex(1);
      expect(controller.selectedIndex.value, 1);
    });

    // Fix: "test(..., () async {"
    test('fetchBerita loads news', () async {
      await controller.fetchBerita();
      expect(controller.isLoadingBerita.value, false);
      expect(controller.beritaList.length, 0); // Mock returns empty
    });
  });
}
