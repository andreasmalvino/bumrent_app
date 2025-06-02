import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../controllers/order_sewa_aset_controller.dart';

class OrderSewaAsetBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('⚡ OrderSewaAsetBinding: dependencies called');
    final box = GetStorage();

    // Ensure providers are registered
    if (!Get.isRegistered<AsetProvider>()) {
      debugPrint('⚡ Registering AsetProvider');
      Get.put(AsetProvider(), permanent: true);
    }

    if (!Get.isRegistered<AuthProvider>()) {
      debugPrint('⚡ Registering AuthProvider');
      Get.put(AuthProvider(), permanent: true);
    }

    // Check if we have the asetId in arguments
    final args = Get.arguments;
    debugPrint('⚡ Arguments received in binding: $args');
    String? asetId;

    if (args != null && args.containsKey('asetId') && args['asetId'] != null) {
      asetId = args['asetId'].toString();
      if (asetId.isNotEmpty) {
        debugPrint('✅ Valid asetId found in arguments: $asetId');
        // Simpan ID di storage untuk digunakan saat hot reload
        box.write('current_aset_id', asetId);
        debugPrint('💾 Saved asetId to GetStorage in binding: $asetId');
      } else {
        debugPrint('⚠️ Warning: Empty asetId found in arguments');
      }
    } else {
      debugPrint(
        '⚠️ Warning: No valid asetId found in arguments, checking storage',
      );
      // Cek apakah ada ID tersimpan di storage
      if (box.hasData('current_aset_id')) {
        asetId = box.read<String>('current_aset_id');
        debugPrint('📦 Found asetId in GetStorage: $asetId');
      }
    }

    // Only delete the existing controller if we're not in a hot reload situation
    if (Get.isRegistered<OrderSewaAsetController>()) {
      // Check if we're going through a hot reload by looking at the controller's state
      final existingController = Get.find<OrderSewaAsetController>();
      if (existingController.aset.value == null) {
        // Controller exists but doesn't have data, likely a fresh navigation or reload
        debugPrint('⚡ Removing old OrderSewaAsetController without data');
        Get.delete<OrderSewaAsetController>(force: true);

        // Use put instead of lazyPut to ensure controller is created immediately
        debugPrint('⚡ Creating new OrderSewaAsetController');
        Get.put(OrderSewaAsetController());
      } else {
        // Controller exists and has data, leave it alone during hot reload
        debugPrint(
          '🔥 Hot reload detected, preserving existing controller with data',
        );
      }
    } else {
      // No controller exists, create a new one
      debugPrint('⚡ Creating new OrderSewaAsetController (first time)');
      Get.put(OrderSewaAsetController());
    }
  }
}
