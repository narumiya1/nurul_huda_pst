import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/tahfidz/controllers/tahfidz_controller.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';

// Mock APIs
class MockSantriApi extends SantriApi {}

// Mock Repositories
class MockSantriRepository extends SantriRepository {
  MockSantriRepository();

  @override
  Future<Map<String, dynamic>> getMyTahfidz() async {
    return {
      'total_juz': 5,
      'pencapaian': 16.6,
      'riwayat': [
        {
          'tanggal': '2026-01-29',
          'surah': 'Al-Fatihah',
          'ayat_awal': 1,
          'ayat_akhir': 7,
          'nilai': 100,
          'status': 'Lancar'
        }
      ]
    };
  }
}

void main() {
  late TahfidzController controller;
  late MockSantriRepository mockSantriRepository;

  setUp(() {
    Get.testMode = true;
    mockSantriRepository = MockSantriRepository();
    controller = TahfidzController(repository: mockSantriRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('TahfidzController Test', () {
    testWidgets('Initial data loading', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Trigger fetch manually (onInit usually called automatically if injected, but here we manually instantiated)
      await controller.fetchHafalan();

      expect(controller.isLoading.value, false);
      expect(controller.currentJuz.value, 5);
      expect(controller.hafalanList.length, 1);
      expect(controller.hafalanList[0]['surah'], 'Al-Fatihah');
    });

    testWidgets('Progress calculation', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.fetchHafalan();

      // current=5, target calculated in fetchHafalan based on logic:
      // if current > 0 && progressPerc > 0 -> target = (current * 100 / progress).round()
      // 5 * 100 / 16.6 = 500 / 16.6 ~= 30.12 -> 30
      expect(controller.targetJuz.value, 30);

      final progress = controller.progressPercentage;
      expect(progress, closeTo(16.6, 0.1));
    });
  });
}
