import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_aset_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class PetugasAsetView extends StatefulWidget {
  const PetugasAsetView({Key? key}) : super(key: key);

  @override
  State<PetugasAsetView> createState() => _PetugasAsetViewState();
}

class _PetugasAsetViewState extends State<PetugasAsetView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PetugasAsetController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PetugasAsetController>();
    // Initialize with default tab (sewa)
    controller.changeTab(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            'Manajemen Aset',
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
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildAssetList()),
          ],
        ),
        bottomNavigationBar: Obx(
          () => PetugasBumdesBottomNavbar(
            selectedIndex: dashboardController.currentTabIndex.value,
            onItemTapped: (index) => dashboardController.changeTab(index),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to PetugasTambahAsetView in add mode and refresh data when returning
            Get.toNamed(
              Routes.PETUGAS_TAMBAH_ASET,
              arguments: {'isEditing': false, 'assetData': null},
            )?.then((_) {
              // Refresh data when returning from tambah_aset page
              debugPrint('Returning from tambah aset page, refreshing data...');
              controller.loadAsetData();
            });
          },
          backgroundColor: AppColorsPetugas.babyBlueBright,
          icon: Icon(Icons.add, color: AppColorsPetugas.blueGrotto),
          label: Text(
            "Tambah Aset",
            style: TextStyle(
              color: AppColorsPetugas.blueGrotto,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          hintText: 'Cari aset...',
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

  // Tab bar has been removed as per requirements

  Widget _buildAssetList() {
    return Obx(() {
      debugPrint('_buildAssetList: isLoading=${controller.isLoading.value}');
      debugPrint(
        '_buildAssetList: filteredAsetList length=${controller.filteredAsetList.length}',
      );
      if (controller.filteredAsetList.isNotEmpty) {
        debugPrint(
          '_buildAssetList: First item name=${controller.filteredAsetList[0]['nama']}',
        );
      }
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColorsPetugas.blueGrotto,
            strokeWidth: 3,
          ),
        );
      }

      if (controller.filteredAsetList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: AppColorsPetugas.babyBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada aset ${controller.selectedTabIndex.value == 0 ? "sewa" : "langganan"} ditemukan',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorsPetugas.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddEditAssetDialog(Get.context!),
                icon: const Icon(Icons.add),
                label: Text(
                  'Tambah Aset ${controller.selectedTabIndex.value == 0 ? "Sewa" : "Langganan"}',
                ),
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
        onRefresh: controller.loadAsetData,
        color: AppColorsPetugas.blueGrotto,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredAsetList.length + 1,
          itemBuilder: (context, index) {
            if (index < controller.filteredAsetList.length) {
              final aset = controller.filteredAsetList[index];
              return _buildAssetCard(context, aset);
            } else {
              // Blank space at the end
              return const SizedBox(height: 80);
            }
          },
        ),
      );
    });
  }

  Widget _buildAssetCard(BuildContext context, Map<String, dynamic> aset) {
    debugPrint('\n--- Building Asset Card ---');
    debugPrint('Asset data: $aset');

    // Extract and validate all asset properties with proper null safety
    final status =
        aset['status']?.toString().toLowerCase() ?? 'tidak_diketahui';
    final isAvailable = status == 'tersedia';
    final imageUrl = aset['imageUrl']?.toString() ?? '';
    final harga =
        aset['harga'] is int
            ? aset['harga'] as int
            : (int.tryParse(aset['harga']?.toString() ?? '0') ?? 0);
    final satuanWaktu =
        aset['satuan_waktu']?.toString().capitalizeFirst ?? 'Hari';
    final nama = aset['nama']?.toString().trim() ?? 'Nama tidak tersedia';
    final kategori = aset['kategori']?.toString().trim() ?? 'Umum';
    final orderId = aset['order_id']?.toString() ?? '';

    // Debug prints for development
    debugPrint('Image URL: $imageUrl');
    debugPrint('Harga: $harga');
    debugPrint('Satuan Waktu: $satuanWaktu');
    debugPrint('Nama: $nama');
    debugPrint('Kategori: $kategori');
    debugPrint('Status: $status (Available: $isAvailable)');

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
            child: Row(
              children: [
                // Asset image
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: AppColorsPetugas.babyBlueLight,
                            child: Center(
                              child: Icon(
                                _getAssetIcon(
                                  kategori,
                                ), // Show category icon as placeholder
                                color: AppColorsPetugas.navyBlue.withOpacity(
                                  0.5,
                                ),
                                size: 32,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: AppColorsPetugas.babyBlueLight,
                            child: Center(
                              child: Icon(
                                Icons
                                    .broken_image, // Or your preferred error icon
                                color: AppColorsPetugas.navyBlue.withOpacity(
                                  0.5,
                                ),
                                size: 32,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),

                // Asset info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColorsPetugas.navyBlue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Harga dan satuan waktu (multi-line, tampilkan semua dari satuanWaktuSewa)
                              Builder(
                                builder: (context) {
                                  final satuanWaktuList =
                                      (aset['satuanWaktuSewa'] is List)
                                          ? List<Map<String, dynamic>>.from(
                                            aset['satuanWaktuSewa'],
                                          )
                                          : [];
                                  final validSatuanWaktu =
                                      satuanWaktuList
                                          .where(
                                            (sw) =>
                                                (sw['harga'] ?? 0) > 0 &&
                                                (sw['nama_satuan_waktu'] !=
                                                        null &&
                                                    (sw['nama_satuan_waktu']
                                                            as String)
                                                        .isNotEmpty),
                                          )
                                          .toList();

                                  if (validSatuanWaktu.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          validSatuanWaktu.map((sw) {
                                            final harga = sw['harga'] ?? 0;
                                            final satuan =
                                                sw['nama_satuan_waktu'] ?? '';
                                            return Text(
                                              '${controller.formatPrice(harga)} / $satuan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppColorsPetugas
                                                        .textSecondary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          }).toList(),
                                    );
                                  } else {
                                    // fallback: harga tunggal
                                    return Text(
                                      '${controller.formatPrice(aset['harga'] ?? 0)} / ${aset['satuan_waktu']?.toString().capitalizeFirst ?? 'Hari'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColorsPetugas.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                                },
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
                            isAvailable ? 'Tersedia' : 'Kosong',
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
                              onTap: () {
                                // Navigate to PetugasTambahAsetView in edit mode with only the asset ID
                                final assetId =
                                    aset['id']?.toString() ??
                                    ''; // Changed from 'id_aset' to 'id'
                                debugPrint(
                                  '[DEBUG] Navigating to edit asset with ID: $assetId',
                                );
                                debugPrint(
                                  '[DEBUG] Full asset data: $aset',
                                ); // Log full asset data for debugging

                                if (assetId.isEmpty) {
                                  debugPrint('[ERROR] Asset ID is empty!');
                                  Get.snackbar(
                                    'Error',
                                    'ID Aset tidak valid',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  return;
                                }

                                Get.toNamed(
                                  Routes.PETUGAS_TAMBAH_ASET,
                                  arguments: {
                                    'isEditing': true,
                                    'assetId': assetId,
                                  },
                                )?.then((_) {
                                  // Refresh data when returning from edit page
                                  debugPrint(
                                    'Returning from edit aset page, refreshing data...',
                                  );
                                  controller.loadAsetData();
                                });
                              },
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
                                  () => _showDeleteConfirmation(context, aset),
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

  IconData _getAssetIcon(String category) {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return Icons.devices;
      case 'furniture':
        return Icons.chair;
      case 'kendaraan':
        return Icons.directions_car;
      default:
        return Icons.inventory_2;
    }
  }

  void _showSortingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColorsPetugas.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Urutkan Aset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColorsPetugas.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Divider(height: 24, color: AppColorsPetugas.divider),
              // Options
              ...controller.sortOptions.map((option) {
                return Obx(() {
                  final isSelected = option == controller.sortBy.value;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.setSortBy(option);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColorsPetugas.babyBlueBright
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getSortOptionIcon(option),
                              color:
                                  isSelected
                                      ? AppColorsPetugas.blueGrotto
                                      : AppColorsPetugas.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? AppColorsPetugas.navyBlue
                                        : AppColorsPetugas.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColorsPetugas.blueGrotto,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  IconData _getSortOptionIcon(String option) {
    switch (option) {
      case 'Nama (A-Z)':
        return Icons.sort_by_alpha;
      case 'Nama (Z-A)':
        return Icons.sort_by_alpha;
      case 'Harga (Rendah-Tinggi)':
        return Icons.arrow_upward;
      case 'Harga (Tinggi-Rendah)':
        return Icons.arrow_downward;
      default:
        return Icons.sort;
    }
  }

  void _showAddEditAssetDialog(BuildContext context) {
    // Navigate to PetugasTambahAsetView in add mode and refresh data when returning
    Get.toNamed(
      Routes.PETUGAS_TAMBAH_ASET,
      arguments: {'isEditing': false, 'assetData': null},
    )?.then((_) {
      // Refresh data when returning from tambah_aset page
      debugPrint('Returning from tambah aset page, refreshing data...');
      controller.loadAsetData();
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> aset,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorsPetugas.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: AppColorsPetugas.error,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 24),

                // Title and message
                Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColorsPetugas.navyBlue,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Apakah Anda yakin ingin menghapus aset "${aset['nama']}"? Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorsPetugas.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsPetugas.textPrimary,
                          side: BorderSide(color: AppColorsPetugas.divider),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Let the controller handle the deletion and showing the snackbar
                          await controller.deleteAset(aset['id']);
                          // The controller will show appropriate success or error messages
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsPetugas.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
