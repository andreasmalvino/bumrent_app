import 'package:get/get.dart';
import '../controllers/petugas_bumdes_cbp_controller.dart';

class PetugasBumdesCbpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetugasBumdesCbpController>(() => PetugasBumdesCbpController());
  }
}
