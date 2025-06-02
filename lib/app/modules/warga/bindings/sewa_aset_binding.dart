import 'package:get/get.dart';
import '../controllers/sewa_aset_controller.dart';
import '../../../data/providers/aset_provider.dart';

class SewaAsetBinding extends Bindings {
  @override
  void dependencies() {
    // Register AsetProvider if not already registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider(), permanent: true);
    }

    // Register SewaAsetController
    Get.lazyPut<SewaAsetController>(() => SewaAsetController());
  }
}
