import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors_petugas.dart';
import '../controllers/petugas_tambah_aset_controller.dart';

class PetugasTambahAsetView extends GetView<PetugasTambahAsetController> {
  const PetugasTambahAsetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Obx(() => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            controller.isEditing.value ? 'Edit Aset' : 'Tambah Aset',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColorsPetugas.navyBlue,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    _buildFormSection(context),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColorsPetugas.blueGrotto),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      )),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 5),  // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorsPetugas.navyBlue, AppColorsPetugas.blueGrotto],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        height: 12,  // Further reduced height
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Basic Information Section
          _buildSectionHeader(
            icon: Icons.info_outline,
            title: 'Informasi Dasar',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Nama Aset',
            hint: 'Masukkan nama aset',
            controller: controller.nameController,
            isRequired: true,
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Deskripsi',
            hint: 'Masukkan deskripsi aset',
            controller: controller.descriptionController,
            maxLines: 3,
            isRequired: true,
            prefixIcon: Icons.description,
          ),
          const SizedBox(height: 24),

          // Media Section
          _buildSectionHeader(
            icon: Icons.photo_library,
            title: 'Media & Gambar',
          ),
          const SizedBox(height: 16),
          _buildImageUploader(),
          const SizedBox(height: 24),

          // Status Section
          _buildSectionHeader(icon: Icons.check_circle, title: 'Status'),
          const SizedBox(height: 16),

          // Status card
          _buildCategorySelect(
            title: 'Status',
            options: controller.statusOptions,
            selectedOption: controller.selectedStatus,
            onChanged: controller.setStatus,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 24),

          // Quantity Section
          _buildSectionHeader(
            icon: Icons.format_list_numbered,
            title: 'Kuantitas',
          ),
          const SizedBox(height: 16),

          // Quantity field
          _buildTextField(
            label: 'Kuantitas',
            hint: 'Jumlah aset',
            controller: controller.quantityController,
            isRequired: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.numbers,
          ),
          const SizedBox(height: 24),

          // Rental Options Section
          _buildSectionHeader(
            icon: Icons.schedule,
            title: 'Opsi Waktu & Harga Sewa',
          ),
          const SizedBox(height: 16),

          // Time Options as cards
          _buildTimeOptionsCards(),
          const SizedBox(height: 16),

          // Rental price fields based on selection
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Per Hour Option
                if (controller.timeOptions['Per Jam']!.value)
                  _buildPriceCard(
                    title: 'Harga Per Jam',
                    icon: Icons.timer,
                    priceController: controller.pricePerHourController,
                    maxController: controller.maxHourController,
                    maxLabel: 'Maksimal Jam',
                  ),

                if (controller.timeOptions['Per Jam']!.value &&
                    controller.timeOptions['Per Hari']!.value)
                  const SizedBox(height: 16),

                // Per Day Option
                if (controller.timeOptions['Per Hari']!.value)
                  _buildPriceCard(
                    title: 'Harga Per Hari',
                    icon: Icons.calendar_today,
                    priceController: controller.pricePerDayController,
                    maxController: controller.maxDayController,
                    maxLabel: 'Maksimal Hari',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTimeOptionsCards() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            controller.timeOptions.entries.map((entry) {
              final option = entry.key;
              final isSelected = entry.value;

              return Obx(
                () => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.toggleTimeOption(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected.value
                                      ? AppColorsPetugas.blueGrotto.withOpacity(
                                        0.1,
                                      )
                                      : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              option == 'Per Jam'
                                  ? Icons.hourglass_bottom
                                  : Icons.calendar_today,
                              color:
                                  isSelected.value
                                      ? AppColorsPetugas.blueGrotto
                                      : Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected.value
                                            ? AppColorsPetugas.navyBlue
                                            : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  option == 'Per Jam'
                                      ? 'Sewa aset dengan basis perhitungan per jam'
                                      : 'Sewa aset dengan basis perhitungan per hari',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected.value,
                            onChanged:
                                (_) => controller.toggleTimeOption(option),
                            activeColor: AppColorsPetugas.blueGrotto,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required IconData icon,
    required TextEditingController priceController,
    required TextEditingController maxController,
    required String maxLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsPetugas.babyBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColorsPetugas.blueGrotto),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColorsPetugas.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Sewa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColorsPetugas.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Masukkan harga',
                        hintStyle: TextStyle(color: AppColorsPetugas.textLight),
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: AppColorsPetugas.babyBlueBright,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maxLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColorsPetugas.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Opsional',
                        hintStyle: TextStyle(color: AppColorsPetugas.textLight),
                        filled: true,
                        fillColor: AppColorsPetugas.babyBlueBright,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsPetugas.blueGrotto.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColorsPetugas.blueGrotto, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColorsPetugas.navyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColorsPetugas.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColorsPetugas.textLight),
            filled: true,
            fillColor: AppColorsPetugas.babyBlueBright,
            prefixText: prefixText,
            prefixIcon:
                prefixIcon != null
                    ? Icon(
                      prefixIcon,
                      size: 20,
                      color: AppColorsPetugas.textSecondary,
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColorsPetugas.blueGrotto,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelect({
    required String title,
    required List<String> options,
    required RxString selectedOption,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColorsPetugas.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: selectedOption.value,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: AppColorsPetugas.blueGrotto,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColorsPetugas.babyBlueBright,
              ),
              items:
                  options.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          color: AppColorsPetugas.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColorsPetugas.blueGrotto,
              ),
              dropdownColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Show image source options
  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorsPetugas.navyBlue,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Get.back();
                    controller.pickImageFromCamera();
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Get.back();
                    controller.pickImageFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColorsPetugas.babyBlueBright,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColorsPetugas.blueGrotto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColorsPetugas.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsPetugas.babyBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unggah Foto Aset',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsPetugas.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan foto aset untuk informasi visual.',
            style: TextStyle(
              fontSize: 12,
              color: AppColorsPetugas.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Add button
                GestureDetector(
                  onTap: _showImageSourceOptions,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColorsPetugas.babyBlueBright,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColorsPetugas.babyBlue,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColorsPetugas.blueGrotto,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambah Foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorsPetugas.blueGrotto,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Image previews
                ...List<Widget>.generate(
                  controller.selectedImages.length,
                  (index) => Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Obx(
                          () {
                            // Check if we have a network URL for this index
                            if (index < controller.networkImageUrls.length && 
                                controller.networkImageUrls[index].isNotEmpty) {
                              // Display network image
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  controller.networkImageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error_outline, color: Colors.red),
                                    );
                                  },
                                ),
                              );
                            } else {
                              // Display local file
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<File>(
                                  future: File(controller.selectedImages[index].path).exists().then((exists) {
                                    if (exists) {
                                      return File(controller.selectedImages[index].path);
                                    } else {
                                      return File(controller.selectedImages[index].path);
                                    }
                                  }),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Image.file(
                                        snapshot.data!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      );
                                    } else {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Batal'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsPetugas.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              side: BorderSide(color: AppColorsPetugas.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() {
              final isValid = controller.isFormValid.value;
              final isSubmitting = controller.isSubmitting.value;
              return ElevatedButton.icon(
                onPressed:
                    isValid && !isSubmitting ? controller.saveAsset : null,
                icon:
                    isSubmitting
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Obx(() => Text(
                  isSubmitting ? 'Menyimpan...' : (controller.isEditing.value ? 'Simpan Perubahan' : 'Simpan Aset'),
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPetugas.blueGrotto,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: AppColorsPetugas.textLight,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
