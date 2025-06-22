import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';
import '../../../data/providers/aset_provider.dart';

class PetugasDetailSewaBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AsetProvider is registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }
    // Memastikan controller sudah tersedia
    Get.lazyPut<PetugasSewaController>(
      () => PetugasSewaController(),
      fenix: true,
    );
  }
}
