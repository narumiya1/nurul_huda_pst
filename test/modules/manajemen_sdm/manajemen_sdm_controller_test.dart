import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/manajemen_sdm/controllers/manajemen_sdm_controller.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_api.dart';

// Mock API
class MockPimpinanApi extends PimpinanApi {}

// Mock Repository
class MockPimpinanRepository extends PimpinanRepository {
  MockPimpinanRepository() : super(MockPimpinanApi());

  @override
  Future<Map<String, dynamic>> getUsersByType(String type,
      {String? search, int? perPage, int? page}) async {
    return {
      'meta': {'current_page': 1, 'last_page': 1},
      'data': [
        {
          'id': 1,
          'user': {
            'email': 'guru@test.com',
            'details': {'full_name': 'Guru Test', 'phone': '08123456789'},
            'is_active': 1
          }
        }
      ]
    };
  }

  @override
  Future<dynamic> createSantri(Map<String, dynamic> data) async {
    return {
      'success': true,
      'data': {'id': 1}
    };
  }
}

void main() {
  late ManajemenSdmController controller;
  late MockPimpinanRepository mockRepository;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockPimpinanRepository();
    controller = ManajemenSdmController(mockRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('ManajemenSdmController Test', () {
    testWidgets('Initial data loading', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Simulate selecting role 'Guru'
      controller.selectedRole.value = 'Guru';
      await controller.fetchUsers('Guru', refresh: true);

      // check loading state
      // fetchUsers has async logic.
      // However, since mock is immediate, it might finish fast.
      // We can check if list is populated.

      expect(controller.selectedRole.value, 'Guru');
      expect(controller.users.length, 1);
      expect(controller.users[0]['name'], 'Guru Test');
      expect(controller.users[0]['role'], 'Guru');
    });

    testWidgets('Add Santri success', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      await controller.addSantri({'nama': 'Budi'});
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      expect(controller.isLoading.value, false);
    });
  });
}
