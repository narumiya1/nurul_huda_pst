import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/login/controllers/login_controller.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:epesantren_mob/app/api/auth/auth_api.dart';
import 'package:epesantren_mob/app/routes/app_pages.dart';

// Mock AuthApi to avoid network calls in AuthRepository constructor
class MockAuthApi extends AuthApi {}

// Mock AuthRepository to simulate login responses
class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super(MockAuthApi());

  bool shouldSucceed = true;
  bool shouldThrow = false;

  @override
  Future<bool> login(String login, String password) async {
    if (shouldThrow) {
      throw Exception("Network Error");
    }
    if (login == 'test@example.com' && password == 'password') {
      return true;
    }
    return shouldSucceed;
  }
}

void main() {
  late LoginController controller;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    controller = LoginController(mockAuthRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('LoginController Test', () {
    testWidgets('Initial state variables are correct',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      expect(controller.emailController.text, '');
      expect(controller.passwordController.text, '');
      expect(controller.isLoading.value, false);
      expect(controller.showPassword.value, false);
    });

    testWidgets('togglePasswordVisibility toggles showPassword',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      expect(controller.showPassword.value, false);
      controller.togglePasswordVisibility();
      expect(controller.showPassword.value, true);
      controller.togglePasswordVisibility();
      expect(controller.showPassword.value, false);
    });

    testWidgets('loginProcess validation fails if empty',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.emailController.text = '';
      controller.passwordController.text = '';

      await controller.loginProcess();
      await tester.pump(const Duration(seconds: 4)); // Wait for snackbar

      expect(controller.isLoading.value, false);
    });

    testWidgets('loginProcess success', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
          home: Scaffold(body: Container()),
          getPages: [
            GetPage(name: Routes.dashboard, page: () => Container())
          ] // Mock dashboard route
          ));

      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password';
      mockAuthRepository.shouldSucceed = true;

      await controller.loginProcess();
      await tester.pump(const Duration(seconds: 4));

      expect(controller.isLoading.value, false);
    });

    testWidgets('loginProcess failure', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.emailController.text = 'wrong@example.com';
      controller.passwordController.text = 'wrongpass';
      mockAuthRepository.shouldSucceed = false;

      await controller.loginProcess();
      await tester.pump(const Duration(seconds: 4));

      expect(controller.isLoading.value, false);
    });

    testWidgets('loginProcess handles exception', (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password';
      mockAuthRepository.shouldThrow = true;

      await controller.loginProcess();
      await tester.pump(const Duration(seconds: 4));

      expect(controller.isLoading.value, false);
    });
  });
}
