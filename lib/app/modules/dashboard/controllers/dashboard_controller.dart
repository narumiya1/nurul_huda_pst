import 'package:get/get.dart';

class DashboardController extends GetxController {
  //TODO: Implement DashboardController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final selectedBeritaIndex = 0.obs;
  final bottomIndex = 0.obs;

  final beritaTabs = [
    'Berita Terbaru',
    'Berita 1',
    'Berita 2',
    'Berita 3',
  ];
  void changeBerita(int index) {
    selectedBeritaIndex.value = index;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
