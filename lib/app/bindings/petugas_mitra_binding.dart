import 'package:get/get.dart';
import '../data/providers/auth_provider.dart';
import '../modules/petugas_mitra/controllers/petugas_mitra_dashboard_controller.dart';

class PetugasMitraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<PetugasMitraDashboardController>(
      () => PetugasMitraDashboardController(),
    );
  }
}
