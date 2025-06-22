import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';
import '../../../data/providers/aset_provider.dart';

class PetugasSewaBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AsetProvider is registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }
    Get.lazyPut<PetugasSewaController>(() => PetugasSewaController());
  }
}
