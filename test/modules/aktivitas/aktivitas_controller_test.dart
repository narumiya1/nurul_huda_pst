import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/aktivitas/controllers/aktivitas_controller.dart';
import 'package:epesantren_mob/app/api/activity/activity_repository.dart';
import 'package:epesantren_mob/app/api/activity/activity_api.dart';

// Mock API
class MockActivityApi extends ActivityApi {}

// Mock Repo
class MockActivityRepository extends ActivityRepository {
  MockActivityRepository();

  @override
  Future<List<dynamic>> getActivities(String filter) async {
    return [
      {'id': 1, 'title': 'Lari Pagi', 'date': '2026-01-20', 'tipe': 'harian'}
    ];
  }

  @override
  Future<dynamic> createActivity(Map<String, dynamic> data) async {
    return {'id': 2, ...data};
  }
}

void main() {
  late AktivitasController controller;
  late MockActivityRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockActivityRepository();
    controller = AktivitasController(repository: mockRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('AktivitasController Test', () {
    testWidgets('Initial data loading', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // onInit calls fetchAktivitas, but we might need manual trigger if not waiting for widget lifecycle
      // Since we injected controller manually, we should call fetchAktivitas or rely on onInit if called.
      // GetxController onInit is called when Get.put is used. Here we used constructor.
      // So we call onInit manually or just fetchAktivitas.

      await controller.fetchAktivitas();

      expect(controller.isLoading.value, false);
      expect(controller.aktivitasList.length, 1);
      expect(controller.aktivitasList[0]['title'], 'Lari Pagi');
    });

    testWidgets('Add Activity success', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.addActivity({'title': 'Senam', 'date': '2026-01-21'});
      await tester.pump(const Duration(seconds: 4)); // wait for snackbar

      expect(controller.isLoading.value, false);
      // Check if list refreshed (mock returns same list but logic calls fetchAktivitas again)
      expect(controller.aktivitasList.length, 1);
    });

    testWidgets('Change Filter', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.changeFilter('mingguan');
      await tester.pump();

      expect(controller.selectedFilter.value, 'mingguan');
      // Mock returns same list, but we verify method called
      expect(controller.aktivitasList.length, 1);
    });
  });
}
