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
    test('Initial fetch logic (simulation)', () async {
      await controller.fetchPsbData();

      expect(controller.isLoading.value, false);
      expect(controller.registrants.length, 4);
      expect(controller.stats['total'], 150);
    });

    test('Filter by status', () async {
      await controller.fetchPsbData();

      controller.filterStatus('Verified');
      expect(controller.filteredRegistrants.length, 2);

      controller.filterStatus('Rejected');
      expect(controller.filteredRegistrants.length, 1);

      controller.filterStatus('Semua');
      expect(controller.filteredRegistrants.length, 4);
    });

    test('Search functionality', () async {
      await controller.fetchPsbData();

      controller.searchRegistrant('Al-Fatih');
      expect(controller.filteredRegistrants.length, 1);

      controller.searchRegistrant('');
      expect(controller.filteredRegistrants.length, 4);
    });
  });
}
