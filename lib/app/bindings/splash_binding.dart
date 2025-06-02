import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/providers/auth_provider.dart';
import '../modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('Initializing SplashBinding dependencies');

    // Pastikan AuthProvider dibuat sekali dan bersifat permanen
    if (!Get.isRegistered<AuthProvider>()) {
      debugPrint('Registering AuthProvider in SplashBinding');
      Get.put<AuthProvider>(AuthProvider(), permanent: true);
    } else {
      debugPrint('AuthProvider already registered');
    }

    // Buat SplashController
    debugPrint('Creating SplashController');
    Get.put<SplashController>(SplashController());

    debugPrint('SplashBinding dependencies initialized');
  }
}
