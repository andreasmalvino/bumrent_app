import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bumrent_app/app/data/models/aset_model.dart';
import 'package:bumrent_app/app/data/providers/aset_provider.dart';

class PetugasTambahAsetController extends GetxController {
  // Flag to check if in edit mode
  final isEditing = false.obs;
  String? assetId; // To store the ID of the asset being edited

  @override
  Future<void> onInit() async {
    super.onInit();
    
    try {
      // Handle edit mode and load data if needed
      final args = Get.arguments;
      debugPrint('[DEBUG] PetugasTambahAsetController initialized with args: $args');
      
      if (args != null && args is Map<String, dynamic>) {
        isEditing.value = args['isEditing'] ?? false;
        debugPrint('[DEBUG] isEditing set to: ${isEditing.value}');
        
        if (isEditing.value) {
          // Get asset ID from arguments
          final assetId = args['assetId']?.toString() ?? '';
          debugPrint('[DEBUG] Edit mode: Loading asset with ID: $assetId');
          
          if (assetId.isNotEmpty) {
            // Store the asset ID and load asset data
            this.assetId = assetId;
            debugPrint('[DEBUG] Asset ID set to: $assetId');
            
            // Load asset data and await completion
            await _loadAssetData(assetId);
          } else {
            debugPrint('[ERROR] Edit mode but no assetId provided in arguments');
            Get.snackbar(
              'Error',
              'ID Aset tidak ditemukan',
              snackPosition: SnackPosition.BOTTOM,
            );
            // Optionally navigate back if in edit mode without an ID
            Future.delayed(Duration.zero, () => Get.back());
          }
        } else {
          // Set default values for new asset
          debugPrint('[DEBUG] Add new asset mode');
          quantityController.text = '1';
          unitOfMeasureController.text = 'Unit';
        }
      } else {
        // Default values for new asset when no arguments are passed
        debugPrint('[DEBUG] No arguments passed, defaulting to add new asset mode');
        quantityController.text = '1';
        unitOfMeasureController.text = 'Unit';
      }
    } catch (e, stackTrace) {
      debugPrint('[ERROR] Error in onInit: $e');
      debugPrint('Stack trace: $stackTrace');
      // Ensure loading is set to false even if there's an error
      isLoading.value = false;
      
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // Listen to field changes for validation
    nameController.addListener(validateForm);
    descriptionController.addListener(validateForm);
    quantityController.addListener(validateForm);
    pricePerHourController.addListener(validateForm);
    pricePerDayController.addListener(validateForm);
  }

  final AsetProvider _asetProvider = Get.find<AsetProvider>();
  final isLoading = false.obs;

  Future<void> _loadAssetData(String assetId) async {
    try {
      isLoading.value = true;
      debugPrint('[DEBUG] Fetching asset data for ID: $assetId');
      
      // Fetch asset data from Supabase
      final aset = await _asetProvider.getAsetById(assetId);
      
      if (aset == null) {
        throw Exception('Aset tidak ditemukan');
      }
      
      debugPrint('[DEBUG] Successfully fetched asset data: ${aset.toJson()}');
      
      // Populate form fields with the fetched data
      nameController.text = aset.nama ?? '';
      descriptionController.text = aset.deskripsi ?? '';
      quantityController.text = (aset.kuantitas ?? 1).toString();
      
      // Ensure the status matches one of the available options exactly
      final status = aset.status?.toLowerCase() ?? 'tersedia';
      if (status == 'tersedia') {
        selectedStatus.value = 'Tersedia';
      } else if (status == 'pemeliharaan') {
        selectedStatus.value = 'Pemeliharaan';
      } else {
        // Default to 'Tersedia' if status is not recognized
        selectedStatus.value = 'Tersedia';
      }
      
      // Handle time options and pricing
      if (aset.satuanWaktuSewa != null && aset.satuanWaktuSewa!.isNotEmpty) {
        // Reset time options
        timeOptions.forEach((key, value) => value.value = false);
        
        // Process each satuan waktu sewa
        for (var sws in aset.satuanWaktuSewa) {
          final satuan = sws['nama_satuan_waktu']?.toString().toLowerCase() ?? '';
          final harga = sws['harga'] as int? ?? 0;
          final maksimalWaktu = sws['maksimal_waktu'] as int? ?? 24;
          
          if (satuan.contains('jam')) {
            timeOptions['Per Jam']?.value = true;
            pricePerHourController.text = harga.toString();
            maxHourController.text = maksimalWaktu.toString();
          } else if (satuan.contains('hari')) {
            timeOptions['Per Hari']?.value = true;
            pricePerDayController.text = harga.toString();
            maxDayController.text = maksimalWaktu.toString();
          }
        }
      }
      
      // Clear existing images
      selectedImages.clear();
      networkImageUrls.clear();
      
      // Get all image URLs from the model
      final allImageUrls = aset.imageUrls.toList();
      
      // If no imageUrls but has imageUrl, use that as fallback (backward compatibility)
      if (allImageUrls.isEmpty && aset.imageUrl != null && aset.imageUrl!.isNotEmpty) {
        allImageUrls.add(aset.imageUrl!);
      }
      
      // Add all images to the lists
      for (final imageUrl in allImageUrls) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            // For network images, we'll store the URL in networkImageUrls
            // and create a dummy XFile with the URL as path for backward compatibility
            final dummyFile = XFile(imageUrl);
            selectedImages.add(dummyFile);
            networkImageUrls.add(imageUrl);
            debugPrint('Added network image: $imageUrl');
          } catch (e) {
            debugPrint('Error adding network image: $e');
          }
        }
      }
      
