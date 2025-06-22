import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/aset_provider.dart';

class WargaSewaController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Get navigation service
  final NavigationService navigationService = Get.find<NavigationService>();

  // Get auth provider for user data and sewa_aset queries
  final AuthProvider authProvider = Get.find<AuthProvider>();

  // Get aset provider for asset data
  final AsetProvider asetProvider = Get.find<AsetProvider>();

  // Observable lists for different rental statuses
  final rentals = <Map<String, dynamic>>[].obs;
  final pendingRentals = <Map<String, dynamic>>[].obs;
  final acceptedRentals = <Map<String, dynamic>>[].obs;
  final completedRentals = <Map<String, dynamic>>[].obs;
  final cancelledRentals = <Map<String, dynamic>>[].obs;
  final returnedRentals = <Map<String, dynamic>>[].obs;
  final activeRentals = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingPending = false.obs;
  final isLoadingAccepted = false.obs;
  final isLoadingCompleted = false.obs;
  final isLoadingCancelled = false.obs;
  final isLoadingReturned = false.obs;
  final isLoadingActive = false.obs;

  bool _tabSetFromArgument = false;

  @override
  void onInit() {
    super.onInit();

    // Initialize tab controller with 7 tabs
    tabController = TabController(length: 7, vsync: this);

    // Load real rental data for all tabs
    loadRentalsData();
    loadPendingRentals();
    loadAcceptedRentals();
    loadActiveRentals();
    loadCompletedRentals();
    loadCancelledRentals();
    loadReturnedRentals();

    // Listen to tab changes to update state if needed
    tabController.addListener(() {
      // Update selected tab index when changed via swipe
      final int currentIndex = tabController.index;
      debugPrint('Tab changed to index: $currentIndex');

      // Load data for the selected tab if not already loaded
      switch (currentIndex) {
        case 0: // Belum Bayar
          if (rentals.isEmpty && !isLoading.value) {
            loadRentalsData();
          }
          break;
        case 1: // Pending
          if (pendingRentals.isEmpty && !isLoadingPending.value) {
            loadPendingRentals();
          }
          break;
        case 2: // Diterima
          if (acceptedRentals.isEmpty && !isLoadingAccepted.value) {
            loadAcceptedRentals();
          }
          break;
        case 3: // Aktif
          if (activeRentals.isEmpty && !isLoadingActive.value) {
            loadActiveRentals();
          }
          break;
        case 4: // Selesai
          if (completedRentals.isEmpty && !isLoadingCompleted.value) {
            loadCompletedRentals();
          }
          break;
        case 5: // Dibatalkan
          if (cancelledRentals.isEmpty && !isLoadingCancelled.value) {
            loadCancelledRentals();
          }
          break;
        case 6: // Dikembalikan
          if (returnedRentals.isEmpty && !isLoadingReturned.value) {
            loadReturnedRentals();
          }
          break;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Jalankan update nav index dan tab index setelah build selesai
    Future.delayed(Duration.zero, () {
      navigationService.setNavIndex(1);

      final args = Get.arguments;
      int initialTab = 0;
      if (!_tabSetFromArgument &&
          args != null &&
          args is Map &&
          args['tab'] != null) {
        initialTab =
            args['tab'] is int
                ? args['tab']
                : int.tryParse(args['tab'].toString()) ?? 0;
        if (tabController.length > initialTab) {
          tabController.index = initialTab;
          _tabSetFromArgument = true;
        }
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load real data from sewa_aset table
  Future<void> loadRentalsData() async {
    try {
      isLoading.value = true;

      // Clear existing data
      rentals.clear();

      // Get sewa_aset data with status "MENUNGGU PEMBAYARAN" or "PEMBAYARAN DENDA"
      final sewaAsetList = await authProvider.getSewaAsetByStatus([
        'MENUNGGU PEMBAYARAN',
        'PEMBAYARAN DENDA',
      ]);

      debugPrint('Fetched ${sewaAsetList.length} sewa_aset records');

      // Process each sewa_aset record
      for (var sewaAset in sewaAsetList) {
        // Get asset details if aset_id is available
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';

        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }

        // Parse waktu mulai and waktu selesai
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';

        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);

          // Format for display
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');

          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);

          // Format based on satuan waktu
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            // For hours, show time range on same day
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            // For days, show date range
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            // Default format
            rentangWaktu = '$jamMulai - $jamSelesai';
          }

          // Full time format for waktuSewa
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }

        // Format price
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }

        // Add to rentals list
        rentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'MENUNGGU PEMBAYARAN',
          'totalPrice': totalPrice,
          'countdown': '00:59:59', // Default countdown
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
          'updated_at': sewaAset['updated_at'],
        });
      }

      debugPrint('Processed ${rentals.length} rental records');
    } catch (e) {
      debugPrint('Error loading rentals data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation methods
  void navigateToRentals() {
    navigationService.toSewaAset();
  }

  void onNavItemTapped(int index) {
    if (navigationService.currentNavIndex.value == index) return;

    navigationService.setNavIndex(index);

    switch (index) {
      case 0:
        // Navigate to Home
        Get.offNamed(Routes.WARGA_DASHBOARD);
        break;
      case 1:
        // Already on Sewa tab
        break;
      case 2:
        // Navigate to Langganan
        Get.offNamed(Routes.LANGGANAN);
        break;
    }
  }

  // Actions
  void cancelRental(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await asetProvider.client
            .from('sewa_aset')
            .update({'status': 'DIBATALKAN'})
            .eq('id', id);
        Get.snackbar(
          'Berhasil',
          'Pesanan berhasil dibatalkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh data
        loadRentalsData();
        loadPendingRentals();
        loadAcceptedRentals();
        loadActiveRentals();
        loadCompletedRentals();
        loadCancelledRentals();
        loadReturnedRentals();
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Gagal membatalkan pesanan: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Navigate to payment page with the selected rental data
  void viewRentalDetail(Map<String, dynamic> rental) {
    debugPrint('Navigating to payment page with rental ID: ${rental['id']}');

    // Navigate to payment page with rental data
    Get.toNamed(
      Routes.PEMBAYARAN_SEWA,
      arguments: {'orderId': rental['id'], 'rentalData': rental},
    );
  }

  void payRental(String id) {
    Get.snackbar(
      'Info',
      'Navigasi ke halaman pembayaran',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Load data for the Selesai tab (status: SELESAI)
  Future<void> loadCompletedRentals() async {
    try {
      isLoadingCompleted.value = true;

      // Clear existing data
      completedRentals.clear();

      // Get sewa_aset data with status "SELESAI"
      final sewaAsetList = await authProvider.getSewaAsetByStatus(['SELESAI']);

      debugPrint('Fetched ${sewaAsetList.length} completed sewa_aset records');

      // Process each sewa_aset record
      for (var sewaAset in sewaAsetList) {
        // Get asset details if aset_id is available
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';

        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }

        // Parse waktu mulai and waktu selesai
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';

        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);

          // Format for display
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');

          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);

          // Format based on satuan waktu
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            // For hours, show time range on same day
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            // For days, show date range
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            // Default format
            rentangWaktu = '$jamMulai - $jamSelesai';
          }

          // Full time format for waktuSewa
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }

        // Format price
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }

        // Add to completed rentals list
        completedRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'SELESAI',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
        });
      }

      debugPrint(
        'Processed ${completedRentals.length} completed rental records',
      );
    } catch (e) {
      debugPrint('Error loading completed rentals data: $e');
    } finally {
      isLoadingCompleted.value = false;
    }
  }

  // Load data for the Dibatalkan tab (status: DIBATALKAN)
  Future<void> loadCancelledRentals() async {
    try {
      isLoadingCancelled.value = true;

      // Clear existing data
      cancelledRentals.clear();

      // Get sewa_aset data with status "DIBATALKAN"
      final sewaAsetList = await authProvider.getSewaAsetByStatus([
        'DIBATALKAN',
      ]);

      debugPrint('Fetched ${sewaAsetList.length} cancelled sewa_aset records');

      // Process each sewa_aset record
      for (var sewaAset in sewaAsetList) {
        // Get asset details if aset_id is available
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';

        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }

        // Parse waktu mulai and waktu selesai
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';

        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);

          // Format for display
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');

          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);

          // Format based on satuan waktu
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            // For hours, show time range on same day
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            // For days, show date range
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            // Default format
            rentangWaktu = '$jamMulai - $jamSelesai';
          }

          // Full time format for waktuSewa
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }

        // Format price
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }

        // Add to cancelled rentals list
        cancelledRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'DIBATALKAN',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
          'alasanPembatalan': sewaAset['alasan_pembatalan'] ?? '-',
        });
      }

      debugPrint(
        'Processed ${cancelledRentals.length} cancelled rental records',
      );
    } catch (e) {
      debugPrint('Error loading cancelled rentals data: $e');
    } finally {
      isLoadingCancelled.value = false;
    }
  }

  // Load data for the Pending tab (status: PERIKSA PEMBAYARAN)
  Future<void> loadPendingRentals() async {
    try {
      isLoadingPending.value = true;

      // Clear existing data
      pendingRentals.clear();

      // Get sewa_aset data with status 'PERIKSA PEMBAYARAN' dan 'PERIKSA PEMBAYARAN DENDA'
      final sewaAsetList = await authProvider.getSewaAsetByStatus([
        'PERIKSA PEMBAYARAN',
        'PERIKSA PEMBAYARAN DENDA',
      ]);

      debugPrint('Fetched ${sewaAsetList.length} pending sewa_aset records');

      // Process each sewa_aset record
      for (var sewaAset in sewaAsetList) {
        // Get asset details if aset_id is available
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';

        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }

        // Parse waktu mulai and waktu selesai
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';

        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);

          // Format for display
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');

          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);

          // Format based on satuan waktu
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            // For hours, show time range on same day
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            // For days, show date range
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            // Default format
            rentangWaktu = '$jamMulai - $jamSelesai';
          }

          // Full time format for waktuSewa
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }

        // Format price
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }

        // Add to pending rentals list
        pendingRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'PERIKSA PEMBAYARAN',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
        });
      }

      debugPrint('Processed ${pendingRentals.length} pending rental records');
    } catch (e) {
      debugPrint('Error loading pending rentals data: $e');
    } finally {
      isLoadingPending.value = false;
    }
  }

  // Load data for the Diterima tab (status: DITERIMA)
  Future<void> loadAcceptedRentals() async {
    try {
      isLoadingAccepted.value = true;

      // Clear existing data
      acceptedRentals.clear();

      // Get sewa_aset data with status "DITERIMA"
      final sewaAsetList = await authProvider.getSewaAsetByStatus(['DITERIMA']);

      debugPrint('Fetched ${sewaAsetList.length} accepted sewa_aset records');

      // Process each sewa_aset record
      for (var sewaAset in sewaAsetList) {
        // Get asset details if aset_id is available
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';

        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }

        // Parse waktu mulai and waktu selesai
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';

        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);

          // Format for display
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');

          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);

          // Format based on satuan waktu
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            // For hours, show time range on same day
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            // For days, show date range
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            // Default format
            rentangWaktu = '$jamMulai - $jamSelesai';
          }

          // Full time format for waktuSewa
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }

        // Format price
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }

        // Add to accepted rentals list
        acceptedRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'DITERIMA',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
        });
      }

      debugPrint('Processed ${acceptedRentals.length} accepted rental records');
    } catch (e) {
      debugPrint('Error loading accepted rentals data: $e');
    } finally {
      isLoadingAccepted.value = false;
    }
  }

  Future<void> loadReturnedRentals() async {
    try {
      isLoadingReturned.value = true;
      returnedRentals.clear();
      final sewaAsetList = await authProvider.getSewaAsetByStatus([
        'DIKEMBALIKAN',
      ]);
      for (var sewaAset in sewaAsetList) {
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';
        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';
        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');
          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            rentangWaktu = '$jamMulai - $jamSelesai';
          }
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }
        returnedRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'DIKEMBALIKAN',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
        });
      }
    } catch (e) {
      debugPrint('Error loading returned rentals data: $e');
    } finally {
      isLoadingReturned.value = false;
    }
  }

  Future<void> loadActiveRentals() async {
    try {
      isLoadingActive.value = true;
      activeRentals.clear();
      final sewaAsetList = await authProvider.getSewaAsetByStatus(['AKTIF']);
      for (var sewaAset in sewaAsetList) {
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';
        if (sewaAset['aset_id'] != null) {
          final asetData = await asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';
        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');
          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            rentangWaktu = '$jamMulai - $jamSelesai';
          }
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }
        activeRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': '${sewaAset['durasi'] ?? 0} ${namaSatuanWaktu}',
          'status': sewaAset['status'] ?? 'AKTIF',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
        });
      }
    } catch (e) {
      debugPrint('Error loading active rentals data: $e');
    } finally {
      isLoadingActive.value = false;
    }
  }
}
