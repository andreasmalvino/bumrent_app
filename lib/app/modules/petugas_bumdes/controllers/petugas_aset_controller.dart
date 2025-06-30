import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../data/models/aset_model.dart';

class PetugasAsetController extends GetxController {
  final AsetProvider _asetProvider = Get.find<AsetProvider>();
  // Observable lists for asset data
  final asetList = <Map<String, dynamic>>[].obs;
  final filteredAsetList = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  // Tab selection (0 for Sewa, 1 for Langganan)
  final selectedTabIndex = 0.obs;

  // Sort options
  final sortBy = 'Nama (A-Z)'.obs;
  final sortOptions =
      [
        'Nama (A-Z)',
        'Nama (Z-A)',
        'Harga (Rendah-Tinggi)',
        'Harga (Tinggi-Rendah)',
      ].obs;

  @override
  void onInit() {
    super.onInit();
    // Load sample data when the controller is initialized
    loadAsetData();
  }

  // Load asset data from AsetProvider
  Future<void> loadAsetData() async {
    try {
      isLoading.value = true;
      debugPrint('PetugasAsetController: Starting to load asset data...');

      // Fetch data using AsetProvider
      final asetData = await _asetProvider.getSewaAsets();
      debugPrint(
        'PetugasAsetController: Fetched ${asetData.length} assets from Supabase',
      );

      if (asetData.isEmpty) {
        debugPrint('PetugasAsetController: No assets found in Supabase');
      }

      final List<Map<String, dynamic>> mappedAsets = [];
      int index = 0; // Initialize index counter
      for (var aset in asetData) {
        String displayKategori = 'Umum'; // Placeholder for descriptive category
        // Attempt to derive a more specific category from description if needed, or add to AsetModel
        if (aset.deskripsi.toLowerCase().contains('meja') ||
            aset.deskripsi.toLowerCase().contains('kursi')) {
          displayKategori = 'Furniture';
        } else if (aset.deskripsi.toLowerCase().contains('proyektor') ||
            aset.deskripsi.toLowerCase().contains('sound') ||
            aset.deskripsi.toLowerCase().contains('internet')) {
          displayKategori = 'Elektronik';
        } else if (aset.deskripsi.toLowerCase().contains('mobil') ||
            aset.deskripsi.toLowerCase().contains('kendaraan')) {
          displayKategori = 'Kendaraan';
        }

        final map = {
          'id': aset.id,
          'nama': aset.nama,
          'deskripsi': aset.deskripsi,
          'harga':
              aset.satuanWaktuSewa.isNotEmpty
                  ? aset.satuanWaktuSewa.first['harga']
                  : 0,
          'status': aset.status,
          'kategori': displayKategori,
          'jenis': aset.jenis ?? 'Sewa', // Add this line with default value
          'imageUrl': aset.imageUrl ?? 'https://via.placeholder.com/150',
          'satuan_waktu':
              aset.satuanWaktuSewa.isNotEmpty
                  ? aset.satuanWaktuSewa.first['nama_satuan_waktu'] ?? 'Hari'
                  : 'Hari',
          'satuanWaktuSewa': aset.satuanWaktuSewa.toList(),
        };

        debugPrint('Mapped asset #$index: $map');
        mappedAsets.add(map);
        index++;
        debugPrint('Deskripsi: ${aset.deskripsi}');
        debugPrint('Kategori (from AsetModel): ${aset.kategori}');
        debugPrint('Status: ${aset.status}');
        debugPrint('Mapped Kategori for Petugas View: ${map['kategori']}');
        debugPrint('Mapped Jenis for Petugas View: ${map['jenis']}');
        debugPrint('--------------------------------');
      }

      // Populate asetList with fetched data and apply filters
      debugPrint(
        'PetugasAsetController: Mapped ${mappedAsets.length} assets for display',
      );
      asetList.assignAll(mappedAsets); // Make data available to UI
      debugPrint(
        'PetugasAsetController: asetList now has ${asetList.length} items',
      );

      applyFilters(); // Apply initial filters
      debugPrint(
        'PetugasAsetController: Applied filters. filteredAsetList has ${filteredAsetList.length} items',
      );

      debugPrint(
        'PetugasAsetController: Data loading complete. Asset list populated and filters applied.',
      );
      debugPrint(
        'PetugasAsetController: First asset name: ${mappedAsets.isNotEmpty ? mappedAsets[0]['nama'] : 'No assets'}',
      );
    } catch (e, stackTrace) {
      debugPrint('PetugasAsetController: Error loading asset data: $e');
      debugPrint('PetugasAsetController: StackTrace: $stackTrace');
      // Optionally, show a snackbar or error message to the user
      Get.snackbar(
        'Error Memuat Data',
        'Gagal mengambil data aset dari server. Silakan coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters and sorting to asset list
  void applyFilters() {
    // Start with all assets
    var filtered = List<Map<String, dynamic>>.from(asetList);

    // Filter by tab selection (Sewa or Langganan)
    String jenisFilter = selectedTabIndex.value == 0 ? 'Sewa' : 'Langganan';
    filtered = filtered.where((aset) => aset['jenis'] == jenisFilter).toList();

    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered =
          filtered.where((aset) {
            final nama = aset['nama'].toString().toLowerCase();
            final deskripsi = aset['deskripsi'].toString().toLowerCase();
            final kategori = aset['kategori'].toString().toLowerCase();

            return nama.contains(query) ||
                deskripsi.contains(query) ||
                kategori.contains(query);
          }).toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'Nama (A-Z)':
        filtered.sort(
          (a, b) => a['nama'].toString().compareTo(b['nama'].toString()),
        );
        break;
      case 'Nama (Z-A)':
        filtered.sort(
          (a, b) => b['nama'].toString().compareTo(a['nama'].toString()),
        );
        break;
      case 'Harga (Rendah-Tinggi)':
        filtered.sort((a, b) => a['harga'].compareTo(b['harga']));
        break;
      case 'Harga (Tinggi-Rendah)':
        filtered.sort((a, b) => b['harga'].compareTo(a['harga']));
        break;
    }

    // Update filtered list
    filteredAsetList.assignAll(filtered);
  }

  // Change tab (Sewa or Langganan)
  Future<void> changeTab(int index) async {
    selectedTabIndex.value = index;
    // Reload data when changing tabs to ensure we have the correct data for the selected tab
    await loadAsetData();
    applyFilters();
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Set sort option
  void setSortBy(String option) {
    sortBy.value = option;
    applyFilters();
  }

  // Format price to Indonesian Rupiah
  String formatPrice(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Add a new asset
  void addAset(Map<String, dynamic> newAset) {
    // In a real app, this would be an API call
    // For demo, we'll just add to the list
    asetList.add(newAset);
    applyFilters();
  }

  // Update an existing asset
  void updateAset(String id, Map<String, dynamic> updatedData) {
    final index = asetList.indexWhere((aset) => aset['id'] == id);
    if (index != -1) {
      asetList[index] = updatedData;
      applyFilters();
    }
  }

  // Delete an asset
  Future<bool> deleteAset(String id) async {
    try {
      debugPrint('🗑️ Starting deletion process for asset ID: $id');

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Call the provider to delete the asset
      final success = await _asetProvider.deleteAset(id);

      // Close the loading dialog
      Get.back();

      if (success) {
        // Remove the asset from our local list
        asetList.removeWhere((aset) => aset['id'] == id);
        // Apply filters to update the UI
        applyFilters();

        // Show success message
        Get.snackbar(
          'Sukses',
          'Aset berhasil dihapus',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        // Show error message
        Get.snackbar(
          'Gagal',
          'Terjadi kesalahan saat menghapus aset',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      // Close the loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Gagal menghapus aset: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
