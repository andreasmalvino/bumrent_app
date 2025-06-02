import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_aset_controller.dart';
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
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes and update controller
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.changeTab(_tabController.index);
      }
    });

    // Listen to controller tab changes and update TabController
    ever(controller.selectedTabIndex, (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildTabBar(),
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
          onPressed: () => Get.toNamed(Routes.PETUGAS_TAMBAH_ASET),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColorsPetugas.babyBlueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColorsPetugas.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColorsPetugas.blueGrotto,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 18),
                  SizedBox(width: 8),
                  Text('Sewa', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subscriptions, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Langganan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetList() {
    return Obx(() {
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
          itemCount: controller.filteredAsetList.length,
          itemBuilder: (context, index) {
            final aset = controller.filteredAsetList[index];
            return _buildAssetCard(context, aset);
          },
        ),
      );
    });
  }

  Widget _buildAssetCard(BuildContext context, Map<String, dynamic> aset) {
    final isAvailable = aset['tersedia'] == true;

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
            onTap: () => _showAssetDetails(context, aset),
            child: Row(
              children: [
                // Asset image
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
                      _getAssetIcon(aset['kategori']),
                      color: AppColorsPetugas.navyBlue,
                      size: 32,
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
                                aset['nama'],
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
                                '${controller.formatPrice(aset['harga'])} ${aset['satuan']}',
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
                              onTap:
                                  () => _showAddEditAssetDialog(
                                    context,
                                    aset: aset,
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

  void _showAssetDetails(BuildContext context, Map<String, dynamic> aset) {
    final isAvailable = aset['tersedia'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorsPetugas.blueGrotto,
                      AppColorsPetugas.navyBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close button and availability badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isAvailable
                                    ? AppColorsPetugas.successLight
                                    : AppColorsPetugas.errorLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isAvailable
                                      ? AppColorsPetugas.success
                                      : AppColorsPetugas.error,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAvailable ? Icons.check_circle : Icons.cancel,
                                color:
                                    isAvailable
                                        ? AppColorsPetugas.success
                                        : AppColorsPetugas.error,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isAvailable
                                          ? AppColorsPetugas.success
                                          : AppColorsPetugas.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        aset['kategori'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Asset name
                    Text(
                      aset['nama'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.formatPrice(aset['harga'])} ${aset['satuan']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Asset details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick info cards
                      Row(
                        children: [
                          _buildInfoCard(
                            Icons.inventory_2,
                            'Stok',
                            '${aset['stok']} unit',
                            flex: 1,
                          ),
                          const SizedBox(width: 16),
                          _buildInfoCard(
                            Icons.category,
                            'Jenis',
                            aset['jenis'],
                            flex: 1,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description section
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColorsPetugas.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aset['deskripsi'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColorsPetugas.textPrimary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddEditAssetDialog(context, aset: aset);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsPetugas.blueGrotto,
                          side: BorderSide(color: AppColorsPetugas.blueGrotto),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(context, aset);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsPetugas.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value, {
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorsPetugas.babyBlueBright,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorsPetugas.babyBlue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColorsPetugas.blueGrotto),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsPetugas.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColorsPetugas.navyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColorsPetugas.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColorsPetugas.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditAssetDialog(
    BuildContext context, {
    Map<String, dynamic>? aset,
  }) {
    final isEditing = aset != null;
    final jenisOptions = ['Sewa', 'Langganan'];
    final typeOptions = ['Elektronik', 'Furniture', 'Kendaraan', 'Lainnya'];

    // In a real app, this would have proper form handling with controllers
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColorsPetugas.babyBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEditing ? Icons.edit : Icons.add,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Aset' : 'Tambah Aset Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorsPetugas.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan lengkapi form di bawah ini',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColorsPetugas.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Mock form - In a real app this would have actual form fields
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorsPetugas.babyBlueBright,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColorsPetugas.babyBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form pengelolaan aset akan ditampilkan di sini dengan field untuk:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColorsPetugas.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMockFormField('Nama Aset', 'Contoh: Meja Rapat'),
                      _buildMockFormField('Kategori', 'Pilih kategori aset'),
                      _buildMockFormField(
                        'Harga',
                        'Masukkan harga per unit/periode',
                      ),
                      _buildMockFormField(
                        'Satuan',
                        'Contoh: per hari, per bulan',
                      ),
                      _buildMockFormField('Stok', 'Jumlah unit tersedia'),
                      _buildMockFormField(
                        'Deskripsi',
                        'Keterangan lengkap aset',
                      ),
                      _buildMockToggle(
                        'Status Ketersediaan',
                        isEditing && aset?['tersedia'] == true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColorsPetugas.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // In a real app, we would save the form data
                        Get.snackbar(
                          isEditing ? 'Aset Diperbarui' : 'Aset Ditambahkan',
                          isEditing
                              ? 'Aset berhasil diperbarui'
                              : 'Aset baru berhasil ditambahkan',
                          backgroundColor: AppColorsPetugas.success,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 10,
                        );
                      },
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
                      child: Text(isEditing ? 'Simpan' : 'Tambah'),
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

  Widget _buildMockFormField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColorsPetugas.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColorsPetugas.babyBlue),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColorsPetugas.textLight,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColorsPetugas.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockToggle(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColorsPetugas.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) {},
            activeColor: AppColorsPetugas.blueGrotto,
          ),
        ],
      ),
    );
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
                        onPressed: () {
                          Navigator.pop(context);
                          controller.deleteAset(aset['id']);
                          Get.snackbar(
                            'Aset Dihapus',
                            'Aset berhasil dihapus dari sistem',
                            backgroundColor: AppColorsPetugas.error,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 10,
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          );
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
