import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/sewa_service.dart';
import '../../../data/models/rental_booking_model.dart';
import '../../../data/providers/aset_provider.dart';

class PetugasSewaController extends GetxController {
  // Reactive variables
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final orderIdQuery = ''.obs;
  final selectedStatusFilter = 'Semua'.obs;
  final filteredSewaList = <SewaModel>[].obs;

  // Filter options
  final List<String> statusFilters = [
    'Semua',
    'Menunggu Pembayaran',
    'Periksa Pembayaran',
    'Diterima',
    'Aktif',
    'Dikembalikan',
    'Selesai',
    'Dibatalkan',
  ];

  // Mock data for sewa list
  final RxList<SewaModel> sewaList = <SewaModel>[].obs;

  // Payment option state (per sewa)
  final Map<String, RxBool> isFullPaymentMap = {};
  final Map<String, TextEditingController> nominalControllerMap = {};
  final Map<String, RxString> paymentMethodMap = {};

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
          final query = searchQuery.value.toLowerCase();
          // Apply search filter: nama warga, id pesanan, atau asetId
          final matchesSearch =
              sewa.wargaNama.toLowerCase().contains(query) ||
              sewa.id.toLowerCase().contains(query) ||
              (sewa.asetId != null &&
                  sewa.asetId!.toLowerCase().contains(query));

          // Apply status filter if not 'Semua'
          final matchesStatus =
              selectedStatusFilter.value == 'Semua' ||
              sewa.status.toUpperCase() ==
                  selectedStatusFilter.value.toUpperCase();

