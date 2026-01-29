import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/pelanggaran/controllers/pelanggaran_controller.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';

// Mock API
class MockSantriApi extends SantriApi {}

// Mock Repository
class MockSantriRepository extends SantriRepository {
  MockSantriRepository();

  @override
  Future<List<dynamic>> getPelanggaran() async {
    return [
      {'judul': 'Telat', 'poin': 10}
    ];
  }

  @override
  Future<bool> submitPelanggaran(Map<String, dynamic> data) async {
    return true;
  }
}

void main() {
  late PelanggaranController controller;
  late MockSantriRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockSantriRepository();
    controller = PelanggaranController(repository: mockRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('PelanggaranController Test', () {
    testWidgets('Initial data loading', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Trigger fetch
      // onInit calls fetchPelanggaran but controller init inside test might not auto-call onInit unless Get.put handling.
      // We can call manually.
      await controller.fetchPelanggaran();

      expect(controller.isLoading.value, false);
      expect(controller.pelanggaranList.length, 1);
      expect(controller.pelanggaranList[0]['judul'], 'Telat');
    });

    testWidgets('Submit Pelanggaran validation', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.submitPelanggaran();
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      // Validation failed, no loading
      expect(controller.isLoading.value, false);
    });

    testWidgets('Submit Pelanggaran success', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.selectedSantriId.value = 1;
      controller.judulController.text = 'Kabur';

      await controller.submitPelanggaran();
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      expect(controller.isLoading.value, false);
    });
  });
}
