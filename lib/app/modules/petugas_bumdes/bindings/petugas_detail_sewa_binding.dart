import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';

class PetugasDetailSewaBinding extends Bindings {
  @override
  void dependencies() {
    // Memastikan controller sudah tersedia
    Get.lazyPut<PetugasSewaController>(
      () => PetugasSewaController(),
      fenix: true,
    );
  }
}