          return matchesSearch && matchesStatus;
        }).toList();
  }

  // Load sewa data (mock data for now)
  Future<void> loadSewaData() async {
    isLoading.value = true;

    try {
      final data = await SewaService().fetchAllSewa();
      sewaList.assignAll(data);
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
              sewa.status.toUpperCase() ==
                  selectedStatusFilter.value.toUpperCase();
          bool matchesSearch =
              searchQuery.value.isEmpty ||
              sewa.wargaNama.toLowerCase().contains(
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
    switch (status.toUpperCase()) {
      case 'MENUNGGU PEMBAYARAN':
        return Colors.orangeAccent;
      case 'PERIKSA PEMBAYARAN':
        return Colors.amber;
      case 'DITERIMA':
        return Colors.blueAccent;
      case 'AKTIF':
        return Colors.green;
      case 'PEMBAYARAN DENDA':
        return Colors.deepOrangeAccent;
      case 'PERIKSA PEMBAYARAN DENDA':
        return Colors.redAccent;
      case 'DIKEMBALIKAN':
        return Colors.teal;
      case 'SELESAI':
        return Colors.purple;
      case 'DIBATALKAN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get icon based on status
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'MENUNGGU PEMBAYARAN':
        return Icons.payments_outlined;
      case 'PERIKSA PEMBAYARAN':
        return Icons.fact_check_outlined;
      case 'DITERIMA':
        return Icons.check_circle_outlined;
      case 'AKTIF':
        return Icons.play_circle_outline;
      case 'PEMBYARAN DENDA':
        return Icons.money_off_csred_outlined;
      case 'PERIKSA PEMBAYARAN DENDA':
        return Icons.assignment_late_outlined;
      case 'DIKEMBALIKAN':
        return Icons.assignment_return_outlined;
      case 'SELESAI':
        return Icons.task_alt_outlined;
      case 'DIBATALKAN':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Handle sewa approval (from "Periksa Pembayaran" to "Diterima")
  void approveSewa(String id) {
    final index = sewaList.indexWhere((sewa) => sewa.id == id);
    if (index != -1) {
      final sewa = sewaList[index];
      final currentStatus = sewa.status;
      String? newStatus;
      if (currentStatus == 'PERIKSA PEMBAYARAN') {
        newStatus = 'DITERIMA';
      } else if (currentStatus == 'PERIKSA PEMBAYARAN DENDA') {
        newStatus = 'SELESAI';
      } else if (currentStatus == 'MENUNGGU PEMBAYARAN') {
        newStatus = 'PERIKSA PEMBAYARAN';
      }
      if (newStatus != null) {
        sewaList[index] = SewaModel(
          id: sewa.id,
          userId: sewa.userId,
          status: newStatus,
          waktuMulai: sewa.waktuMulai,
          waktuSelesai: sewa.waktuSelesai,
          tanggalPemesanan: sewa.tanggalPemesanan,
          tipePesanan: sewa.tipePesanan,
          kuantitas: sewa.kuantitas,
          asetId: sewa.asetId,
          asetNama: sewa.asetNama,
          asetFoto: sewa.asetFoto,
          paketId: sewa.paketId,
          paketNama: sewa.paketNama,
          paketFoto: sewa.paketFoto,
          totalTagihan: sewa.totalTagihan,
          wargaNama: sewa.wargaNama,
          wargaNoHp: sewa.wargaNoHp,
          wargaAvatar: sewa.wargaAvatar,
        );
        sewaList.refresh();
      }
    }
  }

  // Handle sewa rejection or cancellation
  void rejectSewa(String id) {
    final index = sewaList.indexWhere((sewa) => sewa.id == id);
    if (index != -1) {
      final sewa = sewaList[index];
      sewaList[index] = SewaModel(
        id: sewa.id,
        userId: sewa.userId,
        status: 'Dibatalkan',
        waktuMulai: sewa.waktuMulai,
        waktuSelesai: sewa.waktuSelesai,
        tanggalPemesanan: sewa.tanggalPemesanan,
        tipePesanan: sewa.tipePesanan,
        kuantitas: sewa.kuantitas,
        asetId: sewa.asetId,
        asetNama: sewa.asetNama,
        asetFoto: sewa.asetFoto,
        paketId: sewa.paketId,
        paketNama: sewa.paketNama,
        paketFoto: sewa.paketFoto,
        totalTagihan: sewa.totalTagihan,
        wargaNama: sewa.wargaNama,
        wargaNoHp: sewa.wargaNoHp,
        wargaAvatar: sewa.wargaAvatar,
      );
      sewaList.refresh();
    }
  }

  // Request payment for penalty
  void requestPenaltyPayment(String id) {
    final index = sewaList.indexWhere((sewa) => sewa.id == id);
    if (index != -1) {
      final sewa = sewaList[index];
      sewaList[index] = SewaModel(
        id: sewa.id,
        userId: sewa.userId,
        status: 'Pembayaran Denda',
        waktuMulai: sewa.waktuMulai,
        waktuSelesai: sewa.waktuSelesai,
        tanggalPemesanan: sewa.tanggalPemesanan,
        tipePesanan: sewa.tipePesanan,
        kuantitas: sewa.kuantitas,
        asetId: sewa.asetId,
        asetNama: sewa.asetNama,
        asetFoto: sewa.asetFoto,
        paketId: sewa.paketId,
        paketNama: sewa.paketNama,
        paketFoto: sewa.paketFoto,
        totalTagihan: sewa.totalTagihan,
        wargaNama: sewa.wargaNama,
        wargaNoHp: sewa.wargaNoHp,
        wargaAvatar: sewa.wargaAvatar,
      );
      sewaList.refresh();
    }
  }

  // Mark penalty payment as requiring inspection
  void markPenaltyForInspection(String id) {
    final index = sewaList.indexWhere((sewa) => sewa.id == id);
    if (index != -1) {
      final sewa = sewaList[index];
      sewaList[index] = SewaModel(
        id: sewa.id,
        userId: sewa.userId,
        status: 'Periksa Denda',
        waktuMulai: sewa.waktuMulai,
        waktuSelesai: sewa.waktuSelesai,
        tanggalPemesanan: sewa.tanggalPemesanan,
        tipePesanan: sewa.tipePesanan,
        kuantitas: sewa.kuantitas,
        asetId: sewa.asetId,
        asetNama: sewa.asetNama,
        asetFoto: sewa.asetFoto,
        paketId: sewa.paketId,
        paketNama: sewa.paketNama,
        paketFoto: sewa.paketFoto,
        totalTagihan: sewa.totalTagihan,
        wargaNama: sewa.wargaNama,
        wargaNoHp: sewa.wargaNoHp,
        wargaAvatar: sewa.wargaAvatar,
      );
      sewaList.refresh();
    }
  }

  // Handle sewa completion
  void completeSewa(String id) async {
    final index = sewaList.indexWhere((sewa) => sewa.id == id);
    if (index != -1) {
      final sewa = sewaList[index];
      sewaList[index] = SewaModel(
        id: sewa.id,
        userId: sewa.userId,
        status: 'Selesai',
        waktuMulai: sewa.waktuMulai,
        waktuSelesai: sewa.waktuSelesai,
        tanggalPemesanan: sewa.tanggalPemesanan,
        tipePesanan: sewa.tipePesanan,
        kuantitas: sewa.kuantitas,
        asetId: sewa.asetId,
        asetNama: sewa.asetNama,
        asetFoto: sewa.asetFoto,
        paketId: sewa.paketId,
        paketNama: sewa.paketNama,
        paketFoto: sewa.paketFoto,
        totalTagihan: sewa.totalTagihan,
        wargaNama: sewa.wargaNama,
        wargaNoHp: sewa.wargaNoHp,
        wargaAvatar: sewa.wargaAvatar,
      );
      sewaList.refresh();
      // Update status in database
      final asetProvider = Get.find<AsetProvider>();
      await asetProvider.updateSewaAsetStatus(
        sewaAsetId: id,
        status: 'SELESAI',
      );
    }
  }

  // Mark rental as returned
  Future<void> markAsReturned(String id) async {
    final index = sewaList.indexWhere((sewa) => sewa.id == id);
    if (index != -1) {
      final sewa = sewaList[index];
      sewaList[index] = SewaModel(
        id: sewa.id,
        userId: sewa.userId,
        status: 'Dikembalikan',
        waktuMulai: sewa.waktuMulai,
        waktuSelesai: sewa.waktuSelesai,
        tanggalPemesanan: sewa.tanggalPemesanan,
        tipePesanan: sewa.tipePesanan,
        kuantitas: sewa.kuantitas,
        asetId: sewa.asetId,
        asetNama: sewa.asetNama,
        asetFoto: sewa.asetFoto,
        paketId: sewa.paketId,
        paketNama: sewa.paketNama,
        paketFoto: sewa.paketFoto,
        totalTagihan: sewa.totalTagihan,
        wargaNama: sewa.wargaNama,
        wargaNoHp: sewa.wargaNoHp,
        wargaAvatar: sewa.wargaAvatar,
      );
      sewaList.refresh();
      // Update status in database
      final asetProvider = Get.find<AsetProvider>();
      final result = await asetProvider.updateSewaAsetStatus(
        sewaAsetId: id,
        status: 'DIKEMBALIKAN',
      );
      if (!result) {
        Get.snackbar(
          'Gagal',
          'Gagal mengubah status sewa di database',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Ambil detail item paket (nama aset & kuantitas)
  Future<List<Map<String, dynamic>>> getPaketItems(String paketId) async {
    final asetProvider = Get.find<AsetProvider>();
    debugPrint('[DEBUG] getPaketItems called with paketId: $paketId');
    try {
      final items = await asetProvider.getPaketItems(paketId);
      debugPrint('[DEBUG] getPaketItems result for paketId $paketId:');
      for (var item in items) {
        debugPrint('  - item: ${item.toString()}');
      }
      return items;
    } catch (e, stack) {
      debugPrint('[ERROR] getPaketItems failed for paketId $paketId: $e');
      debugPrint('[ERROR] Stacktrace: $stack');
      return [];
    }
  }

  RxBool getIsFullPayment(String sewaId) {
    if (!isFullPaymentMap.containsKey(sewaId)) {
      isFullPaymentMap[sewaId] = false.obs;
    }
    return isFullPaymentMap[sewaId]!;
  }

  TextEditingController getNominalController(String sewaId) {
    if (!nominalControllerMap.containsKey(sewaId)) {
      final controller = TextEditingController(text: '0');
      nominalControllerMap[sewaId] = controller;
    }
    return nominalControllerMap[sewaId]!;
  }

  void setFullPayment(String sewaId, bool value, num totalTagihan) {
    getIsFullPayment(sewaId).value = value;
    if (value) {
      getNominalController(sewaId).text = totalTagihan.toString();
    }
  }

  RxString getPaymentMethod(String sewaId) {
    if (!paymentMethodMap.containsKey(sewaId)) {
      paymentMethodMap[sewaId] = 'Tunai'.obs;
    }
    return paymentMethodMap[sewaId]!;
  }

  void setPaymentMethod(String sewaId, String method) {
    getPaymentMethod(sewaId).value = method;
  }

  Future<String?> getTagihanSewaIdBySewaAsetId(String sewaAsetId) async {
    final asetProvider = Get.find<AsetProvider>();
    final tagihan = await asetProvider.getTagihanSewa(sewaAsetId);
    if (tagihan != null && tagihan['id'] != null) {
      return tagihan['id'] as String;
    }
    return null;
  }

  Future<void> confirmPembayaranTagihan({
    required String sewaAsetId,
    required int nominal,
    required String metodePembayaran,
  }) async {
    final tagihanSewaId = await getTagihanSewaIdBySewaAsetId(sewaAsetId);
    if (tagihanSewaId == null) {
      Get.snackbar(
        'Gagal',
        'Tagihan sewa tidak ditemukan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final asetProvider = Get.find<AsetProvider>();
    // Cek status sewa_aset saat ini
    final sewaAsetData = await asetProvider.getSewaAsetWithAsetData(sewaAsetId);
    if (sewaAsetData != null &&
        (sewaAsetData['status']?.toString()?.toUpperCase() ==
            'PERIKSA PEMBAYARAN')) {
      // Ubah status menjadi MENUNGGU PEMBAYARAN
      await asetProvider.updateSewaAsetStatus(
        sewaAsetId: sewaAsetId,
        status: 'MENUNGGU PEMBAYARAN',
      );
    }
    final result = await asetProvider.processPembayaranTagihan(
      tagihanSewaId: tagihanSewaId,
      nominal: nominal,
      metodePembayaran: metodePembayaran,
    );
    if (result) {
      Get.snackbar(
        'Sukses',
        'Pembayaran berhasil diproses',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Pembayaran gagal diproses',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
