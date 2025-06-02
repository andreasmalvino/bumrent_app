import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_bumdes_cbp_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../../../routes/app_routes.dart';

class PetugasBumdesCbpView extends GetView<PetugasBumdesCbpController> {
  const PetugasBumdesCbpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'BUMDes CBP',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              const Text(
                'Pengelolaan BUMDes CBP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kelola informasi akun bank dan petugas mitra BUMDes',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Bank Account Card
                      _buildInfoCard(
                        title: 'Rekening Bank',
                        icon: Icons.account_balance_outlined,
                        primaryInfo:
                            '${controller.bankAccounts.length} Rekening Terdaftar',
                        secondaryInfo:
                            controller.bankAccounts.isNotEmpty
                                ? 'Rekening Utama: ${controller.bankAccounts.firstWhere((acc) => acc['is_primary'] == true, orElse: () => {'bank_name': 'Tidak ada'})['bank_name']}'
                                : 'Belum ada rekening utama',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0072B5), Color(0xFF0088CC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: _showBankAccountsPage,
                      ),

                      const SizedBox(height: 16),

                      // Partners Card
                      _buildInfoCard(
                        title: 'Petugas Mitra',
                        icon: Icons.people_outline_rounded,
                        primaryInfo: '${controller.partners.length} Mitra',
                        secondaryInfo:
                            '${controller.partners.where((p) => p['is_active'] == true).length} Mitra Aktif',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4D8), Color(0xFF48CAE4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: _showPartnersPage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String primaryInfo,
    required String secondaryInfo,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                primaryInfo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                secondaryInfo,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        child: BottomNavigationBar(
          currentIndex: 5, // BUMDes tab
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColorsPetugas.blueGrotto,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index) {
            // Use the dashboard controller to handle tab navigation
            // This is typically provided by the parent Dashboard
            final dashboardController =
                Get.find<PetugasBumdesDashboardController>();
            dashboardController.changeTab(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Aset',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
              activeIcon: Icon(Icons.archive),
              label: 'Paket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Sewa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.subscriptions_outlined),
              activeIcon: Icon(Icons.subscriptions),
              label: 'Langganan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'BUMDes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColorsPetugas.navyBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 40, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin BUMDes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@bumdes.desa.id',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Get.offAllNamed(Routes.PETUGAS_BUMDES_DASHBOARD);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Kelola Aset'),
            onTap: () {
              Get.offAllNamed(Routes.PETUGAS_ASET);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feed_outlined),
            title: const Text('Kelola Paket'),
            onTap: () {
              Get.offAllNamed(Routes.PETUGAS_PAKET);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Kelola Permintaan Sewa'),
            onTap: () {
              Get.offAllNamed(Routes.PETUGAS_SEWA);
            },
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions_outlined),
            title: const Text('Kelola Langganan'),
            onTap: () {
              Get.offAllNamed(Routes.PETUGAS_LANGGANAN);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('BUMDes CBP'),
            tileColor: Colors.blue.shade50,
            onTap: () {
              Get.back();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Implement logout
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
    );
  }

  // Method to handle navigation to bank accounts management
  void _showBankAccountsPage() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: AppColorsPetugas.blueGrotto,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Rekening Bank',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(
                () =>
                    controller.bankAccounts.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Belum ada rekening yang terdaftar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                        : Column(
                          children:
                              controller.bankAccounts
                                  .map(
                                    (account) => _buildBankAccountItem(account),
                                  )
                                  .toList(),
                        ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    // Show the full-screen bank accounts page
                    Get.snackbar(
                      'Informasi',
                      'Menuju halaman kelola rekening bank',
                      backgroundColor: AppColorsPetugas.blueGrotto,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Lihat Semua Rekening'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankAccountItem(Map<String, dynamic> account) {
    final isPrimary = account['is_primary'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? AppColorsPetugas.blueGrotto : Colors.grey.shade300,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorsPetugas.babyBlueBright,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.credit_card,
              color: AppColorsPetugas.blueGrotto,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      account['bank_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorsPetugas.blueGrotto.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Utama',
                          style: TextStyle(
                            color: AppColorsPetugas.blueGrotto,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  account['account_number'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle navigation to partners management
  void _showPartnersPage() {
    // Navigate to the ListPetugasMitraView
    Get.toNamed(Routes.LIST_PETUGAS_MITRA);
  }
}
