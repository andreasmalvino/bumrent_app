import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bumrent_app/app/data/providers/auth_provider.dart';
import 'package:bumrent_app/app/data/providers/aset_provider.dart';
import 'package:bumrent_app/app/data/providers/pesanan_provider.dart';
import 'package:bumrent_app/app/routes/app_routes.dart';
import '../../../services/sewa_service.dart';
import '../../../services/service_manager.dart';
import '../../../data/models/pembayaran_model.dart';
import '../../../services/pembayaran_service.dart';

class PetugasBumdesDashboardController extends GetxController {
  AuthProvider? _authProvider;

  // Reactive variables
  final userEmail = ''.obs;
  final currentTabIndex = 0.obs;
  final avatarUrl = ''.obs;
  final userName = ''.obs;

  // Revenue Statistics
  final totalPendapatanBulanIni = ''.obs;
  final totalPendapatanBulanLalu = ''.obs;
  final persentaseKenaikan = ''.obs;
  final isKenaikanPositif = true.obs;

  // Revenue by Category
  final pendapatanSewa = ''.obs;
  final persentaseSewa = 0.obs;

  // Revenue Trends (last 6 months)
  final trendPendapatan = <double>[].obs; // 6 bulan terakhir

  // Status Counters for Sewa Aset
  final terlaksanaCount = 0.obs;
  final dijadwalkanCount = 0.obs;
  final aktifCount = 0.obs;
  final dibatalkanCount = 0.obs;

  // Additional Sewa Aset Status Counters
  final menungguPembayaranCount = 0.obs;
  final periksaPembayaranCount = 0.obs;
  final diterimaCount = 0.obs;
  final pembayaranDendaCount = 0.obs;
  final periksaPembayaranDendaCount = 0.obs;
  final selesaiCount = 0.obs;

  // Status counts for Sewa
  final pengajuanSewaCount = 0.obs;
  final pemasanganCountSewa = 0.obs;
  final sewaAktifCount = 0.obs;
  final tagihanAktifCountSewa = 0.obs;
  final periksaPembayaranCountSewa = 0.obs;

  // Tenant (Penyewa) Statistics
  final penyewaPendingCount = 0.obs;
  final penyewaActiveCount = 0.obs;
  final penyewaSuspendedCount = 0.obs;
  final penyewaTotalCount = 0.obs;
  final isPenyewaStatsLoading = true.obs;

  // Statistik pendapatan
  final totalPendapatan = 0.obs;
  final pendapatanBulanIni = 0.obs;
  final pendapatanBulanLalu = 0.obs;
  final pendapatanTunai = 0.obs;
  final pendapatanTransfer = 0.obs;
  final trenPendapatan = <int>[].obs; // 6 bulan terakhir

