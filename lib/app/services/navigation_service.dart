import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

/// Service untuk menangani navigasi dalam aplikasi
/// Memisahkan logika navigasi dari controller
class NavigationService extends GetxService {
  static NavigationService get to => Get.find<NavigationService>();

  // Track the current navbar index for warga pages
  final currentNavIndex = 0.obs;

  /// Inisialisasi service
  Future<NavigationService> init() async {
    debugPrint('🧭 NavigationService initialized');
    return this;
  }

  /// Set current navbar index
  void setNavIndex(int index) {
    currentNavIndex.value = index;
  }

  /// Navigasi ke halaman Sewa Aset
  void toSewaAset() {
    debugPrint('🧭 Navigating to SewaAset');
    setNavIndex(0); // Set appropriate index
    Get.toNamed(Routes.SEWA_ASET, preventDuplicates: false);
  }

  /// Navigasi ke halaman Detail Sewa Aset dengan ID
  Future<void> toOrderSewaAset(String asetId) async {
    debugPrint('🧭 Navigating to OrderSewaAset with ID: $asetId');
    if (asetId.isEmpty) {
      Get.snackbar(
        'Error',
        'ID aset tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navigasi dengan arguments
    Get.toNamed(
      Routes.ORDER_SEWA_ASET,
      arguments: {'asetId': asetId},
      preventDuplicates: false,
    );
  }

  /// Navigasi ke halaman Order Sewa Paket dengan ID
  Future<void> toOrderSewaPaket(String paketId) async {
    debugPrint('🧭 Navigating to OrderSewaPaket with ID: $paketId');
    if (paketId.isEmpty) {
      Get.snackbar(
        'Error',
        'ID paket tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navigasi dengan arguments
    Get.toNamed(
      Routes.ORDER_SEWA_PAKET,
      arguments: {'paketId': paketId},
      preventDuplicates: false,
    );
  }

  /// Navigasi kembali dari OrderSewaAset ke SewaAset
  void backFromOrderSewaAset() {
    debugPrint('🧭 Navigating back from OrderSewaAset to SewaAset');
    Get.back();
  }

  /// Navigasi kembali dari SewaAset ke dashboard warga
  void backFromSewaAset() {
    debugPrint('🧭 Navigating back from SewaAset to WargaDashboard');
    setNavIndex(0); // Home tab
    Get.offNamed(Routes.WARGA_DASHBOARD);
  }

  /// Navigasi ke Warga Sewa (tab sewa)
  void toWargaSewa() {
    debugPrint('🧭 Navigating to WargaSewa');
    setNavIndex(1); // Sewa tab
    Get.offNamed(Routes.WARGA_SEWA);
  }

  /// Navigasi ke Warga Langganan (tab langganan)
  void toWargaLangganan() {
    debugPrint('🧭 Navigating to WargaLangganan');
    setNavIndex(2); // Langganan tab
    Get.offNamed(Routes.LANGGANAN);
  }

  /// Navigasi ke Profile (tab profil)
  void toProfile() {
    debugPrint('🧭 Navigating to Profile');
    setNavIndex(2); // Profile tab
    Get.offNamed(Routes.PROFILE);
  }

  /// Navigasi ke dashboard sesuai role
  void toDashboard(String role) {
    debugPrint('🧭 Navigating to dashboard for role: $role');
    switch (role.toLowerCase()) {
      case 'warga':
        setNavIndex(0); // Reset to home tab
        Get.offAllNamed(Routes.WARGA_DASHBOARD);
        break;
      case 'petugas_bumdes':
        Get.offAllNamed(Routes.PETUGAS_BUMDES_DASHBOARD);
        break;
      default:
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  /// Navigasi ke login
  void toLogin() {
    debugPrint('🧭 Navigating to login');
    Get.offAllNamed(Routes.LOGIN);
  }

  /// Navigasi mundur satu langkah
  void back() {
    debugPrint('🧭 Going back');
    Get.back();
  }
}
