import 'package:get/get.dart';
import '../data/providers/auth_provider.dart';
import '../modules/petugas_bumdes/controllers/petugas_bumdes_dashboard_controller.dart';

class PetugasBumdesBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan AuthProvider teregistrasi
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider());
    }

    // Hapus terlebih dahulu untuk memastikan clean state
    try {
      if (Get.isRegistered<PetugasBumdesDashboardController>()) {
        Get.delete<PetugasBumdesDashboardController>(force: true);
      }
    } catch (e) {
      print('Error removing controller: $e');
    }

    // Gunakan put untuk memastikan controller selalu tersedia dan permanent
    Get.put<PetugasBumdesDashboardController>(
      PetugasBumdesDashboardController(),
      permanent: true,
    );

    print('✅ PetugasBumdesDashboardController registered successfully');
  }
}
