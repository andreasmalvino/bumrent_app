import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class PetugasBumdesDashboardController extends GetxController {
  AuthProvider? _authProvider;

  // Reactive variables
  final userEmail = ''.obs;
  final currentTabIndex = 0.obs;

  // Revenue Statistics
  final totalPendapatanBulanIni = 'Rp 8.500.000'.obs;
  final totalPendapatanBulanLalu = 'Rp 7.200.000'.obs;
  final persentaseKenaikan = '18%'.obs;
  final isKenaikanPositif = true.obs;

  // Revenue by Category
  final pendapatanSewa = 'Rp 5.200.000'.obs;
  final persentaseSewa = 100.obs;

  // Revenue Trends (last 6 months)
  final trendPendapatan = [4.2, 5.1, 4.8, 6.2, 7.2, 8.5].obs; // in millions

  // Status Counters for Sewa Aset
  final terlaksanaCount = 5.obs;
  final dijadwalkanCount = 1.obs;
  final aktifCount = 1.obs;
  final dibatalkanCount = 3.obs;

  // Additional Sewa Aset Status Counters
  final menungguPembayaranCount = 2.obs;
  final periksaPembayaranCount = 1.obs;
  final diterimaCount = 3.obs;
  final pembayaranDendaCount = 1.obs;
  final periksaPembayaranDendaCount = 0.obs;
  final selesaiCount = 4.obs;

  // Status counts for Sewa
  final pengajuanSewaCount = 5.obs;
  final pemasanganCountSewa = 3.obs;
  final sewaAktifCount = 10.obs;
  final tagihanAktifCountSewa = 7.obs;
  final periksaPembayaranCountSewa = 2.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _authProvider = Get.find<AuthProvider>();
      userEmail.value = _authProvider?.currentUser?.email ?? 'Tidak ada email';
    } catch (e) {
      print('Error finding AuthProvider: $e');
      userEmail.value = 'Tidak ada email';
    }

    // In a real app, these counts would be fetched from backend
    // loadStatusCounts();
    print('✅ PetugasBumdesDashboardController initialized successfully');
  }

  // Method to load status counts from backend
  // Future<void> loadStatusCounts() async {
  //   try {
  //     final response = await _asetProvider.getSewaStatusCounts();
  //     if (response != null) {
  //       terlaksanaCount.value = response['terlaksana'] ?? 0;
  //       dijadwalkanCount.value = response['dijadwalkan'] ?? 0;
  //       aktifCount.value = response['aktif'] ?? 0;
  //       dibatalkanCount.value = response['dibatalkan'] ?? 0;
  //       menungguPembayaranCount.value = response['menunggu_pembayaran'] ?? 0;
  //       periksaPembayaranCount.value = response['periksa_pembayaran'] ?? 0;
  //       diterimaCount.value = response['diterima'] ?? 0;
  //       pembayaranDendaCount.value = response['pembayaran_denda'] ?? 0;
  //       periksaPembayaranDendaCount.value = response['periksa_pembayaran_denda'] ?? 0;
  //       selesaiCount.value = response['selesai'] ?? 0;
  //     }
  //   } catch (e) {
  //     print('Error loading status counts: $e');
  //   }
  // }

  void changeTab(int index) {
    try {
      currentTabIndex.value = index;

      // Navigate to the appropriate page based on the tab index
      switch (index) {
        case 0:
          // Navigate to Dashboard
          Get.offAllNamed(Routes.PETUGAS_BUMDES_DASHBOARD);
          break;
        case 1:
          // Navigate to Aset page
          navigateToAset();
          break;
        case 2:
          // Navigate to Paket page
          navigateToPaket();
          break;
        case 3:
          // Navigate to Sewa page
          navigateToSewa();
          break;
      }
    } catch (e) {
      print('Error changing tab: $e');
    }
  }

  void navigateToAset() {
    try {
      Get.offAllNamed(Routes.PETUGAS_ASET);
    } catch (e) {
      print('Error navigating to Aset: $e');
    }
  }

  void navigateToPaket() {
    try {
      Get.offAllNamed(Routes.PETUGAS_PAKET);
    } catch (e) {
      print('Error navigating to Paket: $e');
    }
  }

  void navigateToSewa() {
    try {
      Get.offAllNamed(Routes.PETUGAS_SEWA);
    } catch (e) {
      print('Error navigating to Sewa: $e');
    }
  }

  void logout() async {
    try {
      if (_authProvider != null) {
        await _authProvider!.signOut();
      }
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('Error during logout: $e');
      // Still try to navigate to login even if sign out fails
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
