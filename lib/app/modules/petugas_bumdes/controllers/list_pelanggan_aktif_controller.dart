import 'package:get/get.dart';

class ListPelangganAktifController extends GetxController {
  // Reactive variables
  final isLoading = true.obs;
  final pelangganList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final serviceName = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get the service name passed from previous page
    if (Get.arguments != null && Get.arguments['serviceName'] != null) {
      serviceName.value = Get.arguments['serviceName'];
    }

    // Load the pelanggan data
    loadPelangganData();
  }

  // Load sample pelanggan data (would be replaced with API call in production)
  Future<void> loadPelangganData() async {
    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // For now, we only have Malih as an active subscriber
      final sampleData = [
        {
          'id': '1',
          'nama': 'Malih',
          'alamat': 'Jl. Desa Sejahtera No. 15, RT 03/RW 02',
          'status': 'Aktif',
          'tanggal_mulai': '01/05/2023',
          'tanggal_berakhir': '01/05/2024',
          'pembayaran_terakhir': '01/04/2024',
          'tagihan': 'Rp 20.000',
          'telepon': '081234567890',
          'email': 'malih@example.com',
          'catatan': 'Pelanggan setia sejak 2023',
        },
      ];

      pelangganList.assignAll(sampleData);
    } catch (e) {
      print('Error loading pelanggan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter the list based on search query
  List<Map<String, dynamic>> get filteredPelangganList {
    if (searchQuery.value.isEmpty) {
      return pelangganList;
    }

    final query = searchQuery.value.toLowerCase();
    return pelangganList.where((pelanggan) {
      final nama = pelanggan['nama'].toString().toLowerCase();
      final alamat = pelanggan['alamat'].toString().toLowerCase();
      final status = pelanggan['status'].toString().toLowerCase();

      return nama.contains(query) ||
          alamat.contains(query) ||
          status.contains(query);
    }).toList();
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Get status color based on status value
  getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return 0xFF4CAF50; // Green
      case 'tertunda':
        return 0xFFFFA000; // Amber
      case 'berakhir':
        return 0xFF9E9E9E; // Grey
      case 'dibatalkan':
        return 0xFFE53935; // Red
      default:
        return 0xFF2196F3; // Blue
    }
  }
}
