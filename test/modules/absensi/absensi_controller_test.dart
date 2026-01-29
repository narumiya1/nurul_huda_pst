import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/absensi/controllers/absensi_controller.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';

// Mock APIs
class MockSantriApi extends SantriApi {}

class MockOrangtuaApi extends OrangtuaApi {}

// Mock Repositories
class MockSantriRepository extends SantriRepository {
  MockSantriRepository();

  @override
  Future<List<dynamic>> getMyAbsensi() async {
    return [
      {'tanggal': '2026-01-29', 'status': 'hadir', 'keterangan': '-'}
    ];
  }

  @override
  Future<List<dynamic>> getPerizinan() async {
    return [
      {'jenis_izin': 'Sakit', 'status': 'pending'}
    ];
  }

  @override
  Future<bool> submitPerizinan(Map<String, dynamic> data) async {
    return true;
  }
}

class MockOrangtuaRepository extends OrangtuaRepository {
  MockOrangtuaRepository() : super(MockOrangtuaApi());
}

void main() {
  late AbsensiController controller;
  late MockSantriRepository mockSantriRepository;
  late MockOrangtuaRepository mockOrangtuaRepository;

  setUp(() {
    Get.testMode = true;
    mockSantriRepository = MockSantriRepository();
    mockOrangtuaRepository = MockOrangtuaRepository();
    controller =
        AbsensiController(mockSantriRepository, mockOrangtuaRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('AbsensiController Test', () {
    testWidgets('Initial state', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      expect(controller.isLoading.value, false);
      expect(controller.absensiList.length, 0);
    });

    testWidgets('submitIzin validation fails if empty',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.submitIzin();
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      expect(controller.isLoading.value, false);
    });

    testWidgets('submitIzin success', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Setup
      controller.alasanController.text = 'Reason for leave';
      controller.tanggalKeluarController.text = '2026-02-01';

      // Call
      await controller.submitIzin();
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      // Assert
      expect(controller.isLoading.value, false);
    });
  });
}
