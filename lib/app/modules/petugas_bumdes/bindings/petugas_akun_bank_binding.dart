import 'package:get/get.dart';
import '../controllers/petugas_akun_bank_controller.dart';
import '../../../data/providers/aset_provider.dart';

class PetugasAkunBankBinding extends Bindings {
  @override
  void dependencies() {
    // Register AsetProvider if not already registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }

    // Register PetugasAkunBankController
    Get.lazyPut<PetugasAkunBankController>(() => PetugasAkunBankController());
  }
}
