import 'package:get/get.dart';
import '../data/providers/auth_provider.dart';
import '../modules/warga/controllers/warga_dashboard_controller.dart';

class WargaBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan AuthProvider teregistrasi
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider());
    }

    // Gunakan lazyPut untuk memastikan controller hanya diinisialisasi saat dibutuhkan
    Get.lazyPut<WargaDashboardController>(
      () => WargaDashboardController(),
      fenix: true, // Akan dibuat ulang jika dihapus
    );
  }
}
