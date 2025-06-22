import 'package:get/get.dart';
import 'package:bumrent_app/app/data/providers/aset_provider.dart';
import '../controllers/petugas_paket_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';

class PetugasPaketBinding extends Bindings {
  @override
  void dependencies() {
    // Register AsetProvider first
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }

    // Ensure dashboard controller is registered
    if (!Get.isRegistered<PetugasBumdesDashboardController>()) {
      Get.put(PetugasBumdesDashboardController(), permanent: true);
    }

    // Register the controller
    Get.lazyPut<PetugasPaketController>(
      () => PetugasPaketController(),
      fenix: true,
    );
  }
}
