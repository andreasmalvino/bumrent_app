import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter/material.dart';
import '../../../data/models/paket_model.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../services/service_manager.dart';
import '../../../services/navigation_service.dart';
import '../../../theme/app_colors.dart';
import '../widgets/custom_date_range_picker.dart';

class OrderSewaPaketController extends GetxController {
  // Dependencies
  final AsetProvider asetProvider = Get.find<AsetProvider>();
  final NavigationService navigationService = ServiceManager.navigationService;

  // State variables
  final paket = Rx<PaketModel?>(null);
  final paketImages = RxList<String>([]);
  final currentPhotoIndex = 0.obs;
  final isLoading = RxBool(true);
  final isPhotosLoading = RxBool(true);
  final paketItems = RxList<Map<String, dynamic>>([]);
  final isPaketItemsLoading = RxBool(true);
  final selectedSatuanWaktu = Rx<Map<String, dynamic>?>(null);
  final selectedDate = RxString('');
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final selectedStartTime = RxInt(-1);
  final selectedEndTime = RxInt(-1);
  final formattedDateRange = RxString('');
  final formattedTimeRange = RxString('');
  final duration = RxInt(0);
  final totalPrice = RxDouble(0.0);
  final kuantitas = RxInt(1);
  final isSubmitting = RxBool(false);

  // Hourly inventory tracking
  final Map<String, Map<int, bool>> hourlyAvailability = {};
  final isLoadingHourlyInventory = RxBool(false);
  final unavailableDatesForHourly = <DateTime>[].obs;
  final bookedHours = RxList<Map<String, dynamic>>([]);
  final selectedHours = RxList<int>([]);

  // Available hours for hourly rental (6 AM to 9 PM)
  final List<int> availableHours = List.generate(16, (index) => index + 6);

  // Format currency
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void onInit() {
    super.onInit();
    // FlutterLogs.logInfo("OrderSewaPaketController", "onInit", "Initializing OrderSewaPaketController");

    // Get the paket ID from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String? paketId =
        args['paketId'] ?? args['id']; // Check for both paketId and id keys
    final dynamic paketData = args['paketData'];

    if (paketId != null) {
      loadPaketData(paketId, paketData);
    } else {
      debugPrint('❌ No paket ID provided in arguments');
      isLoading.value = false;
    }
  }

  // Handle hot reload - restore state if needed
  void handleHotReload() {
    if (paket.value == null) {
      final Map<String, dynamic> args = Get.arguments ?? {};
      final String? paketId = args['id'];

      if (paketId != null) {
        // Try to get from cache first
        final cachedPaket = GetStorage().read('cached_paket_$paketId');
        if (cachedPaket != null) {
          debugPrint('🔄 Hot reload: Restoring paket from cache');
          paket.value = cachedPaket;
          loadPaketPhotos(paketId);
          initializePriceOptions();
        } else {
          loadPaketData(paketId);
        }
      }
    }
  }

