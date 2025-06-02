import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PetugasSewaController extends GetxController {
  // Reactive variables
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final orderIdQuery = ''.obs;
  final selectedStatusFilter = 'Semua'.obs;
  final filteredSewaList = <Map<String, dynamic>>[].obs;

  // Filter options
  final List<String> statusFilters = [
    'Semua',
    'Menunggu Pembayaran',
    'Periksa Pembayaran',
    'Diterima',
    'Dikembalikan',
    'Selesai',
    'Dibatalkan',
  ];

  // Mock data for sewa list
  final RxList<Map<String, dynamic>> sewaList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Add listeners to update filtered list when any filter changes
    ever(searchQuery, (_) => _updateFilteredList());
    ever(orderIdQuery, (_) => _updateFilteredList());
    ever(selectedStatusFilter, (_) => _updateFilteredList());
    ever(sewaList, (_) => _updateFilteredList());

    // Load initial data
    loadSewaData();
  }

  // Update filtered list based on current filters
  void _updateFilteredList() {
    filteredSewaList.value =
        sewaList.where((sewa) {
          // Apply search filter
          final matchesSearch = sewa['nama_warga']
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

          // Apply order ID filter if provided
          final matchesOrderId =
              orderIdQuery.value.isEmpty ||
              sewa['order_id'].toString().toLowerCase().contains(
                orderIdQuery.value.toLowerCase(),
              );

          // Apply status filter if not 'Semua'
          final matchesStatus =
              selectedStatusFilter.value == 'Semua' ||
              sewa['status'] == selectedStatusFilter.value;

          return matchesSearch && matchesOrderId && matchesStatus;
        }).toList();
  }

  // Load sewa data (mock data for now)
  Future<void> loadSewaData() async {
    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Populate with mock data
      sewaList.assignAll([
        {
          'id': '1',
          'order_id': 'SWA-001',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-02-05',
          'tanggal_selesai': '2025-02-10',
          'total_biaya': 45000,
          'status': 'Diterima',
          'photo_url': 'https://example.com/photo1.jpg',
        },
        {
          'id': '2',
          'order_id': 'SWA-002',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-02-15',
          'tanggal_selesai': '2025-02-20',
          'total_biaya': 30000,
          'status': 'Selesai',
          'photo_url': 'https://example.com/photo2.jpg',
        },
        {
          'id': '3',
          'order_id': 'SWA-003',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-02-25',
          'tanggal_selesai': '2025-03-01',
          'total_biaya': 35000,
          'status': 'Menunggu Pembayaran',
          'photo_url': 'https://example.com/photo3.jpg',
        },
        {
          'id': '4',
          'order_id': 'SWA-004',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-03-05',
          'tanggal_selesai': '2025-03-08',
          'total_biaya': 20000,
          'status': 'Periksa Pembayaran',
          'photo_url': 'https://example.com/photo4.jpg',
        },
        {
          'id': '5',
          'order_id': 'SWA-005',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-03-12',
          'tanggal_selesai': '2025-03-14',
          'total_biaya': 15000,
          'status': 'Dibatalkan',
          'photo_url': 'https://example.com/photo5.jpg',
        },
        {
          'id': '6',
          'order_id': 'SWA-006',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-03-18',
          'tanggal_selesai': '2025-03-20',
          'total_biaya': 25000,
          'status': 'Pembayaran Denda',
          'photo_url': 'https://example.com/photo6.jpg',
        },
        {
          'id': '7',
          'order_id': 'SWA-007',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-03-25',
          'tanggal_selesai': '2025-03-28',
          'total_biaya': 40000,
          'status': 'Periksa Denda',
          'photo_url': 'https://example.com/photo7.jpg',
        },
        {
          'id': '8',
          'order_id': 'SWA-008',
          'nama_warga': 'Sukimin',
          'nama_aset': 'Mobil Pickup',
          'tanggal_mulai': '2025-04-02',
          'tanggal_selesai': '2025-04-05',
          'total_biaya': 10000,
          'status': 'Dikembalikan',
          'photo_url': 'https://example.com/photo8.jpg',
        },
      ]);
    } catch (e) {
      print('Error loading sewa data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update order ID query
  void setOrderIdQuery(String query) {
    orderIdQuery.value = query;
  }

  // Update status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    applyFilters();
  }

  void resetFilters() {
    selectedStatusFilter.value = 'Semua';
    searchQuery.value = '';
    filteredSewaList.value = sewaList;
  }

  void applyFilters() {
    filteredSewaList.value =
        sewaList.where((sewa) {
          bool matchesStatus =
              selectedStatusFilter.value == 'Semua' ||
              sewa['status'] == selectedStatusFilter.value;
          bool matchesSearch =
              searchQuery.value.isEmpty ||
              sewa['nama_warga'].toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              );
          return matchesStatus && matchesSearch;
        }).toList();
  }

  // Format price to rupiah
  String formatPrice(num price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Get color based on status
  Color getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return Colors.orange;
      case 'Periksa Pembayaran':
        return Colors.amber.shade700;
      case 'Diterima':
        return Colors.blue;
      case 'Pembayaran Denda':
        return Colors.deepOrange;
      case 'Periksa Denda':
        return Colors.red.shade600;
      case 'Dikembalikan':
        return Colors.teal;
      case 'Sedang Disewa':
        return Colors.green;
      case 'Selesai':
        return Colors.purple;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Handle sewa approval (from "Periksa Pembayaran" to "Diterima")
  void approveSewa(String id) {
    final index = sewaList.indexWhere((sewa) => sewa['id'] == id);
    if (index != -1) {
      final sewa = Map<String, dynamic>.from(sewaList[index]);
      final currentStatus = sewa['status'];

      if (currentStatus == 'Periksa Pembayaran') {
        sewa['status'] = 'Diterima';
      } else if (currentStatus == 'Periksa Denda') {
        sewa['status'] = 'Selesai';
      } else if (currentStatus == 'Menunggu Pembayaran') {
        sewa['status'] = 'Periksa Pembayaran';
      }

      sewaList[index] = sewa;
      sewaList.refresh();
    }
  }

  // Handle sewa rejection or cancellation
  void rejectSewa(String id) {
    final index = sewaList.indexWhere((sewa) => sewa['id'] == id);
    if (index != -1) {
      final sewa = Map<String, dynamic>.from(sewaList[index]);
      sewa['status'] = 'Dibatalkan';
      sewaList[index] = sewa;
      sewaList.refresh();
    }
  }

  // Request payment for penalty
  void requestPenaltyPayment(String id) {
    final index = sewaList.indexWhere((sewa) => sewa['id'] == id);
    if (index != -1) {
      final sewa = Map<String, dynamic>.from(sewaList[index]);
      sewa['status'] = 'Pembayaran Denda';
      sewaList[index] = sewa;
      sewaList.refresh();
    }
  }

  // Mark penalty payment as requiring inspection
  void markPenaltyForInspection(String id) {
    final index = sewaList.indexWhere((sewa) => sewa['id'] == id);
    if (index != -1) {
      final sewa = Map<String, dynamic>.from(sewaList[index]);
      sewa['status'] = 'Periksa Denda';
      sewaList[index] = sewa;
      sewaList.refresh();
    }
  }

  // Handle sewa completion
  void completeSewa(String id) {
    final index = sewaList.indexWhere((sewa) => sewa['id'] == id);
    if (index != -1) {
      final sewa = Map<String, dynamic>.from(sewaList[index]);
      sewa['status'] = 'Selesai';
      sewaList[index] = sewa;
      sewaList.refresh();
    }
  }

  // Mark rental as returned
  void markAsReturned(String id) {
    final index = sewaList.indexWhere((sewa) => sewa['id'] == id);
    if (index != -1) {
      final sewa = Map<String, dynamic>.from(sewaList[index]);
      sewa['status'] = 'Dikembalikan';
      sewaList[index] = sewa;
      sewaList.refresh();
    }
  }
}