      debugPrint('Total ${networkImageUrls.length} images loaded for asset $assetId');
      debugPrint('[DEBUG] Successfully loaded asset data for ID: $assetId');
    } catch (e, stackTrace) {
      debugPrint('[ERROR] Failed to load asset data: $e');
      debugPrint('Stack trace: $stackTrace');
      
      Get.snackbar(
        'Error',
        'Gagal memuat data aset: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      // Optionally navigate back if there's an error
      Future.delayed(const Duration(seconds: 2), () => Get.back());
    } finally {
      isLoading.value = false;
    }
  }
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final unitOfMeasureController = TextEditingController();
  final pricePerHourController = TextEditingController();
  final maxHourController = TextEditingController();
  final pricePerDayController = TextEditingController();
  final maxDayController = TextEditingController();

  // Dropdown and toggle values
  final selectedCategory = 'Sewa'.obs;
  final selectedStatus = 'Tersedia'.obs;

  // Replace single selection with multiple selections
  final timeOptions = {'Per Jam': true.obs, 'Per Hari': false.obs};

  // Category options
  final categoryOptions = ['Sewa', 'Langganan'];
  final statusOptions = ['Tersedia', 'Pemeliharaan'];

  // List to store selected images
  final RxList<XFile> selectedImages = <XFile>[].obs;
  // List to store network image URLs
  final RxList<String> networkImageUrls = <String>[].obs;
  final _picker = ImagePicker();

  // Form validation
  final isFormValid = false.obs;
  final isSubmitting = false.obs;



  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    unitOfMeasureController.dispose();
    pricePerHourController.dispose();
    maxHourController.dispose();
    pricePerDayController.dispose();
    maxDayController.dispose();
    super.onClose();
  }

  // Change selected category
  void setCategory(String category) {
    selectedCategory.value = category;
    validateForm();
  }

  // Change selected status
  void setStatus(String status) {
    selectedStatus.value = status;
    validateForm();
  }

  // Toggle time option
  void toggleTimeOption(String option) {
    timeOptions[option]?.value = !(timeOptions[option]?.value ?? false);

    // Ensure at least one option is selected
    bool anySelected = false;
    timeOptions.forEach((key, value) {
      if (value.value) anySelected = true;
    });

    // If none selected, force this one to remain selected
    if (!anySelected) {
      timeOptions[option]?.value = true;
    }
    
    validateForm();
  }

  
  // Create a new asset in Supabase
  Future<String?> _createAsset(
    Map<String, dynamic> assetData,
    List<Map<String, dynamic>> satuanWaktuSewa,
  ) async {
    try {
      // Create the asset in the 'aset' table
      final response = await _asetProvider.createAset(assetData);
      
      if (response == null || response['id'] == null) {
        debugPrint('❌ Failed to create asset: No response or ID from server');
        return null;
      }

      final String assetId = response['id'].toString();
      debugPrint('✅ Asset created with ID: $assetId');

      // Add satuan waktu sewa
      for (var sws in satuanWaktuSewa) {
        final success = await _asetProvider.addSatuanWaktuSewa(
          asetId: assetId,
          satuanWaktu: sws['satuan_waktu'],
          harga: sws['harga'],
          maksimalWaktu: sws['maksimal_waktu'],
        );
        
        if (!success) {
          debugPrint('❌ Failed to add satuan waktu sewa: $sws');
        }
      }

      return assetId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating asset: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Update an existing asset in Supabase
  Future<bool> _updateAsset(
    String assetId,
    Map<String, dynamic> assetData,
    List<Map<String, dynamic>> satuanWaktuSewa,
  ) async {
    try {
      debugPrint('\n🔄 Starting update for asset ID: $assetId');
      
      // 1. Extract and remove foto_aset from assetData as it's not in the aset table
      final fotoAsetUrl = assetData['foto_aset'];
      assetData.remove('foto_aset');
      debugPrint('📝 Asset data prepared for update (without foto_aset)');
      
      // 2. Update the main asset data (without foto_aset)
      debugPrint('🔄 Updating main asset data...');
      final success = await _asetProvider.updateAset(assetId, assetData);
      if (!success) {
        debugPrint('❌ Failed to update asset with ID: $assetId');
        return false;
      }
      debugPrint('✅ Successfully updated main asset data');

      // 3. Update satuan waktu sewa
      debugPrint('\n🔄 Updating rental time units...');
      // First, delete existing satuan waktu sewa
      await _asetProvider.deleteSatuanWaktuSewaByAsetId(assetId);
      
      // Then add the new ones
      for (var sws in satuanWaktuSewa) {
        debugPrint('   - Adding: ${sws['satuan_waktu']} (${sws['harga']} IDR)');
        await _asetProvider.addSatuanWaktuSewa(
          asetId: assetId,
          satuanWaktu: sws['satuan_waktu'],
          harga: sws['harga'] as int,
          maksimalWaktu: sws['maksimal_waktu'] as int,
        );
      }
      debugPrint('✅ Successfully updated rental time units');

      // 4. Update photos in the foto_aset table if any exist
      if (selectedImages.isNotEmpty || networkImageUrls.isNotEmpty) {
        // Combine network URLs and local file paths
        final List<String> allImageUrls = [
          ...networkImageUrls,
          ...selectedImages.map((file) => file.path),
        ];
        
        debugPrint('\n🖼️  Processing photos for asset $assetId');
        debugPrint('   - Network URLs: ${networkImageUrls.length}');
        debugPrint('   - Local files: ${selectedImages.length}');
        debugPrint('   - Total unique photos: ${allImageUrls.toSet().length} (before deduplication)');
        
        try {
          // Use updateFotoAset which handles both uploading new photos and updating the database
          final photoSuccess = await _asetProvider.updateFotoAset(
            asetId: assetId,
            fotoUrls: allImageUrls,
          );
          
          if (!photoSuccess) {
            debugPrint('⚠️  Some photos might not have been updated for asset $assetId');
            // We don't fail the whole update if photo update fails
            // as the main asset data has been saved successfully
          } else {
            debugPrint('✅ Successfully updated photos for asset $assetId');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error updating photos: $e');
          debugPrint('Stack trace: $stackTrace');
          // Continue with the update even if photo update fails
        }
      } else {
        debugPrint('ℹ️  No photos to update');
      }

      debugPrint('\n✅ Asset update completed successfully for ID: $assetId');
      return true;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating asset: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Remove an image from the selected images list
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      // Remove from both lists if they have an entry at this index
      if (index < networkImageUrls.length) {
        networkImageUrls.removeAt(index);
      }
      selectedImages.removeAt(index);
    }
  }

  // Validate form fields
  void validateForm() {
    // Basic validation
    bool basicValid =
        nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        int.tryParse(quantityController.text) != null;

    // Time option validation
    bool perHourValid =
        !timeOptions['Per Jam']!.value ||
        (pricePerHourController.text.isNotEmpty &&
            int.tryParse(pricePerHourController.text) != null);

    bool perDayValid =
        !timeOptions['Per Hari']!.value ||
        (pricePerDayController.text.isNotEmpty &&
            int.tryParse(pricePerDayController.text) != null);

    // At least one time option must be selected
    bool anyTimeOptionSelected = false;
    timeOptions.forEach((key, value) {
      if (value.value) anyTimeOptionSelected = true;
    });

    isFormValid.value =
        basicValid && perHourValid && perDayValid && anyTimeOptionSelected;
  }

  // Submit form and save or update asset
  Future<void> saveAsset() async {
    if (!isFormValid.value) return;

    isSubmitting.value = true;

    try {
      // Prepare the basic asset data
      final Map<String, dynamic> assetData = {
        'nama': nameController.text,
        'deskripsi': descriptionController.text,
        'kategori': 'sewa', // Default to 'sewa' category
        'status': selectedStatus.value,
        'kuantitas': int.parse(quantityController.text),
        'satuan_ukur': 'unit', // Default unit of measure
      };

      // Handle time options and pricing
      final List<Map<String, dynamic>> satuanWaktuSewa = [];
      
      if (timeOptions['Per Jam']?.value == true) {
        final hargaPerJam = int.tryParse(pricePerHourController.text) ?? 0;
        final maxJam = int.tryParse(maxHourController.text) ?? 24;
        
        if (hargaPerJam <= 0) {
          throw Exception('Harga per jam harus lebih dari 0');
        }
        
        satuanWaktuSewa.add({
          'satuan_waktu': 'jam',
          'harga': hargaPerJam,
          'maksimal_waktu': maxJam,
        });
      }
      
      if (timeOptions['Per Hari']?.value == true) {
        final hargaPerHari = int.tryParse(pricePerDayController.text) ?? 0;
        final maxHari = int.tryParse(maxDayController.text) ?? 30;
        
        if (hargaPerHari <= 0) {
          throw Exception('Harga per hari harus lebih dari 0');
        }
        
        satuanWaktuSewa.add({
          'satuan_waktu': 'hari',
          'harga': hargaPerHari,
          'maksimal_waktu': maxHari,
        });
      }

      // Validate that at least one time option is selected
      if (satuanWaktuSewa.isEmpty) {
        throw Exception('Pilih setidaknya satu opsi waktu sewa (jam/hari)');
      }

      // Handle image uploads
      List<String> imageUrls = [];
      
      if (networkImageUrls.isNotEmpty) {
        // Use existing network URLs
        imageUrls = List.from(networkImageUrls);
      } else if (selectedImages.isNotEmpty) {
        // For local files, we'll upload them to Supabase Storage
        // Store the file paths for now, they'll be uploaded in the provider
        imageUrls = selectedImages.map((file) => file.path).toList();
        debugPrint('Found ${imageUrls.length} local images to upload');
      } else if (!isEditing.value) {
        // For new assets, require at least one image
        throw Exception('Harap unggah setidaknya satu gambar');
      }

      // Ensure at least one image is provided for new assets
      if (imageUrls.isEmpty && !isEditing.value) {
        throw Exception('Harap unggah setidaknya satu gambar');
      }

      // Create or update the asset
      bool success;
      String? createdAssetId;
      
      if (isEditing.value && (assetId?.isNotEmpty ?? false)) {
        // Update existing asset
        debugPrint('🔄 Updating asset with ID: $assetId');
        success = await _updateAsset(assetId!, assetData, satuanWaktuSewa);
        
        // Update all photos if we have any
        if (success && imageUrls.isNotEmpty) {
          await _asetProvider.updateFotoAset(
            asetId: assetId!,
            fotoUrls: imageUrls,
          );
        }
      } else {
        // Create new asset
        debugPrint('🔄 Creating new asset');
        createdAssetId = await _createAsset(assetData, satuanWaktuSewa);
        success = createdAssetId != null;
        
        // Add all photos for new asset
        if (success && createdAssetId != null && imageUrls.isNotEmpty) {
          await _asetProvider.updateFotoAset(
            asetId: createdAssetId,
            fotoUrls: imageUrls,
          );
        }
      }

      if (success) {
        // Show success message
        Get.snackbar(
          'Sukses',
          isEditing.value ? 'Aset berhasil diperbarui' : 'Aset berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate back with success after a short delay
        await Future.delayed(const Duration(seconds: 1));
        Get.back(result: true);
      } else {
        throw Exception('Gagal menyimpan aset');
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  
  // Example method to upload images (to be implemented with your backend)
  // Future<List<String>> _uploadImages(List<XFile> images) async {
  //   List<String> urls = [];
  //   for (var image in images) {
  //     // Upload image to your server and get the URL
  //     // final url = await yourApiService.uploadImage(File(image.path));
  //     // urls.add(url);
  //     urls.add('https://example.com/path/to/uploaded/image.jpg'); // Mock URL
  //   }
  //   return urls;
  // }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        selectedImages.add(image);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil gambar dari kamera: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar dari galeri: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // For demonstration purposes: add sample image
  void addSampleImage() {
    // In a real app, this would open the image picker
    selectedImages.add(XFile('assets/images/sample_asset_${selectedImages.length + 1}.jpg'));
    validateForm();
  }
}