  // Dashboard statistics
  final pembayaranStats = <String, dynamic>{}.obs;
  final isStatsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _authProvider = Get.find<AuthProvider>();
      userEmail.value = _authProvider?.currentUser?.email ?? 'Tidak ada email';
      fetchPetugasAvatar();
      fetchPetugasName();
    } catch (e) {
      print('Error finding AuthProvider: $e');
      userEmail.value = 'Tidak ada email';
    }
    print('\u2705 PetugasBumdesDashboardController initialized successfully');
    countSewaByStatus();
    fetchPembayaranStats();
    fetchPenyewaStats();
  }

  Future<void> countSewaByStatus() async {
    try {
      final data = await SewaService().fetchAllSewa();
      menungguPembayaranCount.value =
          data.where((s) => s.status == 'MENUNGGU PEMBAYARAN').length;
      periksaPembayaranCount.value =
          data.where((s) => s.status == 'PERIKSA PEMBAYARAN').length;
      diterimaCount.value = data.where((s) => s.status == 'DITERIMA').length;
      pembayaranDendaCount.value =
          data.where((s) => s.status == 'PEMBAYARAN DENDA').length;
      periksaPembayaranDendaCount.value =
          data.where((s) => s.status == 'PERIKSA PEMBAYARAN DENDA').length;
      selesaiCount.value = data.where((s) => s.status == 'SELESAI').length;
      print(
        'Count for MENUNGGU PEMBAYARAN: \\${menungguPembayaranCount.value}',
      );
      print('Count for PERIKSA PEMBAYARAN: \\${periksaPembayaranCount.value}');
      print('Count for DITERIMA: \\${diterimaCount.value}');
      print('Count for PEMBAYARAN DENDA: \\${pembayaranDendaCount.value}');
      print(
        'Count for PERIKSA PEMBAYARAN DENDA: \\${periksaPembayaranDendaCount.value}',
      );
      print('Count for SELESAI: \\${selesaiCount.value}');
    } catch (e) {
      print('Error counting sewa by status: $e');
    }
  }

  Future<void> fetchPembayaranStats() async {
    isStatsLoading.value = true;
    try {
      final stats = await PembayaranService().fetchStats();
      pembayaranStats.value = stats;
      // Set trendPendapatan from stats['trendPerMonth'] if available
      if (stats['trendPerMonth'] != null) {
        trendPendapatan.value = List<double>.from(stats['trendPerMonth']);
      }
      print('Pembayaran stats: $stats');
    } catch (e, st) {
      print('Error fetching pembayaran stats: $e\n$st');
      pembayaranStats.value = {};
      trendPendapatan.value = [];
    }
    isStatsLoading.value = false;
  }

  Future<void> fetchPetugasAvatar() async {
    try {
      final userId = _authProvider?.getCurrentUserId();
      if (userId == null) return;
      final client = _authProvider!.client;
      final data =
          await client
              .from('petugas_bumdes')
              .select('avatar')
              .eq('id', userId)
              .maybeSingle();
      if (data != null &&
          data['avatar'] != null &&
          data['avatar'].toString().isNotEmpty) {
        avatarUrl.value = data['avatar'].toString();
      } else {
        avatarUrl.value = '';
      }
    } catch (e) {
      print('Error fetching petugas avatar: $e');
      avatarUrl.value = '';
    }
  }

  Future<void> fetchPetugasName() async {
    try {
      final userId = _authProvider?.getCurrentUserId();
      if (userId == null) return;
      final client = _authProvider!.client;
      final data =
          await client
              .from('petugas_bumdes')
              .select('nama')
              .eq('id', userId)
              .maybeSingle();
      if (data != null &&
          data['nama'] != null &&
          data['nama'].toString().isNotEmpty) {
        userName.value = data['nama'].toString();
      } else {
        userName.value = '';
      }
    } catch (e) {
      print('Error fetching petugas name: $e');
      userName.value = '';
    }
  }

  Future<void> fetchPenyewaStats() async {
    isPenyewaStatsLoading.value = true;
    try {
      if (_authProvider == null || _authProvider!.client == null) {
        print('Auth provider or client is null');
        return;
      }

      final data = await _authProvider!.client
          .from('warga_desa')
          .select('status, user_id')
          .not('user_id', 'is', null);

      if (data != null) {
        final List<dynamic> penyewaList = data as List<dynamic>;

        // Count penyewa by status
        penyewaPendingCount.value =
            penyewaList
                .where(
                  (p) => p['status']?.toString().toLowerCase() == 'pending',
                )
                .length;

        penyewaActiveCount.value =
            penyewaList
                .where((p) => p['status']?.toString().toLowerCase() == 'active')
                .length;

        penyewaSuspendedCount.value =
            penyewaList
                .where(
                  (p) => p['status']?.toString().toLowerCase() == 'suspended',
                )
                .length;

        penyewaTotalCount.value = penyewaList.length;

        print(
          'Penyewa stats - Pending: ${penyewaPendingCount.value}, Active: ${penyewaActiveCount.value}, Suspended: ${penyewaSuspendedCount.value}, Total: ${penyewaTotalCount.value}',
        );
      }
    } catch (e) {
      print('Error fetching penyewa stats: $e');
    } finally {
      isPenyewaStatsLoading.value = false;
    }
  }

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
        case 4:
          // Navigate to Penyewa page
          navigateToPenyewa();
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

  void navigateToPenyewa() {
    try {
      Get.offAllNamed(Routes.PETUGAS_PENYEWA);
    } catch (e) {
      print('Error navigating to Penyewa: $e');
    }
  }

  void logout() async {
    try {
      // Store login route for navigation
      final loginRoute = Routes.LOGIN;

      // Sign out from Supabase
      if (_authProvider != null) {
        await _authProvider!.signOut();
      }

      // Navigate to login screen while context is still valid
      Get.offAllNamed(loginRoute);

      // Clear auth provider data if available
      if (_authProvider != null) {
        _authProvider!.clearAuthData();
      }

      // Clear provider caches
      _clearProviderCaches();

      // Clean up GetX controllers but keep navigation intact
      Get.deleteAll(force: false);
    } catch (e) {
      print('Error during logout: $e');
      // Still try to navigate to login even if sign out fails
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // Helper method to clear provider caches that need explicit clearing
  void _clearProviderCaches() {
    try {
      // Clear AsetProvider cache
      if (Get.isRegistered<AsetProvider>()) {
        final asetProvider = Get.find<AsetProvider>();
        asetProvider.clearCache();
      }
    } catch (e) {
      print('Error clearing AsetProvider: $e');
    }

    try {
      // Clear PesananProvider cache
      if (Get.isRegistered<PesananProvider>()) {
        final pesananProvider = Get.find<PesananProvider>();
        pesananProvider.clearCache();
      }
    } catch (e) {
      print('Error clearing PesananProvider: $e');
    }

    // Add other providers here that need explicit cache clearing
  }
}
