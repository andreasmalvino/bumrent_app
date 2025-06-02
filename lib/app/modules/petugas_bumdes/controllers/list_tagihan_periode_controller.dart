import 'package:get/get.dart';

class ListTagihanPeriodeController extends GetxController {
  // Reactive variables
  final isLoading = true.obs;
  final periodeList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  // Customer data
  final pelangganData = Rx<Map<String, dynamic>>({});
  final serviceName = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get the customer data and service name passed from previous page
    if (Get.arguments != null) {
      if (Get.arguments['pelanggan'] != null) {
        pelangganData.value = Map<String, dynamic>.from(
          Get.arguments['pelanggan'],
        );
      }

      if (Get.arguments['serviceName'] != null) {
        serviceName.value = Get.arguments['serviceName'];
      }
    }

    // Load periode data
    loadPeriodeData();
  }

  // Load sample periode data (would be replaced with API call in production)
  Future<void> loadPeriodeData() async {
    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Sample data for periods
      final sampleData = [
        {
          'id': '1',
          'bulan': 'Maret',
          'tahun': '2025',
          'nominal': 'Rp 20.000',
          'status_pembayaran': 'Lunas',
          'tanggal_pembayaran': '05/03/2025',
          'metode_pembayaran': 'Transfer Bank',
          'keterangan': 'Pembayaran tepat waktu',
          'is_current': true,
        },
      ];

      periodeList.assignAll(sampleData);
    } catch (e) {
      print('Error loading periode data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter the list based on search query
  List<Map<String, dynamic>> get filteredPeriodeList {
    if (searchQuery.value.isEmpty) {
      return periodeList;
    }

    final query = searchQuery.value.toLowerCase();
    return periodeList.where((periode) {
      final bulan = periode['bulan'].toString().toLowerCase();
      final tahun = periode['tahun'].toString().toLowerCase();
      final status = periode['status_pembayaran'].toString().toLowerCase();

      return bulan.contains(query) ||
          tahun.contains(query) ||
          status.contains(query);
    }).toList();
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Get status color based on payment status
  getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return 0xFF4CAF50; // Green
      case 'belum lunas':
        return 0xFFFFA000; // Amber
      case 'terlambat':
        return 0xFFE53935; // Red
      default:
        return 0xFF2196F3; // Blue
    }
  }

  // Get formatted month-year string
  String getPeriodeString(Map<String, dynamic> periode) {
    return '${periode['bulan']} ${periode['tahun']}';
  }
}
