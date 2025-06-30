import 'package:get/get.dart';
import '../controllers/petugas_detail_penyewa_controller.dart';

class PetugasDetailPenyewaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetugasDetailPenyewaController>(
      () => PetugasDetailPenyewaController(),
    );
  }
}
