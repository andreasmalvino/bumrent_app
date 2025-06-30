import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:logger/logger.dart';
import 'package:bumrent_app/app/data/models/paket_model.dart';
import 'package:bumrent_app/app/data/providers/aset_provider.dart';

class PetugasPaketController extends GetxController {
  // Dependencies
  final AsetProvider _asetProvider = Get.find<AsetProvider>();

  // State
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Semua'.obs;
  final RxString sortBy = 'Terbaru'.obs;
  final RxList<PaketModel> packages = <PaketModel>[].obs;
  final RxList<PaketModel> filteredPackages = <PaketModel>[].obs;

  // Sort options for the dropdown
  final List<String> sortOptions = [
    'Terbaru',
    'Terlama',
    'Harga Tertinggi',
    'Harga Terendah',
    'Nama A-Z',
    'Nama Z-A',
  ];

  // For backward compatibility
  final RxList<Map<String, dynamic>> paketList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredPaketList =
      <Map<String, dynamic>>[].obs;

  // Logger
  late final Logger _logger;

  @override
  void onInit() {
    super.onInit();

    // Initialize logger
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        colors: true,
        printEmojis: true,
      ),
    );

    // Load initial data
    fetchPackages();
  }

  /// Fetch packages from the API
  Future<void> fetchPackages() async {
    try {
      isLoading.value = true;
      _logger.i('🔄 [fetchPackages] Fetching packages...');

      final result = await _asetProvider.getAllPaket();

      if (result.isEmpty) {
        _logger.w('ℹ️ [fetchPackages] No packages found');
        packages.clear();
        filteredPackages.clear();
        return;
      }

      packages.assignAll(result);
      filteredPackages.assignAll(result);

      // Update legacy list for backward compatibility
      _updateLegacyPaketList();

      _logger.i(
        '✅ [fetchPackages] Successfully loaded ${result.length} packages',
      );
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [fetchPackages] Error fetching packages',
        error: e,
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Error',
        'Gagal memuat data paket. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update legacy paketList for backward compatibility
  void _updateLegacyPaketList() {
    try {
      _logger.d('🔄 [_updateLegacyPaketList] Updating legacy paketList...');

      final List<Map<String, dynamic>> legacyList =
          packages.map((pkg) {
            return {
              'id': pkg.id,
              'nama': pkg.nama,
              'deskripsi': pkg.deskripsi,
              'harga': pkg.harga,
              'kuantitas': pkg.kuantitas,
              'status': pkg.status, // Add status to legacy mapping
              'foto': pkg.foto,
              'foto_paket': pkg.foto_paket,
              'images': pkg.images,
              'satuanWaktuSewa': pkg.satuanWaktuSewa,
              'created_at': pkg.createdAt,
              'updated_at': pkg.updatedAt,
            };
          }).toList();

      paketList.assignAll(legacyList);
      filteredPaketList.assignAll(legacyList);

      _logger.d(
        '✅ [_updateLegacyPaketList] Updated ${legacyList.length} packages',
      );
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [_updateLegacyPaketList] Error updating legacy list',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// For backward compatibility
  Future<void> loadPaketData() async {
    _logger.d('ℹ️ [loadPaketData] Using fetchPackages() instead');
    await fetchPackages();
  }

  /// Filter packages based on search query and category
  void filterPaket() {
    try {
      _logger.d('🔄 [filterPaket] Filtering packages...');

      if (searchQuery.value.isEmpty && selectedCategory.value == 'Semua') {
        filteredPackages.value = List.from(packages);
        filteredPaketList.value = List.from(paketList);
      } else {
        // Filter new packages
        filteredPackages.value =
            packages.where((paket) {
              final matchesSearch =
                  searchQuery.value.isEmpty ||
                  paket.nama.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  );

              // For now, we're not using categories in the new model
              // You can add category filtering if needed
              final matchesCategory = selectedCategory.value == 'Semua';

              return matchesSearch && matchesCategory;
            }).toList();

        // Also update legacy list for backward compatibility
        filteredPaketList.value =
            paketList.where((paket) {
              final matchesSearch =
                  searchQuery.value.isEmpty ||
                  (paket['nama']?.toString() ?? '').toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  );

              // For legacy support, check if category exists
              final matchesCategory =
                  selectedCategory.value == 'Semua' ||
                  (paket['kategori']?.toString() ?? '') ==
                      selectedCategory.value;

              return matchesSearch && matchesCategory;
            }).toList();
      }

      sortFilteredList();
      _logger.d(
        '✅ [filterPaket] Filtered to ${filteredPackages.length} packages',
      );
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [filterPaket] Error filtering packages',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sort the filtered list based on the selected sort option
  void sortFilteredList() {
    try {
      _logger.d('🔄 [sortFilteredList] Sorting packages by ${sortBy.value}');

      // Sort new packages
      switch (sortBy.value) {
        case 'Terbaru':
          filteredPackages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'Terlama':
          filteredPackages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'Harga Tertinggi':
          filteredPackages.sort((a, b) => b.harga.compareTo(a.harga));
          break;
        case 'Harga Terendah':
          filteredPackages.sort((a, b) => a.harga.compareTo(b.harga));
          break;
        case 'Nama A-Z':
          filteredPackages.sort((a, b) => a.nama.compareTo(b.nama));
          break;
        case 'Nama Z-A':
          filteredPackages.sort((a, b) => b.nama.compareTo(a.nama));
          break;
      }

      // Also sort legacy list for backward compatibility
      switch (sortBy.value) {
        case 'Terbaru':
          filteredPaketList.sort(
            (a, b) => ((b['created_at'] ?? '') as String).compareTo(
              (a['created_at'] ?? '') as String,
            ),
          );
          break;
        case 'Terlama':
          filteredPaketList.sort(
            (a, b) => ((a['created_at'] ?? '') as String).compareTo(
              (b['created_at'] ?? '') as String,
            ),
          );
          break;
        case 'Harga Tertinggi':
          filteredPaketList.sort(
            (a, b) =>
                ((b['harga'] ?? 0) as int).compareTo((a['harga'] ?? 0) as int),
          );
          break;
        case 'Harga Terendah':
          filteredPaketList.sort(
            (a, b) =>
                ((a['harga'] ?? 0) as int).compareTo((b['harga'] ?? 0) as int),
          );
          break;
        case 'Nama A-Z':
          filteredPaketList.sort(
            (a, b) => ((a['nama'] ?? '') as String).compareTo(
              (b['nama'] ?? '') as String,
            ),
          );
          break;
        case 'Nama Z-A':
          filteredPaketList.sort(
            (a, b) => ((b['nama'] ?? '') as String).compareTo(
              (a['nama'] ?? '') as String,
            ),
          );
          break;
      }

      _logger.d(
        '✅ [sortFilteredList] Sorted ${filteredPackages.length} packages',
      );
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [sortFilteredList] Error sorting packages',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Set search query dan filter paket
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterPaket();
  }

  // Set kategori dan filter paket
  void setCategory(String category) {
    selectedCategory.value = category;
    filterPaket();
  }

  // Set opsi pengurutan dan filter paket
  void setSortBy(String option) {
    sortBy.value = option;
    sortFilteredList();
  }

  // Tambah paket baru
  Future<void> addPaket(Map<String, dynamic> paketData) async {
    try {
      isLoading.value = true;

      // Convert to PaketModel
      final newPaket = PaketModel.fromJson({
        ...paketData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Add to the list
      packages.add(newPaket);
      _updateLegacyPaketList();
      filterPaket();

      Get.back();
      Get.snackbar(
        'Sukses',
        'Paket baru berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [addPaket] Error adding package',
        error: e,
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Error',
        'Gagal menambahkan paket. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Edit paket
  Future<void> editPaket(String id, Map<String, dynamic> updatedData) async {
    try {
      isLoading.value = true;

      final index = packages.indexWhere((pkg) => pkg.id == id);
      if (index >= 0) {
        // Update the package
        final updatedPaket = packages[index].copyWith(
          nama: updatedData['nama']?.toString() ?? packages[index].nama,
          deskripsi:
              updatedData['deskripsi']?.toString() ?? packages[index].deskripsi,
          kuantitas:
              (updatedData['kuantitas'] is int)
                  ? updatedData['kuantitas']
                  : (int.tryParse(
                        updatedData['kuantitas']?.toString() ?? '0',
                      ) ??
                      packages[index].kuantitas),
          updatedAt: DateTime.now(),
        );

        packages[index] = updatedPaket;
        _updateLegacyPaketList();
        filterPaket();

        Get.back();
        Get.snackbar(
          'Sukses',
          'Paket berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [editPaket] Error updating package',
        error: e,
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Error',
        'Gagal memperbarui paket. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Hapus paket
  Future<void> deletePaket(String id) async {
    try {
      _logger.i(
        '🔄 [deletePaket] Starting deletion process for package ID: $id',
      );

      // Show a loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Call the provider to delete the package and all related data from Supabase
      final success = await _asetProvider.deletePaket(id);

      // Close the loading dialog
      Get.back();

      if (success) {
        _logger.i('✅ [deletePaket] Package deleted successfully from database');

        // Remove the package from the UI lists
        packages.removeWhere((pkg) => pkg.id == id);
        _updateLegacyPaketList();
        filterPaket();

        // Show success message
        Get.snackbar(
          'Sukses',
          'Paket berhasil dihapus dari sistem',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        _logger.e('❌ [deletePaket] Failed to delete package from database');

        // Show error message
        Get.snackbar(
          'Gagal',
          'Terjadi kesalahan saat menghapus paket',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [deletePaket] Error deleting package',
        error: e,
        stackTrace: stackTrace,
      );

      // Close the loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Gagal menghapus paket: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Format price to Rupiah currency
  String formatPrice(num price) {
    return 'Rp ${NumberFormat('#,##0', 'id_ID').format(price)}';
  }
}
