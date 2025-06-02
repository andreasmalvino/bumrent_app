import 'package:get/get.dart';
import '../controllers/petugas_manajemen_bumdes_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../data/providers/auth_provider.dart';

class PetugasManajemenBumdesBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure AuthProvider is registered
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider());
    }

    // Register the dashboard controller if not already registered
    if (!Get.isRegistered<PetugasBumdesDashboardController>()) {
      Get.put<PetugasBumdesDashboardController>(
        PetugasBumdesDashboardController(),
        permanent: true,
      );
    }

    // Register the manajemen bumdes controller
    Get.lazyPut<PetugasManajemenBumdesController>(
      () => PetugasManajemenBumdesController(),
    );
  }
}
