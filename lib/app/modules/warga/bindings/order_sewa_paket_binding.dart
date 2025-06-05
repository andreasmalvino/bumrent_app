import 'package:get/get.dart';
import '../controllers/order_sewa_paket_controller.dart';
import '../../../data/providers/aset_provider.dart';

class OrderSewaPaketBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure providers are registered
    if (!Get.isRegistered<AsetProvider>()) {
      Get.put(AsetProvider());
    }
    
    Get.lazyPut<OrderSewaPaketController>(
      () => OrderSewaPaketController(),
    );
  }
}
