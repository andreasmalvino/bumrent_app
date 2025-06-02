import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../../../data/models/aset_model.dart';
import '../../../data/models/foto_aset_model.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../services/navigation_service.dart';
import '../../../services/service_manager.dart';
import '../widgets/custom_date_range_picker.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class OrderSewaAsetController extends GetxController {
  // Dependency injection melalui Get.find
  final AsetProvider asetProvider = Get.find<AsetProvider>();
  final AuthProvider authProvider = Get.find<AuthProvider>();

  // Use Rx for NavigationService to ensure it's always available, even after hot reload
  final Rx<NavigationService?> _navigationService = Rx<NavigationService?>(
    null,
  );

  // Getter for navigation service with auto-recovery capability
  NavigationService get navigationService {
    // If navigation service is null, try to find it
    if (_navigationService.value == null) {
      try {
        // Try to find existing instance
        if (Get.isRegistered<NavigationService>()) {
          _navigationService.value = Get.find<NavigationService>();
          debugPrint('✅ Found existing NavigationService instance');
        } else {
          // Create a new instance if not found
          _navigationService.value = Get.put(NavigationService());
          debugPrint('✅ Created new NavigationService instance');
        }
      } catch (e) {
        debugPrint('⚠️ Error accessing NavigationService: $e');
        // Create a temporary instance as fallback
        _navigationService.value = NavigationService();
      }
    }
    return _navigationService.value!;
  }

  final box = GetStorage();

  // Asset data
  final aset = Rx<AsetModel?>(null);
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Store the asset ID to retrieve it after hot reload
  final asetId = RxString('');

  // Asset photos data
  final assetPhotos = <FotoAsetModel>[].obs;
  final currentPhotoIndex = 0.obs;
  final isPhotosLoading = false.obs;

  // Booking data
  final selectedSatuanWaktu = Rx<Map<String, dynamic>?>(null);
  final duration = 1.obs;
  final totalPrice = 0.obs;

  // Unit quantity data
  final jumlahUnit = 1.obs;
  final maxUnit = 1.obs;

  // Date and time selection
  final selectedDate = ''.obs;
  final startHour = RxInt(-1);
  final endHour = RxInt(-1);
  final formattedTimeRange = ''.obs;
  final DateTime now = DateTime.now();

  // Date range for daily rental
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final formattedDateRange = ''.obs;
  final bookedDates = <DateTime>[].obs;
  final isLoadingBookedDates = false.obs;
  final maxDayLimit = RxInt(
    0,
  ); // Maximum allowed rental days from maksimal_waktu

  // Available hours and booked hours
  final availableHours = <int>[].obs;
  final RxList<Map<String, dynamic>> bookedHours = <Map<String, dynamic>>[].obs;
  final RxList<int> selectedHours = <int>[].obs;
  final RxList<int> bookedHoursList = <int>[].obs;
  final isLoadingBookings = false.obs;

  // New hourly inventory tracking
  final Map<String, Map<int, int>> hourlyInventory =
      <String, Map<int, int>>{}.obs;
  final unavailableDatesForHourly = <DateTime>[].obs;

  // Static method for navigation (moved to NavigationService)
  static Future<void> navigateToOrderPage(String asetId) async {
    try {
      // Use ServiceManager to get NavigationService instead of direct Get.find
      ServiceManager.navigationService.toOrderSewaAset(asetId);
      debugPrint('✅ Successfully navigated to order page via ServiceManager');
    } catch (e) {
      debugPrint('⚠️ Error in navigateToOrderPage: $e');
      // Fallback direct navigation
      Get.toNamed(
        '/warga/order-sewa-aset',
        arguments: {'asetId': asetId},
        preventDuplicates: false,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 OrderSewaAsetController: onInit called');

    // Ensure navigation service is available - use ServiceManager instead of direct Get.find
    try {
      // Use ServiceManager's navigationService getter instead of trying to access it directly
      _navigationService.value = ServiceManager.navigationService;
      debugPrint('✅ Obtained NavigationService via ServiceManager in onInit');
    } catch (e) {
      debugPrint('⚠️ Error setting up NavigationService: $e');
      // Create a new instance as fallback
      _navigationService.value = NavigationService();
      Get.put(_navigationService.value!);
    }

    // Initialize unavailable dates collection
    unavailableDatesForHourly.clear();

    _initializeController();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('🚀 OrderSewaAsetController: onReady called');

    // Check if there was an error during initialization or loading aset data
    if (hasError.value) {
      debugPrint('⚠️ Showing error from onReady: ${errorMessage.value}');
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }

    // If we don't have an asset yet but we have an ID stored, load it
    if (aset.value == null && asetId.value.isNotEmpty) {
      debugPrint('🔄 Loading asset data from onReady with ID: ${asetId.value}');
      loadAsetData(asetId.value);
    }
    // If we still don't have an asset and no error is set, go back to the previous screen
    else if (aset.value == null &&
        !hasError.value &&
        isLoading.value == false) {
      debugPrint(
        '⚠️ No asset loaded and no error - returning to previous screen',
      );
      Future.microtask(() {
        navigationService.backFromOrderSewaAset();
        Get.snackbar(
          'Info',
          'Tidak dapat menampilkan aset - data tidak tersedia',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }

  @override
  void onClose() {
    // Bersihkan resource yang tidak diperlukan lagi
    debugPrint('🧹 OrderSewaAsetController: onClose called');

    // Simpan ID aset ke storage agar bisa di-load kembali setelah hot reload
    if (asetId.value.isNotEmpty) {
      box.write('current_aset_id', asetId.value);
      debugPrint('💾 Saved asetId to GetStorage: ${asetId.value}');
    }

    super.onClose();
  }

  // Method ini digunakan untuk menghandle hotreload
  void handleHotReload() {
    debugPrint('🔥 Hot reload detected in OrderSewaAsetController');
    // Jika aset belum di-load tapi ID ada di storage, maka load ulang
    if (aset.value == null) {
      String? storedId;

      // Coba dapatkan ID dari arguments terlebih dahulu
      final args = Get.arguments;
      if (args != null && args.containsKey('asetId')) {
        storedId = args['asetId'] as String?;
        debugPrint('📦 Found asetId in arguments after hot reload: $storedId');
      }

      // Jika tidak ada di arguments, cek di GetStorage
      if ((storedId == null || storedId.isEmpty) &&
          box.hasData('current_aset_id')) {
        storedId = box.read<String>('current_aset_id');
        debugPrint('📦 Found asetId in GetStorage after hot reload: $storedId');
      }

      if (storedId != null && storedId.isNotEmpty) {
        debugPrint(
          '🔄 Reloading asset data with ID after hot reload: $storedId',
        );
        asetId.value = storedId;

        // Tambahkan delay kecil untuk memastikan controller sudah siap
        Future.delayed(const Duration(milliseconds: 100), () {
          loadAsetData(storedId!);
        });
      } else {
        debugPrint('⚠️ No asetId found after hot reload');
      }
    } else {
      debugPrint('✅ Asset already loaded, no need to reload after hot reload');
    }
  }

  void _initializeController() {
    // Get asset ID from arguments
    final args = Get.arguments;
    debugPrint('📌 Arguments received in controller: $args');

    String? newAsetId;
    if (args != null && args.containsKey('asetId')) {
      newAsetId = args['asetId'] as String?;
      debugPrint('📌 Asset ID from arguments: $newAsetId');

      // Simpan ID ke storage segera setelah menerimanya dari arguments
      if (newAsetId != null && newAsetId.isNotEmpty) {
        box.write('current_aset_id', newAsetId);
        debugPrint('💾 Immediately saved asetId to GetStorage: $newAsetId');
      }
    }

    // Try to get asetId from GetStorage if not in arguments
    if ((newAsetId == null || newAsetId.isEmpty) &&
        box.hasData('current_aset_id')) {
      newAsetId = box.read('current_aset_id');
      debugPrint('📌 Asset ID from GetStorage: $newAsetId');
    }

    if (newAsetId != null && newAsetId.isNotEmpty) {
      debugPrint('📌 Using asset ID: $newAsetId');
      asetId.value = newAsetId;
      debugPrint('🔄 Loading asset data with ID: ${asetId.value}');
      loadAsetData(asetId.value);
    } else {
      debugPrint('❌ No asset ID available - returning to previous screen');
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'ID aset tidak ditemukan';
      // Don't navigate back here, let onReady handle it
    }

    // Initialize default date (today)
    final now = DateTime.now();
    selectedDate.value = DateFormat('dd MMMM yyyy', 'id_ID').format(now);
    debugPrint('📅 Initial selected date: ${selectedDate.value}');

    // Initialize available hours (6:00 to 21:00)
    availableHours.clear();
    for (int i = 6; i <= 21; i++) {
      availableHours.add(i);
    }
  }

  // Method untuk load data aset
  Future<void> loadAsetData(String id) async {
    if (id.isEmpty) {
      debugPrint('❌ Cannot load asset: ID is empty');
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'ID aset tidak valid';
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      debugPrint('🔄 Loading asset data with ID: $id');

      // Simpan ID aset saat ini ke storage
      asetId.value = id;
      box.write('current_aset_id', id);
      debugPrint(
        '💾 Saved current asetId to GetStorage during loadAsetData: $id',
      );

      // Get asset data
      final loadedAset = await asetProvider.getAsetById(id);

      if (loadedAset != null) {
        aset.value = loadedAset;
        debugPrint('✅ Asset loaded successfully: ${loadedAset.nama}');

        // Set max unit to total quantity of the asset
        maxUnit.value = loadedAset.kuantitas ?? 1;
        debugPrint(
          '📊 Set max unit to: ${maxUnit.value} (total available: ${loadedAset.kuantitas ?? 0}, used: ${loadedAset.kuantitasTerpakai ?? 0})',
        );

        // Load asset photos
        await loadAssetPhotos(id);

        // Load all bookings for the next 30 days to initialize availability data
        await loadAllBookings();

        // Find and select hourly option by default if exists
        final hourlyOption = loadedAset.satuanWaktuSewa.firstWhereOrNull(
          (element) =>
              element['nama_satuan_waktu']?.toString().toLowerCase().contains(
                'jam',
              ) ??
              false,
        );

        if (hourlyOption != null) {
          debugPrint(
            '✅ Selected hourly option: ${hourlyOption['nama_satuan_waktu']}',
          );
          selectSatuanWaktu(hourlyOption);
        } else if (loadedAset.satuanWaktuSewa.isNotEmpty) {
          // Otherwise select the first option if any exist
          debugPrint(
            '✅ Selected first available option: ${loadedAset.satuanWaktuSewa[0]['nama_satuan_waktu']}',
          );
          selectSatuanWaktu(loadedAset.satuanWaktuSewa[0]);
        }
      } else {
        debugPrint('❌ Asset with ID $id not found');
        hasError.value = true;
        errorMessage.value = 'Aset tidak ditemukan';
      }
    } catch (e) {
      debugPrint('❌ Error loading asset: $e');
      hasError.value = true;
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Ketika tombol back pada halaman order-sewa-aset ditekan
  void onBackPressed() {
    debugPrint('🔙 Back button pressed in OrderSewaAsetView');

    try {
      // Try to use the navigation service
      navigationService.backFromOrderSewaAset();
    } catch (e) {
      debugPrint('⚠️ Error using navigation service: $e');
      // Fallback to direct navigation
      Get.back();
    }
  }

  // Format price with IDR currency
  String formatPrice(int price) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return currencyFormatter.format(price);
  }

  // Format hour as string (e.g., "06:00")
  String formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  // Load photos for the asset
  Future<void> loadAssetPhotos(String asetId) async {
    try {
      isPhotosLoading.value = true;
      debugPrint('🔄 Loading photos for asset $asetId');

      final photos = await asetProvider.getAsetPhotos(asetId);
      assetPhotos.value = photos;

      debugPrint('✅ Loaded ${photos.length} photos for asset');
    } catch (e) {
      debugPrint('❌ Error loading asset photos: $e');
      hasError.value = true;
      errorMessage.value = 'Gagal memuat foto aset: ${e.toString()}';
    } finally {
      isPhotosLoading.value = false;
    }
  }

  // Move to next photo
  void nextPhoto() {
    if (assetPhotos.isEmpty) return;
    if (currentPhotoIndex.value < assetPhotos.length - 1) {
      currentPhotoIndex.value++;
    } else {
      currentPhotoIndex.value = 0; // Loop back to first photo
    }
  }

  // Move to previous photo
  void previousPhoto() {
    if (assetPhotos.isEmpty) return;
    if (currentPhotoIndex.value > 0) {
      currentPhotoIndex.value--;
    } else {
      currentPhotoIndex.value = assetPhotos.length - 1; // Loop to last photo
    }
  }

  // Get current photo URL
  String? getCurrentPhotoUrl() {
    if (assetPhotos.isEmpty) {
      return aset.value?.imageUrl;
    }
    return assetPhotos[currentPhotoIndex.value].fotoAset;
  }

  // Load bookings for the selected date and calculate availability across dates and times
  Future<void> loadBookingsForDate(DateTime date) async {
    try {
      isLoadingBookings(true);

      // Clear selections and booked hours
      selectedHours.clear();
      bookedHours.clear();
      bookedHoursList.clear();

      // Format date for API
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      debugPrint(
        '🔍 Loading bookings for date: $date (formatted: $formattedDate)',
      );

      // Get bookings from server
      final bookings = await asetProvider.getAsetBookings(
        aset.value!.id,
        formattedDate,
      );

      // Update the bookedHours list for reference
      bookedHours.assignAll(bookings);
      debugPrint(
        '📆 Loaded ${bookings.length} bookings for $formattedDate and related days',
      );

      // Initialize a range of dates to check (30 days from now)
      Map<String, Map<int, int>> fullInventory = {};
      final int totalAssetQuantity = aset.value?.kuantitas ?? 0;
      final DateTime today = DateTime.now();

      // Initialize inventory for next 30 days, each with hours 0-23
      for (int day = 0; day < 30; day++) {
        final DateTime currentDate = today.add(Duration(days: day));
        final String currentDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(currentDate);

        // Initialize inventory for each hour of this day with full quantity
        Map<int, int> dayInventory = {};
        for (int hour = 0; hour < 24; hour++) {
          dayInventory[hour] = totalAssetQuantity;
        }

        fullInventory[currentDateStr] = dayInventory;
      }

      debugPrint('📊 INVENTORY - INITIAL STATE:');
      debugPrint('------------------------------------');
      debugPrint('Total asset quantity: $totalAssetQuantity');
      debugPrint('Days initialized: ${fullInventory.length}');
      debugPrint('------------------------------------');

      // Process all bookings to adjust inventory across dates and times
      if (bookings.isNotEmpty) {
        debugPrint(
          '🔢 Processing ${bookings.length} bookings to calculate inventory:',
        );

        // Process each booking and adjust inventory
        for (var booking in bookings) {
          final String bookingId = booking['id'] ?? '';
          final String status = booking['status'] ?? '';
          final int bookingQuantity = booking['kuantitas'] ?? 1;

          // Get start and end date-times
          final String waktuMulaiStr = booking['waktu_mulai'] ?? '';
          final String waktuSelesaiStr = booking['waktu_selesai'] ?? '';

          if (waktuMulaiStr.isEmpty || waktuSelesaiStr.isEmpty) {
            debugPrint(
              '⚠️ Booking ID $bookingId has invalid timestamps, skipping',
            );
            continue;
          }

          try {
            final DateTime waktuMulai = DateTime.parse(waktuMulaiStr);
            final DateTime waktuSelesai = DateTime.parse(waktuSelesaiStr);

            debugPrint('🔎 Processing booking ID: $bookingId');
            debugPrint(
              '  - Period: ${DateFormat('yyyy-MM-dd HH:mm').format(waktuMulai)} to ${DateFormat('yyyy-MM-dd HH:mm').format(waktuSelesai)}',
            );
            debugPrint('  - Status: $status, Quantity: $bookingQuantity');

            // Calculate the end time for inventory restoration (1 hour after booking ends)
            final DateTime inventoryRestorationTime = waktuSelesai.add(
              const Duration(hours: 1),
            );

            // Calculate all date-hour combinations in the booking range
            final List<DateTime> allDateHours = [];

            // Add all hours from start to end
            DateTime currentHour = DateTime(
              waktuMulai.year,
              waktuMulai.month,
              waktuMulai.day,
              waktuMulai.hour,
            );

            while (!currentHour.isAfter(waktuSelesai)) {
              allDateHours.add(currentHour);
              currentHour = currentHour.add(const Duration(hours: 1));
            }

            debugPrint('  - Total hours in booking: ${allDateHours.length}');

            // Process each hour in the booking range to reduce inventory
            for (DateTime dateHour in allDateHours) {
              final String dateStr = DateFormat('yyyy-MM-dd').format(dateHour);
              final int hour = dateHour.hour;

              // Skip if outside our initialized inventory range
              if (!fullInventory.containsKey(dateStr)) {
                continue;
              }

              // Reduce inventory for this hour
              if (fullInventory[dateStr]!.containsKey(hour)) {
                final int previousQty = fullInventory[dateStr]![hour]!;
                fullInventory[dateStr]![hour] = previousQty - bookingQuantity;

                debugPrint(
                  '📉 $dateStr Hour $hour: DECREASED inventory from $previousQty to ${fullInventory[dateStr]![hour]} (by $bookingQuantity)',
                );
              }
            }

            // Handle inventory restoration one hour after booking ends
            final String restorationDateStr = DateFormat(
              'yyyy-MM-dd',
            ).format(inventoryRestorationTime);
            final int restorationHour = inventoryRestorationTime.hour;

            // Verify this restoration point is in our initialized inventory
            if (fullInventory.containsKey(restorationDateStr) &&
                fullInventory[restorationDateStr]!.containsKey(
                  restorationHour,
                )) {
              // Don't increase above the total asset quantity
              final int currentInventory =
                  fullInventory[restorationDateStr]![restorationHour]!;
              final int newInventory = math.min(
                currentInventory + bookingQuantity,
                totalAssetQuantity,
              );

              fullInventory[restorationDateStr]![restorationHour] =
                  newInventory;

              debugPrint(
                '📈 $restorationDateStr Hour $restorationHour: INCREASED inventory from $currentInventory to $newInventory (by $bookingQuantity)',
              );
            }
          } catch (e) {
            debugPrint('❌ Error processing booking $bookingId: $e');
          }
        }
      } else {
        debugPrint('✅ No bookings found affecting the selected date');
      }

      // Store the inventory in our controller
      hourlyInventory.clear();
      hourlyInventory.addAll(fullInventory);

      // Now determine which hours are available for the selected date
      if (hourlyInventory.containsKey(formattedDate)) {
        final dayInventory = hourlyInventory[formattedDate]!;

        // Debug output of inventory status for this date
        debugPrint('📊 INVENTORY STATUS FOR $formattedDate:');
        debugPrint('------------------------------------');
        debugPrint('Requested quantity: ${jumlahUnit.value}');

        // Business hours (typically 6-21)
        List<int> businessHours = List.generate(16, (index) => index + 6);

        // Count available vs unavailable hours
        int availableHoursCount = 0;
        int unavailableHoursCount = 0;

        for (int hour in businessHours) {
          final int availableQty =
              dayInventory.containsKey(hour) ? dayInventory[hour]! : 0;
          final bool isAvailable = availableQty >= jumlahUnit.value;
          final String status = isAvailable ? "✅ AVAILABLE" : "❌ UNAVAILABLE";

          debugPrint(
            'Hour ${formatHour(hour)}: $availableQty/$totalAssetQuantity units - $status',
          );

          if (isAvailable) {
            availableHoursCount++;
          } else {
            unavailableHoursCount++;
            bookedHoursList.add(hour); // Mark this hour as unavailable
          }
        }

        debugPrint('------------------------------------');
        debugPrint(
          'Summary: $availableHoursCount hours available, $unavailableHoursCount hours unavailable',
        );

        // If all business hours are unavailable, add this date to unavailable dates list
        if (availableHoursCount == 0) {
          final DateTime unavailableDate = DateFormat(
            'yyyy-MM-dd',
          ).parse(formattedDate);
          if (!unavailableDatesForHourly.contains(unavailableDate)) {
            unavailableDatesForHourly.add(unavailableDate);
            debugPrint(
              '🚫 Date $formattedDate FULLY BOOKED - Adding to unavailable dates',
            );
          }
        }
      }

      // Calculate and display fully booked dates (helpful for debugging)
      List<String> fullyBookedDates = [];

      // Check all days in our inventory
      for (String dateStr in hourlyInventory.keys) {
        final Map<int, int> dayInventory = hourlyInventory[dateStr]!;

        // Business hours (typically 6-21)
        List<int> businessHours = List.generate(16, (index) => index + 6);

        // Check if all business hours are unavailable
        bool anyHourAvailable = false;
        for (int hour in businessHours) {
          if (dayInventory.containsKey(hour)) {
            final int availableQty = dayInventory[hour]!;
            if (availableQty >= jumlahUnit.value) {
              anyHourAvailable = true;
              break;
            }
          }
        }

        if (!anyHourAvailable) {
          fullyBookedDates.add(dateStr);

          // Add to unavailable dates if not already there
          final DateTime unavailableDate = DateFormat(
            'yyyy-MM-dd',
          ).parse(dateStr);
          if (!unavailableDatesForHourly.contains(unavailableDate)) {
            unavailableDatesForHourly.add(unavailableDate);
          }
        }
      }

      debugPrint('🗓️ Fully booked dates: ${fullyBookedDates.join(", ")}');
      debugPrint(
        '🗓️ Total unavailable dates: ${unavailableDatesForHourly.length}',
      );
    } catch (e) {
      debugPrint('❌ Error loading bookings: $e');
    } finally {
      isLoadingBookings(false);
    }
  }

  // Select a time unit (e.g., hourly or daily)
  void selectSatuanWaktu(Map<String, dynamic> satuan) {
    final bool wasDaily = isDailyRental();
    final bool willBeDaily =
        satuan['nama_satuan_waktu']?.toString().toLowerCase().contains(
          'hari',
        ) ??
        false;

    // Reset duration and total price before changing selected satuan waktu
    duration.value = 0;
    totalPrice.value = 0;

    selectedSatuanWaktu.value = satuan;

    // Set the maximum day limit based on maksimal_waktu
    maxDayLimit.value = satuan['maksimal_waktu'] ?? 0;
    debugPrint('🕒 Set maximum day limit to: ${maxDayLimit.value} days');
    debugPrint('💲 Reset duration to 0 and total price to 0');

    // Reset selections when switching between hourly and daily
    if (willBeDaily) {
      // Reset hourly selections
      startHour.value = -1;
      endHour.value = -1;
      formattedTimeRange.value = '';

      // Initialize date range to null for daily rental
      startDate.value = null;
      endDate.value = null;
      formattedDateRange.value = '';

      // Load booked dates with current quantity
      debugPrint(
        '🧮 Initializing daily rental mode with quantity: ${jumlahUnit.value}',
      );
      loadBookedDates();
    } else {
      // Reset date range selections
      startDate.value = null;
      endDate.value = null;
      formattedDateRange.value = '';

      // If switching from daily to hourly, reload hourly inventory
      if (wasDaily) {
        // Get current date for hourly rental
        final DateTime currentDate = DateTime.now();
        final String formattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(currentDate);

        debugPrint(
          '🔄 Switching to hourly rental mode, loading hourly inventory',
        );

        // Clear the hourly inventory to force recalculation
        hourlyInventory.clear();
        unavailableDatesForHourly.clear();

        // Load current date and next 7 days to have availability data
        loadBookingsForDate(currentDate);
        for (int i = 1; i <= 7; i++) {
          final futureDate = currentDate.add(Duration(days: i));
          loadBookingsForDate(futureDate);
        }
      }
    }

    // Make sure to recalculate total price with the new values (which should be 0)
    calculateTotalPrice();

    update();
  }

  // Calculate total price based on duration and selected time unit
  void calculateTotalPrice() {
    if (selectedSatuanWaktu.value == null || duration.value <= 0) {
      totalPrice.value = 0;
      debugPrint(
        '💰 Total price set to 0 (no satuan waktu selected or duration is 0)',
      );
      return;
    }

    final unitPrice = selectedSatuanWaktu.value?['harga'] ?? 0;
    totalPrice.value = unitPrice * duration.value * jumlahUnit.value;
    debugPrint(
      '💰 Calculated total price: ${totalPrice.value} ($unitPrice × ${duration.value} × ${jumlahUnit.value})',
    );
  }

  // Pick a date
  Future<void> pickDate(BuildContext context) async {
    if (aset.value == null) return;

    try {
      // Prepare unavailable dates (past dates or fully booked dates)
      final unavailableDates = <DateTime>[];

      // Add only past dates (before today, not including today)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Add only past dates to unavailable list (not including today)
      for (
        DateTime date = DateTime(today.year, today.month, 1);
        date.isBefore(todayDate); // Changed from !date.isAfter(todayDate)
        date = date.add(const Duration(days: 1))
      ) {
        unavailableDates.add(date);
      }

      // Add dates that are fully booked (no available hours)
      if (unavailableDatesForHourly.isNotEmpty) {
        unavailableDates.addAll(unavailableDatesForHourly);
      }

      debugPrint(
        '🗓️ Unavailable dates for hourly rental: ${unavailableDatesForHourly.length}',
      );

      // Get a temporary value for storing error messages
      final errorMessageText = Rx<String>('');

      // Try to parse the current selected date as initialDate
      DateTime initialDate;
      try {
        initialDate = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).parse(selectedDate.value);

        // Verify it's not an unavailable date
        if (unavailableDates.any((date) => _isSameDay(date, initialDate))) {
          // Find the next available date
          initialDate = _findNextAvailableDate(todayDate, unavailableDates);
        }
      } catch (e) {
        // If parsing fails, use the next available date
        initialDate = _findNextAvailableDate(todayDate, unavailableDates);
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
                    const SizedBox(height: 4),
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
                    // Use the custom calendar widget here for single date selection
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
                          // Clear previous error messages
                          errorMessageText.value = '';

                          // For hourly rental, we only need the start date
                          // We'll ignore the end date from the picker
                          debugPrint(
                            '📅 Selected date for hourly rental: ${DateFormat('yyyy-MM-dd').format(start)}',
                          );

                          // Update the selected date
                          final selectedDateFormatted = DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(start);
                          selectedDate.value = selectedDateFormatted;
                          debugPrint(
                            '📅 Set selected date to: ${selectedDate.value}',
                          );

                          // Reset selections
                          startHour.value = -1;
                          endHour.value = -1;
                          formattedTimeRange.value = '';
                          duration.value = 0;
                          calculateTotalPrice();

                          // Load bookings for this date
                          loadBookingsForDate(start);

                          Navigator.of(
                            context,
                          ).pop(true); // Close dialog with success result
                        } catch (e) {
                          debugPrint('❌ Error in date selection: $e');
                          errorMessageText.value =
                              'Terjadi kesalahan saat memilih tanggal: coba lagi';
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
      _showError('Terjadi kesalahan saat memilih tanggal: ${e.toString()}');
    }
  }

  // Helper method to find the next available date
  DateTime _findNextAvailableDate(
    DateTime startFrom,
    List<DateTime> unavailableDates,
  ) {
    // Start from the next day after the given date
    DateTime testDate = startFrom.add(const Duration(days: 1));

    // Try up to 30 days in the future
    for (int i = 0; i < 30; i++) {
      final bool isUnavailable = unavailableDates.any(
        (date) => _isSameDay(date, testDate),
      );
      if (!isUnavailable) {
        return testDate;
      }
      testDate = testDate.add(const Duration(days: 1));
    }

    // If no available date found in 30 days, return a date anyway
    return startFrom.add(const Duration(days: 1));
  }

  // Check if an hour is in the past
  bool isHourInPast(int hour) {
    final currentDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).parse(selectedDate.value);
    final today = DateTime.now();

    // If selected date is today, check if hour is in the past
    if (currentDate.year == today.year &&
        currentDate.month == today.month &&
        currentDate.day == today.day) {
      return hour <
          today.hour; // Changed from hour <= today.hour to allow current hour
    }

    return false;
  }

  // Check if an hour is booked
  bool isHourBooked(int hour) {
    debugPrint(
      '🔍 Checking if hour $hour is booked among ${bookedHoursList.length} blocked hours',
    );

    // Check if hour is in the bookedHoursList
    bool isBooked = bookedHoursList.contains(hour);

    if (isBooked) {
      debugPrint('🔴 Hour $hour is booked (found in bookedHoursList)');
    } else {
      debugPrint('✅ Hour $hour is available');
    }

    return isBooked;
  }

  // Check if an hour is disabled (past or booked)
  bool isHourDisabled(int hour) {
    // Always check if the hour is in the past
    if (isHourInPast(hour)) {
      return true;
    }

    // Get the current date in yyyy-MM-dd format
    final currentDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).parse(selectedDate.value);
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    // Check if we have inventory data for this date
    if (!hourlyInventory.containsKey(formattedDate)) {
      debugPrint(
        '⚠️ No inventory data for date $formattedDate - defaulting to disabled',
      );
      return true;
    }

    // Get the inventory for this hour
    final inventory = hourlyInventory[formattedDate]!;
    if (!inventory.containsKey(hour)) {
      debugPrint(
        '⚠️ No inventory data for hour $hour - defaulting to disabled',
      );
      return true;
    }

    // Check if requested quantity is available for this hour
    final int availableQty = inventory[hour]!;
    final bool isAvailable = availableQty >= jumlahUnit.value;

    debugPrint(
      '🕒 Hour $hour (${formatHour(hour)}): Available=$availableQty, Needed=${jumlahUnit.value}, Available=$isAvailable',
    );

    return !isAvailable;
  }

  // Select hour
  void selectHour(int hour) {
    if (isHourDisabled(hour)) return;

    // Get maximum allowed hours from selected satuan waktu
    final int maxHours = selectedSatuanWaktu.value?['maksimal_waktu'] ?? 0;

    // If no hour is selected, set as start hour
    if (startHour.value == -1) {
      startHour.value = hour;
      // Set end hour as the next hour, but check if we have a max limit
      endHour.value = hour + 1;
    }
    // If clicking the same hour, deselect it
    else if (startHour.value == hour) {
      startHour.value = -1;
      endHour.value = -1;
    }
    // If selecting a different hour
    else {
      // If selecting a later hour, set as end hour
      if (hour > startHour.value) {
        // Check if the new selection would exceed the maximum allowed duration
        if (maxHours > 0 && (hour - startHour.value + 1) > maxHours) {
          _showError('Maksimal waktu sewa untuk aset ini adalah $maxHours jam');
          return;
        }

        // Check if all hours between start and selected are available
        bool allAvailable = true;
        for (int i = startHour.value + 1; i <= hour; i++) {
          if (isHourDisabled(i)) {
            allAvailable = false;
            break;
          }
        }

        if (allAvailable) {
          endHour.value = hour + 1;
        } else {
          _showError(
            'Terdapat jam yang tidak tersedia di antara rentang waktu yang dipilih',
          );
          return;
        }
      }
      // If selecting an earlier hour, set as new start hour and check max duration
      else {
        // Check if new selection would exceed maximum allowed duration
        if (maxHours > 0 && (endHour.value - hour) > maxHours) {
          _showError('Maksimal waktu sewa untuk aset ini adalah $maxHours jam');
          return;
        }

        startHour.value = hour;
      }
    }

    _updateFormattedTimeRange();
    calculateDurationFromTimeRange();
    update();
  }

  void _updateFormattedTimeRange() {
    if (startHour.value == -1) {
      formattedTimeRange.value = '';
      return;
    }

    final start = formatHour(startHour.value);
    final end = formatHour(endHour.value > 21 ? 21 : endHour.value);
    formattedTimeRange.value = '$start - $end';
  }

  void calculateDurationFromTimeRange() {
    if (startHour.value == -1 || endHour.value == -1) {
      duration.value = 0;
      calculateTotalPrice();
      return;
    }

    // Calculate hours between start and end hour
    int hoursDiff = endHour.value - startHour.value;

    // Get maximum allowed hours
    final int maxHours = selectedSatuanWaktu.value?['maksimal_waktu'] ?? 0;

    // If max hours is set and the current duration exceeds it, cap the duration
    if (maxHours > 0 && hoursDiff > maxHours) {
      // Adjust end hour to match maximum allowed duration
      endHour.value = startHour.value + maxHours;
      hoursDiff = maxHours;

      // Update formatted time range with the new end hour
      _updateFormattedTimeRange();

      // Show a message to the user
      _showError('Durasi disesuaikan ke maksimal $maxHours jam untuk aset ini');
    }

    duration.value = hoursDiff;
    calculateTotalPrice();
  }

  // Pick a date range (for daily rental)
  Future<void> pickDateRange(BuildContext context) async {
    if (aset.value == null) return;

    try {
      // First make sure bookedDates is loaded
      if (isLoadingBookedDates.value) {
        // Show loading indicator
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        // Wait for booked dates to load with a timeout
        int attempts = 0;
        while (isLoadingBookedDates.value && attempts < 100) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }

        // Close the loading dialog
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // If still loading after timeout, show error
        if (isLoadingBookedDates.value) {
          _showError('Timeout loading booked dates. Please try again.');
          return;
        }
      }

      // Log maximum day limit
      debugPrint('📅 Maximum rental period: ${maxDayLimit.value} days');

      // Add today to booked dates to prevent selection
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Create a new list with today added to the booked dates
      final unavailableDates = <DateTime>[];

      // Add today and past dates
      for (
        DateTime date = DateTime(today.year, today.month, 1);
        !date.isAfter(todayDate);
        date = date.add(const Duration(days: 1))
      ) {
        unavailableDates.add(date);
      }

      // Then add all booked dates
      if (bookedDates.isNotEmpty) {
        unavailableDates.addAll(bookedDates);
      }

      debugPrint(
        '🗓️ Today (${DateFormat('yyyy-MM-dd').format(todayDate)}) added to unavailable dates',
      );
      debugPrint('🗓️ Total unavailable dates: ${unavailableDates.length}');

      // Get a temporary value for storing error messages
      final errorMessageText = Rx<String>('');

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
                    if (maxDayLimit.value > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Maksimal waktu sewa: ${maxDayLimit.value} hari',
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
                    // Use the custom calendar widget here
                    CustomDateRangePicker(
                      disabledDates: unavailableDates,
                      initialStartDate: startDate.value,
                      initialEndDate: endDate.value,
                      maxDays: maxDayLimit.value > 0 ? maxDayLimit.value : null,
                      onClearSelection: () {
                        // Handle selection clearing
                        debugPrint('🧹 Date selection cleared by user');
                        // Don't close the dialog, let the user select new dates
                      },
                      onSelectRange: (start, end) {
                        try {
                          // Clear previous error messages
                          errorMessageText.value = '';

                          // If start and end are the same, this is a single day selection
                          final bool isSingleDaySelection = _isSameDay(
                            start,
                            end,
                          );
                          debugPrint(
                            '📅 Selected ${isSingleDaySelection ? "single day" : "date range"}: ${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)}',
                          );

                          // Calculate duration in days
                          int selectedDuration =
                              end.difference(start).inDays + 1;

                          // Check if the selected duration exceeds the maximum
                          if (maxDayLimit.value > 0 &&
                              selectedDuration > maxDayLimit.value) {
                            // Show error message but don't close the dialog
                            errorMessageText.value =
                                'Maksimal waktu sewa untuk aset ini adalah ${maxDayLimit.value} hari. Anda memilih $selectedDuration hari.';
                            debugPrint(
                              '⚠️ Max rental period exceeded: $selectedDuration days selected, max is ${maxDayLimit.value}',
                            );
                            return; // Don't proceed with selection
                          }

                          // This will be called when the user selects a valid range
                          startDate.value = start;
                          endDate.value = end;

                          // Log selection type for clarity
                          if (_isSameDay(start, end)) {
                            debugPrint(
                              '📅 SINGLE DAY SELECTED: ${DateFormat('yyyy-MM-dd').format(start)} (duration: 1 day)',
                            );
                          } else {
                            debugPrint(
                              '📅 DATE RANGE SELECTED: ${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)} (duration: $selectedDuration days)',
                            );
                          }

                          _updateFormattedDateRange();
                          // Calculate duration in days (already validated)
                          duration.value = selectedDuration;
                          calculateTotalPrice();
                          Navigator.of(
                            context,
                          ).pop(true); // Close dialog with success result
                        } catch (e) {
                          debugPrint('❌ Error in date range selection: $e');
                          errorMessageText.value =
                              'Terjadi kesalahan saat memilih tanggal: coba lagi';
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
          '📅 Date range selected: ${startDate.value} to ${endDate.value}, duration: ${duration.value} days',
        );
      }
    } catch (e) {
      debugPrint('❌ Error in date range picker: $e');
      _showError('Terjadi kesalahan saat memilih tanggal: ${e.toString()}');
    }
  }

  // Load booked dates for daily rental with inventory-based logic
  Future<void> loadBookedDates() async {
    try {
      isLoadingBookedDates(true);
      bookedDates.clear();

      // Get the total quantity of the asset
      final int totalQuantity = aset.value?.kuantitas ?? 0;
      debugPrint('📊 Total asset quantity: $totalQuantity');

      // Get the requested quantity from user
      final int requestedQuantity = jumlahUnit.value;
      debugPrint('🔢 Requested quantity: $requestedQuantity');

      // Date range to check (next 90 days)
      final startDateForQuery = DateTime.now();
      final endDateForQuery = DateTime.now().add(const Duration(days: 90));

      // Format dates for API
      final String formattedStartDate = DateFormat(
        'yyyy-MM-dd',
      ).format(startDateForQuery);
      final String formattedEndDate = DateFormat(
        'yyyy-MM-dd',
      ).format(endDateForQuery);

      debugPrint(
        '🔍 Checking available quantity from $formattedStartDate to $formattedEndDate',
      );

      // Get all bookings for this asset in the date range
      final List<Map<String, dynamic>> bookings = await asetProvider
          .getAsetDailyBookings(
            aset.value!.id,
            formattedStartDate,
            formattedEndDate,
          );

      debugPrint('📑 Found ${bookings.length} bookings for this asset');

      // Create an inventory map to track available quantity for each day
      Map<String, int> dailyInventory = {};

      // Initialize inventory for each day in the range
      for (
        DateTime day = startDateForQuery;
        !day.isAfter(endDateForQuery);
        day = day.add(const Duration(days: 1))
      ) {
        String dateStr = DateFormat('yyyy-MM-dd').format(day);
        dailyInventory[dateStr] = totalQuantity;
      }

      // Process all bookings to calculate inventory deductions
      for (var booking in bookings) {
        final String? startDateStr = booking['waktu_mulai'];
        final String? endDateStr = booking['waktu_selesai'];
        final int bookingQuantity = booking['kuantitas'] ?? 0;
        final String bookingStatus = booking['status'] ?? '';
        final String bookingId = booking['id'] ?? '';

        debugPrint(
          '🔎 Processing booking: ID: $bookingId, $startDateStr to $endDateStr, quantity: $bookingQuantity, status: $bookingStatus',
        );

        if (startDateStr != null && endDateStr != null && bookingQuantity > 0) {
          final DateTime bookingStart = DateTime.parse(startDateStr);
          final DateTime bookingEnd = DateTime.parse(endDateStr);

          // Get dates without time
          final DateTime startDateOnly = DateTime(
            bookingStart.year,
            bookingStart.month,
            bookingStart.day,
          );
          final DateTime endDateOnly = DateTime(
            bookingEnd.year,
            bookingEnd.month,
            bookingEnd.day,
          );

          debugPrint(
            '📊 Inventory status BEFORE processing booking $bookingId:',
          );
          // Show a sample of inventory before changes
          int sampleCount = 0;
          for (
            DateTime day = startDateOnly;
            !day.isAfter(endDateOnly) && sampleCount < 3;
            day = day.add(const Duration(days: 1)), sampleCount++
          ) {
            String dateStr = DateFormat('yyyy-MM-dd').format(day);
            debugPrint(
              '  - BEFORE: $dateStr: Available=${dailyInventory[dateStr]}',
            );
          }

          // Reduce available quantity for each day in the booking range
          for (
            DateTime day = startDateOnly;
            !day.isAfter(endDateOnly);
            day = day.add(const Duration(days: 1))
          ) {
            String dateStr = DateFormat('yyyy-MM-dd').format(day);

            // Subtract the booking quantity from available inventory
            if (dailyInventory.containsKey(dateStr)) {
              int previousInventory = dailyInventory[dateStr]!;
              dailyInventory[dateStr] = previousInventory - bookingQuantity;
              debugPrint(
                '📉 Day $dateStr: Booking $bookingId reduced inventory from $previousInventory to ${dailyInventory[dateStr]} (by $bookingQuantity)',
              );
            }
          }

          // Show inventory after changes for the same sample days
          debugPrint(
            '📊 Inventory status AFTER processing booking $bookingId:',
          );
          sampleCount = 0;
          for (
            DateTime day = startDateOnly;
            !day.isAfter(endDateOnly) && sampleCount < 3;
            day = day.add(const Duration(days: 1)), sampleCount++
          ) {
            String dateStr = DateFormat('yyyy-MM-dd').format(day);
            debugPrint(
              '  - AFTER: $dateStr: Available=${dailyInventory[dateStr]}',
            );
          }
        }
      }

      // Final inventory status after processing all bookings
      debugPrint('📊 FINAL INVENTORY STATUS SUMMARY:');
      debugPrint('------------------------------------');
      debugPrint('Total asset quantity: $totalQuantity');
      debugPrint('Requested quantity: $requestedQuantity');
      debugPrint('Total bookings processed: ${bookings.length}');

      // Show detailed inventory for next 10 days
      DateTime currentDate = DateTime.now();
      debugPrint('INVENTORY FOR NEXT 10 DAYS:');
      for (int i = 0; i < 10; i++) {
        String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
        int available = dailyInventory[dateStr] ?? 0;
        bool isAvailable = available >= requestedQuantity;
        String availabilityStatus =
            isAvailable ? "✅ AVAILABLE" : "❌ UNAVAILABLE";

        debugPrint(
          '${i + 1}. $dateStr: $available/$totalQuantity units available - $availabilityStatus',
        );
        currentDate = currentDate.add(const Duration(days: 1));
      }
      debugPrint('------------------------------------');

      // Find days where available quantity is less than requested quantity
      for (var entry in dailyInventory.entries) {
        if (entry.value < requestedQuantity) {
          // Parse the date and add to booked dates
          final DateTime bookedDate = DateFormat('yyyy-MM-dd').parse(entry.key);
          bookedDates.add(bookedDate);
          debugPrint(
            '🚫 Disabling date ${entry.key}: available quantity ${entry.value} < requested $requestedQuantity',
          );
        }
      }

      // Also add past dates (today and before) to booked dates
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      for (
        DateTime day = startDateForQuery;
        !day.isAfter(todayDate);
        day = day.add(const Duration(days: 1))
      ) {
        bookedDates.add(day);
        debugPrint(
          '🕒 Disabling past date: ${DateFormat('yyyy-MM-dd').format(day)}',
        );
      }

      // Log a sample of the inventory status
      debugPrint('📊 Inventory status sample:');
      int counter = 0;
      for (var entry in dailyInventory.entries) {
        if (counter++ >= 10) break; // Show only first 10 days
        debugPrint(
          '  - ${entry.key}: Available=${entry.value}, Required=$requestedQuantity, Available=${entry.value >= requestedQuantity}',
        );
      }

      // Debug the total number of disabled dates
      debugPrint('📋 Total dates disabled: ${bookedDates.length}');
      if (bookedDates.isNotEmpty) {
        debugPrint('📅 Sample disabled dates:');
        for (int i = 0; i < math.min(5, bookedDates.length); i++) {
          debugPrint('  - ${DateFormat('yyyy-MM-dd').format(bookedDates[i])}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading booked dates: $e');
      debugPrint('🔍 Stack trace: $stackTrace');
    } finally {
      isLoadingBookedDates(false);
    }
  }

  // Update the formatted date range string
  void _updateFormattedDateRange() {
    if (startDate.value != null && endDate.value != null) {
      final startDateStr = DateFormat(
        'dd MMM yyyy',
        'id_ID',
      ).format(startDate.value!);

      // If start and end date are the same, show just one date
      if (startDate.value!.year == endDate.value!.year &&
          startDate.value!.month == endDate.value!.month &&
          startDate.value!.day == endDate.value!.day) {
        formattedDateRange.value = '$startDateStr (1 hari)';
      } else {
        // Show date range
        final endDateStr = DateFormat(
          'dd MMM yyyy',
          'id_ID',
        ).format(endDate.value!);
        final days = endDate.value!.difference(startDate.value!).inDays + 1;
        formattedDateRange.value = '$startDateStr - $endDateStr ($days hari)';
      }
    } else {
      formattedDateRange.value = '';
    }
  }

  // Helper method to check if we're using daily rental
  bool isDailyRental() {
    return selectedSatuanWaktu.value != null &&
        (selectedSatuanWaktu.value!['nama_satuan_waktu']
                ?.toString()
                .toLowerCase()
                .contains('hari') ??
            false);
  }

  // Helper method to show error messages
  void _showError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  // Helper method to show success messages
  void _showSuccess(String message) {
    Get.snackbar(
      'Sukses',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Recalculate hourly inventory based on current quantity
  void recalculateHourlyInventory() {
    // Only proceed if we're in hourly rental mode
    if (isDailyRental()) return;

    // Get current date
    final currentDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).parse(selectedDate.value);
    debugPrint(
      '🔄 Recalculating hourly inventory for ${DateFormat('yyyy-MM-dd').format(currentDate)}',
    );

    // Reload bookings to recalculate inventory
    loadBookingsForDate(currentDate);
  }

  // Increase unit quantity
  void increaseUnit() {
    if (jumlahUnit.value < maxUnit.value) {
      // Save previous value to check for changes in availability logic
      final int prevValue = jumlahUnit.value;
      jumlahUnit.value++;

      // Clear date/time selections when quantity changes
      if (isDailyRental()) {
        // Clear date selections for daily rental
        startDate.value = null;
        endDate.value = null;
        formattedDateRange.value = '';
        debugPrint('🧹 Cleared date selections due to quantity change');
      } else {
        // Clear time selections for hourly rental
        startHour.value = -1;
        endHour.value = -1;
        formattedTimeRange.value = '';
        debugPrint('🧹 Cleared time selections due to quantity change');
      }

      // Reset duration and update total price
      duration.value = 0;
      calculateTotalPrice();

      // If we're in daily rental mode, reload booked dates with new quantity
      if (isDailyRental()) {
        debugPrint(
          '🔄 Quantity changed in daily rental mode, reloading availability',
        );
        loadBookedDates();
      } else {
        // In hourly mode, recalculate hourly inventory
        recalculateHourlyInventory();
      }

      // Update the UI since availability may have changed
      update();
    }
  }

  // Decrease unit quantity
  void decreaseUnit() {
    if (jumlahUnit.value > 1) {
      // Save previous value to check for changes in availability logic
      final int prevValue = jumlahUnit.value;
      jumlahUnit.value--;

      // Clear date/time selections when quantity changes
      if (isDailyRental()) {
        // Clear date selections for daily rental
        startDate.value = null;
        endDate.value = null;
        formattedDateRange.value = '';
        debugPrint('🧹 Cleared date selections due to quantity change');
      } else {
        // Clear time selections for hourly rental
        startHour.value = -1;
        endHour.value = -1;
        formattedTimeRange.value = '';
        debugPrint('🧹 Cleared time selections due to quantity change');
      }

      // Reset duration and update total price
      duration.value = 0;
      calculateTotalPrice();

      // If we're in daily rental mode, reload booked dates with new quantity
      if (isDailyRental()) {
        debugPrint(
          '🔄 Quantity changed in daily rental mode, reloading availability',
        );
        loadBookedDates();
      } else {
        // In hourly mode, recalculate hourly inventory
        recalculateHourlyInventory();
      }

      // Update the UI since availability may have changed
      update();
    }
  }

  // Update unit from text input
  void updateUnitFromInput(String value) {
    try {
      int newValue = int.parse(value);

      // Ensure value is within allowed range
      if (newValue < 1) {
        newValue = 1;
      } else if (newValue > maxUnit.value) {
        newValue = maxUnit.value;
      }

      // Check if the value has changed
      bool valueChanged = jumlahUnit.value != newValue;

      if (valueChanged) {
        jumlahUnit.value = newValue;

        // Clear date/time selections when quantity changes
        if (isDailyRental()) {
          // Clear date selections for daily rental
          startDate.value = null;
          endDate.value = null;
          formattedDateRange.value = '';
          debugPrint('🧹 Cleared date selections due to quantity change');
        } else {
          // Clear time selections for hourly rental
          startHour.value = -1;
          endHour.value = -1;
          formattedTimeRange.value = '';
          debugPrint('🧹 Cleared time selections due to quantity change');
        }

        // Reset duration and update total price
        duration.value = 0;
        calculateTotalPrice();

        // If we're in daily rental mode, reload booked dates with new quantity
        if (isDailyRental()) {
          debugPrint(
            '🔄 Quantity changed in daily rental mode, reloading availability',
          );
          loadBookedDates();
        } else {
          // In hourly mode, load all bookings to recalculate availability
          loadAllBookings();
        }

        // Update the UI
        update();
      }
    } catch (e) {
      // If parsing fails, reset to 1
      jumlahUnit.value = 1;

      // Clear date/time selections due to error
      if (isDailyRental()) {
        // Clear date selections for daily rental
        startDate.value = null;
        endDate.value = null;
        formattedDateRange.value = '';
      } else {
        // Clear time selections for hourly rental
        startHour.value = -1;
        endHour.value = -1;
        formattedTimeRange.value = '';
      }

      // Reset duration and calculate total price
      duration.value = 0;
      calculateTotalPrice();

      // If we're in daily rental mode, reload booked dates with new quantity
      if (isDailyRental()) {
        debugPrint(
          '🔄 Quantity reset to 1 in daily rental mode, reloading availability',
        );
        loadBookedDates();
      } else {
        // In hourly mode, load all bookings to recalculate availability
        loadAllBookings();
      }

      update();
    }
  }

  // Reset time selection
  void resetTimeSelection() {
    startHour.value = -1;
    endHour.value = -1;
    formattedTimeRange.value = '';
    duration.value = 0;
    calculateTotalPrice();
  }

  // Pesan sekarang
  Future<void> pesanSekarang() async {
    if (!_validateBookingInputs()) {
      return;
    }

    final userId = authProvider.getCurrentUserId();

    // Generate a unique UUID for the order
    final uuid = Uuid();
    final String orderId = uuid.v4();
    debugPrint('🆔 Generated order ID: $orderId');

    try {
      isLoading.value = true;

      Map<String, dynamic> sewaAsetData;
      Map<String, dynamic> bookedDetailData;
      Map<String, dynamic> tagihanSewaData;

      if (isDailyRental()) {
        // Create daily rental order
        final String formattedStartDate = DateFormat(
          'yyyy-MM-dd',
        ).format(startDate.value!);
        final String formattedEndDate = DateFormat(
          'yyyy-MM-dd',
        ).format(endDate.value!);

        // Create ISO timestamp strings for waktu_mulai and waktu_selesai with default times
        // Default time for start is 06:00:00
        final String waktuMulai = '${formattedStartDate}T06:00:00';
        // Default time for end is 21:00:00
        final String waktuSelesai = '${formattedEndDate}T21:00:00';

        debugPrint(
          '📅 Creating daily booking from $waktuMulai to $waktuSelesai',
        );

        // Daily rental price from selected satuan waktu
        final int dailyPrice = selectedSatuanWaktu.value?['harga'] ?? 0;
        // Calculate days duration
        final int daysDuration =
            endDate.value!.difference(startDate.value!).inDays + 1;

        // Prepare sewa_aset data
        sewaAsetData = {
          'id': orderId, // Set UUID as the ID
          'user_id': userId,
          'aset_id': aset.value!.id,
          'waktu_mulai': waktuMulai,
          'waktu_selesai': waktuSelesai,
          'kuantitas': jumlahUnit.value,
          'status': 'MENUNGGU PEMBAYARAN',
          'tipe_pesanan': 'tunggal',
          'total': totalPrice.value,
          'nama_satuan_waktu':
              'hari', // Set satuan waktu to "hari" for daily rentals
        };

        // Prepare booked_detail data
        bookedDetailData = {
          'id': uuid.v4(), // Generate a new UUID for booked_detail
          'aset_id': aset.value!.id,
          'sewa_aset_id': orderId,
          'waktu_mulai': waktuMulai,
          'waktu_selesai': waktuSelesai,
          'kuantitas': jumlahUnit.value,
        };

        // Prepare tagihan_sewa data
        tagihanSewaData = {
          'sewa_aset_id': orderId,
          'durasi': daysDuration,
          'satuan_waktu': 'hari',
          'harga_sewa': dailyPrice,
          'tagihan_awal': totalPrice.value,
        };
      } else {
        // Format date for booking
        final DateTime bookingDate = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).parse(selectedDate.value);

        // Format start and end times using ISO format
        final String formattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(bookingDate);
        final String startTime = formatHour(startHour.value);
        final String endTime = formatHour(endHour.value);

        // Create ISO timestamp strings for waktu_mulai and waktu_selesai
        final String waktuMulai = '${formattedDate}T$startTime:00';
        final String waktuSelesai = '${formattedDate}T$endTime:00';

        debugPrint(
          '📅 Creating hourly booking from $waktuMulai to $waktuSelesai',
        );
        debugPrint('🔢 Unit quantity: ${jumlahUnit.value}');

        // Hourly price from selected satuan waktu
        final int hourlyPrice = selectedSatuanWaktu.value?['harga'] ?? 0;

        // Prepare sewa_aset data
        sewaAsetData = {
          'id': orderId, // Set UUID as the ID
          'user_id': userId,
          'aset_id': aset.value!.id,
          'kuantitas': jumlahUnit.value,
          'status': 'MENUNGGU PEMBAYARAN',
          'waktu_mulai': waktuMulai,
          'waktu_selesai': waktuSelesai,
          'tipe_pesanan': 'tunggal',
          'total': totalPrice.value,
          'nama_satuan_waktu': 'jam', // Set satuan waktu to "jam"
        };

        // Prepare booked_detail data
        bookedDetailData = {
          'id': uuid.v4(), // Generate a new UUID for booked_detail
          'aset_id': aset.value!.id,
          'sewa_aset_id': orderId,
          'waktu_mulai': waktuMulai,
          'waktu_selesai': waktuSelesai,
          'kuantitas': jumlahUnit.value,
        };

        // Prepare tagihan_sewa data
        tagihanSewaData = {
          'sewa_aset_id': orderId,
          'durasi': duration.value,
          'satuan_waktu': 'jam',
          'harga_sewa': hourlyPrice,
          'tagihan_awal': totalPrice.value,
        };
      }

      // Call the API to create the complete order
      final success = await asetProvider.createCompleteOrder(
        sewaAsetData: sewaAsetData,
        bookedDetailData: bookedDetailData,
        tagihanSewaData: tagihanSewaData,
      );

      if (success) {
        debugPrint('✅ Complete order created successfully with ID: $orderId');

        // Navigate to payment page
        Get.toNamed(Routes.PEMBAYARAN_SEWA, arguments: {'orderId': orderId});
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          'Gagal membuat pesanan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Validate booking inputs
  bool _validateBookingInputs() {
    if (selectedSatuanWaktu.value == null || aset.value == null) {
      _showError('Harap pilih satuan waktu terlebih dahulu');
      return false;
    }

    // Check if we're using hourly or daily rental
    if (isDailyRental()) {
      if (startDate.value == null || endDate.value == null) {
        _showError('Harap pilih tanggal terlebih dahulu');
        return false;
      }
    } else {
      if (startHour.value == -1 || duration.value <= 0) {
        _showError('Harap pilih waktu terlebih dahulu');
        return false;
      }
    }

    if (jumlahUnit.value <= 0) {
      _showError('Jumlah unit tidak valid');
      return false;
    }

    if (jumlahUnit.value > maxUnit.value) {
      _showError(
        'Jumlah unit melebihi ketersediaan (maksimal ${maxUnit.value})',
      );
      return false;
    }

    // Check if user is logged in
    final userId = authProvider.getCurrentUserId();
    if (userId == null) {
      _showError('Anda belum login. Silakan login terlebih dahulu.');
      return false;
    }

    return true;
  }

  // Load all bookings for the next 30 days to determine available dates
  Future<void> loadAllBookings() async {
    try {
      debugPrint(
        '🔄 Loading all bookings for asset ${aset.value!.id} for the next 30 days',
      );

      // Clear current inventory data
      hourlyInventory.clear();
      unavailableDatesForHourly.clear();

      // Date range to check (today + 30 days)
      final DateTime today = DateTime.now();
      final DateTime endDate = today.add(const Duration(days: 30));

      // Format dates for API
      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(today);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      debugPrint(
        '📅 Fetching bookings from $formattedStartDate to $formattedEndDate',
      );

      // Get all bookings for this asset in the date range
      final List<Map<String, dynamic>> bookings = await asetProvider
          .getAsetDailyBookings(
            aset.value!.id,
            formattedStartDate,
            formattedEndDate,
          );

      debugPrint('📊 Found ${bookings.length} bookings for asset');

      // Initialize inventory for each day in the 30-day period
      final int totalAssetQuantity = aset.value?.kuantitas ?? 0;
      Map<String, Map<int, int>> fullInventory = {};

      // Initialize inventory for next 30 days, each with hours 0-23
      for (int day = 0; day < 30; day++) {
        final DateTime currentDate = today.add(Duration(days: day));
        final String currentDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(currentDate);

        // Initialize inventory for each hour of this day with full quantity
        Map<int, int> dayInventory = {};
        for (int hour = 0; hour < 24; hour++) {
          dayInventory[hour] = totalAssetQuantity;
        }

        fullInventory[currentDateStr] = dayInventory;
      }

      debugPrint('📊 INVENTORY - INITIAL STATE:');
      debugPrint('------------------------------------');
      debugPrint('Total asset quantity: $totalAssetQuantity');
      debugPrint('Days initialized: ${fullInventory.length}');
      debugPrint('------------------------------------');

      // Process all bookings chronologically to determine inventory
      if (bookings.isNotEmpty) {
        // Sort bookings by start time to process them chronologically
        bookings.sort((a, b) {
          final String startA = a['waktu_mulai'] ?? '';
          final String startB = b['waktu_mulai'] ?? '';
          return startA.compareTo(startB);
        });

        debugPrint(
          '🔢 Processing ${bookings.length} bookings to calculate inventory:',
        );

        // Process each booking and adjust inventory
        for (var booking in bookings) {
          final String bookingId = booking['id'] ?? '';
          final String status = booking['status'] ?? '';
          final int bookingQuantity = booking['kuantitas'] ?? 1;

          // Skip rejected bookings
          if (status == 'ditolak') {
            debugPrint('⏩ Skipping rejected booking: $bookingId');
            continue;
          }

          // Get start and end date-times
          final String waktuMulaiStr = booking['waktu_mulai'] ?? '';
          final String waktuSelesaiStr = booking['waktu_selesai'] ?? '';

          if (waktuMulaiStr.isEmpty || waktuSelesaiStr.isEmpty) {
            debugPrint(
              '⚠️ Booking ID $bookingId has invalid timestamps, skipping',
            );
            continue;
          }

          try {
            final DateTime waktuMulai = DateTime.parse(waktuMulaiStr);
            final DateTime waktuSelesai = DateTime.parse(waktuSelesaiStr);

            debugPrint('🔎 Processing booking ID: $bookingId');
            debugPrint(
              '  - Period: ${DateFormat('yyyy-MM-dd HH:mm').format(waktuMulai)} to ${DateFormat('yyyy-MM-dd HH:mm').format(waktuSelesai)}',
            );
            debugPrint('  - Status: $status, Quantity: $bookingQuantity');

            // Calculate all date-hour combinations in the booking range
            final List<DateTime> allDateHours = [];

            // Add all hours from start to end
            DateTime currentHour = DateTime(
              waktuMulai.year,
              waktuMulai.month,
              waktuMulai.day,
              waktuMulai.hour,
            );

            while (!currentHour.isAfter(waktuSelesai)) {
              allDateHours.add(currentHour);
              currentHour = currentHour.add(const Duration(hours: 1));
            }

            // Process each hour in the booking range to reduce inventory
            for (DateTime dateHour in allDateHours) {
              final String dateStr = DateFormat('yyyy-MM-dd').format(dateHour);
              final int hour = dateHour.hour;

              // Skip if outside our initialized inventory range
              if (!fullInventory.containsKey(dateStr)) {
                continue;
              }

              // Reduce inventory for this hour
              if (fullInventory[dateStr]!.containsKey(hour)) {
                final int previousQty = fullInventory[dateStr]![hour]!;
                fullInventory[dateStr]![hour] = math.max(
                  0,
                  previousQty - bookingQuantity,
                );

                debugPrint(
                  '📉 $dateStr Hour $hour: DECREASED inventory from $previousQty to ${fullInventory[dateStr]![hour]} (by $bookingQuantity)',
                );
              }
            }

            // Handle inventory restoration one hour after booking ends
            final DateTime inventoryRestorationTime = waktuSelesai.add(
              const Duration(hours: 1),
            );
            final String restorationDateStr = DateFormat(
              'yyyy-MM-dd',
            ).format(inventoryRestorationTime);
            final int restorationHour = inventoryRestorationTime.hour;

            // Verify this restoration point is in our initialized inventory
            if (fullInventory.containsKey(restorationDateStr) &&
                fullInventory[restorationDateStr]!.containsKey(
                  restorationHour,
                )) {
              // Don't increase above the total asset quantity
              final int currentInventory =
                  fullInventory[restorationDateStr]![restorationHour]!;
              final int newInventory = math.min(
                currentInventory + bookingQuantity,
                totalAssetQuantity,
              );

              fullInventory[restorationDateStr]![restorationHour] =
                  newInventory;

              debugPrint(
                '📈 $restorationDateStr Hour $restorationHour: INCREASED inventory from $currentInventory to $newInventory (by $bookingQuantity)',
              );
            }
          } catch (e) {
            debugPrint('❌ Error processing booking $bookingId: $e');
          }
        }
      }

      // Store the inventory in our controller
      hourlyInventory.clear();
      hourlyInventory.addAll(fullInventory);

      // Now determine which dates are fully booked (no available hours during business hours)
      _identifyUnavailableDates();

      debugPrint(
        '✅ Completed loading all bookings and calculating availability',
      );
      debugPrint(
        '🗓️ Total unavailable dates identified: ${unavailableDatesForHourly.length}',
      );
    } catch (e) {
      debugPrint('❌ Error loading all bookings: $e');
    } finally {
      isLoadingBookings(false);
    }
  }

  // Identify dates that have no available hours for the current requested quantity
  void _identifyUnavailableDates() {
    final int requestedQuantity = jumlahUnit.value;
    debugPrint(
      '🔍 Identifying unavailable dates for quantity: $requestedQuantity',
    );

    // Clear previous unavailable dates
    unavailableDatesForHourly.clear();

    // Business hours (typically 6-21)
    List<int> businessHours = List.generate(16, (index) => index + 6);

    // Check each day in our inventory
    for (String dateStr in hourlyInventory.keys) {
      final Map<int, int> dayInventory = hourlyInventory[dateStr]!;

      // Check if any business hour is available for this date
      bool anyHourAvailable = false;
      for (int hour in businessHours) {
        if (dayInventory.containsKey(hour)) {
          final int availableQty = dayInventory[hour]!;
          if (availableQty >= requestedQuantity) {
            anyHourAvailable = true;
            break;
          }
        }
      }

      // If no business hours are available, mark this date as unavailable
      if (!anyHourAvailable) {
        final DateTime unavailableDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(dateStr);
        unavailableDatesForHourly.add(unavailableDate);
        debugPrint(
          '🚫 Date $dateStr marked as UNAVAILABLE (no available hours)',
        );
      }
    }

    // Also mark past dates as unavailable (but not today)
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);

    // Add only past dates (before today)
    for (
      DateTime date = DateTime(today.year, today.month, 1);
      date.isBefore(todayDate);
      date = date.add(const Duration(days: 1))
    ) {
      if (!unavailableDatesForHourly.any((d) => _isSameDay(d, date))) {
        unavailableDatesForHourly.add(date);
        debugPrint(
          '🕒 Past date (${DateFormat('yyyy-MM-dd').format(date)}) marked as unavailable',
        );
      }
    }
  }

  // Helper method to check if two dates represent the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
