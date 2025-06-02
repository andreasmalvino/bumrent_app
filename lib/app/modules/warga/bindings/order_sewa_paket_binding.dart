import 'package:get/get.dart';
import '../controllers/order_sewa_paket_controller.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../data/providers/sewa_provider.dart';

class OrderSewaPaketBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure providers are registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider());
    }
    
    if (!Get.isRegistered<SewaProvider>()) {
      Get.put(SewaProvider());
    }
    
    Get.lazyPut<OrderSewaPaketController>(
      () => OrderSewaPaketController(),
    );
  }
}
