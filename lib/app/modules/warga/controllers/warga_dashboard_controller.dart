import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';
import '../../../data/providers/aset_provider.dart';
import '../../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class WargaDashboardController extends GetxController {
  // Dependency injection
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final NavigationService navigationService = Get.find<NavigationService>();
  final AsetProvider _asetProvider = Get.find<AsetProvider>();

  // User data
  final userName = 'Pengguna Warga'.obs;
  final userRole = 'Warga'.obs;
  final userAvatar = Rx<String?>(null);
  final userEmail = ''.obs;
  final userNik = ''.obs;
  final userPhone = ''.obs;
  final userAddress = ''.obs;
  final userTanggalLahir = ''.obs;
  final userRtRw = ''.obs;
  final userKelurahanDesa = ''.obs;
  final userKecamatan = ''.obs;

  // Navigation state is now managed by NavigationService

  // Sample data (would be loaded from API)
  final activeRentals = <Map<String, dynamic>>[].obs;

  // Active bills
  final activeBills = <Map<String, dynamic>>[].obs;

  // Active penalties
  final activePenalties = <Map<String, dynamic>>[].obs;

  // Summary counts
  final diterimaCount = 0.obs;
  final tagihanAktifCount = 0.obs;
  final dendaAktifCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Set navigation index to Home (0)
    navigationService.setNavIndex(0);

    // Load user data
    fetchProfileFromWargaDesa();
    _loadUserData();

    // Load sample data
    _loadSampleData();

    // Load dummy data for bills and penalties
    loadDummyData();

    // Load unpaid rentals
    loadUnpaidRentals();

    // Debug count sewa_aset by status
    _debugCountSewaAset();

    // Load sewa aktif
    loadActiveRentals();
  }

  Future<void> _loadUserData() async {
    try {
      // Get the full name from warga_desa table
      final fullName = await _authProvider.getUserFullName();
      if (fullName != null && fullName.isNotEmpty) {
        userName.value = fullName;
      }

      // Get the avatar URL
      final avatar = await _authProvider.getUserAvatar();
      userAvatar.value = avatar;

      // Get the role name
      final roleId = await _authProvider.getUserRoleId();
      if (roleId != null) {
        final roleName = await _authProvider.getRoleName(roleId);
        if (roleName != null) {
          userRole.value = roleName;
        }
      }

      // Load additional user data
      // In a real app, these would come from the API/database
      userEmail.value = await _authProvider.getUserEmail() ?? '';
      userNik.value = await _authProvider.getUserNIK() ?? '';
      userPhone.value = await _authProvider.getUserPhone() ?? '';
      userAddress.value = await _authProvider.getUserAddress() ?? '';

      // Load additional profile data
      final tanggalLahir = await _authProvider.getUserTanggalLahir();
      final rtRw = await _authProvider.getUserRtRw();
      final kelurahanDesa = await _authProvider.getUserKelurahanDesa();
      final kecamatan = await _authProvider.getUserKecamatan();

      // Set values for additional profile data
      userTanggalLahir.value = tanggalLahir ?? 'Tidak tersedia';
      userRtRw.value = rtRw ?? 'Tidak tersedia';
      userKelurahanDesa.value = kelurahanDesa ?? 'Tidak tersedia';
      userKecamatan.value = kecamatan ?? 'Tidak tersedia';
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _loadSampleData() {
    // Clear any existing data
    activeRentals.clear();

    // Load active rentals from API
    // For now, using sample data
    activeRentals.add({
      'id': '1',
      'name': 'Kursi',
      'time': '24 April 2023, 10:00 - 12:00',
      'duration': '2 jam',
      'price': 'Rp50.000',
      'can_extend': true,
    });
  }

  void extendRental(String rentalId) {
    // Implementasi untuk memperpanjang sewa
    // Seharusnya melakukan API call ke backend
  }

  void endRental(String rentalId) {
    // Implementasi untuk mengakhiri sewa
    // Seharusnya melakukan API call ke backend
  }

  void navigateToRentals() {
    // Navigate to SewaAset using the navigation service
    navigationService.toSewaAset();
  }

  void refreshData() {
    fetchProfileFromWargaDesa();
    _loadSampleData();
    loadDummyData();
  }

  void onNavItemTapped(int index) {
    if (navigationService.currentNavIndex.value == index) {
      return; // Don't do anything if same tab
    }

    navigationService.setNavIndex(index);

    switch (index) {
      case 0:
        // Already on Home tab
        break;
      case 1:
        // Navigate to Sewa page, tab Aktif
        toWargaSewaTabAktif();
        break;
    }
  }

  void toWargaSewaTabAktif() {
    // Navigasi ke halaman warga sewa dan tab Aktif (index 3)
    Get.toNamed(Routes.WARGA_SEWA, arguments: {'tab': 3});
  }

  void logout() async {
    await _authProvider.signOut();
    navigationService.toLogin();
  }

  void loadDummyData() {
    // Dummy active bills
    activeBills.clear();
    activeBills.add({
      'id': '1',
      'title': 'Tagihan Air',
      'due_date': '30 Apr 2023',
      'amount': 'Rp 125.000',
    });
    activeBills.add({
      'id': '2',
      'title': 'Sewa Aula Desa',
      'due_date': '15 Apr 2023',
      'amount': 'Rp 350.000',
    });

    // Dummy active penalties
    activePenalties.clear();
    activePenalties.add({
      'id': '1',
      'title': 'Keterlambatan Sewa Traktor',
      'days_late': '7',
      'amount': 'Rp 75.000',
    });
  }

  Future<void> loadUnpaidRentals() async {
    try {
      final results = await _authProvider.getSewaAsetByStatus([
        'MENUNGGU PEMBAYARAN',
        'PEMBAYARANAN DENDA',
      ]);
      activeBills.value = results;
    } catch (e) {
      print('Error loading unpaid rentals: $e');
    }
  }

  Future<void> _debugCountSewaAset() async {
    diterimaCount.value = await _asetProvider.countSewaAsetByStatus([
      'DITERIMA',
    ]);
    tagihanAktifCount.value = await _asetProvider.countSewaAsetByStatus([
      'MENUNGGU PEMBAYARAN',
      'PERIKSA PEMBAYARAN',
    ]);
    dendaAktifCount.value = await _asetProvider.countSewaAsetByStatus([
      'PEMBAYARAN DENDA',
      'PERIKSA PEMBAYARAN DENDA',
    ]);
    print('[DEBUG] Jumlah sewa diterima: ${diterimaCount.value}');
    print('[DEBUG] Jumlah tagihan aktif: ${tagihanAktifCount.value}');
    print('[DEBUG] Jumlah denda aktif: ${dendaAktifCount.value}');
  }

  Future<void> loadActiveRentals() async {
    try {
      activeRentals.clear();
      final sewaAsetList = await _authProvider.getSewaAsetByStatus(['AKTIF']);
      for (var sewaAset in sewaAsetList) {
        String assetName = 'Aset';
        String? imageUrl;
        String namaSatuanWaktu = sewaAset['nama_satuan_waktu'] ?? 'jam';
        if (sewaAset['aset_id'] != null) {
          final asetData = await _asetProvider.getAsetById(sewaAset['aset_id']);
          if (asetData != null) {
            assetName = asetData.nama;
            imageUrl = asetData.imageUrl;
          }
        }
        DateTime? waktuMulai;
        DateTime? waktuSelesai;
        String waktuSewa = '';
        String tanggalSewa = '';
        String jamMulai = '';
        String jamSelesai = '';
        String rentangWaktu = '';
        if (sewaAset['waktu_mulai'] != null &&
            sewaAset['waktu_selesai'] != null) {
          waktuMulai = DateTime.parse(sewaAset['waktu_mulai']);
          waktuSelesai = DateTime.parse(sewaAset['waktu_selesai']);
          final formatTanggal = DateFormat('dd-MM-yyyy');
          final formatWaktu = DateFormat('HH:mm');
          final formatTanggalLengkap = DateFormat('dd MMMM yyyy', 'id_ID');
          tanggalSewa = formatTanggalLengkap.format(waktuMulai);
          jamMulai = formatWaktu.format(waktuMulai);
          jamSelesai = formatWaktu.format(waktuSelesai);
          if (namaSatuanWaktu.toLowerCase() == 'jam') {
            rentangWaktu = '$jamMulai - $jamSelesai';
          } else if (namaSatuanWaktu.toLowerCase() == 'hari') {
            final tanggalMulai = formatTanggalLengkap.format(waktuMulai);
            final tanggalSelesai = formatTanggalLengkap.format(waktuSelesai);
            rentangWaktu = '$tanggalMulai - $tanggalSelesai';
          } else {
            rentangWaktu = '$jamMulai - $jamSelesai';
          }
          waktuSewa =
              '${formatTanggal.format(waktuMulai)} | ${formatWaktu.format(waktuMulai)} - '
              '${formatTanggal.format(waktuSelesai)} | ${formatWaktu.format(waktuSelesai)}';
        }
        String totalPrice = 'Rp 0';
        if (sewaAset['total'] != null) {
          final formatter = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          totalPrice = formatter.format(sewaAset['total']);
        }
        String duration = '-';
        final tagihan = await _asetProvider.getTagihanSewa(sewaAset['id']);
        if (tagihan != null) {
          final durasiTagihan = tagihan['durasi'] ?? sewaAset['durasi'];
          final satuanTagihan = tagihan['nama_satuan_waktu'] ?? namaSatuanWaktu;
          duration = '${durasiTagihan ?? '-'} ${satuanTagihan ?? ''}';
        } else {
          duration = '${sewaAset['durasi'] ?? '-'} ${namaSatuanWaktu ?? ''}';
        }
        activeRentals.add({
          'id': sewaAset['id'] ?? '',
          'name': assetName,
          'imageUrl': imageUrl ?? 'assets/images/gambar_pendukung.jpg',
          'jumlahUnit': sewaAset['kuantitas'] ?? 0,
          'waktuSewa': waktuSewa,
          'duration': duration,
          'status': sewaAset['status'] ?? 'AKTIF',
          'totalPrice': totalPrice,
          'tanggalSewa': tanggalSewa,
          'jamMulai': jamMulai,
          'jamSelesai': jamSelesai,
          'rentangWaktu': rentangWaktu,
          'namaSatuanWaktu': namaSatuanWaktu,
          'waktuMulai': sewaAset['waktu_mulai'],
          'waktuSelesai': sewaAset['waktu_selesai'],
          'can_extend': sewaAset['can_extend'] == true,
        });
      }
    } catch (e) {
      print('Error loading active rentals: $e');
    }
  }

  void toSewaAsetTabPaket() {
    // Navigasi ke halaman sewa_aset tab Paket (index 1)
    Get.toNamed(Routes.SEWA_ASET, arguments: {'tab': 1});
  }

  Future<void> fetchProfileFromWargaDesa() async {
    try {
      final user = _authProvider.currentUser;
      if (user == null) return;
      final userId = user.id;
      final data =
          await _authProvider.client
              .from('warga_desa')
              .select('nik, alamat, email, nama_lengkap, no_hp, avatar')
              .eq('user_id', userId)
              .maybeSingle();
      if (data != null) {
        userNik.value = data['nik']?.toString() ?? '';
        userAddress.value = data['alamat']?.toString() ?? '';
        userEmail.value = data['email']?.toString() ?? '';
        userName.value = data['nama_lengkap']?.toString() ?? '';
        userPhone.value = data['no_hp']?.toString() ?? '';
        userAvatar.value = data['avatar']?.toString() ?? '';
      }
    } catch (e) {
      print('Error fetching profile from warga_desa: $e');
    }
  }

  // Method to update user profile data in warga_desa table
  Future<bool> updateUserProfile({
    required String namaLengkap,
    required String noHp,
  }) async {
    try {
      final user = _authProvider.currentUser;
      if (user == null) {
        print('Cannot update profile: No current user');
        return false;
      }

      final userId = user.id;

      // Update data in warga_desa table
      await _authProvider.client
          .from('warga_desa')
          .update({'nama_lengkap': namaLengkap, 'no_hp': noHp})
          .eq('user_id', userId);

      // Update local values
      userName.value = namaLengkap;
      userPhone.value = noHp;

      print('Profile updated successfully for user: $userId');
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Method to delete user avatar
  Future<bool> deleteUserAvatar() async {
    try {
      final user = _authProvider.currentUser;
      if (user == null) {
        print('Cannot delete avatar: No current user');
        return false;
      }

      final userId = user.id;
      final currentAvatarUrl = userAvatar.value;

      // If there's an avatar URL, delete it from storage
      if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
        try {
          print('Attempting to delete avatar from URL: $currentAvatarUrl');

          // Extract filename from URL
          // The URL format is typically:
          // https://[project-ref].supabase.co/storage/v1/object/public/warga/[filename]

          final uri = Uri.parse(currentAvatarUrl);
          final path = uri.path;

          // Find the filename after the last slash
          final filename = path.substring(path.lastIndexOf('/') + 1);

          if (filename.isNotEmpty) {
            print('Extracted filename: $filename');

            // Delete from storage bucket 'warga'
            final response = await _authProvider.client.storage
                .from('warga')
                .remove([filename]);

            print('Storage deletion response: $response');
          } else {
            print('Failed to extract filename from avatar URL');
          }
        } catch (e) {
          print('Error deleting avatar from storage: $e');
          // Continue with database update even if storage delete fails
        }
      }

      // Update warga_desa table to set avatar to null
      await _authProvider.client
          .from('warga_desa')
          .update({'avatar': null})
          .eq('user_id', userId);

      // Update local value
      userAvatar.value = '';

      print('Avatar deleted successfully for user: $userId');
      return true;
    } catch (e) {
      print('Error deleting user avatar: $e');
      return false;
    }
  }

  // Method to update user avatar URL
  Future<bool> updateUserAvatar(String avatarUrl) async {
    try {
      final user = _authProvider.currentUser;
      if (user == null) {
        print('Cannot update avatar: No current user');
        return false;
      }

      final userId = user.id;

      // Update data in warga_desa table
      await _authProvider.client
          .from('warga_desa')
          .update({'avatar': avatarUrl})
          .eq('user_id', userId);

      // Update local value
      userAvatar.value = avatarUrl;

      print('Avatar updated successfully for user: $userId');
      return true;
    } catch (e) {
      print('Error updating user avatar: $e');
      return false;
    }
  }

  // Method to upload avatar image to Supabase storage
  Future<String?> uploadAvatar(Uint8List fileBytes, String fileName) async {
    try {
      final user = _authProvider.currentUser;
      if (user == null) {
        print('Cannot upload avatar: No current user');
        return null;
      }

      // Generate a unique filename using timestamp and user ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final uniqueFileName = 'avatar_${user.id}_$timestamp.$extension';

      // Upload to 'warga' bucket
      final response = await _authProvider.client.storage
          .from('warga')
          .uploadBinary(
            uniqueFileName,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get the public URL
      final publicUrl = _authProvider.client.storage
          .from('warga')
          .getPublicUrl(uniqueFileName);

      print('Avatar uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // Method to handle image picking from camera or gallery
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      // Pick image directly without permission checks
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
      }
      return pickedFile;
    } catch (e) {
      print('Error picking image: $e');

      // Show error message if there's an issue
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengakses ${source == ImageSource.camera ? 'kamera' : 'galeri'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return null;
    }
  }

  // Method to show image source selection dialog
  Future<void> showImageSourceDialog() async {
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () async {
                    Get.back();
                    final pickedFile = await pickImage(ImageSource.camera);
                    if (pickedFile != null) {
                      await processPickedImage(pickedFile);
                    }
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onTap: () async {
                    Get.back();
                    final pickedFile = await pickImage(ImageSource.gallery);
                    if (pickedFile != null) {
                      await processPickedImage(pickedFile);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // Helper method to build image source option
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // Method to process picked image (temporary preview before saving)
  Future<void> processPickedImage(XFile pickedFile) async {
    try {
      // Read file as bytes
      final bytes = await pickedFile.readAsBytes();

      // Store the picked file temporarily for later use when saving
      tempPickedFile.value = pickedFile;

      // Update UI with temporary avatar preview
      tempAvatarBytes.value = bytes;

      print('Image processed for preview');
    } catch (e) {
      print('Error processing picked image: $e');
    }
  }

  // Method to save the picked image to Supabase and update profile
  Future<bool> saveNewAvatar() async {
    try {
      if (tempPickedFile.value == null || tempAvatarBytes.value == null) {
        print('No temporary image to save');
        return false;
      }

      final pickedFile = tempPickedFile.value!;
      final bytes = tempAvatarBytes.value!;

      // First delete the old avatar if exists
      final currentAvatarUrl = userAvatar.value;
      if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
        try {
          await deleteUserAvatar();
        } catch (e) {
          print('Error deleting old avatar: $e');
          // Continue with upload even if delete fails
        }
      }

      // Upload new avatar
      final newAvatarUrl = await uploadAvatar(bytes, pickedFile.name);
      if (newAvatarUrl == null) {
        print('Failed to upload new avatar');
        return false;
      }

      // Update avatar URL in database
      final success = await updateUserAvatar(newAvatarUrl);

      if (success) {
        // Clear temporary data
        tempPickedFile.value = null;
        tempAvatarBytes.value = null;

        print('Avatar updated successfully');
      }

      return success;
    } catch (e) {
      print('Error saving new avatar: $e');
      return false;
    }
  }

  // Method to cancel avatar change
  void cancelAvatarChange() {
    tempPickedFile.value = null;
    tempAvatarBytes.value = null;
    print('Avatar change canceled');
  }

  // Temporary storage for picked image
  final Rx<XFile?> tempPickedFile = Rx<XFile?>(null);
  final Rx<Uint8List?> tempAvatarBytes = Rx<Uint8List?>(null);
}
