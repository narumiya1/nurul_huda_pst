import 'package:get/get.dart';
import '../controllers/teacher_area_controller.dart';

class TeacherAreaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherAreaController>(() => TeacherAreaController());
  }
}
