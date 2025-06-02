import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PetugasTambahPaketController extends GetxController {
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final itemQuantityController = TextEditingController();

  // Dropdown and toggle values
  final selectedCategory = 'Bulanan'.obs;
  final selectedStatus = 'Aktif'.obs;

  // Category options
  final categoryOptions = ['Bulanan', 'Tahunan', 'Premium', 'Bisnis'];
  final statusOptions = ['Aktif', 'Nonaktif'];

  // Images
  final selectedImages = <String>[].obs;

  // For package name and description
  final packageNameController = TextEditingController();
  final packageDescriptionController = TextEditingController();
  final packagePriceController = TextEditingController();

  // For items/assets in the package
  final RxList<Map<String, dynamic>> packageItems =
      <Map<String, dynamic>>[].obs;

  // For asset selection
  final RxList<Map<String, dynamic>> availableAssets =
      <Map<String, dynamic>>[].obs;
  final Rx<int?> selectedAsset = Rx<int?>(null);
  final RxBool isLoadingAssets = false.obs;

  // Form validation
  final isFormValid = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to field changes for validation
    nameController.addListener(validateForm);
    descriptionController.addListener(validateForm);
    priceController.addListener(validateForm);

    // Load available assets when the controller initializes
    fetchAvailableAssets();
  }

  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    itemQuantityController.dispose();
    packageNameController.dispose();
    packageDescriptionController.dispose();
    packagePriceController.dispose();
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

  // Add image to the list (in a real app, this would handle file upload)
  void addImage(String imagePath) {
    selectedImages.add(imagePath);
    validateForm();
  }

  // Remove image from the list
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      validateForm();
    }
  }

  // Fetch available assets from the API or local data
  void fetchAvailableAssets() {
    isLoadingAssets.value = true;

    // This is a mock implementation - replace with actual API call
    Future.delayed(const Duration(seconds: 1), () {
      availableAssets.value = [
        {'id': 1, 'nama': 'Laptop Dell XPS', 'stok': 5},
        {'id': 2, 'nama': 'Proyektor Epson', 'stok': 3},
        {'id': 3, 'nama': 'Meja Kantor', 'stok': 10},
        {'id': 4, 'nama': 'Kursi Ergonomis', 'stok': 15},
        {'id': 5, 'nama': 'Printer HP LaserJet', 'stok': 2},
        {'id': 6, 'nama': 'AC Panasonic 1PK', 'stok': 8},
      ];
      isLoadingAssets.value = false;
    });
  }

  // Set the selected asset
  void setSelectedAsset(int? assetId) {
    selectedAsset.value = assetId;
  }

  // Get remaining stock for an asset (considering current selections)
  int getRemainingStock(int assetId) {
    // Find the asset in available assets
    final asset = availableAssets.firstWhere(
      (item) => item['id'] == assetId,
      orElse: () => <String, dynamic>{},
    );

    if (asset.isEmpty) return 0;

    // Get total stock
    final totalStock = asset['stok'] as int;

    // Calculate how many of this asset are already in the package
    int alreadySelected = 0;
    for (var item in packageItems) {
      if (item['asetId'] == assetId) {
        alreadySelected += item['jumlah'] as int;
      }
    }

    // Return the remaining available stock
    return totalStock - alreadySelected;
  }

  // Add an asset to the package
  void addAssetToPackage() {
    if (selectedAsset.value == null || itemQuantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih aset dan masukkan jumlah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Find the selected asset
    final asset = availableAssets.firstWhere(
      (item) => item['id'] == selectedAsset.value,
      orElse: () => <String, dynamic>{},
    );

    if (asset.isEmpty) return;

    // Convert quantity to int
    final quantity = int.tryParse(itemQuantityController.text) ?? 0;
    if (quantity <= 0) {
      Get.snackbar(
        'Error',
        'Jumlah harus lebih dari 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if quantity is within limits
    final remainingStock = getRemainingStock(selectedAsset.value!);
    if (quantity > remainingStock) {
      Get.snackbar(
        'Error',
        'Jumlah melebihi stok yang tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Add the item to package
    packageItems.add({
      'asetId': selectedAsset.value,
      'nama': asset['nama'],
      'jumlah': quantity,
      'stok': asset['stok'],
    });

    // Clear selection
    selectedAsset.value = null;
    itemQuantityController.clear();

    Get.snackbar(
      'Sukses',
      'Item berhasil ditambahkan ke paket',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Update an existing package item
  void updatePackageItem(int index) {
    if (selectedAsset.value == null || itemQuantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih aset dan masukkan jumlah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Find the selected asset
    final asset = availableAssets.firstWhere(
      (item) => item['id'] == selectedAsset.value,
      orElse: () => <String, dynamic>{},
    );

    if (asset.isEmpty) return;

    // Convert quantity to int
    final quantity = int.tryParse(itemQuantityController.text) ?? 0;
    if (quantity <= 0) {
      Get.snackbar(
        'Error',
        'Jumlah harus lebih dari 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // If updating the same asset, check remaining stock + current quantity
    final currentItem = packageItems[index];
    int availableQuantity = asset['stok'] as int;

    // If editing the same asset, we need to consider its current quantity
    if (currentItem['asetId'] == selectedAsset.value) {
      // For the same asset, we can reuse its current quantity
      final alreadyUsed = packageItems
          .where(
            (item) =>
                item['asetId'] == selectedAsset.value &&
                packageItems.indexOf(item) != index,
          )
          .fold(0, (sum, item) => sum + (item['jumlah'] as int));

      availableQuantity -= alreadyUsed;

      if (quantity > availableQuantity) {
        Get.snackbar(
          'Error',
          'Jumlah melebihi stok yang tersedia',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      // If changing to a different asset, check the new asset's remaining stock
      final remainingStock = getRemainingStock(selectedAsset.value!);
      if (quantity > remainingStock) {
        Get.snackbar(
          'Error',
          'Jumlah melebihi stok yang tersedia',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Update the item
    packageItems[index] = {
      'asetId': selectedAsset.value,
      'nama': asset['nama'],
      'jumlah': quantity,
      'stok': asset['stok'],
    };

    // Clear selection
    selectedAsset.value = null;
    itemQuantityController.clear();

    Get.snackbar(
      'Sukses',
      'Item berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Remove an item from the package
  void removeItem(int index) {
    packageItems.removeAt(index);
    Get.snackbar(
      'Dihapus',
      'Item berhasil dihapus dari paket',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Validate form fields
  void validateForm() {
    // Basic validation
    bool basicValid =
        nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        int.tryParse(priceController.text) != null;

    // Package should have at least one item
    bool hasItems = packageItems.isNotEmpty;

    isFormValid.value = basicValid && hasItems;
  }

  // Submit form and save package
  Future<void> savePaket() async {
    if (!isFormValid.value) return;

    isSubmitting.value = true;

    try {
      // In a real app, this would make an API call to save the package
      await Future.delayed(const Duration(seconds: 1)); // Mock API call

      // Prepare package data
      final paketData = {
        'nama': nameController.text,
        'deskripsi': descriptionController.text,
        'kategori': selectedCategory.value,
        'status': selectedStatus.value == 'Aktif',
        'harga': int.parse(priceController.text),
        'gambar': selectedImages,
        'items': packageItems,
      };

      // Log the data (in a real app, this would be sent to an API)
      print('Package data: $paketData');

      // Return to the package list page
      Get.back();

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Paket berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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

  // Old sample method (will be replaced)
  void addSampleItem() {
    packageItems.add({'nama': 'Laptop Dell XPS', 'jumlah': 1});
  }

  // Method untuk menambahkan gambar sample
  void addSampleImage() {
    // Menambahkan URL gambar dummy untuk keperluan pengembangan
    selectedImages.add('https://example.com/sample_image.jpg');
    validateForm();
  }
}
