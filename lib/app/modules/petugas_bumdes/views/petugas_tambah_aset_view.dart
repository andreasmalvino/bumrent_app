import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors_petugas.dart';
import '../controllers/petugas_tambah_aset_controller.dart';

class PetugasTambahAsetView extends GetView<PetugasTambahAsetController> {
  const PetugasTambahAsetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Aset',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeaderSection(), _buildFormSection(context)],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorsPetugas.navyBlue, AppColorsPetugas.blueGrotto],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Aset Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Isi data dengan lengkap untuk menambahkan aset',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
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

          // Category Section
          _buildSectionHeader(icon: Icons.category, title: 'Kategori & Status'),
          const SizedBox(height: 16),

          // Category and Status as cards
          Row(
            children: [
              Expanded(
                child: _buildCategorySelect(
                  title: 'Kategori',
                  options: controller.categoryOptions,
                  selectedOption: controller.selectedCategory,
                  onChanged: controller.setCategory,
                  icon: Icons.inventory_2,
                ),
              ),
              const SizedBox(width: 12),
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

          // Quantity Section
          _buildSectionHeader(
            icon: Icons.format_list_numbered,
            title: 'Kuantitas & Pengukuran',
          ),
          const SizedBox(height: 16),

          // Quantity fields
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'Kuantitas',
                  hint: 'Jumlah aset',
                  controller: controller.quantityController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.numbers,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildTextField(
                  label: 'Satuan Ukur',
                  hint: 'contoh: Unit, Buah',
                  controller: controller.unitOfMeasureController,
                  prefixIcon: Icons.straighten,
                ),
              ),
            ],
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
                  onTap: () => controller.addSampleImage(),
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
                ...controller.selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColorsPetugas.babyBlueLight,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: AppColorsPetugas.babyBlueLight,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: AppColorsPetugas.blueGrotto,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColorsPetugas.error,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
                label: Text(isSubmitting ? 'Menyimpan...' : 'Simpan Aset'),
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
