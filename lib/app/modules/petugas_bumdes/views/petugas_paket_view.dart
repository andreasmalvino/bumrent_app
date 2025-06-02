import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_paket_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class PetugasPaketView extends GetView<PetugasPaketController> {
  const PetugasPaketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get dashboard controller for navigation
    final dashboardController = Get.find<PetugasBumdesDashboardController>();

    return WillPopScope(
      onWillPop: () async {
        // Saat back button ditekan, kembali ke dashboard
        dashboardController.changeTab(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manajemen Paket',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColorsPetugas.navyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.sort, size: 22),
              onPressed: () => _showSortingBottomSheet(context),
              tooltip: 'Urutkan',
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: PetugasSideNavbar(controller: dashboardController),
        drawerEdgeDragWidth: 60,
        drawerScrimColor: Colors.black.withOpacity(0.6),
        backgroundColor: AppColorsPetugas.babyBlueBright,
        body: Column(
          children: [_buildSearchBar(), Expanded(child: _buildPaketList())],
        ),
        bottomNavigationBar: Obx(
          () => PetugasBumdesBottomNavbar(
            selectedIndex: dashboardController.currentTabIndex.value,
            onItemTapped: (index) => dashboardController.changeTab(index),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.PETUGAS_TAMBAH_PAKET),
          label: Text(
            'Tambah Paket',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColorsPetugas.blueGrotto,
            ),
          ),
          icon: Icon(Icons.add, color: AppColorsPetugas.blueGrotto),
          backgroundColor: AppColorsPetugas.babyBlueBright,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColorsPetugas.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari paket...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.search,
            color: AppColorsPetugas.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColorsPetugas.babyBlueBright,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPaketList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColorsPetugas.blueGrotto,
            strokeWidth: 3,
          ),
        );
      }

      if (controller.filteredPaketList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 80,
                color: AppColorsPetugas.babyBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada paket ditemukan',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorsPetugas.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.PETUGAS_TAMBAH_PAKET),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Paket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPetugas.blueGrotto,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadPaketData,
        color: AppColorsPetugas.blueGrotto,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredPaketList.length,
          itemBuilder: (context, index) {
            final paket = controller.filteredPaketList[index];
            return _buildPaketCard(context, paket);
          },
        ),
      );
    });
  }

  Widget _buildPaketCard(BuildContext context, Map<String, dynamic> paket) {
    final isAvailable = paket['tersedia'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsPetugas.shadowColor,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPaketDetails(context, paket),
            child: Row(
              children: [
                // Paket image or icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColorsPetugas.babyBlueLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getPaketIcon(paket['kategori']),
                      color: AppColorsPetugas.navyBlue,
                      size: 32,
                    ),
                  ),
                ),

                // Paket info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name and price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                paket['nama'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColorsPetugas.navyBlue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_formatPrice(paket['harga'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColorsPetugas.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isAvailable
                                    ? AppColorsPetugas.successLight
                                    : AppColorsPetugas.errorLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isAvailable
                                      ? AppColorsPetugas.success
                                      : AppColorsPetugas.error,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isAvailable ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isAvailable
                                      ? AppColorsPetugas.success
                                      : AppColorsPetugas.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Action icons
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            // Edit icon
                            GestureDetector(
                              onTap:
                                  () => _showAddEditPaketDialog(
                                    context,
                                    paket: paket,
                                  ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColorsPetugas.babyBlueBright,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColorsPetugas.blueGrotto
                                        .withOpacity(0.5),
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColorsPetugas.blueGrotto,
                                  size: 16,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Delete icon
                            GestureDetector(
                              onTap:
                                  () => _showDeleteConfirmation(context, paket),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColorsPetugas.errorLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColorsPetugas.error.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: AppColorsPetugas.error,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';

    // Convert the price to string and handle formatting
    String priceStr = price.toString();

    // Add thousand separators
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatted = priceStr.replaceAllMapped(reg, (Match m) => '${m[1]}.');

    return formatted;
  }

  IconData _getPaketIcon(String? category) {
    if (category == null) return Icons.category;

    switch (category.toLowerCase()) {
      case 'bulanan':
        return Icons.calendar_month;
      case 'tahunan':
        return Icons.calendar_today;
      case 'premium':
        return Icons.star;
      case 'bisnis':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  void _showSortingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Urutkan Paket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsPetugas.navyBlue,
                ),
              ),
              const SizedBox(height: 16),
              ...controller.sortOptions.map((option) {
                return Obx(() {
                  final isSelected = option == controller.sortBy.value;
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: controller.sortBy.value,
                    activeColor: AppColorsPetugas.blueGrotto,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSortBy(value);
                        Navigator.pop(context);
                      }
                    },
                  );
                });
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showPaketDetails(BuildContext context, Map<String, dynamic> paket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      paket['nama'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColorsPetugas.blueGrotto),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailItem('Kategori', paket['kategori']),
                            _buildDetailItem(
                              'Harga',
                              controller.formatPrice(paket['harga']),
                            ),
                            _buildDetailItem(
                              'Status',
                              paket['tersedia'] ? 'Tersedia' : 'Tidak Tersedia',
                            ),
                            _buildDetailItem('Deskripsi', paket['deskripsi']),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Item dalam Paket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: paket['items'].length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = paket['items'][index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColorsPetugas.babyBlue,
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: AppColorsPetugas.blueGrotto,
                                size: 16,
                              ),
                            ),
                            title: Text(item['nama']),
                            trailing: Text(
                              '${item['jumlah']} unit',
                              style: TextStyle(
                                color: AppColorsPetugas.blueGrotto,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.toNamed(
                          Routes.PETUGAS_TAMBAH_PAKET,
                          arguments: paket,
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColorsPetugas.blueGrotto,
                        side: BorderSide(color: AppColorsPetugas.blueGrotto),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, paket);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsPetugas.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColorsPetugas.blueGrotto),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColorsPetugas.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditPaketDialog(
    BuildContext context, {
    Map<String, dynamic>? paket,
  }) {
    final isEditing = paket != null;

    // This would be implemented with proper form validation in a real app
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditing ? 'Edit Paket' : 'Tambah Paket Baru',
            style: TextStyle(color: AppColorsPetugas.navyBlue),
          ),
          content: const Text(
            'Form pengelolaan paket akan ditampilkan di sini dengan field untuk nama, kategori, harga, deskripsi, status, dan item-item dalam paket.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, we would save the form data
                Get.snackbar(
                  isEditing ? 'Paket Diperbarui' : 'Paket Ditambahkan',
                  isEditing
                      ? 'Paket berhasil diperbarui'
                      : 'Paket baru berhasil ditambahkan',
                  backgroundColor: AppColorsPetugas.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.blueGrotto,
              ),
              child: Text(isEditing ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> paket,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus',
            style: TextStyle(color: AppColorsPetugas.navyBlue),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus paket "${paket['nama']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deletePaket(paket['id']);
                Get.snackbar(
                  'Paket Dihapus',
                  'Paket berhasil dihapus dari sistem',
                  backgroundColor: AppColorsPetugas.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.error,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
