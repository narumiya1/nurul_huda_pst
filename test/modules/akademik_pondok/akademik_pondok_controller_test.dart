import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/akademik_pondok/controllers/akademik_pondok_controller.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';
import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart';

class MockPimpinanApi extends PimpinanApi {}

class MockSantriApi extends SantriApi {}

class MockOrangtuaApi extends OrangtuaApi {}

class MockPimpinanRepository extends PimpinanRepository {
  MockPimpinanRepository() : super(MockPimpinanApi());

  @override
  Future<List<dynamic>> getRekapNilai() async {
    return [
      {
        'kelas': {'nama_kelas': 'VII'},
        'nilai_akhir': 90
      }
    ];
  }

  @override
  Future<Map<String, dynamic>> getLaporanAbsensi(
      {String? startDate, String? endDate, String? tingkatId}) async {
    return {
      'summary': {
        'total_hadir': 10,
        'total_izin': 2,
        'total_sakit': 1,
        'total_alpha': 0
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getKurikulum() async {
    return {'data': []};
  }

  @override
  Future<Map<String, dynamic>> getAgenda({String filter = ''}) async {
    return {'data': []};
  }

  @override
  Future<Map<String, dynamic>> getTahfidz() async {
    return {'data': []};
  }
}

class MockSantriRepository extends SantriRepository {
  MockSantriRepository();
  @override
  Future<List<dynamic>> getMyTugas({String? tipe}) async => [];
  @override
  Future<List<dynamic>> getMateriList() async => [];
  @override
  Future<List<dynamic>> getNilaiSekolah(
          {String? semester,
          String? tahun,
          int? siswaId,
          String? tahunAjaran}) async =>
      [];
  @override
  Future<Map<String, dynamic>> getMyTahfidz() async => {};
}

class MockOrangtuaRepository extends OrangtuaRepository {
  MockOrangtuaRepository() : super(MockOrangtuaApi());

  @override
  Future<List<dynamic>> getMyChildren() async => [];
  @override
  Future<List<dynamic>> getChildTasks(int santriId, {String? tipe}) async => [];
  @override
  Future<dynamic> getChildScores(int santriId, {String? tipe}) async => [];
}

void main() {
  late AkademikPondokController controller;
  late MockPimpinanRepository mockPimpinanRepo;
  late MockSantriRepository mockSantriRepo;
  late MockOrangtuaRepository mockOrangtuaRepo;

  setUp(() {
    Get.testMode = true;
    mockPimpinanRepo = MockPimpinanRepository();
    mockSantriRepo = MockSantriRepository();
    mockOrangtuaRepo = MockOrangtuaRepository();

    controller = AkademikPondokController(
      pimpinanRepository: mockPimpinanRepo,
      orangtuaRepository: mockOrangtuaRepo,
      santriRepository: mockSantriRepo,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('AkademikPondokController Test', () {
    testWidgets('Initial fetching and logic (Default role)',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.fetchAllData();

      expect(controller.isLoading.value, false);
      expect(controller.rekapNilai.length, 1);
      expect(controller.rekapNilai[0]['tingkat'], 'VII');
      expect(controller.rekapNilai[0]['rata_rata'], 90.0);

      expect(controller.laporanAbsensi.length, 4);
      expect(controller.laporanAbsensi[0]['value'], 10);

      await tester.pump(const Duration(seconds: 1)); // Clear timers
    });

    testWidgets('Filtering Logic', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      await controller.fetchAllData();

      controller.selectedTingkat.value = 'VII';
      await controller.applyFilters();
      expect(controller.filteredRekapNilai.length, 1);

      controller.selectedTingkat.value = 'VIII';
      await controller.applyFilters();
      expect(controller.filteredRekapNilai.length, 0); // No VIII in mock
    });
  });
}
