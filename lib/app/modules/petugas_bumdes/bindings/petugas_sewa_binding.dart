import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';

class PetugasSewaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetugasSewaController>(() => PetugasSewaController());
  }
}
