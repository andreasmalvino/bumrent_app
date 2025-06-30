import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';

class PetugasPenyewaController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  // Reactive variables
  final isLoading = true.obs;
  final penyewaList = <Map<String, dynamic>>[].obs;
  final filteredPenyewaList = <Map<String, dynamic>>[].obs;
  final filterStatus = 'all'.obs;
  final currentTabIndex = 0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPenyewaList();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when the page is first loaded
    refreshData();
  }

  // Method to refresh data when returning to the page
  void refreshData() {
    fetchPenyewaList();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    if (penyewaList.isEmpty) return;

    // First apply status filter based on current tab
    String statusFilter;
    switch (currentTabIndex.value) {
      case 0: // Verifikasi
        statusFilter = 'pending';
        break;
      case 1: // Aktif
        statusFilter = 'active';
        break;
      case 2: // Ditangguhkan
        statusFilter = 'suspended';
        break;
      default:
        statusFilter = 'all';
    }

    // Filter by status
    var result =
        statusFilter == 'all'
            ? penyewaList
            : penyewaList
                .where((p) => p['status']?.toLowerCase() == statusFilter)
                .toList();

    // Then apply search filter if there's a query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result =
          result
              .where(
                (p) =>
                    (p['nama_lengkap']?.toString().toLowerCase().contains(
                          query,
                        ) ??
                        false) ||
                    (p['email']?.toString().toLowerCase().contains(query) ??
                        false),
              )
              .toList();
    }

    filteredPenyewaList.value = result;
  }

  Future<void> fetchPenyewaList() async {
    try {
      isLoading.value = true;

      // Get all penyewa data without filtering
      final data =
          await _authProvider.client
                  .from('warga_desa')
                  .select(
                    'user_id, nama_lengkap, email, nik, no_hp, avatar, status, keterangan',
                  )
              as List<dynamic>;

      // Filter out rows where user_id is null
      final filteredData = data.where((row) => row['user_id'] != null).toList();

      // Get total sewa count for each user
      final enrichedData = await _enrichWithSewaCount(filteredData);

      penyewaList.value = enrichedData;

      // Apply filters to update filteredPenyewaList
      applyFilters();
    } catch (e) {
      print('Error fetching penyewa list: $e');
      penyewaList.value = [];
      filteredPenyewaList.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _enrichWithSewaCount(
    List<dynamic> penyewaData,
  ) async {
    final result = <Map<String, dynamic>>[];

    for (var penyewa in penyewaData) {
      final userId = penyewa['user_id'];

      // Count total sewa for this user
      final sewaCount = await _countUserSewa(userId);

      // Create a new map with all the original data plus the total_sewa count
      final enrichedPenyewa = Map<String, dynamic>.from(penyewa);
      enrichedPenyewa['total_sewa'] = sewaCount;

      result.add(enrichedPenyewa);
    }

    return result;
  }

  Future<int> _countUserSewa(String userId) async {
    try {
      final response = await _authProvider.client
          .from('sewa_aset')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('Error counting sewa for user $userId: $e');
      return 0;
    }
  }

  void viewPenyewaDetail(String userId) {
    // Navigate to penyewa detail page (to be implemented)
    print('View detail for penyewa with ID: $userId');

    // Get.toNamed(Routes.PETUGAS_PENYEWA_DETAIL, arguments: {'user_id': userId});
  }

  void updatePenyewaStatus(
    String userId,
    String newStatus,
    String keterangan,
  ) async {
    try {
      isLoading.value = true;

      await _authProvider.client
          .from('warga_desa')
          .update({'status': newStatus, 'keterangan': keterangan})
          .eq('user_id', userId);

      // Refresh the list
      await fetchPenyewaList();

      Get.snackbar(
        'Berhasil',
        'Status penyewa berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error updating penyewa status: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat memperbarui status penyewa',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
