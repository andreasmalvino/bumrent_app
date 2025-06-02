import 'package:get/get.dart';
import '../controllers/petugas_aset_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';

class PetugasAsetBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dashboard controller is registered
    if (!Get.isRegistered<PetugasBumdesDashboardController>()) {
      Get.put(PetugasBumdesDashboardController(), permanent: true);
    }

    Get.lazyPut<PetugasAsetController>(() => PetugasAsetController());
  }
}
