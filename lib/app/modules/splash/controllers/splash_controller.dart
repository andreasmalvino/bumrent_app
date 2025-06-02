import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    debugPrint('SplashController onInit called');

    // Menggunakan Timer alih-alih Future.delayed
    _timer = Timer(const Duration(seconds: 3), () {
      debugPrint('Timer completed, navigating to LOGIN');
      // Gunakan Get.offAll untuk menghapus semua rute sebelumnya
      Get.offAllNamed(Routes.LOGIN);
    });
  }

  @override
  void onClose() {
    // Pastikan timer dibatalkan saat controller ditutup
    _timer.cancel();
    super.onClose();
  }
}
