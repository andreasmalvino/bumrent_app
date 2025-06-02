import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../data/models/aset_model.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/pesanan_model.dart';
import '../../../data/models/satuan_waktu_model.dart';
import '../../../data/models/satuan_waktu_sewa_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/pesanan_provider.dart';
import '../../../services/navigation_service.dart';
import '../../../services/service_manager.dart';
import 'package:get_storage/get_storage.dart';

class SewaAsetController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AsetProvider _asetProvider = Get.find<AsetProvider>();
  final AuthProvider authProvider = Get.find<AuthProvider>();
  final PesananProvider pesananProvider = Get.put(PesananProvider());
  final NavigationService navigationService = Get.find<NavigationService>();
  final box = GetStorage();

  // Tab controller
  late TabController tabController;
  // Reactive tab index
  final currentTabIndex = 0.obs;

  // State variables
  final asets = <AsetModel>[].obs;
  final filteredAsets = <AsetModel>[].obs;

  // Paket-related variables
  final pakets = RxList<dynamic>([]);
  final filteredPakets = RxList<dynamic>([]);
  final isLoadingPakets = false.obs;

  final isLoading = true.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Reactive variables
  final isOrdering = false.obs;
  final selectedAset = Rx<AsetModel?>(null);
  final selectedSatuanWaktuSewa = Rx<SatuanWaktuSewaModel?>(null);
  final selectedDurasi = 1.obs;
  final totalHarga = 0.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = '08:00'.obs;
  final satuanWaktuDropdownItems =
      <DropdownMenuItem<SatuanWaktuSewaModel>>[].obs;

  // Flag untuk menangani hot reload
  final hasInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 SewaAsetController: onInit called');

    // Initialize tab controller
    tabController = TabController(length: 2, vsync: this);
    // Listen for tab changes
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;

      // Load packages data when switching to package tab for the first time
      if (currentTabIndex.value == 1 && pakets.isEmpty) {
        loadPakets();
      }
    });

    loadAsets();

    searchController.addListener(() {
      if (currentTabIndex.value == 0) {
        filterAsets(searchController.text);
      } else {
        filterPakets(searchController.text);
      }
    });

    hasInitialized.value = true;
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('🚀 SewaAsetController: onReady called');
  }

  @override
  void onClose() {
    debugPrint('🧹 SewaAsetController: onClose called');
    searchController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // Method untuk menangani hot reload
  void handleHotReload() {
    debugPrint('🔥 Hot reload detected in SewaAsetController');
    if (!hasInitialized.value) {
      debugPrint('🔄 Reinitializing SewaAsetController after hot reload');
      loadAsets();
      if (currentTabIndex.value == 1) {
        loadPakets();
      }
      hasInitialized.value = true;
    }
  }

  // Method untuk menangani tombol back
  void onBackPressed() {
    debugPrint('🔙 Back button pressed in SewaAsetView');
    navigationService.backFromSewaAset();
  }

  Future<void> loadAsets() async {
    try {
      isLoading.value = true;
      final sewaAsets = await _asetProvider.getSewaAsets();

      // Debug data satuan waktu sewa yang diterima
      debugPrint('===== DEBUG ASET & SATUAN WAKTU SEWA =====');
      for (var aset in sewaAsets) {
        debugPrint('Aset: ${aset.nama} (ID: ${aset.id})');

        if (aset.satuanWaktuSewa.isEmpty) {
          debugPrint('  - Tidak ada satuan waktu sewa yang terkait');
        } else {
          debugPrint(
            '  - Memiliki ${aset.satuanWaktuSewa.length} satuan waktu sewa:',
          );
          for (var sws in aset.satuanWaktuSewa) {
            debugPrint('    * ID: ${sws['id']}');
            debugPrint('      Aset ID: ${sws['aset_id']}');
            debugPrint('      Satuan Waktu ID: ${sws['satuan_waktu_id']}');
            debugPrint('      Harga: ${sws['harga']}');
            debugPrint('      Nama Satuan Waktu: ${sws['nama_satuan_waktu']}');
            debugPrint('      -----');
          }
        }
        debugPrint('=====================================');
      }

      asets.assignAll(sewaAsets);
      filteredAsets.assignAll(sewaAsets);

      // Tambahkan log info tentang jumlah aset yang berhasil dimuat
      debugPrint('Loaded ${sewaAsets.length} aset sewa successfully');
    } catch (e) {
      debugPrint('Error loading asets: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data aset',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterAsets(String query) {
    if (query.isEmpty) {
      filteredAsets.assignAll(asets);
    } else {
      filteredAsets.assignAll(
        asets
            .where(
              (aset) => aset.nama.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
  }

  void refreshAsets() {
    loadAsets();
  }

  String formatPrice(dynamic price) {
    if (price == null) return 'Rp 0';

    // Handle different types
    num numericPrice;
    if (price is int || price is double) {
      numericPrice = price;
    } else if (price is String) {
      numericPrice = double.tryParse(price) ?? 0;
    } else {
      return 'Rp 0';
    }

    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(numericPrice);
  }

  void selectAset(AsetModel aset) {
    selectedAset.value = aset;
    // Reset related values
    selectedSatuanWaktuSewa.value = null;
    selectedDurasi.value = 1;
    totalHarga.value = 0;

    // Prepare dropdown items for satuan waktu sewa
    updateSatuanWaktuDropdown();
  }

  void updateSatuanWaktuDropdown() {
    satuanWaktuDropdownItems.clear();

    if (selectedAset.value != null &&
        selectedAset.value!.satuanWaktuSewa.isNotEmpty) {
      for (var item in selectedAset.value!.satuanWaktuSewa) {
        final satuanWaktuSewa = SatuanWaktuSewaModel.fromJson(item);
        satuanWaktuDropdownItems.add(
          DropdownMenuItem<SatuanWaktuSewaModel>(
            value: satuanWaktuSewa,
            child: Text(
              '${satuanWaktuSewa.namaSatuanWaktu ?? "Unknown"} - Rp${NumberFormat.decimalPattern('id').format(satuanWaktuSewa.harga)}',
            ),
          ),
        );
      }
    }
  }

  void selectSatuanWaktu(SatuanWaktuSewaModel? satuanWaktuSewa) {
    selectedSatuanWaktuSewa.value = satuanWaktuSewa;
    calculateTotalPrice();
  }

  void updateDurasi(int durasi) {
    if (durasi < 1) durasi = 1;
    selectedDurasi.value = durasi;
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    if (selectedSatuanWaktuSewa.value != null) {
      totalHarga.value =
          selectedSatuanWaktuSewa.value!.harga * selectedDurasi.value;
    } else {
      totalHarga.value = 0;
    }
  }

  void pickDate(DateTime date) {
    selectedDate.value = date;
  }

  void pickTime(String time) {
    selectedTime.value = time;
  }

  // Helper method to show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Method untuk melakukan pemesanan
  Future<void> placeOrderAset() async {
    if (selectedAset.value == null) {
      _showError('Silakan pilih aset terlebih dahulu');
      return;
    }

    if (selectedSatuanWaktuSewa.value == null) {
      _showError('Silakan pilih satuan waktu sewa');
      return;
    }

    if (selectedDurasi.value <= 0) {
      _showError('Durasi sewa harus lebih dari 0');
      return;
    }

    final userId = authProvider.getCurrentUserId();
    if (userId == null) {
      _showError('Anda belum login, silakan login terlebih dahulu');
      return;
    }

    try {
      final result = await _asetProvider.orderAset(
        userId: userId,
        asetId: selectedAset.value!.id,
        satuanWaktuSewaId: selectedSatuanWaktuSewa.value!.id,
        durasi: selectedDurasi.value,
        totalHarga: totalHarga.value,
      );

      if (result) {
        Get.snackbar(
          'Sukses',
          'Pesanan berhasil dibuat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        resetSelections();
      } else {
        _showError('Gagal membuat pesanan');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  // Method untuk reset pilihan setelah pemesanan berhasil
  void resetSelections() {
    selectedAset.value = null;
    selectedSatuanWaktuSewa.value = null;
    selectedDurasi.value = 1;
    totalHarga.value = 0;
  }

  // Load packages data from paket table
  Future<void> loadPakets() async {
    try {
      isLoadingPakets.value = true;

      // Call the provider method to get paket data
      final paketData = await _asetProvider.getPakets();

      // Debug paket data
      debugPrint('===== DEBUG PAKET & SATUAN WAKTU SEWA =====');
      for (var paket in paketData) {
        debugPrint('Paket: ${paket['nama']} (ID: ${paket['id']})');

        if (paket['satuanWaktuSewa'] == null ||
            paket['satuanWaktuSewa'].isEmpty) {
          debugPrint('  - Tidak ada satuan waktu sewa yang terkait');
        } else {
          debugPrint(
            '  - Memiliki ${paket['satuanWaktuSewa'].length} satuan waktu sewa:',
          );
          for (var sws in paket['satuanWaktuSewa']) {
            debugPrint('    * ID: ${sws['id']}');
            debugPrint('      Paket ID: ${sws['paket_id']}');
            debugPrint('      Satuan Waktu ID: ${sws['satuan_waktu_id']}');
            debugPrint('      Harga: ${sws['harga']}');
            debugPrint('      Nama Satuan Waktu: ${sws['nama_satuan_waktu']}');
            debugPrint('      -----');
          }
        }
        debugPrint('=====================================');
      }

      pakets.assignAll(paketData);
      filteredPakets.assignAll(paketData);

      debugPrint('Loaded ${paketData.length} paket successfully');
    } catch (e) {
      debugPrint('Error loading pakets: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data paket',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPakets.value = false;
    }
  }

  // Method to filter pakets based on search query
  void filterPakets(String query) {
    if (query.isEmpty) {
      filteredPakets.assignAll(pakets);
    } else {
      filteredPakets.assignAll(
        pakets
            .where(
              (paket) => paket['nama'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList(),
      );
    }
  }

  void refreshPakets() {
    loadPakets();
  }

  // Method to load paket data
  Future<void> loadPaketData() async {
    try {
      isLoadingPakets.value = true;
      final result = await _asetProvider.getPakets();
      if (result != null) {
        pakets.clear();
        filteredPakets.clear();
        pakets.addAll(result);
        filteredPakets.addAll(result);
      }
    } catch (e) {
      debugPrint('Error loading pakets: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data paket. Silakan coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPakets.value = false;
    }
  }

  // Method for placing an order for a paket
  Future<void> placeOrderPaket({
    required String paketId,
    required String satuanWaktuSewaId,
    required int durasi,
    required int totalHarga,
  }) async {
    debugPrint('===== PLACE ORDER PAKET =====');
    debugPrint('paketId: $paketId');
    debugPrint('satuanWaktuSewaId: $satuanWaktuSewaId');
    debugPrint('durasi: $durasi');
    debugPrint('totalHarga: $totalHarga');

    final userId = authProvider.getCurrentUserId();
    if (userId == null) {
      _showError('Anda belum login, silakan login terlebih dahulu');
      return;
    }

    try {
      final result = await _asetProvider.orderPaket(
        userId: userId,
        paketId: paketId,
        satuanWaktuSewaId: satuanWaktuSewaId,
        durasi: durasi,
        totalHarga: totalHarga,
      );

      if (result) {
        Get.snackbar(
          'Sukses',
          'Pesanan paket berhasil dibuat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _showError('Gagal membuat pesanan paket');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }
}
