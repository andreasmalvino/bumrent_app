import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class PetugasMitraDashboardController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  // Observable user data
  final userEmail = ''.obs;
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserEmail();
  }

  // Load user email from auth provider
  Future<void> _loadUserEmail() async {
    try {
      final user = _authProvider.currentUser;
      userEmail.value = user?.email ?? 'User';
    } catch (e) {
      debugPrint('Error loading user email: $e');
    }
  }

  // Change tab index
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Logout function
  void logout() async {
    try {
      await _authProvider.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint('Error signing out: $e');
      Get.snackbar(
        'Error',
        'Gagal keluar dari aplikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