  // Load paket data from API or direct argument
  Future<void> loadPaketData(String id, [dynamic directPaketData]) async {
    try {
      isLoading.value = true;
      debugPrint('🔍 Loading paket data for ID: $id');

      // If directPaketData is provided, use it directly
      if (directPaketData != null) {
        debugPrint('✅ Using directly provided paket data');
        processPaketData(id, directPaketData);

        // Load package items even when using direct data
        await loadPaketItems(id);
        return;
      }

      // Otherwise check if we have it in cache
      final cachedPaket = GetStorage().read('cached_paket_$id');
      if (cachedPaket != null) {
        debugPrint('✅ Found cached paket data');
        paket.value = cachedPaket;
        await loadPaketPhotos(id);
        await loadPaketItems(id); // Load package items
        await loadHourlyInventory(id);
        initializePriceOptions();
      } else {
        // Fetch from API
        debugPrint('🔍 Fetching paket data from API for ID: $id');
        final allPakets = await asetProvider.getPakets();
        Map<String, dynamic>? paketData;
        try {
          paketData = allPakets.firstWhere((paket) => paket['id'] == id);
        } catch (e) {
          debugPrint(
            '❌ Paket with ID $id not found in list of ${allPakets.length} pakets',
          );
          paketData = null;
        }
        if (paketData != null) {
          processPaketData(id, paketData);
          await loadPaketItems(id); // Load package items
          await loadHourlyInventory(id);
        } else {
          debugPrint('❌ Failed to load paket data for ID: $id');
          Get.snackbar(
            'Error',
            'Gagal memuat data paket',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading paket data: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data paket',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Process and set the paket data
  Future<void> processPaketData(String id, dynamic rawPaket) async {
    try {
      debugPrint('🔄 Processing paket data for ID: $id');
      debugPrint('📦 Raw paket data type: ${rawPaket.runtimeType}');

      // Initialize loadedPaket with a default value
      late final PaketModel loadedPaket;

      try {
        // Handle Map directly - pakets from getPakets() are always maps
        loadedPaket = PaketModel.fromMap(rawPaket);
        debugPrint('✅ Successfully converted paket to PaketModel');
      } catch (e) {
        debugPrint('❌ Error converting paket map to PaketModel: $e');
        // Fallback using our helper methods
        loadedPaket = PaketModel(
          id: getPaketId(rawPaket),
          nama: getPaketNama(rawPaket),
          deskripsi: getPaketDeskripsi(rawPaket),
          harga: getPaketHarga(rawPaket),
          kuantitas: getPaketKuantitas(rawPaket),
          foto:
              const <
                String
              >[], // Initialize with empty list, will be populated later
          satuanWaktuSewa: getPaketSatuanWaktuSewa(rawPaket),
          foto_paket: getPaketMainPhoto(rawPaket),
          images:
              const <
                String
              >[], // Initialize with empty list, will be populated later
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        debugPrint('✅ Created PaketModel using helper methods');
      }

      // Update the state with the loaded paket
      debugPrint('✅ Loaded paket: ${loadedPaket.nama}');
      paket.value = loadedPaket;

      // Cache for future use
      GetStorage().write('cached_paket_$id', loadedPaket);

      // Load photos for this paket
      await loadPaketPhotos(id);

      // Set initial pricing option
      initializePriceOptions();

      // Ensure we have at least one photo if available
      if (paketImages.isEmpty) {
        String? mainPhoto = getPaketMainPhoto(paket.value);
        if (mainPhoto != null && mainPhoto.isNotEmpty) {
          paketImages.add(mainPhoto);
          debugPrint('✅ Added main paket photo: $mainPhoto');
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing paket data: $e');
      isLoading.value = false;
    }
  }

  // Helper methods to safely access paket properties
  String getPaketId(dynamic paket) {
    if (paket == null) return '';
    try {
      return (paket.id ?? paket['id'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  String getPaketNama(dynamic paket) {
    if (paket == null) return 'Paket Tanpa Nama';
    try {
      return (paket.nama ?? paket['nama'] ?? 'Paket Tanpa Nama').toString();
    } catch (_) {
      return 'Paket Tanpa Nama';
    }
  }

  String getPaketDeskripsi(dynamic paket) {
    if (paket == null) return '';
    try {
      return (paket.deskripsi ?? paket['deskripsi'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  double getPaketHarga(dynamic paket) {
    if (paket == null) return 0.0;
    try {
      var harga = paket.harga ?? paket['harga'] ?? 0.0;
      if (harga is int) return harga.toDouble();
      if (harga is double) return harga;
      return double.tryParse(harga.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  int getPaketKuantitas(dynamic paket) {
    if (paket == null) return 1;
    try {
      var qty = paket.kuantitas ?? paket['kuantitas'] ?? 1;
      return int.tryParse(qty.toString()) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  String getPaketMainPhoto(dynamic paket) {
    if (paket == null) return '';
    try {
      return (paket.foto_paket ?? paket['foto_paket'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  List<Map<String, dynamic>> getPaketSatuanWaktuSewa(dynamic paket) {
    if (paket == null) return const [];
    try {
      final dynamic rawList = paket.satuanWaktuSewa ?? paket['satuanWaktuSewa'];
      if (rawList is List) {
        return rawList.whereType<Map<String, dynamic>>().toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  // Load photos for the paket
  Future<void> loadPaketPhotos(String paketId) async {
    try {
      isPhotosLoading.value = true;
      debugPrint('📷 Loading photos for paket: $paketId');

      final photos = await asetProvider.getFotoPaket(paketId);
      paketImages.clear();

      if (photos.isNotEmpty) {
        // Process each photo URL
        for (var photoUrl in photos) {
          if (photoUrl != null && photoUrl.isNotEmpty) {
            paketImages.add(photoUrl);
          }
        }

        debugPrint('✅ Found ${paketImages.length} photos for paket $paketId');
      }

      // If we got no photos but have a model with a main photo, use that
      if (paketImages.isEmpty && paket.value != null) {
        String? mainPhoto = getPaketMainPhoto(paket.value);
        if (mainPhoto != null && mainPhoto.isNotEmpty) {
          paketImages.add(mainPhoto);
          debugPrint(
            '✅ No photos from API, using main photo as fallback: $mainPhoto',
          );
        }
      }

      // If we still have no photos but have package data with gambar_url, use that
      if (paketImages.isEmpty && paket.value is Map<String, dynamic>) {
        final paketMap = paket.value as Map<String, dynamic>;
        if (paketMap['gambar_url'] != null &&
            paketMap['gambar_url'].toString().isNotEmpty) {
          paketImages.add(paketMap['gambar_url'].toString());
          debugPrint(
            '✅ Using gambar_url as final fallback: ${paketMap['gambar_url']}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading paket photos: $e');
      paketImages.value = [];
    } finally {
      isPhotosLoading.value = false;
    }
  }

  // Load package items with asset details
  Future<void> loadPaketItems(String paketId) async {
    try {
      isPaketItemsLoading.value = true;
      debugPrint('🧩 Loading items for paket: $paketId');

      final items = await asetProvider.getPaketItems(paketId);
      if (items.isNotEmpty) {
        paketItems.value = items;
        debugPrint('✅ Loaded ${paketItems.length} package items');
      }
    } catch (e) {
      debugPrint('❌ Error loading paket items: $e');
      paketItems.value = [];
    } finally {
      isPaketItemsLoading.value = false;
    }
  }

  // Load hourly inventory for all assets in the package
  Future<void> loadHourlyInventory(String paketId) async {
    if (paketItems.isEmpty) {
      // debugPrint('⚠️ Cannot load hourly inventory: No package items available');
      return;
    }

    try {
      isLoadingHourlyInventory.value = true;

      // Print a clear section header
      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // debugPrint('📊 LOADING HOURLY INVENTORY');
      // debugPrint('📦 Package: $paketId | Items: ${paketItems.length}');
      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Reset availability data
      hourlyAvailability.clear();
      unavailableDatesForHourly.clear();

      // Get the current date for checking availability
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('yyyy-MM-dd').format(today);
      // debugPrint('📆 Starting from date: $formattedToday');

      // Initialize availability map for the next 30 days (all hours available by default)
      for (int day = 0; day < 30; day++) {
        final DateTime currentDate = today.add(Duration(days: day));
        final String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);

        hourlyAvailability[dateStr] = {};
        for (int hour = 0; hour < 24; hour++) {
          hourlyAvailability[dateStr]![hour] =
              true; // Initially all hours are available
        }
      }
      // debugPrint('✅ Initialized availability data for 30 days');

      // Process each asset in the package
      int processedAssets = 0;
      int unavailableHoursCount = 0;

      // debugPrint('┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈');
      // debugPrint('🔍 CHECKING ASSET AVAILABILITY');

      // Check each asset in the package for availability
      for (var item in paketItems) {
        final asetId = item['aset_id'];
        final int requiredQuantity = item['kuantitas'] ?? 1;
        processedAssets++;

        if (asetId == null || asetId.isEmpty) {
          // debugPrint('⚠️ Skipping item with missing aset_id');
          continue;
        }

        // debugPrint('🔹 Asset ${processedAssets}/${paketItems.length}: $asetId (needed qty: $requiredQuantity)');

        // Get all bookings for this asset
        try {
          final bookings = await asetProvider.getAsetBookings(
            asetId,
            formattedToday,
          );
          // debugPrint('  📋 Found ${bookings.length} bookings');

          // Process each booking to update availability
          for (var booking in bookings) {
            final String bookingId = booking['id'] ?? '';
            final String status = booking['status'] ?? '';
            final int bookingQuantity = booking['kuantitas'] ?? 1;

            // Skip canceled bookings
            if (status.toLowerCase() == 'dibatalkan') {
              continue;
            }

            // Get start and end date-times
            final String waktuMulaiStr = booking['waktu_mulai'] ?? '';
            final String waktuSelesaiStr = booking['waktu_selesai'] ?? '';

            if (waktuMulaiStr.isEmpty || waktuSelesaiStr.isEmpty) {
              continue;
            }

            try {
              final DateTime waktuMulai = DateTime.parse(waktuMulaiStr);
              final DateTime waktuSelesai = DateTime.parse(waktuSelesaiStr);

              // Get all hours between start and end
              DateTime currentHour = DateTime(
                waktuMulai.year,
                waktuMulai.month,
                waktuMulai.day,
                waktuMulai.hour,
              );

              while (currentHour.isBefore(waktuSelesai) ||
                  currentHour.isAtSameMomentAs(waktuSelesai)) {
                final String dateStr = DateFormat(
                  'yyyy-MM-dd',
                ).format(currentHour);
                final int hour = currentHour.hour;

                // If this date is in our availability map
                if (hourlyAvailability.containsKey(dateStr)) {
                  // Check if the asset quantity would be insufficient
                  final int assetTotalQuantity = await getAssetTotalQuantity(
                    asetId,
                  );
                  final int bookedQuantity = bookingQuantity;

                  // If the booked quantity plus what we need exceeds total, mark as unavailable
                  if (bookedQuantity + requiredQuantity > assetTotalQuantity) {
                    hourlyAvailability[dateStr]![hour] = false;
                    unavailableHoursCount++;

                    // If this date isn't already in our unavailable dates list, add it
                    final DateTime unavailableDate = DateTime(
                      currentHour.year,
                      currentHour.month,
                      currentHour.day,
                    );
                    if (!unavailableDatesForHourly.contains(unavailableDate)) {
                      unavailableDatesForHourly.add(unavailableDate);
                    }
                  }
                }

                currentHour = currentHour.add(const Duration(hours: 1));
              }
            } catch (e) {
              // Just silently skip problematic bookings
              continue;
            }
          }
        } catch (e) {
          // debugPrint('  ❌ Error loading bookings: ${e.toString().split('\n').first}');
          continue;
        }
      }

      // Final summary section
      // debugPrint('┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈');
      // debugPrint('📊 HOURLY INVENTORY SUMMARY');
      // debugPrint('✅ Processed ${paketItems.length} assets');
      // debugPrint('🚫 Found $unavailableHoursCount unavailable hour slots');
      // debugPrint('📅 Found ${unavailableDatesForHourly.length} dates with unavailable hours');
      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      // debugPrint('❌ ERROR: ${e.toString().split('\n').first}');
    } finally {
      isLoadingHourlyInventory.value = false;
    }
  }

  // Get the total quantity of an asset
  Future<int> getAssetTotalQuantity(String asetId) async {
    try {
      final assetData = await asetProvider.getAsetById(asetId);
      if (assetData != null) {
        final int quantity = assetData.kuantitas ?? 0;
        // debugPrint('📊 Asset $asetId total quantity: $quantity');
        return quantity;
      }
    } catch (e) {
      // debugPrint('❌ Error getting asset quantity: $e');
    }
    return 0;
  }

  // Initialize price options
  void initializePriceOptions() {
    if (paket.value == null) return;

    final satuanWaktuSewa = getPaketSatuanWaktuSewa(paket.value);
    if (satuanWaktuSewa.isNotEmpty) {
      // Default to the first option
      selectSatuanWaktu(satuanWaktuSewa.first);
    }
  }

  // Select satuan waktu
  void selectSatuanWaktu(Map<String, dynamic> satuanWaktu) async {
    selectedSatuanWaktu.value = satuanWaktu;

    // Reset date and time selections
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStartTime.value = -1;
    selectedEndTime.value = -1;
    selectedDate.value = '';
    formattedDateRange.value = '';
    formattedTimeRange.value = '';

    // If hourly rental is selected, automatically set today's date
    final namaSatuan = satuanWaktu['nama_satuan_waktu'] ?? '';
    final bool isHourly = !namaSatuan.toString().toLowerCase().contains('hari');

    if (isHourly && paket.value != null) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🕒 HOURLY RENTAL SELECTED');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Set today as the default date
      final now = DateTime.now();
      selectedStartDate.value = now;
      selectedDate.value = DateFormat('yyyy-MM-dd').format(now);
      formattedDateRange.value = DateFormat('d MMMM yyyy').format(now);

      // Immediately load hourly inventory
      if (paket.value != null && paket.value!.id != null) {
        await loadHourlyInventory(paket.value!.id!);
      } else {
        // debugPrint('⚠️ Cannot load hourly inventory: Package ID is null or empty');
      }
    }

    calculateTotalPrice();
  }

  // Check if the rental is daily
  bool isDailyRental() {
    final namaSatuan = selectedSatuanWaktu.value?['nama_satuan_waktu'] ?? '';
    return namaSatuan.toString().toLowerCase().contains('hari');
  }

  // Select date for hourly rental
  void selectDate(DateTime date) {
    selectedStartDate.value = date;
    selectedDate.value = DateFormat('d MMM yyyy', 'id').format(date);
    calculateTotalPrice();
  }

  // Select date range for daily rental
  void selectDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;

    // Format the date range
    final formatter = DateFormat('d MMM yyyy', 'id');
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      formattedDateRange.value = formatter.format(start);
      duration.value = 1; // Same day rental is considered as 1 day
    } else {
      formattedDateRange.value =
          '${formatter.format(start)} - ${formatter.format(end)}';
      // Calculate the difference in days
      duration.value =
          end.difference(start).inDays +
          1; // +1 because both start and end days are inclusive
    }

    selectedDate.value = formatter.format(start);
    calculateTotalPrice();
  }

  // Pick date range using custom date range picker for daily rental
  Future<void> pickDateRange(BuildContext context) async {
    try {
      // Get current date
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      // Create unavailable dates list
      final unavailableDates = <DateTime>[];

      // Add past dates as unavailable
      for (
        DateTime date = DateTime(now.year, now.month, 1);
        !date.isAfter(todayDate);
        date = date.add(const Duration(days: 1))
      ) {
        unavailableDates.add(date);
      }

      // Get initial dates
      DateTime initialStartDate;
      DateTime initialEndDate;

      try {
        initialStartDate =
            selectedStartDate.value ?? todayDate.add(const Duration(days: 1));
        initialEndDate =
            selectedEndDate.value ??
            initialStartDate.add(const Duration(days: 1));
      } catch (e) {
        initialStartDate = todayDate.add(const Duration(days: 1));
        initialEndDate = todayDate.add(const Duration(days: 2));
      }

      // Store error message if needed
      final errorMessageText = RxString('');

      // Show our custom date range picker in a dialog
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Maximum rental days info
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Maksimal waktu sewa: 30 hari',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Obx(
                      () =>
                          errorMessageText.value.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    errorMessageText.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    // Use the custom calendar widget
                    CustomDateRangePicker(
                      disabledDates: unavailableDates,
                      initialStartDate: initialStartDate,
                      initialEndDate: initialEndDate,
                      maxDays: 30, // Default max days
                      onClearSelection: () {
                        // Handle selection clearing
                        debugPrint('🧹 Date range selection cleared by user');
                      },
                      onSelectRange: (start, end) {
                        try {
                          // Clear error message
                          errorMessageText.value = '';

                          final days = end.difference(start).inDays + 1;

                          // Validate maximum days
                          if (days > 30) {
                            errorMessageText.value = 'Maksimal 30 hari sewa';
                            debugPrint('⚠️ Max days exceeded: $days');
                            return;
                          }

                          debugPrint(
                            '📅 Selected date range: ${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)} ($days days)',
                          );

                          // Update the selected date range
                          selectDateRange(start, end);

                          Navigator.of(
                            context,
                          ).pop(true); // Close dialog with success
                        } catch (e) {
                          debugPrint('❌ Error in date range selection: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Handle result if needed
      if (result == true) {
        debugPrint(
          '📅 Date range selected successfully: ${formattedDateRange.value}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error in date range picker: $e');
    }
  }

  // Pick date using custom date picker dialog
  Future<void> pickDate(BuildContext context) async {
    try {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final unavailableDates = <DateTime>[];

      // Add past dates as unavailable
      for (
        DateTime date = DateTime(now.year, now.month, 1);
        date.isBefore(todayDate);
        date = date.add(const Duration(days: 1))
      ) {
        unavailableDates.add(date);
      }

      // Get initial date
      DateTime initialDate;
      try {
        initialDate = selectedStartDate.value ?? todayDate;
      } catch (e) {
        initialDate = todayDate;
      }

      // Show our custom date picker in a dialog
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Use the custom calendar widget for single date selection
                    CustomDateRangePicker(
                      disabledDates: unavailableDates,
                      initialStartDate: initialDate,
                      initialEndDate:
                          initialDate, // For hourly rental, set end date to same as start date
                      singleDateMode:
                          true, // Force single date selection for hourly rentals
                      maxDays: 1, // Limit to 1 day
                      onClearSelection: () {
                        // Handle selection clearing
                        debugPrint('🧹 Date selection cleared by user');
                      },
                      onSelectRange: (start, end) {
                        try {
                          // For hourly rental, we only need the start date
                          debugPrint(
                            '📅 Selected date for hourly rental: ${DateFormat('yyyy-MM-dd').format(start)}',
                          );

                          // Update the selected date
                          updateSelectedDate(start);

                          // Reset time selections
                          selectedStartTime.value = -1;
                          selectedEndTime.value = -1;
                          formattedTimeRange.value = '';
                          duration.value = 0;

                          Navigator.of(
                            context,
                          ).pop(true); // Close dialog with success result
                        } catch (e) {
                          debugPrint('❌ Error in date selection: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Handle result if needed
      if (result == true) {
        debugPrint('📅 Date selected successfully: ${selectedDate.value}');
      }
    } catch (e) {
      debugPrint('❌ Error in date picker: $e');
    }
  }

  // Select time range for hourly rental
  void selectTimeRange(int start, int end) {
    selectedStartTime.value = start;
    selectedEndTime.value = end;

    // Format the time range
    final startTime = '$start:00';
    final endTime = '$end:00';
    formattedTimeRange.value = '$startTime - $endTime';

    // Calculate duration in hours
    duration.value = end - start;

    calculateTotalPrice();
  }

  // Check if an hour should be disabled (unavailable)
  bool isHourDisabled(int hour) {
    // Always check if the hour is in the past
    if (isHourInPast(hour)) {
      return true;
    }

    // If no date selected, disable all hours
    if (selectedStartDate.value == null) {
      return true;
    }

    // Get the current date in yyyy-MM-dd format
    final String formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(selectedStartDate.value!);

    // Check if we have availability data for this date
    if (!hourlyAvailability.containsKey(formattedDate)) {
      // For future dates with no data, assume all hours are available
      final now = DateTime.now();
      final selectedDate = selectedStartDate.value!;

      // If the selected date is today or in the future
      if (selectedDate.isAfter(now) ||
          (selectedDate.year == now.year &&
              selectedDate.month == now.month &&
              selectedDate.day == now.day)) {
        debugPrint(
          '✅ No availability data for future date $formattedDate - defaulting to available',
        );
        return false; // Not disabled
      } else {
        debugPrint(
          '⚠️ No availability data for past date $formattedDate - defaulting to disabled',
        );
        return true;
      }
    }

    // Get the availability for this hour
    if (!hourlyAvailability[formattedDate]!.containsKey(hour)) {
      // Default to available if we don't have specific data for this hour
      debugPrint(
        '✅ No availability data for hour $hour - defaulting to available',
      );
      return false; // Not disabled
    }

    // Return the stored availability (false = disabled/unavailable)
    final bool isAvailable = hourlyAvailability[formattedDate]![hour]!;

    debugPrint('🕒 Hour $hour availability: $isAvailable on $formattedDate');
    return !isAvailable;
  }

  // Check if an hour is in the past
  bool isHourInPast(int hour) {
    // If no date selected, we can't determine if it's in the past
    if (selectedStartDate.value == null) return false;

    final DateTime now = DateTime.now();
    final DateTime selectedDateTime = DateTime(
      selectedStartDate.value!.year,
      selectedStartDate.value!.month,
      selectedStartDate.value!.day,
      hour,
    );

    return selectedDateTime.isBefore(now);
  }

  // Select a date and update availability for that date
  Future<void> updateSelectedDate(DateTime date) async {
    debugPrint('📅 Selecting date: ${DateFormat('yyyy-MM-dd').format(date)}');

    // Update the selected date
    selectedStartDate.value = date;
    selectedDate.value = DateFormat('yyyy-MM-dd').format(date);

    // For hourly rentals, set the end date to the same day
    if (!isDailyRental()) {
      selectedEndDate.value = date;
      formattedDateRange.value = DateFormat('d MMMM yyyy').format(date);
    }

    // Reset time selections
    selectedStartTime.value = -1;
    selectedEndTime.value = -1;
    formattedTimeRange.value = '';
    duration.value = 0;

    // Refresh hourly inventory data if we're in hourly rental mode
    if (!isDailyRental() && paket.value != null) {
      debugPrint('🕐 Refreshing hourly inventory for selected date');
      await loadHourlyInventory(paket.value?.id ?? '');
    }

    // Recalculate price
    calculateTotalPrice();
  }

  // Select a specific time from the grid
  void selectTime(int hour) {
    if (hour < 0 || hour > 23) {
      debugPrint('❌ Invalid hour: $hour');
      return;
    }

    // Only continue if we have a date selected
    if (selectedStartDate.value == null) {
      debugPrint('⚠️ Cannot select time: No date selected');
      return;
    }

    // Check if this hour is available
    if (isHourDisabled(hour)) {
      debugPrint('❌ Cannot select hour $hour: It is disabled/unavailable');
      Get.snackbar(
        'Waktu Tidak Tersedia',
        'Jam ini tidak tersedia karena ada aset dalam paket yang sudah dipesan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // If this hour is already selected, deselect it
    if (selectedStartTime.value == hour) {
      selectedStartTime.value = -1;
      selectedEndTime.value = -1;
      formattedTimeRange.value = '';
      calculateTotalPrice();
      return;
    }

    // Otherwise select it
    selectedStartTime.value = hour;
    selectedEndTime.value = hour + 1; // Default to 1 hour

    // Update formatted time range
    formattedTimeRange.value = '$hour:00 - ${hour + 1}:00';

    // Recalculate price
    calculateTotalPrice();
  }

  // Check if a time is selected (either as start or end time)
  bool isTimeSelected(int hour) {
    return selectedStartTime.value == hour || selectedEndTime.value == hour;
  }

  // Check if a time is in the selected range (between start and end, not inclusive)
  bool isTimeInRange(int hour) {
    return selectedStartTime.value >= 0 &&
        selectedEndTime.value >= 0 &&
        hour > selectedStartTime.value &&
        hour < selectedEndTime.value;
  }

  // Calculate total price
  void calculateTotalPrice() {
    if (selectedSatuanWaktu.value == null) {
      totalPrice.value = 0.0;
      return;
    }

    final basePrice =
        double.tryParse(selectedSatuanWaktu.value!['harga'].toString()) ?? 0.0;

    if (isDailyRental()) {
      if (selectedStartDate.value != null && selectedEndDate.value != null) {
        final days =
            selectedEndDate.value!.difference(selectedStartDate.value!).inDays +
            1;
        totalPrice.value = basePrice * days;
      } else {
        totalPrice.value = basePrice;
      }
    } else {
      if (selectedStartTime.value >= 0 && selectedEndTime.value >= 0) {
        final hours = selectedEndTime.value - selectedStartTime.value;
        totalPrice.value = basePrice * hours;
      } else {
        totalPrice.value = basePrice;
      }
    }

    // Multiply by quantity
    totalPrice.value *= kuantitas.value;
  }

  // Format price as currency
  String formatPrice(double price) {
    return currencyFormat.format(price);
  }

  // Submit order
  Future<void> submitOrder() async {
    try {
      if (paket.value == null || selectedSatuanWaktu.value == null) {
        Get.snackbar(
          'Error',
          'Data paket tidak lengkap',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if ((isDailyRental() &&
              (selectedStartDate.value == null ||
                  selectedEndDate.value == null)) ||
          (!isDailyRental() &&
              (selectedStartDate.value == null ||
                  selectedStartTime.value < 0 ||
                  selectedEndTime.value < 0))) {
        Get.snackbar(
          'Error',
          'Silakan pilih waktu sewa',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSubmitting.value = true;

      // Prepare order data
      final Map<String, dynamic> orderData = {
        'id_paket': paket.value!.id,
        'id_satuan_waktu_sewa': selectedSatuanWaktu.value!['id'],
        'tanggal_mulai': selectedStartDate.value!.toIso8601String(),
        'tanggal_selesai':
            selectedEndDate.value?.toIso8601String() ??
            selectedStartDate.value!.toIso8601String(),
        'jam_mulai': isDailyRental() ? null : selectedStartTime.value,
        'jam_selesai': isDailyRental() ? null : selectedEndTime.value,
        'total_harga': totalPrice.value,
        'kuantitas': kuantitas.value,
      };

      // Submit the order using AsetProvider's orderPaket method
      final userId = GetStorage().read('user_id') ?? '';
      final result = await asetProvider.orderPaket(
        userId: userId,
        paketId: orderData['id_paket'],
        satuanWaktuSewaId: orderData['id_satuan_waktu'],
        durasi: orderData['durasi'] ?? 1, // Default to 1 if not provided
        totalHarga: orderData['total_harga'].toInt(),
      );

      // Create a mock result for navigation
      final resultData = {
        'id': 'order_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'PENDING',
      };

      if (result != null) {
        Get.snackbar(
          'Sukses',
          'Pesanan berhasil dibuat',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to payment page
        if (result && resultData != null && resultData['id'] != null) {
          navigationService.navigateToPembayaranSewa(
            resultData['id'].toString(),
          );
        } else if (result) {
          // If result is true but we don't have an ID, navigate back to sewa aset
          navigationService.navigateToSewaAset();
          Get.snackbar(
            'Error',
            'Gagal mendapatkan ID pesanan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Gagal membuat pesanan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Gagal membuat pesanan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error submitting order: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Handle back button press
  void onBackPressed() {
    navigationService.navigateToSewaAset();
  }

  // Get paket images from the paket model or fallback to a default list
  List<String> getPaketImages(dynamic paket) {
    if (paket == null) return [];

    debugPrint('🔍 Getting images for paket: ${paket.runtimeType}');

    // Check if we already have loaded images in the RxList
    if (paketImages.isNotEmpty) {
      debugPrint('✅ Using ${paketImages.length} already loaded images');
      return paketImages.toList();
    }

    // If it's already a PaketModel with images
    if (paket is PaketModel) {
      if (paket.images != null && paket.images!.isNotEmpty) {
        debugPrint(
          '✅ Using ${paket.images!.length} images from PaketModel.images',
        );
        return paket.images!;
      }
      // Check for foto_paket (main photo)
      if (paket.foto_paket != null && paket.foto_paket!.isNotEmpty) {
        debugPrint(
          '✅ Using main photo from PaketModel.foto_paket: ${paket.foto_paket}',
        );
        return [paket.foto_paket!];
      }
    }

    // If it's a Map, try to extract images
    if (paket is Map<String, dynamic>) {
      debugPrint(
        '📝 Extracting images from map with keys: ${paket.keys.join(', ')}',
      );

      // First try the images array
      if (paket['images'] != null && paket['images'] is List) {
        final imageList = List<String>.from(paket['images']);
        debugPrint('✅ Found ${imageList.length} images in paket["images"]');
        return imageList;
      }

      // Try gambar_url (commonly used in the app)
      if (paket['gambar_url'] != null &&
          paket['gambar_url'].toString().isNotEmpty) {
        debugPrint('✅ Using gambar_url: ${paket['gambar_url']}');
        return [paket['gambar_url'].toString()];
      }

      // Try foto_paket
      if (paket['foto_paket'] != null &&
          paket['foto_paket'].toString().isNotEmpty) {
        debugPrint('✅ Using foto_paket: ${paket['foto_paket']}');
        return [paket['foto_paket'].toString()];
      }
    }

    debugPrint('❌ No images found for paket');
    return [];
  }

  // Open image gallery to view full-size images
  void openImageGallery(
    BuildContext context,
    List<dynamic> images,
    int initialIndex,
  ) {
    if (images.isEmpty) return;

    // Convert all images to strings
    final List<String> imageUrls = images.map((img) => img.toString()).toList();

    // Show dialog with gallery
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.black.withOpacity(0.9),
            child: Stack(
              children: [
                // Image display
                PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Get formatted duration string based on selected dates/times
  String getFormattedDuration() {
    if (selectedSatuanWaktu.value == null) {
      return '-';
    }

    if (isDailyRental()) {
      if (selectedStartDate.value != null && selectedEndDate.value != null) {
        final days =
            selectedEndDate.value!.difference(selectedStartDate.value!).inDays +
            1;
        return '$days hari';
      }
      return '-';
    } else {
      if (selectedStartTime.value >= 0 && selectedEndTime.value >= 0) {
        final hours = selectedEndTime.value - selectedStartTime.value;
        return '$hours jam';
      }
      return '-';
    }
  }

  // Get formatted selected date for display
  String get formattedSelectedDate {
    if (selectedStartDate.value == null) {
      return 'Pilih tanggal';
    }

    final formatter = DateFormat('EEEE, d MMMM yyyy', 'id');
    if (isDailyRental() && selectedEndDate.value != null) {
      final startStr = formatter.format(selectedStartDate.value!);
      final endStr = formatter.format(selectedEndDate.value!);
      return '$startStr - $endStr';
    } else {
      return formatter.format(selectedStartDate.value!);
    }
  }

  // Show time selection dialog
  Future<void> showTimeSelectionDialog(BuildContext context) async {
    if (selectedStartDate.value == null) {
      Get.snackbar(
        'Peringatan',
        'Pilih tanggal terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Predefined time slots from 7 AM to 9 PM
    final List<int> availableStartTimes = List.generate(
      15,
      (index) => index + 7,
    ); // 7 AM to 9 PM

    int? selectedStart;
    int? selectedEnd;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Pilih Waktu Sewa'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Jam Mulai'),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          availableStartTimes.length -
                          1, // Exclude last time as start time
                      itemBuilder: (context, index) {
                        final time = availableStartTimes[index];
                        return ListTile(
                          title: Text('$time:00'),
                          onTap: () {
                            selectedStart = time;
                            // Auto-select end time as start + 1 hour initially
                            selectedEnd = time + 1;
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    if (selectedStart != null && selectedEnd != null) {
      // Show end time selection
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Pilih Jam Selesai'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Jam Selesai (setelah ${selectedStart!}:00)'),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableStartTimes.length - selectedStart!,
                        itemBuilder: (context, index) {
                          final time =
                              selectedStart! +
                              index +
                              1; // Start from selected + 1
                          return ListTile(
                            title: Text('$time:00'),
                            onTap: () {
                              selectedEnd = time;
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      if (selectedEnd != null && selectedStart != null) {
        selectTimeRange(selectedStart!, selectedEnd!);
      }
    }
  }
}
