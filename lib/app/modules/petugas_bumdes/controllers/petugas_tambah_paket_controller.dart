import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bumrent_app/app/data/models/paket_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bumrent_app/app/data/providers/aset_provider.dart';
import 'dart:io';
import 'package:bumrent_app/app/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class PetugasTambahPaketController extends GetxController {
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final itemQuantityController = TextEditingController();

  // Dropdown and toggle values
  final selectedCategory = 'Bulanan'.obs;
  final selectedStatus = 'Tersedia'.obs;

  // Category options
  final categoryOptions = ['Bulanan', 'Tahunan', 'Premium', 'Bisnis'];
  final statusOptions = ['Tersedia', 'Pemeliharaan'];

  // Images
  final selectedImages = <dynamic>[].obs;

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
  final Rx<String?> selectedAsset = Rx<String?>(null);
  final RxBool isLoadingAssets = false.obs;

  // Form validation
  final isFormValid = false.obs;
  final isSubmitting = false.obs;

  // New RxBool for editing
  final isEditing = false.obs;

  // New RxBool for viewing (read-only mode)
  final isViewing = false.obs;

  final timeOptions = {'Per Jam': true.obs, 'Per Hari': false.obs};
  final pricePerHourController = TextEditingController();
  final maxHourController = TextEditingController();
  final pricePerDayController = TextEditingController();
  final maxDayController = TextEditingController();

  final _picker = ImagePicker();

  final isFormChanged = false.obs;
  Map<String, dynamic> initialFormData = {};

  final AsetProvider _asetProvider = Get.put(AsetProvider());

  @override
  void onInit() {
    super.onInit();

    // Ambil flag isEditing dan isViewing dari arguments
    isEditing.value =
        Get.arguments != null && Get.arguments['isEditing'] == true;
    isViewing.value =
        Get.arguments != null && Get.arguments['isViewing'] == true;

    if (isEditing.value || isViewing.value) {
      final paketArg = Get.arguments['paket'];
      String? paketId;
      if (paketArg != null) {
        if (paketArg is Map && paketArg['id'] != null) {
          paketId = paketArg['id'].toString();
        } else if (paketArg is PaketModel && paketArg.id != null) {
          paketId = paketArg.id.toString();
        }
      }
      if (paketId != null) {
        fetchPaketDetail(paketId);
      }
    }

    // Listen to field changes for validation
    nameController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    descriptionController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    priceController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    itemQuantityController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    pricePerHourController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    maxHourController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    pricePerDayController.addListener(() {
      validateForm();
      checkFormChanged();
    });
    maxDayController.addListener(() {
      validateForm();
      checkFormChanged();
    });

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
    checkFormChanged();
  }

  // Change selected status
  void setStatus(String status) {
    selectedStatus.value = status;
    validateForm();
    checkFormChanged();
  }

  // Add image to the list (in a real app, this would handle file upload)
  void addImage(String imagePath) {
    selectedImages.add(imagePath);
    validateForm();
    checkFormChanged();
  }

  // Remove image from the list
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      validateForm();
      checkFormChanged();
    }
  }

  // Fetch available assets from Supabase and filter out already selected ones
  Future<void> fetchAvailableAssets() async {
    isLoadingAssets.value = true;
    try {
      final allAssets = await _asetProvider.getSewaAsets();
      final selectedAsetIds =
          packageItems.map((item) => item['asetId'].toString()).toSet();
      // Only show assets not yet selected
      availableAssets.value =
          allAssets
              .where((aset) => !selectedAsetIds.contains(aset.id))
              .map(
                (aset) => {
                  'id': aset.id,
                  'nama': aset.nama,
                  'stok': aset.kuantitas,
                },
              )
              .toList();
    } catch (e) {
      availableAssets.value = [];
    } finally {
      isLoadingAssets.value = false;
    }
  }

  // Set the selected asset
  void setSelectedAsset(String? assetId) {
    selectedAsset.value = assetId;
  }

  // Get remaining stock for an asset (considering current selections)
  int getRemainingStock(String assetId) {
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
      if (item['asetId'].toString() == assetId) {
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
        snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
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
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    checkFormChanged();
  }

  // Update an existing package item
  void updatePackageItem(int index) {
    if (selectedAsset.value == null || itemQuantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih aset dan masukkan jumlah',
        snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
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
          snackPosition: SnackPosition.TOP,
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
          snackPosition: SnackPosition.TOP,
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
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    checkFormChanged();
  }

  // Remove an item from the package
  void removeItem(int index) {
    if (index >= 0 && index < packageItems.length) {
      packageItems.removeAt(index);
      checkFormChanged();
    }
    Get.snackbar(
      'Dihapus',
      'Item berhasil dihapus dari paket',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Validate form fields
  void validateForm() {
    // Basic validation
    bool basicValid =
        nameController.text.isNotEmpty && descriptionController.text.isNotEmpty;

    // Package should have at least one item
    bool hasItems = packageItems.isNotEmpty;

    isFormValid.value = basicValid && hasItems;
  }

  // Submit form and save package
  Future<void> savePaket() async {
    if (!isFormValid.value) return;

    isSubmitting.value = true;

    try {
      final supabase = Supabase.instance.client;
      if (isEditing.value) {
        // --- UPDATE LOGIC ---
        final paketArg = Get.arguments['paket'];
        final String paketId =
            paketArg is Map && paketArg['id'] != null
                ? paketArg['id'].toString()
                : (paketArg is PaketModel && paketArg.id != null
                    ? paketArg.id.toString()
                    : '');
        if (paketId.isEmpty) throw Exception('ID paket tidak ditemukan');

        // 1. Update data utama paket
        await supabase
            .from('paket')
            .update({
              'nama': nameController.text,
              'deskripsi': descriptionController.text,
              'status': selectedStatus.value.toLowerCase(),
            })
            .eq('id', paketId);

        // 2. Update paket_item: hapus semua, insert ulang
        await supabase.from('paket_item').delete().eq('paket_id', paketId);
        for (var item in packageItems) {
          await supabase.from('paket_item').insert({
            'paket_id': paketId,
            'aset_id': item['asetId'],
            'kuantitas': item['jumlah'],
          });
        }

        // 3. Update satuan_waktu_sewa: hapus semua, insert ulang
        await supabase
            .from('satuan_waktu_sewa')
            .delete()
            .eq('paket_id', paketId);
        // Fetch satuan_waktu UUIDs
        final satuanWaktuList = await supabase
            .from('satuan_waktu')
            .select('id, nama_satuan_waktu');
        String? jamId;
        String? hariId;
        for (var sw in satuanWaktuList) {
          final nama = (sw['nama_satuan_waktu'] ?? '').toString().toLowerCase();
          if (nama.contains('jam')) jamId = sw['id'];
          if (nama.contains('hari')) hariId = sw['id'];
        }
        if (timeOptions['Per Jam']?.value == true && jamId != null) {
          await supabase.from('satuan_waktu_sewa').insert({
            'paket_id': paketId,
            'satuan_waktu_id': jamId,
            'harga': int.tryParse(pricePerHourController.text) ?? 0,
            'maksimal_waktu': int.tryParse(maxHourController.text) ?? 0,
          });
        }
        if (timeOptions['Per Hari']?.value == true && hariId != null) {
          await supabase.from('satuan_waktu_sewa').insert({
            'paket_id': paketId,
            'satuan_waktu_id': hariId,
            'harga': int.tryParse(pricePerDayController.text) ?? 0,
            'maksimal_waktu': int.tryParse(maxDayController.text) ?? 0,
          });
        }

        // 4. Update foto_aset
        // a. Ambil foto lama dari DB
        final oldPhotos = await supabase
            .from('foto_aset')
            .select('foto_aset')
            .eq('id_paket', paketId);
        final oldPhotoUrls =
            oldPhotos
                .map((e) => e['foto_aset']?.toString())
                .whereType<String>()
                .toSet();
        final newPhotoUrls =
            selectedImages
                .map((img) => img is String ? img : (img.path ?? ''))
                .where((e) => e.isNotEmpty)
                .toSet();
        // b. Hapus foto yang dihapus user (dari DB dan storage)
        final removedPhotos = oldPhotoUrls.difference(newPhotoUrls);
        for (final url in removedPhotos) {
          await supabase
              .from('foto_aset')
              .delete()
              .eq('foto_aset', url)
              .eq('id_paket', paketId);
          await _asetProvider.deleteFileFromStorage(url);
        }
        // c. Tambah foto baru (upload jika perlu, insert ke DB)
        for (final img in selectedImages) {
          String url = '';
          if (img is String && img.startsWith('http')) {
            url = img;
          } else if (img is XFile) {
            final uploaded = await _asetProvider.uploadFileToStorage(
              File(img.path),
            );
            if (uploaded != null) url = uploaded;
          }
          if (url.isNotEmpty && !oldPhotoUrls.contains(url)) {
            await supabase.from('foto_aset').insert({
              'id_paket': paketId,
              'foto_aset': url,
            });
          }
        }

        // Sukses
        Get.offNamed(Routes.PETUGAS_PAKET);
        Get.snackbar(
          'Berhasil',
          'Paket berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // --- ADD LOGIC ---
        final uuid = Uuid();
        final String paketId = uuid.v4();
        // 1. Insert ke tabel paket
        await supabase.from('paket').insert({
          'id': paketId,
          'nama': nameController.text,
          'deskripsi': descriptionController.text,
          'status': selectedStatus.value.toLowerCase(),
        });
        // 2. Insert ke paket_item
        for (var item in packageItems) {
          await supabase.from('paket_item').insert({
            'paket_id': paketId,
            'aset_id': item['asetId'],
            'kuantitas': item['jumlah'],
          });
        }
        // 3. Insert ke satuan_waktu_sewa (ambil UUID satuan waktu)
        final satuanWaktuList = await supabase
            .from('satuan_waktu')
            .select('id, nama_satuan_waktu');
        String? jamId;
        String? hariId;
        for (var sw in satuanWaktuList) {
          final nama = (sw['nama_satuan_waktu'] ?? '').toString().toLowerCase();
          if (nama.contains('jam')) jamId = sw['id'];
          if (nama.contains('hari')) hariId = sw['id'];
        }
        if (timeOptions['Per Jam']?.value == true && jamId != null) {
          await supabase.from('satuan_waktu_sewa').insert({
            'paket_id': paketId,
            'satuan_waktu_id': jamId,
            'harga': int.tryParse(pricePerHourController.text) ?? 0,
            'maksimal_waktu': int.tryParse(maxHourController.text) ?? 0,
          });
        }
        if (timeOptions['Per Hari']?.value == true && hariId != null) {
          await supabase.from('satuan_waktu_sewa').insert({
            'paket_id': paketId,
            'satuan_waktu_id': hariId,
            'harga': int.tryParse(pricePerDayController.text) ?? 0,
            'maksimal_waktu': int.tryParse(maxDayController.text) ?? 0,
          });
        }
        // 4. Insert ke foto_aset (upload jika perlu)
        for (final img in selectedImages) {
          String url = '';
          if (img is String && img.startsWith('http')) {
            url = img;
          } else if (img is XFile) {
            final uploaded = await _asetProvider.uploadFileToStorage(
              File(img.path),
            );
            if (uploaded != null) url = uploaded;
          }
          if (url.isNotEmpty) {
            await supabase.from('foto_aset').insert({
              'id_paket': paketId,
              'foto_aset': url,
            });
          }
        }
        // Sukses
        Get.back(result: true);
        Get.snackbar(
          'Berhasil',
          'Paket berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: \\${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
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

  void toggleTimeOption(String option) {
    timeOptions[option]?.value = !(timeOptions[option]?.value ?? false);
    // Ensure at least one option is selected
    bool anySelected = false;
    timeOptions.forEach((key, value) {
      if (value.value) anySelected = true;
    });
    if (!anySelected) {
      timeOptions[option]?.value = true;
    }
    validateForm();
    checkFormChanged();
  }

  Future<void> fetchPaketDetail(String paketId) async {
    try {
      debugPrint('[DEBUG] Fetching paket detail for id: $paketId');
      final supabase = Supabase.instance.client;
      // 1) Ambil data paket utama
      final paketData =
          await supabase
              .from('paket')
              .select('id, nama, deskripsi, status')
              .eq('id', paketId)
              .single();
      debugPrint('[DEBUG] Paket data: ' + paketData.toString());

      // 2) Ambil paket_item
      final paketItemData = await supabase
          .from('paket_item')
          .select('id, paket_id, aset_id, kuantitas')
          .eq('paket_id', paketId);
      debugPrint('[DEBUG] Paket item data: ' + paketItemData.toString());

      // 3) Ambil satuan_waktu_sewa
      final swsData = await supabase
          .from('satuan_waktu_sewa')
          .select('id, paket_id, satuan_waktu_id, harga, maksimal_waktu')
          .eq('paket_id', paketId);
      debugPrint('[DEBUG] Satuan waktu sewa data: ' + swsData.toString());

      // 4) Ambil semua satuan_waktu_id dari swsData
      final swIds = swsData.map((e) => e['satuan_waktu_id']).toSet().toList();
      final swData =
          swIds.isNotEmpty
              ? await supabase
                  .from('satuan_waktu')
                  .select('id, nama_satuan_waktu')
                  .inFilter('id', swIds)
              : [];
      debugPrint('[DEBUG] Satuan waktu data: ' + swData.toString());
      final Map satuanWaktuMap = {
        for (var sw in swData) sw['id']: sw['nama_satuan_waktu'],
      };

      // 5) Ambil foto_aset
      final fotoData = await supabase
          .from('foto_aset')
          .select('id_paket, foto_aset')
          .eq('id_paket', paketId);
      debugPrint('[DEBUG] Foto aset data: ' + fotoData.toString());

      // 6) Kumpulkan semua aset_id dari paketItemData
      final asetIds = paketItemData.map((e) => e['aset_id']).toSet().toList();
      final asetData =
          asetIds.isNotEmpty
              ? await supabase
                  .from('aset')
                  .select('id, nama, kuantitas')
                  .inFilter('id', asetIds)
              : [];
      debugPrint('[DEBUG] Aset data: ' + asetData.toString());
      final Map asetMap = {for (var a in asetData) a['id']: a};

      // Prefill field controller
      nameController.text = paketData['nama']?.toString() ?? '';
      descriptionController.text = paketData['deskripsi']?.toString() ?? '';
      // Status mapping
      final statusDb =
          (paketData['status']?.toString().toLowerCase() ?? 'tersedia');
      selectedStatus.value =
          statusDb == 'pemeliharaan' ? 'Pemeliharaan' : 'Tersedia';

      // Foto
      selectedImages.clear();
      if (fotoData.isNotEmpty) {
        for (var foto in fotoData) {
          final url = foto['foto_aset']?.toString();
          if (url != null && url.isNotEmpty) {
            selectedImages.add(url);
          }
        }
      }

      // Item paket
      packageItems.clear();
      for (var item in paketItemData) {
        final aset = asetMap[item['aset_id']];
        packageItems.add({
          'asetId': item['aset_id'],
          'nama': aset != null ? aset['nama'] : '',
          'jumlah': item['kuantitas'],
          'stok': aset != null ? aset['kuantitas'] : 0,
        });
      }

      // Opsi waktu & harga sewa
      // Reset
      timeOptions['Per Jam']?.value = false;
      timeOptions['Per Hari']?.value = false;
      pricePerHourController.clear();
      maxHourController.clear();
      pricePerDayController.clear();
      maxDayController.clear();
      for (var sws in swsData) {
        final satuanNama =
            satuanWaktuMap[sws['satuan_waktu_id']]?.toString().toLowerCase() ??
            '';
        if (satuanNama.contains('jam')) {
          timeOptions['Per Jam']?.value = true;
          pricePerHourController.text = (sws['harga'] ?? '').toString();
          maxHourController.text = (sws['maksimal_waktu'] ?? '').toString();
        } else if (satuanNama.contains('hari')) {
          timeOptions['Per Hari']?.value = true;
          pricePerDayController.text = (sws['harga'] ?? '').toString();
          maxDayController.text = (sws['maksimal_waktu'] ?? '').toString();
        }
      }

      // Simpan snapshot initialFormData setelah prefill
      initialFormData = {
        'nama': nameController.text,
        'deskripsi': descriptionController.text,
        'status': selectedStatus.value,
        'images': List.from(selectedImages),
        'items': List.from(packageItems),
        'perJam': timeOptions['Per Jam']?.value ?? false,
        'perHari': timeOptions['Per Hari']?.value ?? false,
        'hargaJam': pricePerHourController.text,
        'maxJam': maxHourController.text,
        'hargaHari': pricePerDayController.text,
        'maxHari': maxDayController.text,
      };
      isFormChanged.value = false;
    } catch (e, st) {
      debugPrint('[ERROR] Gagal fetch paket detail: $e');
    }
  }

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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (images != null && images.isNotEmpty) {
        for (final img in images) {
          selectedImages.add(img);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar dari galeri: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void checkFormChanged() {
    final current = {
      'nama': nameController.text,
      'deskripsi': descriptionController.text,
      'status': selectedStatus.value,
      'images': List.from(selectedImages),
      'items': List.from(packageItems),
      'perJam': timeOptions['Per Jam']?.value ?? false,
      'perHari': timeOptions['Per Hari']?.value ?? false,
      'hargaJam': pricePerHourController.text,
      'maxJam': maxHourController.text,
      'hargaHari': pricePerDayController.text,
      'maxHari': maxDayController.text,
    };
    isFormChanged.value = current.toString() != initialFormData.toString();
  }
}
