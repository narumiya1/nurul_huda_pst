import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/administrasi/controllers/administrasi_controller.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';

// Mock API
class MockPimpinanApi extends PimpinanApi {}

// Mock Repository
class MockPimpinanRepository extends PimpinanRepository {
  MockPimpinanRepository() : super(MockPimpinanApi());

  @override
  Future<Map<String, dynamic>> getPersuratanSurat(
      {String? search, String? status}) async {
    return {
      'data': [
        {
          'id': 1,
          'perihal': 'Surat Undangan',
          'tipe': 'masuk',
          'nomor_surat': '001/INV/2026',
          'status': 'Approved',
          'pembuat': {
            'details': {'full_name': 'Admin'}
          },
          'file_path': 'path/to/file.pdf'
        }
      ]
    };
  }

  @override
  Future<Map<String, dynamic>> approvePersuratanSurat(String id) async {
    return {'status': 'success'};
  }

  @override
  Future<Map<String, dynamic>> rejectPersuratanSurat(String id) async {
    return {'status': 'success'};
  }
}

void main() {
  late AdministrasiController controller;
  late MockPimpinanRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockPimpinanRepository();
    controller = AdministrasiController(mockRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('AdministrasiController Test', () {
    testWidgets('Initial fetching and filtering', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.fetchAdministrasiData();

      expect(controller.isLoading.value, false);
      expect(controller.archiveList.length, 1);
      expect(controller.archiveList[0]['title'], 'Surat Undangan');
      expect(controller.filteredArchives.length, 1);
    });

    testWidgets('Search functionality', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      await controller.fetchAdministrasiData();

      controller.searchArchive('001');
      expect(controller.filteredArchives.length, 1);

      controller.searchArchive('XXX');
      expect(controller.filteredArchives.length, 0);
    });

    testWidgets('Status update actions', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Approve
      await controller.approveSurat('1');
      await tester.pump(const Duration(seconds: 4));

      // Reject
      await controller.rejectSurat('1');
      await tester.pump(const Duration(seconds: 4));

      expect(controller.isLoading.value, false);
    });
  });
}
