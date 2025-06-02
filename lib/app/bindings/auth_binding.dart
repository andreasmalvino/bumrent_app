import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/providers/auth_provider.dart';
import '../modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('Initializing AuthBinding dependencies');

    // Pastikan AuthProvider dibuat sekali dan bersifat permanen
    if (!Get.isRegistered<AuthProvider>()) {
      debugPrint('Registering AuthProvider in AuthBinding');
      Get.put<AuthProvider>(AuthProvider(), permanent: true);
    } else {
      debugPrint('AuthProvider already registered');
    }

    // Buat AuthController
    debugPrint('Creating AuthController');
    Get.lazyPut<AuthController>(() => AuthController());

    debugPrint('AuthBinding dependencies initialized');
  }
}
