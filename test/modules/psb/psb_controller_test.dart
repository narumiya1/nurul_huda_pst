import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/psb/controllers/psb_controller.dart';

void main() {
  late PsbController controller;

  setUp(() {
    Get.testMode = true;
    controller = PsbController();
  });

  tearDown(() {
    Get.reset();
  });

  group('PsbController Test', () {
    test('Controller initializes correctly', () {
      expect(controller.isLoading.value, false);
      expect(controller.currentStep.value, 0);
      expect(controller.registrants.length, 0);
    });

    test('Step navigation works correctly', () {
      expect(controller.currentStep.value, 0);

      controller.nextStep();
      expect(controller.currentStep.value, 1);

      controller.nextStep();
      expect(controller.currentStep.value, 2);

      // Should not go beyond step 2
      controller.nextStep();
      expect(controller.currentStep.value, 2);

      controller.previousStep();
      expect(controller.currentStep.value, 1);

      controller.previousStep();
      expect(controller.currentStep.value, 0);

      // Should not go below step 0
      controller.previousStep();
      expect(controller.currentStep.value, 0);
    });

    test('Filter by status updates correctly', () {
      controller.filterByStatus('pending');
      expect(controller.selectedStatus.value, 'pending');

      controller.filterByStatus('accepted');
      expect(controller.selectedStatus.value, 'accepted');

      controller.filterByStatus(null);
      expect(controller.selectedStatus.value, null);
    });

    test('Search query updates correctly', () {
      controller.searchQuery.value = 'Ahmad';
      expect(controller.searchQuery.value, 'Ahmad');

      controller.searchQuery.value = '';
      expect(controller.searchQuery.value, '');
    });
  });
}
