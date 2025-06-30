import 'package:get/get.dart';
import '../controllers/petugas_penyewa_controller.dart';

class PetugasPenyewaBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PetugasPenyewaController>(
      PetugasPenyewaController(),
      permanent: true,
    );
  }
}
