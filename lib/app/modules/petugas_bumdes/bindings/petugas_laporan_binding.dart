import 'package:get/get.dart';
import '../controllers/petugas_laporan_controller.dart';
import '../../../data/providers/aset_provider.dart';

class PetugasLaporanBinding extends Bindings {
  @override
  void dependencies() {
    // Register AsetProvider if not already registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }

    // Register PetugasLaporanController
    Get.lazyPut<PetugasLaporanController>(() => PetugasLaporanController());
  }
}
