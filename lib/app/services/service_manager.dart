import 'package:get/get.dart';
import 'navigation_service.dart';
import '../data/providers/auth_provider.dart';
import '../modules/warga/controllers/warga_dashboard_controller.dart';

/// Abstract class untuk mengelola lifecycle service dan dependency
abstract class ServiceManager {
  /// Getter untuk akses NavigationService
  static NavigationService get navigationService {
    if (!Get.isRegistered<NavigationService>()) {
      Get.put(NavigationService());
    }
    return Get.find<NavigationService>();
  }

  /// Mendaftarkan semua service yang dibutuhkan aplikasi
  /// Sebaiknya dipanggil di awal aplikasi (main.dart)
  static void registerServices() {
    // Register service yang bersifat global dan permanent
    if (!Get.isRegistered<NavigationService>()) {
      Get.put(NavigationService());
    }

    // Register AuthProvider if not already registered
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider(), permanent: true);
    }

    // Register WargaDashboardController as a permanent controller
    // This ensures it's always available for the drawer
    registerWargaDashboardController();
  }

  /// Register WargaDashboardController as a singleton
  static void registerWargaDashboardController() {
    // Make sure Auth Provider is registered first
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider(), permanent: true);
    }

    // Register WargaDashboardController if not already registered
    if (!Get.isRegistered<WargaDashboardController>()) {
      Get.put(WargaDashboardController(), permanent: true);
    }
  }

  /// Mendaftarkan controller untuk suatu page
  /// Sebaiknya dipanggil di method dependencies() dalam Binding class
  static void registerController<T>(T controller, {bool permanent = false}) {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
    Get.put<T>(controller, permanent: permanent);
  }

  /// Membersihkan controller ketika tidak digunakan
  /// Sebaiknya dipanggil dalam method onClose() di controller
  static void cleanupController<T>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }

  /// Memeriksa apakah sebuah controller sudah terdaftar
  static bool isControllerRegistered<T>() {
    return Get.isRegistered<T>();
  }
}
