import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PetugasTambahAsetController extends GetxController {
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

  // Images
  final selectedImages = <String>[].obs;

  // Form validation
  final isFormValid = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set default values
    quantityController.text = '1';
    unitOfMeasureController.text = 'Unit';

    // Listen to field changes for validation
    nameController.addListener(validateForm);
    descriptionController.addListener(validateForm);
    quantityController.addListener(validateForm);
    pricePerHourController.addListener(validateForm);
    pricePerDayController.addListener(validateForm);
  }

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

  // Submit form and save asset
  Future<void> saveAsset() async {
    if (!isFormValid.value) return;

    isSubmitting.value = true;

    try {
      // In a real app, this would make an API call to save the asset
      await Future.delayed(const Duration(seconds: 1)); // Mock API call

      // Prepare asset data
      final assetData = {
        'nama': nameController.text,
        'deskripsi': descriptionController.text,
        'kategori': selectedCategory.value,
        'status': selectedStatus.value,
        'kuantitas': int.parse(quantityController.text),
        'satuan_ukur': unitOfMeasureController.text,
        'opsi_waktu_sewa':
            timeOptions.entries
                .where((entry) => entry.value.value)
                .map((entry) => entry.key)
                .toList(),
        'harga_per_jam':
            timeOptions['Per Jam']!.value
                ? int.parse(pricePerHourController.text)
                : null,
        'max_jam':
            timeOptions['Per Jam']!.value && maxHourController.text.isNotEmpty
                ? int.parse(maxHourController.text)
                : null,
        'harga_per_hari':
            timeOptions['Per Hari']!.value
                ? int.parse(pricePerDayController.text)
                : null,
        'max_hari':
            timeOptions['Per Hari']!.value && maxDayController.text.isNotEmpty
                ? int.parse(maxDayController.text)
                : null,
        'gambar': selectedImages,
      };

      // Log the data (in a real app, this would be sent to an API)
      print('Asset data: $assetData');

      // Return to the asset list page
      Get.back();

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Aset berhasil ditambahkan',
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

  // For demonstration purposes: add sample image
  void addSampleImage() {
    addImage('assets/images/sample_asset_${selectedImages.length + 1}.jpg');
  }
}
