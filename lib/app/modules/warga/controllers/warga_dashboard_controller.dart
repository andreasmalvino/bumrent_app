import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';
import '../../../data/providers/aset_provider.dart';
import 'package:intl/intl.dart';

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
}
