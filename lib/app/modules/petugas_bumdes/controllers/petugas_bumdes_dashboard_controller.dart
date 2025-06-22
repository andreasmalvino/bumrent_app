import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
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
  final totalPendapatanBulanIni = 'Rp 8.500.000'.obs;
  final totalPendapatanBulanLalu = 'Rp 7.200.000'.obs;
  final persentaseKenaikan = '18%'.obs;
  final isKenaikanPositif = true.obs;

  // Revenue by Category
  final pendapatanSewa = 'Rp 5.200.000'.obs;
  final persentaseSewa = 100.obs;

  // Revenue Trends (last 6 months)
  final trendPendapatan = <double>[].obs; // 6 bulan terakhir

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
