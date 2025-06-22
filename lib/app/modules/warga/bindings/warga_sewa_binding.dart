import 'package:get/get.dart';
import '../controllers/warga_sewa_controller.dart';
import '../controllers/warga_dashboard_controller.dart';
import '../../../services/navigation_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/aset_provider.dart';

class WargaSewaBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthProvider is registered
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider(), permanent: true);
    }

    // Ensure AsetProvider is registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }

    // Register WargaDashboardController if not already registered
    if (!Get.isRegistered<WargaDashboardController>()) {
      Get.put(WargaDashboardController());
    }

    Get.lazyPut<WargaSewaController>(() => WargaSewaController());
  }
}
