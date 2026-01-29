import 'package:flutter/services.dart'; // Added
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/profil/controllers/profil_controller.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:get_storage/get_storage.dart';

// Mock ApiHelper
class MockApiHelper extends ApiHelper {
  @override
  Future<T> getData<T>(
      {required Uri uri,
      required T Function(dynamic p1) builder,
      Map<String, String>? header,
      Map<String, String>? params}) async {
    dynamic responseData;
    if (uri.path.contains('user/my-profile')) {
      responseData = {
        'status': true,
        'data': {
          'user': {
            'username': 'test_user',
            'email': 'test@example.com',
            'details': {'full_name': 'Test User'},
            'role': {'role_name': 'Santri'}
          }
        }
      };
    } else if (uri.path.contains('settings')) {
      responseData = {
        'status': true,
        'data': {'version': '1.0.0'}
      };
    }

    if (responseData != null) {
      return builder(responseData);
    }
    throw Exception('Not mocked');
  }
}

void main() {
  late ProfilController controller;
  late MockApiHelper mockApiHelper;

  setUpAll(() async {
    // Mock PathProvider for GetStorage if needed
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return ".";
    });

    await GetStorage.init();
  });

  setUp(() {
    Get.testMode = true;
    mockApiHelper = MockApiHelper();
    controller = ProfilController(apiHelper: mockApiHelper);
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfilController Test', () {
    testWidgets('Initial data loading', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Trigger manually if needed, or let onInit run (it runs on creation/Get.put,
      // but here we instantiated controller.
      // onInit is called by Get when controller is injected.
      // Manually calling onInit() is possible for pure unit test.

      controller.onInit();

      // Allow async calls to complete
      await tester.pump(const Duration(seconds: 1));

      expect(controller.userData.value?['username'], 'test_user');
      expect(controller.userName, 'Test User');
    });
  });
}
