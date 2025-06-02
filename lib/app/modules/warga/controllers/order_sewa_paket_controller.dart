import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_logs/flutter_logs.dart';
import '../../../data/models/paket_model.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../data/providers/sewa_provider.dart';
import '../../../services/service_manager.dart';
import '../../../services/navigation_service.dart';

class OrderSewaPaketController extends GetxController {
  // Dependencies
  final AsetProvider asetProvider = Get.find<AsetProvider>();
  final SewaProvider sewaProvider = Get.find<SewaProvider>();
  final NavigationService navigationService = ServiceManager().navigationService;

  // State variables
  final paket = Rx<PaketModel?>(null);
  final paketImages = RxList<String>([]);
  final isLoading = RxBool(true);
  final isPhotosLoading = RxBool(true);
  final selectedSatuanWaktu = Rx<Map<String, dynamic>?>(null);
  final selectedDate = RxString('');
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final selectedStartTime = RxInt(-1);
  final selectedEndTime = RxInt(-1);
  final formattedDateRange = RxString('');
  final formattedTimeRange = RxString('');
  final totalPrice = RxDouble(0.0);
  final kuantitas = RxInt(1);
  final isSubmitting = RxBool(false);

  // Format currency
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void onInit() {
    super.onInit();
    FlutterLogs.logInfo("OrderSewaPaketController", "onInit", "Initializing OrderSewaPaketController");
    
    // Get the paket ID from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String? paketId = args['id'];
    
    if (paketId != null) {
      loadPaketData(paketId);
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

  // Load paket data from API
  Future<void> loadPaketData(String id) async {
    try {
      isLoading.value = true;
      debugPrint('🔍 Loading paket data for ID: $id');
      
      // First check if we have it in cache
      final cachedPaket = GetStorage().read('cached_paket_$id');
      if (cachedPaket != null) {
        debugPrint('✅ Found cached paket data');
        paket.value = cachedPaket;
        await loadPaketPhotos(id);
        initializePriceOptions();
      } else {
        // Get all pakets and filter for the one we need
        final List<dynamic> allPakets = await asetProvider.getPakets();
        final rawPaket = allPakets.firstWhere(
          (paket) => paket['id'] == id,
          orElse: () => null,
        );
        
        // Declare loadedPaket outside the if block for wider scope
        PaketModel? loadedPaket;
        
        if (rawPaket != null) {
          // Convert to PaketModel
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
              foto_paket: getPaketMainPhoto(rawPaket),
              satuanWaktuSewa: getPaketSatuanWaktuSewa(rawPaket),
            );
            debugPrint('✅ Created PaketModel using helper methods');
          }

          // Update the state with the loaded paket
          if (loadedPaket != null) {
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
          }
        } else {
          debugPrint('❌ No paket found with id: $id');
        }
      }
      
      // Calculate the total price if we have a paket loaded
      if (paket.value != null) {
        calculateTotalPrice();
        debugPrint('💰 Total price calculated: ${totalPrice.value}');
      }
    } catch (e) {
      debugPrint('❌ Error loading paket data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods to safely access paket properties
  String? getPaketId(dynamic paket) {
    if (paket == null) return null;
    try {
      return paket.id ?? paket['id'];
    } catch (_) {
      return null;
    }
  }

  String? getPaketNama(dynamic paket) {
    if (paket == null) return null;
    try {
      return paket.nama ?? paket['nama'];
    } catch (_) {
      return null;
    }
  }

  String? getPaketDeskripsi(dynamic paket) {
    if (paket == null) return null;
    try {
      return paket.deskripsi ?? paket['deskripsi'];
    } catch (_) {
      return null;
    }
  }

  double getPaketHarga(dynamic paket) {
    if (paket == null) return 0.0;
    try {
      var harga = paket.harga ?? paket['harga'] ?? 0;
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

  String? getPaketMainPhoto(dynamic paket) {
    if (paket == null) return null;
    try {
      return paket.foto_paket ?? paket['foto_paket'];
    } catch (_) {
      return null;
    }
  }

  List<dynamic> getPaketSatuanWaktuSewa(dynamic paket) {
    if (paket == null) return [];
    try {
      return paket.satuanWaktuSewa ?? paket['satuanWaktuSewa'] ?? [];
    } catch (_) {
      return [];
    }
  }

  // Load photos for the paket
  Future<void> loadPaketPhotos(String paketId) async {
    try {
      isPhotosLoading.value = true;
      final photos = await asetProvider.getFotoPaket(paketId);
      if (photos != null && photos.isNotEmpty) {
        paketImages.clear();
        for (var photo in photos) {
          try {
            if (photo.fotoPaket != null && photo.fotoPaket.isNotEmpty) {
              paketImages.add(photo.fotoPaket);
            } else if (photo.fotoAset != null && photo.fotoAset.isNotEmpty) {
              paketImages.add(photo.fotoAset);
            }
          } catch (e) {
            var fotoUrl = photo['foto_paket'] ?? photo['foto_aset'];
            if (fotoUrl != null && fotoUrl.isNotEmpty) {
              paketImages.add(fotoUrl);
            }
          }
        }
      }
    } finally {
      isPhotosLoading.value = false;
    }
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
  void selectSatuanWaktu(Map<String, dynamic> satuanWaktu) {
    selectedSatuanWaktu.value = satuanWaktu;
    
    // Reset date and time selections
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStartTime.value = -1;
    selectedEndTime.value = -1;
    selectedDate.value = '';
    formattedDateRange.value = '';
    formattedTimeRange.value = '';
    
    calculateTotalPrice();
  }

  // Check if the rental is daily
  bool isDailyRental() {
    final namaSatuan = selectedSatuanWaktu.value?['nama_satuan_waktu'] ?? '';
    return namaSatuan.toString().toLowerCase().contains('hari');
  }

  // Select date range for daily rental
  void selectDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    
    // Format the date range
    final formatter = DateFormat('d MMM yyyy', 'id');
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      formattedDateRange.value = formatter.format(start);
    } else {
      formattedDateRange.value = '${formatter.format(start)} - ${formatter.format(end)}';
    }
    
    selectedDate.value = formatter.format(start);
    calculateTotalPrice();
  }

  // Select date for hourly rental
  void selectDate(DateTime date) {
    selectedStartDate.value = date;
    selectedDate.value = DateFormat('d MMM yyyy', 'id').format(date);
    calculateTotalPrice();
  }

  // Select time range for hourly rental
  void selectTimeRange(int start, int end) {
    selectedStartTime.value = start;
    selectedEndTime.value = end;
    
    // Format the time range
    final startTime = '$start:00';
    final endTime = '$end:00';
    formattedTimeRange.value = '$startTime - $endTime';
    
    calculateTotalPrice();
  }

  // Calculate total price
  void calculateTotalPrice() {
    if (selectedSatuanWaktu.value == null) {
      totalPrice.value = 0.0;
      return;
    }
    
    final basePrice = double.tryParse(selectedSatuanWaktu.value!['harga'].toString()) ?? 0.0;
    
    if (isDailyRental()) {
      if (selectedStartDate.value != null && selectedEndDate.value != null) {
        final days = selectedEndDate.value!.difference(selectedStartDate.value!).inDays + 1;
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
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      if ((isDailyRental() && (selectedStartDate.value == null || selectedEndDate.value == null)) ||
          (!isDailyRental() && (selectedStartDate.value == null || selectedStartTime.value < 0 || selectedEndTime.value < 0))) {
        Get.snackbar(
          'Error',
          'Silakan pilih waktu sewa',
          snackPosition: SnackPosition.BOTTOM,
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
        'tanggal_selesai': selectedEndDate.value?.toIso8601String() ?? selectedStartDate.value!.toIso8601String(),
        'jam_mulai': isDailyRental() ? null : selectedStartTime.value,
        'jam_selesai': isDailyRental() ? null : selectedEndTime.value,
        'total_harga': totalPrice.value,
        'kuantitas': kuantitas.value,
      };
      
      // Submit the order
      final result = await sewaProvider.createPaketOrder(orderData);
      
      if (result != null) {
        Get.snackbar(
          'Sukses',
          'Pesanan berhasil dibuat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to payment page
        navigationService.navigateToPembayaranSewa(result['id']);
      } else {
        Get.snackbar(
          'Error',
          'Gagal membuat pesanan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error submitting order: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
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
}
