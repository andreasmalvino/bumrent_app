import 'package:get/get.dart';
import '../controllers/petugas_paket_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';

class PetugasPaketBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dashboard controller is registered
    if (!Get.isRegistered<PetugasBumdesDashboardController>()) {
      Get.put(PetugasBumdesDashboardController(), permanent: true);
    }

    Get.lazyPut<PetugasPaketController>(() => PetugasPaketController());
  }
}
