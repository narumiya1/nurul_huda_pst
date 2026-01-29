import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/keuangan/controllers/keuangan_controller.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';

// Mock APIs
class MockPimpinanApi extends PimpinanApi {}

class MockSantriApi extends SantriApi {}

class MockOrangtuaApi extends OrangtuaApi {}

// Mock Repositories
class MockPimpinanRepository extends PimpinanRepository {
  MockPimpinanRepository() : super(MockPimpinanApi());

  @override
  Future<Map<String, dynamic>> getFinancing(
      {String filter = 'bulanan', String? search, String? type}) async {
    return {
      'data': {
        'summary': {'total_saldo': 1000000},
        'items': []
      }
    };
  }
}

class MockSantriRepository extends SantriRepository {
  MockSantriRepository();

  @override
  Future<List<dynamic>> getMyBills() async {
    return [
      {'id': 1, 'judul': 'SPP', 'total_tagihan': 50000, 'status': 'pending'}
    ];
  }
}

class MockOrangtuaRepository extends OrangtuaRepository {
  MockOrangtuaRepository() : super(MockOrangtuaApi());
}

void main() {
  late KeuanganController controller;
  late MockPimpinanRepository mockPimpinanRepository;
  late MockSantriRepository mockSantriRepository;
  late MockOrangtuaRepository mockOrangtuaRepository;

  setUp(() {
    Get.testMode = true;
    mockPimpinanRepository = MockPimpinanRepository();
    mockSantriRepository = MockSantriRepository();
    mockOrangtuaRepository = MockOrangtuaRepository();
    controller = KeuanganController(
        mockPimpinanRepository, mockSantriRepository, mockOrangtuaRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('KeuanganController Test', () {
    testWidgets('Initial state', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      expect(controller.isLoading.value, false);
      expect(controller.bills.length, 0);
    });

    testWidgets('filter updates trigger fetch', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.applyFilters(period: 'Hari Ini');
      expect(controller.selectedPeriod.value, 'daily');

      // Since it's an async void call, we can't await it unless we return future from applyFilters.
      // But we can check if loading flips.
    });

    // Additional tests for role specific logic (Santri vs Pimpinan) would require mocking LocalStorage which is static.
    // Testing static mock might be tricky without a wrapper or shared_preferences_mock.
  });
}
