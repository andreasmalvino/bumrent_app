import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/providers/aset_provider.dart';
import '../../../services/navigation_service.dart';

// Custom class for web platform to handle image URLs
class WebImageFile {
  final String imageUrl;
  String id = ''; // Database ID for the foto_pembayaran record (UUID string)
  
  WebImageFile(this.imageUrl);
}

class PembayaranSewaController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Dependencies
  final NavigationService navigationService = Get.find<NavigationService>();
  final AsetProvider asetProvider = Get.find<AsetProvider>();
  
  // Direct access to Supabase client for storage operations
  final SupabaseClient client = Supabase.instance.client;

  // Tab controller
  late TabController tabController;

  // Order details
  final orderId = ''.obs;
  final orderDetails = Rx<Map<String, dynamic>>({});

  // Sewa Aset details with related aset info
  final sewaAsetDetails = Rx<Map<String, dynamic>>({});

  // Tagihan Sewa details
  final tagihanSewa = Rx<Map<String, dynamic>>({});

  // Payment details
  final paymentMethod = ''.obs;
  final selectedPaymentType = ''.obs;
  final isLoading = false.obs;
  final currentStep = 0.obs;

  // Payment proof images - now a list to support multiple images (both File and WebImageFile)
  final RxList<dynamic> paymentProofImages = <dynamic>[].obs;
  
  // Track original images loaded from database
  final RxList<WebImageFile> originalImages = <WebImageFile>[].obs;
  
  // Track images marked for deletion
  final RxList<WebImageFile> imagesToDelete = <WebImageFile>[].obs;
  
  // Flag to track if there are changes that need to be saved
  final RxBool hasUnsavedChanges = false.obs;
  
  // Get image widget for a specific image
  Widget getImageWidget(dynamic imageFile) {
    // Check if it's a WebImageFile (for existing images loaded from URLs)
    if (imageFile is WebImageFile) {
      return Image.network(
        imageFile.imageUrl,
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: 120,
            color: Colors.grey[300],
            child: const Center(child: Text('Error')),
          );
        },
      );
    }
    // Check if running on web with a File object
    else if (kIsWeb && imageFile is File) {
      // For web, we need to use Image.network with the path
      return Image.network(
        imageFile.path,
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: 120,
            color: Colors.grey[300],
            child: const Center(child: Text('Error')),
          );
        },
      );
    } 
    // For mobile with a File object
    else if (imageFile is File) {
      return Image.file(
        imageFile,
        height: 120,
        width: 120,
        fit: BoxFit.cover,
      );
    }
    // Fallback for any other type
    else {
      return Container(
        height: 120,
        width: 120,
        color: Colors.grey[300],
        child: const Center(child: Text('Invalid image')),
      );
    }
  }
  
  // Remove an image from the list
  void removeImage(dynamic image) {
    // If this is an existing image (WebImageFile), add it to imagesToDelete
    if (image is WebImageFile && image.id.isNotEmpty) {
      imagesToDelete.add(image);
      debugPrint('🗑️ Marked image for deletion: ${image.imageUrl} (ID: ${image.id})');
    }
    
    // Remove from the current list
    paymentProofImages.remove(image);
    
    // Check if we have any changes (additions or deletions)
    _checkForChanges();
    
    update();
  }
  
  // Show image in full screen when tapped
  void showFullScreenImage(dynamic image) {
    String imageUrl;
    
    if (image is WebImageFile) {
      imageUrl = image.imageUrl;
    } else if (image is File) {
      imageUrl = image.path;
    } else {
      debugPrint('❌ Cannot display image: Unknown image type');
      return;
    }
    
    debugPrint('📷 Showing full screen image: $imageUrl');
    
    // Show full screen image dialog
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image with pinch to zoom
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: kIsWeb
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      height: Get.height,
                      width: Get.width,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Error loading image'));
                      },
                    )
                  : Image.file(
                      File(imageUrl),
                      fit: BoxFit.contain,
                      height: Get.height,
                      width: Get.width,
                    ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }
  
  // Check if there are any changes to save (new images added or existing images removed)
  void _checkForChanges() {
    // We have changes if:
    // 1. We have images marked for deletion
    // 2. We have new images (files) added
    // 3. The current list differs from the original list
    
    bool hasChanges = false;
    
    // Check if any images are marked for deletion
    if (imagesToDelete.isNotEmpty) {
      hasChanges = true;
    }
    
    // Check if any new images have been added
    for (dynamic image in paymentProofImages) {
      if (image is File) {
        // This is a new image
        hasChanges = true;
        break;
      }
    }
    
    // Check if the number of images has changed
    if (paymentProofImages.length != originalImages.length) {
      hasChanges = true;
    }
    
    hasUnsavedChanges.value = hasChanges;
    debugPrint('💾 Has unsaved changes: $hasChanges');
  }
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;

  // Timer countdown
  final remainingTime = ''.obs;
  Timer? _countdownTimer;
  final int paymentTimeLimit = 3600; // 1 hour in seconds
  final timeRemaining = 0.obs;
  
  // Bank accounts for transfer
  final bankAccounts = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    // Get order ID and rental data from arguments
    if (Get.arguments != null) {
      if (Get.arguments['orderId'] != null) {
        orderId.value = Get.arguments['orderId'];
        
        // If rental data is passed, use it directly
        if (Get.arguments['rentalData'] != null) {
          Map<String, dynamic> rentalData = Get.arguments['rentalData'];
          debugPrint('Received rental data: $rentalData');
          
          // Pre-populate order details with rental data
          orderDetails.value = {
            'id': rentalData['id'] ?? '',
            'item_name': rentalData['name'] ?? 'Aset',
            'quantity': rentalData['jumlahUnit'] ?? 0,
            'rental_period': rentalData['waktuSewa'] ?? '',
            'duration': rentalData['duration'] ?? '',
            'price_per_unit': 0, // This might not be available in rental data
            'total_price': rentalData['totalPrice'] != null ? 
                          int.tryParse(rentalData['totalPrice'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0 : 0,
            'status': rentalData['status'] ?? 'MENUNGGU PEMBAYARAN',
            'created_at': DateTime.now().toString(),
            'denda': 0, // Default value
            'keterangan': '', // Default value
            'image_url': rentalData['imageUrl'],
            'waktu_mulai': rentalData['waktuMulai'],
            'waktu_selesai': rentalData['waktuSelesai'],
            'rentang_waktu': rentalData['rentangWaktu'],
          };
          
          // Still load additional details from the database
          checkSewaAsetTableStructure();
          loadTagihanSewaDetails().then((_) {
            // Load existing payment proof images after tagihan_sewa details are loaded
            loadExistingPaymentProofImages();
          });
          loadSewaAsetDetails();
          loadBankAccounts(); // Load bank accounts data
        } else {
          // If no rental data is passed, load everything from the database
          checkSewaAsetTableStructure();
          loadOrderDetails();
          loadTagihanSewaDetails().then((_) {
            // Load existing payment proof images after tagihan_sewa details are loaded
            loadExistingPaymentProofImages();
          });
          loadSewaAsetDetails();
          loadBankAccounts(); // Load bank accounts data
        }
      }
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    tabController.dispose();
    super.onClose();
  }

  // Load order details
  void loadOrderDetails() {
    isLoading.value = true;

    // Simulating API call
    Future.delayed(Duration(seconds: 1), () {
      // Mock data
      orderDetails.value = {
        'id': orderId.value,
        'item_name': 'Sewa Kursi Taman',
        'quantity': 5,
        'rental_period': '24 April 2023, 10:00 - 12:00',
        'duration': '2 jam',
        'price_per_unit': 10000,
        'total_price': 50000,
        'status': 'MENUNGGU PEMBAYARAN',
        'created_at':
            DateTime.now().toString(), // Use this for countdown calculation
        'denda': 20000, // Dummy data for denda
        'keterangan':
            'Terjadi kerusakan pada bagian kaki', // Dummy keterangan for denda
      };

      // Update the current step based on the status
      updateCurrentStepBasedOnStatus();

      isLoading.value = false;
      startCountdownTimer();
    });
  }

  // Load sewa_aset details with aset data
  void loadSewaAsetDetails() {
    isLoading.value = true;

    debugPrint(
      '🔍 Starting to load sewa_aset details for orderId: ${orderId.value}',
    );

    asetProvider
        .getSewaAsetWithAsetData(orderId.value)
        .then((data) {
          if (data != null) {
            // Use actual data without adding dummy values
            sewaAsetDetails.value = data;
            debugPrint(
              '✅ Sewa aset details loaded: ${sewaAsetDetails.value['id']}',
            );

            // Debug all fields in the sewaAsetDetails
            debugPrint('📋 SEWA ASET DETAILS (COMPLETE DATA):');
            data.forEach((key, value) {
              debugPrint('  $key: $value');
            });

            // Specifically debug waktu_mulai and waktu_selesai
            debugPrint('⏰ WAKTU DETAILS:');
            debugPrint('  waktu_mulai: ${data['waktu_mulai']}');
            debugPrint('  waktu_selesai: ${data['waktu_selesai']}');
            debugPrint('  denda: ${data['denda']}');
            debugPrint('  keterangan: ${data['keterangan']}');

            // If aset_detail exists, debug it too
            if (data['aset_detail'] != null) {
              debugPrint('🏢 ASET DETAILS:');
              (data['aset_detail'] as Map<String, dynamic>).forEach((
                key,
                value,
              ) {
                debugPrint('  $key: $value');
              });
            }

            // Update order details based on sewa_aset data
            orderDetails.update((val) {
              if (data['aset_detail'] != null) {
                val?['item_name'] = data['aset_detail']['nama'] ?? 'Aset Sewa';
              }
              val?['quantity'] = data['kuantitas'] ?? 1;
              val?['denda'] =
                  data['denda'] ??
                  0; // Use data from API or default to 0
              val?['keterangan'] =
                  data['keterangan'] ??
                  ''; // Use data from API or default to empty string
              
              // Update status if it exists in the data
              if (data['status'] != null && data['status'].toString().isNotEmpty) {
                val?['status'] = data['status'];
                debugPrint('📊 Order status from sewa_aset: ${data['status']}');
              }

              // Format rental period
              if (data['waktu_mulai'] != null &&
                  data['waktu_selesai'] != null) {
                try {
                  final startTime = DateTime.parse(data['waktu_mulai']);
                  final endTime = DateTime.parse(data['waktu_selesai']);
                  val?['rental_period'] =
                      '${startTime.day}/${startTime.month}/${startTime.year}, ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
                  debugPrint(
                    '✅ Successfully formatted rental period: ${val?['rental_period']}',
                  );
                } catch (e) {
                  debugPrint('❌ Error parsing date: $e');
                }
              } else {
                debugPrint(
                  '⚠️ Missing waktu_mulai or waktu_selesai for formatting rental period',
                );
              }
            });
            
            // Update the current step based on the status
            updateCurrentStepBasedOnStatus();
          } else {
            debugPrint(
              '⚠️ No sewa_aset details found for order: ${orderId.value}',
            );

            // Add dummy data when no real data is available
            sewaAsetDetails.value = {
              'id': orderId.value,
              'denda': 20000,
              'keterangan': 'Terjadi kerusakan pada bagian kaki',
            };
          }
          isLoading.value = false;
        })
        .catchError((error) {
          debugPrint('❌ Error loading sewa_aset details: $error');

          // Add dummy data in case of error
          sewaAsetDetails.value = {
            'id': orderId.value,
            'denda': 20000,
            'keterangan': 'Terjadi kerusakan pada bagian kaki',
          };

          isLoading.value = false;
        });
  }

  // Load tagihan sewa details
  Future<void> loadTagihanSewaDetails() {
    isLoading.value = true;

    // Use the AsetProvider to fetch the tagihan_sewa data
    return asetProvider
        .getTagihanSewa(orderId.value)
        .then((data) {
          if (data != null) {
            tagihanSewa.value = data;
            debugPrint('✅ Tagihan sewa loaded: ${tagihanSewa.value['id']}');
            
            // Debug the tagihan_sewa data
            debugPrint('📋 TAGIHAN SEWA DETAILS:');
            data.forEach((key, value) {
              debugPrint('  $key: $value');
            });
            
            // Specifically debug denda, keterangan, and foto_kerusakan
            debugPrint('💰 DENDA DETAILS:');
            debugPrint('  denda: ${data['denda']}');
            debugPrint('  keterangan: ${data['keterangan']}');
            debugPrint('  foto_kerusakan: ${data['foto_kerusakan']}');
          } else {
            debugPrint('⚠️ No tagihan sewa found for order: ${orderId.value}');
            // Initialize with empty data instead of mock data
            tagihanSewa.value = {
              'id': '',
              'sewa_aset_id': orderId.value,
              'denda': 0,
              'keterangan': '',
              'foto_kerusakan': '',
            };
          }
          isLoading.value = false;
        })
        .catchError((error) {
          debugPrint('❌ Error loading tagihan sewa: $error');
          // Initialize with empty data instead of mock data
          tagihanSewa.value = {
            'id': '',
            'sewa_aset_id': orderId.value,
            'denda': 0,
            'keterangan': '',
            'foto_kerusakan': '',
          };
          isLoading.value = false;
        });
  }

  // Start countdown timer (1 hour)
  void startCountdownTimer() {
    timeRemaining.value = paymentTimeLimit;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining.value <= 0) {
        timer.cancel();
        handlePaymentTimeout();
      } else {
        timeRemaining.value--;
        updateRemainingTimeDisplay();
      }
    });
  }

  // Update the time display in format HH:MM:SS
  void updateRemainingTimeDisplay() {
    int hours = timeRemaining.value ~/ 3600;
    int minutes = (timeRemaining.value % 3600) ~/ 60;
    int seconds = timeRemaining.value % 60;

    remainingTime.value =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Handle payment timeout - change status to DIBATALKAN
  void handlePaymentTimeout() {
    if (orderDetails.value['status'] == 'MENUNGGU PEMBAYARAN') {
      orderDetails.update((val) {
        val?['status'] = 'DIBATALKAN';
      });

      Get.snackbar(
        'Pesanan Dibatalkan',
        'Batas waktu pembayaran telah berakhir',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  // Change payment method
  void selectPaymentMethod(String method) {
    paymentMethod.value = method;
    update();
  }

  // Select payment type (tagihan_awal or denda)
  void selectPaymentType(String type) {
    selectedPaymentType.value = type;
    update();
  }

  // Take photo using camera
  Future<void> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        // Add to the list of images instead of replacing
        paymentProofImages.add(File(image.path));
        
        // Check for changes
        _checkForChanges();
        
        update();
      }
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Select photo from gallery
  Future<void> selectPhotoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Add to the list of images instead of replacing
        paymentProofImages.add(File(image.path));
        update();
      }
    } catch (e) {
      debugPrint('❌ Error selecting photo from gallery: $e');
      Get.snackbar(
        'Error',
        'Gagal memilih foto dari galeri: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Upload payment proof to Supabase storage and save to foto_pembayaran table
  Future<void> uploadPaymentProof() async {
    // If there are no images and none marked for deletion, show error
    if (paymentProofImages.isEmpty && imagesToDelete.isEmpty) {
      Get.snackbar(
        'Error',
        'Mohon unggah bukti pembayaran terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // If there are no changes, no need to do anything
    if (!hasUnsavedChanges.value) {
      Get.snackbar(
        'Info',
        'Tidak ada perubahan yang perlu disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;
      
      // Set up upload progress listener
      final progressNotifier = StreamController<double>();
      progressNotifier.stream.listen((progress) {
        uploadProgress.value = progress;
      });
      
      // First, delete any images marked for deletion
      if (imagesToDelete.isNotEmpty) {
        debugPrint('🗑️ Deleting ${imagesToDelete.length} images from database and storage');
        
        for (WebImageFile image in imagesToDelete) {
          // Delete the record from the foto_pembayaran table
          if (image.id.isNotEmpty) {
            debugPrint('🗑️ Deleting record with ID: ${image.id}');
            try {
              // Delete the record using the UUID string
              final result = await client
                  .from('foto_pembayaran')
                  .delete()
                  .eq('id', image.id); // ID is already a string UUID
                  
              debugPrint('🗑️ Delete result: $result');
            } catch (e) {
              debugPrint('❌ Error deleting record: $e');
              throw e; // Re-throw so the main catch block handles it
            }
            
            debugPrint('🗑️ Deleted database record with ID: ${image.id}');
            
            // Extract the file name from the URL to delete from storage
            try {
              // Parse the URL to get the filename more reliably
              Uri uri = Uri.parse(image.imageUrl);
              String path = uri.path;
              // The filename is the last part of the path after the last '/'
              final String fileName = path.substring(path.lastIndexOf('/') + 1);
              
              debugPrint('🗑️ Attempting to delete file from storage: $fileName');
              
              // Delete the file from storage
              await client.storage
                  .from('bukti.pembayaran')
                  .remove([fileName]);
              
              debugPrint('🗑️ Successfully deleted file from storage: $fileName');
            } catch (e) {
              debugPrint('⚠️ Error deleting file from storage: $e');
              // Continue even if file deletion fails - we've at least deleted from the database
            }
          }
        }
        
        // Clear the deleted images list
        imagesToDelete.clear();
      }
      
      // Upload each new image to Supabase Storage and save to database
      debugPrint('🔄 Uploading new payment proof images to Supabase storage...');
      
      List<String> uploadedUrls = [];
      List<dynamic> newImagesToUpload = [];
      List<String> existingImageUrls = [];
      
      // Separate existing WebImageFile objects from new File objects that need uploading
      for (final image in paymentProofImages) {
        if (image is WebImageFile) {
          // This is an existing image, no need to upload again
          existingImageUrls.add(image.imageUrl);
        } else if (image is File) {
          // This is a new image that needs to be uploaded
          newImagesToUpload.add(image);
        }
      }
      
      debugPrint('🔄 Found ${existingImageUrls.length} existing images and ${newImagesToUpload.length} new images to upload');
      
      // If there are new images to upload
      if (newImagesToUpload.isNotEmpty) {
        // Calculate progress increment per image
        final double progressIncrement = 1.0 / newImagesToUpload.length;
        double currentProgress = 0.0;
        
        // Upload each new image
        for (int i = 0; i < newImagesToUpload.length; i++) {
          final dynamic imageFile = newImagesToUpload[i];
          final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${orderId.value}_$i.jpg';
          
          // Create a sub-progress tracker for this image
          final subProgressNotifier = StreamController<double>();
          subProgressNotifier.stream.listen((subProgress) {
            // Calculate overall progress
            progressNotifier.add(currentProgress + (subProgress * progressIncrement));
          });
          
          // Upload to Supabase Storage
          final String? imageUrl = await _uploadToSupabaseStorage(
            imageFile, 
            fileName, 
            subProgressNotifier,
          );
          
          if (imageUrl == null) {
            throw Exception('Failed to upload image $i to storage');
          }
          
          debugPrint('✅ Image $i uploaded successfully: $imageUrl');
          uploadedUrls.add(imageUrl);
          
          // Update progress for next image
          currentProgress += progressIncrement;
        }
      } else {
        // If there are only existing images, set progress to 100%
        progressNotifier.add(1.0);
      }
      
      // Save all new URLs to foto_pembayaran table
      for (String imageUrl in uploadedUrls) {
        await _saveToFotoPembayaranTable(imageUrl);
      }
      
      // Reload the existing images to get fresh data with new IDs
      await loadExistingPaymentProofImages();
      
      // Update order status in orderDetails
      orderDetails.update((val) {
        val?['status'] = 'MEMERIKSA PEMBAYARAN';
      });
      
      // Also update the status in the sewa_aset table
      try {
        // Get the sewa_aset_id from the tagihanSewa data
        final dynamic sewaAsetId = tagihanSewa.value['sewa_aset_id'];
        
        if (sewaAsetId != null && sewaAsetId.toString().isNotEmpty) {
          debugPrint('🔄 Updating status in sewa_aset table for ID: $sewaAsetId');
          
          // Update the status in the sewa_aset table
          final updateResult = await client
              .from('sewa_aset')
              .update({'status': 'PERIKSA PEMBAYARAN'})
              .eq('id', sewaAsetId.toString());
              
          debugPrint('✅ Status updated in sewa_aset table: $updateResult');
        } else {
          debugPrint('⚠️ Could not update sewa_aset status: No valid sewa_aset_id found');
        }
      } catch (e) {
        // Don't fail the entire operation if this update fails
        debugPrint('❌ Error updating status in sewa_aset table: $e');
      }
      
      // Update current step based on status
      updateCurrentStepBasedOnStatus();

      // Cancel countdown timer as payment has been submitted
      _countdownTimer?.cancel();

      // Reset change tracking
      hasUnsavedChanges.value = false;

      // Show success message
      Get.snackbar(
        'Sukses',
        'Bukti pembayaran berhasil diunggah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Error uploading payment proof: $e');
      Get.snackbar(
        'Error',
        'Gagal mengunggah bukti pembayaran: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Go to next step
  void nextStep() {
    if (currentStep.value < 7) {
      currentStep.value++;
      updateOrderStatusBasedOnStep();
    }
  }

  // Update order status based on current step
  void updateOrderStatusBasedOnStep() {
    String newStatus;

    switch (currentStep.value) {
      case 0:
        newStatus = 'MENUNGGU PEMBAYARAN';
        break;
      case 1:
        newStatus = 'MEMERIKSA PEMBAYARAN';
        break;
      case 2:
        newStatus = 'DITERIMA';
        break;
      case 3:
        newStatus = 'PENGEMBALIAN';
        break;
      case 4:
        newStatus = 'PEMBAYARAN DENDA';
        break;
      case 5:
        newStatus = 'MEMERIKSA PEMBAYARAN DENDA';
        break;
      case 6:
        newStatus = 'SELESAI';
        break;
      default:
        newStatus = 'MENUNGGU PEMBAYARAN';
    }

    orderDetails.update((val) {
      val?['status'] = newStatus;
    });
  }
  
  // Update currentStep based on order status
  void updateCurrentStepBasedOnStatus() {
    final status = orderDetails.value['status']?.toString().toUpperCase() ?? '';
    debugPrint('📊 Updating current step based on status: $status');
    
    switch (status) {
      case 'MENUNGGU PEMBAYARAN':
        currentStep.value = 0;
        break;
      case 'MEMERIKSA PEMBAYARAN':
        currentStep.value = 1;
        break;
      case 'DITERIMA':
        currentStep.value = 2;
        break;
      case 'PENGEMBALIAN':
        currentStep.value = 3;
        break;
      case 'PEMBAYARAN DENDA':
        currentStep.value = 4;
        break;
      case 'MEMERIKSA PEMBAYARAN DENDA':
        currentStep.value = 5;
        break;
      case 'SELESAI':
        currentStep.value = 6;
        break;
      case 'DIBATALKAN':
        // Special case for canceled orders
        currentStep.value = 0;
        break;
      default:
        currentStep.value = 0;
        break;
    }
    
    debugPrint('📊 Current step updated to: ${currentStep.value}');
  }

  // This method has been moved and improved above

  // Submit cash payment
  void submitCashPayment() {
    // Update order status
    orderDetails.update((val) {
      val?['status'] = 'MEMERIKSA PEMBAYARAN';
    });

    // Cancel countdown timer as payment has been submitted
    _countdownTimer?.cancel();

    // Show success message
    Get.snackbar(
      'Sukses',
      'Pembayaran tunai berhasil disubmit',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Update step
    currentStep.value = 1;
  }

  // Cancel payment
  void cancelPayment() {
    Get.back();
  }
  
  // Debug function to check sewa_aset table structure
  void checkSewaAsetTableStructure() {
    try {
      debugPrint('🔍 DEBUG: Checking sewa_aset table structure');
      final client = asetProvider.client;

      // Get a single record to check field names
      client
          .from('sewa_aset')
          .select('*')
          .limit(1)
          .then((response) {
            if (response.isNotEmpty) {
              final record = response.first;
              debugPrint('📋 SEWA_ASET TABLE STRUCTURE:');
              debugPrint('Available fields in sewa_aset table:');

              record.forEach((key, value) {
                debugPrint('  $key: (${value != null ? value.runtimeType : 'null'})');
              });

              // Specifically check for time fields
              final timeFields = [
                'waktu_mulai',
                'waktu_selesai',
                'start_time',
                'end_time',
              ];
              for (final field in timeFields) {
                debugPrint(
                  '  Field "$field" exists: ${record.containsKey(field)}',
                );
                if (record.containsKey(field)) {
                  debugPrint('  Field "$field" value: ${record[field]}');
                }
              }
            } else {
              debugPrint('⚠️ No records found in sewa_aset table');
            }
          })
          .catchError((e) {
            debugPrint('❌ Error checking sewa_aset table: $e');
          });
    } catch (e) {
      debugPrint('❌ Error in checkSewaAsetTableStructure: $e');
    }
  }
  
  // Load bank accounts from akun_bank table
  Future<void> loadBankAccounts() async {
    debugPrint('Loading bank accounts from akun_bank table...');
    try {
      final data = await asetProvider.getBankAccounts();
      if (data.isNotEmpty) {
        bankAccounts.assignAll(data);
        debugPrint('✅ Bank accounts loaded: ${bankAccounts.length} accounts found');
        
        // Debug the bank accounts data
        debugPrint('📋 BANK ACCOUNTS DETAILS:');
        for (var account in bankAccounts) {
          debugPrint('  Bank: ${account['nama_bank']}, Account: ${account['nama_akun']}, Number: ${account['no_rekening']}');
        }
      } else {
        debugPrint('⚠️ No bank accounts found in akun_bank table');
      }
    } catch (e) {
      debugPrint('❌ Error loading bank accounts: $e');
    }
  }
  
  // Helper method to upload image to Supabase storage
  Future<String?> _uploadToSupabaseStorage(dynamic imageFile, String fileName, StreamController<double> progressNotifier) async {
    try {
      debugPrint('🔄 Uploading image to Supabase storage: $fileName');
      
      // If it's already a WebImageFile, just return the URL
      if (imageFile is WebImageFile) {
        progressNotifier.add(1.0); // No upload needed
        return imageFile.imageUrl;
      }
      
      // Handle File objects
      if (imageFile is File) {
        // Get file bytes
        List<int> fileBytes = await imageFile.readAsBytes();
        
        // Upload to Supabase Storage
        await client.storage
            .from('bukti.pembayaran')
            .uploadBinary(
              fileName,
              Uint8List.fromList(fileBytes),
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
        
        // Get public URL
        final String publicUrl = client.storage.from('bukti.pembayaran').getPublicUrl(fileName);
        
        debugPrint('✅ Upload successful: $publicUrl');
        progressNotifier.add(1.0); // Upload complete
        
        return publicUrl;
      }
      
      // If we get here, we don't know how to handle this type
      throw Exception('Unsupported image type: ${imageFile.runtimeType}');
    } catch (e) {
      debugPrint('❌ Error uploading to Supabase storage: $e');
      return null;
    } finally {
      progressNotifier.close();
    }
  }

  // Helper method to save image URL to foto_pembayaran table
  Future<void> _saveToFotoPembayaranTable(String imageUrl) async {
    try {
      debugPrint('🔄 Saving image URL to foto_pembayaran table...');
      
      // Get the tagihan_sewa_id from the tagihanSewa object
      final dynamic tagihanSewaId = tagihanSewa.value['id'];
      
      if (tagihanSewaId == null || tagihanSewaId.toString().isEmpty) {
        throw Exception('tagihan_sewa_id not found in tagihanSewa data');
      }
      
      debugPrint('🔄 Using tagihan_sewa_id: $tagihanSewaId');
      
      // Prepare the data to insert
      final Map<String, dynamic> data = {
        'tagihan_sewa_id': tagihanSewaId,
        'foto_pembayaran': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Insert data into the foto_pembayaran table
      final response = await client
          .from('foto_pembayaran')
          .insert(data)
          .select()
          .single();
      
      debugPrint('✅ Image URL saved to foto_pembayaran table: ${response['id']}');
    } catch (e) {
      debugPrint('❌ Error in _saveToFotoPembayaranTable: $e');
      throw Exception('Failed to save image URL to database: $e');
    }
  }
  
  // Load existing payment proof images
  Future<void> loadExistingPaymentProofImages() async {
    try {
      debugPrint('🔄 Loading existing payment proof images for tagihan_sewa_id: ${tagihanSewa.value['id']}');
      
      // Check if we have a valid tagihan_sewa_id
      final dynamic tagihanSewaId = tagihanSewa.value['id'];
      if (tagihanSewaId == null || tagihanSewaId.toString().isEmpty) {
        debugPrint('⚠️ No valid tagihan_sewa_id found, skipping image load');
        return;
      }
      
      // First, make a test query to see the structure of the response
      final testResponse = await client
          .from('foto_pembayaran')
          .select()
          .limit(1);
          
      // Log the test response structure
      if (testResponse.isNotEmpty) {
        debugPrint('💾 DEBUG: Test database response: ${testResponse[0]}');
        testResponse[0].forEach((key, value) {
          debugPrint('💾 DEBUG: Field $key = $value (${value?.runtimeType})');
        });
      }
      
      // Now make the actual query for this tagihan_sewa_id
      final List<dynamic> response = await client
          .from('foto_pembayaran')
          .select()
          .eq('tagihan_sewa_id', tagihanSewaId)
          .order('created_at', ascending: false);
          
      debugPrint('🔄 Found ${response.length} existing payment proof images');
      
      // Clear existing tracking lists
      paymentProofImages.clear();
      originalImages.clear();
      imagesToDelete.clear();
      hasUnsavedChanges.value = false;
      
      // Process each image in the response
      for (final item in response) {
        // Extract the image URL
        final String imageUrl = item['foto_pembayaran'];
        
        // Extract the ID - debug the item structure
        debugPrint('💾 Image data: $item');
        
        // Get the ID field - in Supabase, this is a UUID string
        String imageId = '';
        try {
          if (item.containsKey('id')) {
            final dynamic rawId = item['id'];
            if (rawId != null) {
              // Store ID as string since it's a UUID
              imageId = rawId.toString();
            }
            debugPrint('🔄 Image ID: $imageId');
          }
        } catch (e) {
          debugPrint('❌ Error getting image ID: $e');
        }
        
        // Create the WebImageFile object
        final webImageFile = WebImageFile(imageUrl);
        webImageFile.id = imageId;
        
        // Add to tracking lists
        paymentProofImages.add(webImageFile);
        originalImages.add(webImageFile);
        
        debugPrint('✅ Added image: $imageUrl with ID: $imageId');
      }
      
      // Update the UI
      update();
      
    } catch (e) {
      debugPrint('❌ Error loading payment proof images: $e');
    }
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    debugPrint('Refreshing payment page data...');
    isLoading.value = true;
    
    try {
      // Reload all data
      await Future.delayed(const Duration(milliseconds: 500)); // Small delay for better UX
      loadOrderDetails();
      loadTagihanSewaDetails();
      loadSewaAsetDetails();
      loadBankAccounts(); // Load bank accounts data
      
      // Explicitly update the current step based on the status
      // This ensures the progress timeline is always in sync with the actual status
      updateCurrentStepBasedOnStatus();
      
      // Restart countdown timer if needed
      if (orderDetails.value['status'] == 'MENUNGGU PEMBAYARAN') {
        _countdownTimer?.cancel();
        startCountdownTimer();
      }
      
      debugPrint('Data refresh completed');
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
    
    return Future.value();
  }
}
