import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/register/controllers/register_controller.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_repository.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_api.dart';
import 'package:epesantren_mob/app/api/address/kota_kab/kota_kab_repository.dart';
import 'package:epesantren_mob/app/api/address/kota_kab/kota_kab_api.dart';
import 'package:epesantren_mob/app/api/address/kecamatan/kecamatan_repository.dart';
import 'package:epesantren_mob/app/api/address/kecamatan/kecamatan_api.dart';
import 'package:epesantren_mob/app/api/address/desa_kelurahan/desa_kelurahan_repository.dart';
import 'package:epesantren_mob/app/api/address/desa_kelurahan/desa_kelurahan_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';

// Mock APIs
class MockAuthApi extends AuthApi {}

class MockProvinsiApi extends ProvinsiApi {}

class MockKotaKabApi extends KotaKabApi {}

class MockKecamatanApi extends KecamatanApi {}

class MockDesaKelurahanApi extends DesaKelurahanApi {}

// Mock Repositories
class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super(MockAuthApi());
  @override
  Future<bool> register(Map<String, dynamic> data) async => true;
}

class MockProvinsiRepository extends ProvinsiRepository {
  MockProvinsiRepository() : super(MockProvinsiApi());
  @override
  Future<List<ProvinsModel>> provinsiResponse() async {
    return [ProvinsModel(id: '1', name: 'Jawa Barat')];
  }
}

class MockKotaKabRepository extends KotaKabRepository {
  MockKotaKabRepository() : super(MockKotaKabApi());
  @override
  Future<List<ProvinsModel>> districtResponse(String provinceId) async {
    return [ProvinsModel(id: '1', name: 'Bandung')];
  }
}

class MockKecamatanRepository extends KecamatanRepository {
  MockKecamatanRepository() : super(MockKecamatanApi());
}

class MockDesaKelurahanRepository extends DesaKelurahanRepository {
  MockDesaKelurahanRepository() : super(MockDesaKelurahanApi());
}

void main() {
  late RegisterController controller;
  late MockAuthRepository mockAuthRepository;
  late MockProvinsiRepository mockProvinsiRepository;
  late MockKotaKabRepository mockKotaKabRepository;
  late MockKecamatanRepository mockKecamatanRepository;
  late MockDesaKelurahanRepository mockDesaKelurahanRepository;

  setUpAll(() async {
    // Mock PathProvider for GetStorage potential usage in deps
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return ".";
    });
  });

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    mockProvinsiRepository = MockProvinsiRepository();
    mockKotaKabRepository = MockKotaKabRepository();
    mockKecamatanRepository = MockKecamatanRepository();
    mockDesaKelurahanRepository = MockDesaKelurahanRepository();

    controller = RegisterController(
      mockAuthRepository,
      provinsiRepository: mockProvinsiRepository,
      kotaKabRepository: mockKotaKabRepository,
      kecamatanRepository: mockKecamatanRepository,
      desaKelurahanRepository: mockDesaKelurahanRepository,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('RegisterController Test', () {
    testWidgets('Initial state and fetchProvinsi', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.onInit();
      await tester.pump(const Duration(seconds: 1)); // Wait fetch

      expect(controller.stepIndex.value, 0);
      expect(controller.provinsiDataList.length, 1);
      expect(controller.provinsiDataList[0].name, 'Jawa Barat');
    });

    testWidgets('Navigation steps', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      expect(controller.stepIndex.value, 0);
      controller.nextStep();
      expect(controller.stepIndex.value, 1);
      controller.prevStep();
      expect(controller.stepIndex.value, 0);
    });

    testWidgets('Submit Akhir success', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
          home: Scaffold(body: Container()),
          getPages: [GetPage(name: '/login', page: () => Container())]));

      controller.namaLengkap.value = "Test User";
      await controller.submitAkhir();
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      // Should navigate to login on success
      expect(Get.currentRoute, '/login');
    });
  });
}
