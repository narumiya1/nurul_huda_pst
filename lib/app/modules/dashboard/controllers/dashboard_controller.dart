import 'package:epesantren_mob/app/api/news/news_model.dart';
import 'package:epesantren_mob/app/api/news/news_repository.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final NewsRepository _newsRepository;

  DashboardController(this._newsRepository);

  final beritaList = <BeritaModel>[].obs;
  final isLoadingBerita = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    try {
      isLoadingBerita.value = true;
      final data = await _newsRepository.getAllNews();
      beritaList.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat berita: $e");
    } finally {
      isLoadingBerita.value = false;
    }
  }

  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final selectedBeritaIndex = 0.obs;
  final bottomIndex = 0.obs;

  void changeBerita(int index) {
    selectedBeritaIndex.value = index;
  }
}
