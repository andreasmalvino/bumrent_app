import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors_petugas.dart';
import '../controllers/petugas_tambah_paket_controller.dart';
import 'dart:io';

class PetugasTambahPaketView extends GetView<PetugasTambahPaketController> {
  const PetugasTambahPaketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isViewing.value
                ? 'Detail Paket'
                : (controller.isEditing.value ? 'Edit Paket' : 'Tambah Paket'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildFormSection(context)],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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
            label: 'Nama Paket',
            hint: 'Masukkan nama paket',
            controller: controller.nameController,
            isRequired: true,
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Deskripsi',
            hint: 'Masukkan deskripsi paket',
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

          // Category Section
          _buildSectionHeader(icon: Icons.category, title: 'Status'),
          const SizedBox(height: 16),

          // Category and Status as cards
          Row(
            children: [
              // Expanded(
              //   child: _buildCategorySelect(
              //     title: 'Kategori',
              //     options: controller.categoryOptions,
              //     selectedOption: controller.selectedCategory,
              //     onChanged: controller.setCategory,
              //     icon: Icons.category,
              //   ),
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: _buildCategorySelect(
                  title: 'Status',
                  options: controller.statusOptions,
                  selectedOption: controller.selectedStatus,
                  onChanged: controller.setStatus,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Package Items Section
          _buildSectionHeader(
            icon: Icons.inventory_2,
            title: 'Item dalam Paket',
          ),
          const SizedBox(height: 16),
          _buildPackageItems(),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.schedule,
            title: 'Opsi Waktu & Harga Sewa',
          ),
          const SizedBox(height: 16),
          _buildTimeOptionsCards(),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  Widget _buildPackageItems() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item Paket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (!controller.isViewing.value)
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.babyBlueLight,
                      foregroundColor: AppColorsPetugas.blueGrotto,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () =>
                  controller.packageItems.isEmpty
                      ? const Center(
                        child: Text(
                          'Belum ada item dalam paket',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.packageItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.packageItems[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item['nama'] ?? 'Item Paket'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Jumlah: ${item['jumlah']}'),
                                  if (item['stok'] != null)
                                    Text('Stok tersedia: ${item['stok']}'),
                                ],
                              ),
                              trailing:
                                  controller.isViewing.value
                                      ? null
                                      : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed:
                                                () =>
                                                    _showEditItemDialog(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => controller.removeItem(
                                                  index,
                                                ),
                                          ),
                                        ],
                                      ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    // Reset controllers
    controller.selectedAsset.value = null;
    controller.itemQuantityController.clear();

    // Fetch available assets
    controller.fetchAvailableAssets();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.isLoadingAssets.value) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tambah Item ke Paket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Asset dropdown
                DropdownButtonFormField<String>(
                  value: controller.selectedAsset.value,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Aset',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Pilih Aset'),
                  items:
                      controller.availableAssets.map((asset) {
                        return DropdownMenuItem<String>(
                          value: asset['id'].toString(),
                          child: Text(
                            '${asset['nama']} (Stok: ${asset['stok']})',
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    controller.setSelectedAsset(value);
                  },
                ),

                const SizedBox(height: 16),

                // Quantity field
                Obx(() {
                  // Calculate max quantity based on selected asset
                  String? helperText;
                  if (controller.selectedAsset.value != null) {
                    final remaining = controller.getRemainingStock(
                      controller.selectedAsset.value!,
                    );
                    helperText = 'Maksimal: $remaining unit';
                  }

                  return TextFormField(
                    controller: controller.itemQuantityController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      border: const OutlineInputBorder(),
                      helperText: helperText,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  );
                }),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.addAssetToPackage();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsPetugas.babyBlueLight,
                        foregroundColor: AppColorsPetugas.blueGrotto,
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showEditItemDialog(int index) {
    final item = controller.packageItems[index];

    // Set controllers
    controller.selectedAsset.value = item['asetId'];
    controller.itemQuantityController.text = item['jumlah'].toString();

    // Fetch available assets
    controller.fetchAvailableAssets();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.isLoadingAssets.value) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Item Paket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Asset dropdown
                DropdownButtonFormField<String>(
                  value: controller.selectedAsset.value,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Aset',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Pilih Aset'),
                  items:
                      controller.availableAssets.map((asset) {
                        return DropdownMenuItem<String>(
                          value: asset['id'].toString(),
                          child: Text(
                            '${asset['nama']} (Stok: ${asset['stok']})',
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    controller.setSelectedAsset(value);
                  },
                ),

                const SizedBox(height: 16),

                // Quantity field
                Obx(() {
                  // Calculate max quantity based on selected asset
                  String? helperText;
                  if (controller.selectedAsset.value != null) {
                    // Get the appropriate max quantity for editing
                    final currentItem = controller.packageItems[index];
                    final isCurrentAsset =
                        currentItem['asetId'] == controller.selectedAsset.value;

                    int maxQuantity;
                    if (isCurrentAsset) {
                      // For same asset, include current quantity in calculation
                      final asset = controller.availableAssets.firstWhere(
                        (a) => a['id'] == controller.selectedAsset.value,
                        orElse: () => {'stok': 0},
                      );

                      final totalUsed = controller.packageItems
                          .where(
                            (item) =>
                                item['asetId'] ==
                                    controller.selectedAsset.value &&
                                controller.packageItems.indexOf(item) != index,
                          )
                          .fold(
                            0,
                            (sum, item) => sum + (item['jumlah'] as int),
                          );

                      maxQuantity = (asset['stok'] as int) - totalUsed;
                    } else {
                      // For different asset, use remaining stock
                      maxQuantity = controller.getRemainingStock(
                        controller.selectedAsset.value!,
                      );
                    }

                    helperText = 'Maksimal: $maxQuantity unit';
                  }

                  return TextFormField(
                    controller: controller.itemQuantityController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      border: const OutlineInputBorder(),
                      helperText: helperText,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  );
                }),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.updatePackageItem(index);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsPetugas.babyBlueLight,
                        foregroundColor: AppColorsPetugas.blueGrotto,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
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
    final petugasController =
        this.controller; // Reference to PetugasTambahPaketController

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
            if (isRequired && !petugasController.isViewing.value) ...[
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
        Obx(
          () => TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: petugasController.isViewing.value,
            style: TextStyle(
              color:
                  petugasController.isViewing.value
                      ? AppColorsPetugas.textSecondary
                      : AppColorsPetugas.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColorsPetugas.textLight),
              filled: true,
              fillColor:
                  petugasController.isViewing.value
                      ? AppColorsPetugas.babyBlueLight
                      : AppColorsPetugas.babyBlueBright,
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
                fillColor:
                    controller.isViewing.value
                        ? AppColorsPetugas.babyBlueLight
                        : AppColorsPetugas.babyBlueBright,
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
              onChanged:
                  controller.isViewing.value
                      ? null // Disable in view-only mode
                      : (value) {
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
            'Unggah Foto Paket',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsPetugas.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan foto paket untuk informasi visual.',
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
                if (!controller.isViewing.value)
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
                ...List<Widget>.generate(controller.selectedImages.length, (
                  index,
                ) {
                  final img = controller.selectedImages[index];
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              (img is String && img.startsWith('http'))
                                  ? Image.network(
                                    img,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  )
                                  : (img is String)
                                  ? Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  )
                                  : Image.file(
                                    File(img.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child:
                            !controller.isViewing.value
                                ? InkWell(
                                  onTap: () => controller.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          ],
        ),
      ),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorsPetugas.babyBlueBright,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColorsPetugas.blueGrotto, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColorsPetugas.navyBlue,
              fontWeight: FontWeight.w500,
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
      child: Obx(() {
        // In view-only mode, just show a back button
        if (controller.isViewing.value) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.blueGrotto,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        // For edit/add mode, show cancel and save buttons
        return Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Batal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColorsPetugas.textSecondary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
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
                      controller.isFormChanged.value && !isSubmitting
                          ? controller.savePaket
                          : null,
                  icon:
                      isSubmitting
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(
                    isSubmitting
                        ? 'Menyimpan...'
                        : (controller.isEditing.value
                            ? 'Simpan Paket'
                            : 'Tambah Paket'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColorsPetugas.textLight,
                  ),
                );
              }),
            ),
          ],
        );
      }),
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
                    onTap:
                        controller.isViewing.value
                            ? null
                            : () => controller.toggleTimeOption(option),
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
                                      ? 'Sewa paket dengan basis perhitungan per jam'
                                      : 'Sewa paket dengan basis perhitungan per hari',
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
                      readOnly: controller.isViewing.value,
                      style: TextStyle(
                        color:
                            controller.isViewing.value
                                ? AppColorsPetugas.textSecondary
                                : AppColorsPetugas.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan harga',
                        hintStyle: TextStyle(color: AppColorsPetugas.textLight),
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor:
                            controller.isViewing.value
                                ? AppColorsPetugas.babyBlueLight
                                : AppColorsPetugas.babyBlueBright,
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
                      readOnly: controller.isViewing.value,
                      style: TextStyle(
                        color:
                            controller.isViewing.value
                                ? AppColorsPetugas.textSecondary
                                : AppColorsPetugas.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Opsional',
                        hintStyle: TextStyle(color: AppColorsPetugas.textLight),
                        filled: true,
                        fillColor:
                            controller.isViewing.value
                                ? AppColorsPetugas.babyBlueLight
                                : AppColorsPetugas.babyBlueBright,
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
}
