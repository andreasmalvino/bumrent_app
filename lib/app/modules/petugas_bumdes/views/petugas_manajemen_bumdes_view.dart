import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_manajemen_bumdes_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';

class PetugasManajemenBumdesView
    extends GetView<PetugasManajemenBumdesController> {
  const PetugasManajemenBumdesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<PetugasBumdesDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen BUMDes'),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: Obx(() {
                        switch (controller.selectedTabIndex.value) {
                          case 0:
                            return _buildProfileTab();
                          case 1:
                            return _buildBankAccountTab();
                          case 2:
                            return _buildPartnerTab();
                          default:
                            return _buildProfileTab();
                        }
                      }),
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: _buildBottomNav(dashboardController),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(0, 'Profile'),
          _buildTab(1, 'Rekening Bank'),
          _buildTab(2, 'Mitra'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = controller.selectedTabIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? AppColorsPetugas.navyBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isSelected ? AppColorsPetugas.navyBlue : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile BUMDes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildProfileForm(),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileField('Nama BUMDes', 'BUMDes Sejahtera'),
            _buildProfileField('Alamat', 'Jl. Desa No. 123, Kecamatan Makmur'),
            _buildProfileField('Email', 'bumdes.sejahtera@gmail.com'),
            _buildProfileField('Telepon', '081234567890'),
            _buildProfileField(
              'Deskripsi',
              'BUMDes yang bergerak dalam bidang penyewaan aset dan paket untuk masyarakat desa.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.navyBlue,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildBankAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rekening Bank',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBankAccountDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPetugas.navyBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: controller.bankAccounts.length,
              itemBuilder: (context, index) {
                final account = controller.bankAccounts[index];
                return _buildBankAccountCard(account, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(Map<String, dynamic> account, int index) {
    final isPrimary = account['isPrimary'] as bool;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPrimary ? AppColorsPetugas.navyBlue : Colors.transparent,
          width: isPrimary ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account['bankName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        if (!isPrimary)
                          PopupMenuItem(
                            value: 'primary',
                            child: const Text('Jadikan Utama'),
                          ),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                  onSelected: (value) {
                    switch (value) {
                      case 'primary':
                        controller.setPrimaryBankAccount(index);
                        break;
                      case 'edit':
                        _showEditBankAccountDialog(account, index);
                        break;
                      case 'delete':
                        _showDeleteBankAccountDialog(index);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildBankAccountInfo('Nama Pemilik', account['accountName']),
            _buildBankAccountInfo('Nomor Rekening', account['accountNumber']),
            if (isPrimary)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorsPetugas.navyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Rekening Utama',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsPetugas.navyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPartnerTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mitra BUMDes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddPartnerDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPetugas.navyBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: controller.partners.length,
              itemBuilder: (context, index) {
                final partner = controller.partners[index];
                return _buildPartnerCard(partner, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner, int index) {
    final isActive = partner['isActive'] as bool;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  partner['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Switch(
                      value: isActive,
                      onChanged:
                          (value) => controller.togglePartnerStatus(index),
                      activeColor: AppColorsPetugas.navyBlue,
                    ),
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showEditPartnerDialog(partner, index);
                            break;
                          case 'delete':
                            _showDeletePartnerDialog(index);
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPartnerInfo('Email', partner['email']),
            _buildPartnerInfo('Telepon', partner['phone']),
            _buildPartnerInfo('Alamat', partner['address']),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isActive ? 'Aktif' : 'Tidak Aktif',
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildBottomNav(PetugasBumdesDashboardController dashboardController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.dashboard, 'Dashboard', 0, dashboardController),
            _buildNavItem(Icons.inventory, 'Aset', 1, dashboardController),
            _buildNavItem(Icons.inventory_2, 'Paket', 2, dashboardController),
            _buildNavItem(Icons.shopping_cart, 'Sewa', 3, dashboardController),
            _buildNavItem(
              Icons.subscriptions,
              'Langganan',
              4,
              dashboardController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    PetugasBumdesDashboardController dashboardController,
  ) {
    return InkWell(
      onTap: () => dashboardController.changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColorsPetugas.blueGrotto, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColorsPetugas.blueGrotto),
          ),
        ],
      ),
    );
  }

  void _showAddBankAccountDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Rekening Bank',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Bank',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Pemilik Rekening',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
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
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Fitur tambah rekening bank sedang dalam pengembangan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.navyBlue,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBankAccountDialog(Map<String, dynamic> account, int index) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Rekening Bank',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama Bank',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: account['bankName']),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama Pemilik Rekening',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: account['accountName']),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: account['accountNumber'],
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
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
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Fitur edit rekening bank sedang dalam pengembangan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.navyBlue,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteBankAccountDialog(int index) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hapus Rekening Bank',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apakah Anda yakin ingin menghapus rekening bank ini?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Fitur hapus rekening bank sedang dalam pengembangan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPartnerDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Mitra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Mitra',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
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
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Fitur tambah mitra sedang dalam pengembangan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.navyBlue,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPartnerDialog(Map<String, dynamic> partner, int index) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Mitra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama Mitra',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: partner['name']),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: partner['email']),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Telepon',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: partner['phone']),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: partner['address']),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
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
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Fitur edit mitra sedang dalam pengembangan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.navyBlue,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletePartnerDialog(int index) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hapus Mitra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apakah Anda yakin ingin menghapus mitra ini?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Fitur hapus mitra sedang dalam pengembangan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
