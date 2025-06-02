import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';

class WargaDashboardController extends GetxController {
  // Dependency injection
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final NavigationService navigationService = Get.find<NavigationService>();

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

  @override
  void onInit() {
    super.onInit();

    // Set navigation index to Home (0)
    navigationService.setNavIndex(0);

    // Load user data
    _loadUserData();

    // Load sample data
    _loadSampleData();

    // Load dummy data for bills and penalties
    loadDummyData();

    // Load unpaid rentals
    loadUnpaidRentals();
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
    // Refresh data from repository
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
        // Navigate to Sewa page
        navigationService.toWargaSewa();
        break;
    }
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
}
