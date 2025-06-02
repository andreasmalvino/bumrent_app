import 'package:get/get.dart';

class PetugasAsetController extends GetxController {
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

  // Load sample asset data (would be replaced with API call in production)
  Future<void> loadAsetData() async {
    isLoading.value = true;

    try {
      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 1));

      // Sample assets data
      final sampleData = [
        {
          'id': '1',
          'nama': 'Meja Rapat',
          'kategori': 'Furniture',
          'jenis': 'Sewa', // Added jenis field
          'harga': 50000,
          'satuan': 'per hari',
          'stok': 10,
          'deskripsi':
              'Meja rapat kayu jati ukuran besar untuk acara pertemuan',
          'gambar': 'https://example.com/meja.jpg',
          'tersedia': true,
        },
        {
          'id': '2',
          'nama': 'Kursi Taman',
          'kategori': 'Furniture',
          'jenis': 'Sewa', // Added jenis field
          'harga': 10000,
          'satuan': 'per hari',
          'stok': 50,
          'deskripsi': 'Kursi taman plastik yang nyaman untuk acara outdoor',
          'gambar': 'https://example.com/kursi.jpg',
          'tersedia': true,
        },
        {
          'id': '3',
          'nama': 'Proyektor',
          'kategori': 'Elektronik',
          'jenis': 'Sewa', // Added jenis field
          'harga': 100000,
          'satuan': 'per hari',
          'stok': 5,
          'deskripsi': 'Proyektor HD dengan brightness tinggi',
          'gambar': 'https://example.com/proyektor.jpg',
          'tersedia': true,
        },
        {
          'id': '4',
          'nama': 'Sound System',
          'kategori': 'Elektronik',
          'jenis': 'Langganan', // Added jenis field
          'harga': 200000,
          'satuan': 'per bulan',
          'stok': 3,
          'deskripsi': 'Sound system lengkap dengan speaker dan mixer',
          'gambar': 'https://example.com/sound.jpg',
          'tersedia': false,
        },
        {
          'id': '5',
          'nama': 'Mobil Pick Up',
          'kategori': 'Kendaraan',
          'jenis': 'Langganan', // Added jenis field
          'harga': 250000,
          'satuan': 'per bulan',
          'stok': 2,
          'deskripsi': 'Mobil pick up untuk mengangkut barang',
          'gambar': 'https://example.com/pickup.jpg',
          'tersedia': true,
        },
        {
          'id': '6',
          'nama': 'Internet Fiber',
          'kategori': 'Elektronik',
          'jenis': 'Langganan', // Added jenis field
          'harga': 350000,
          'satuan': 'per bulan',
          'stok': 15,
          'deskripsi': 'Paket internet fiber 100Mbps untuk kantor',
          'gambar': 'https://example.com/internet.jpg',
          'tersedia': true,
        },
      ];

      asetList.assignAll(sampleData);
      applyFilters(); // Apply default filters
    } catch (e) {
      print('Error loading asset data: $e');
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
  void changeTab(int index) {
    selectedTabIndex.value = index;
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
  void deleteAset(String id) {
    asetList.removeWhere((aset) => aset['id'] == id);
    applyFilters();
  }
}
