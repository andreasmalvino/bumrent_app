import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import 'petugas_detail_sewa_view.dart';

class PetugasSewaView extends StatefulWidget {
  const PetugasSewaView({Key? key}) : super(key: key);

  @override
  State<PetugasSewaView> createState() => _PetugasSewaViewState();
}

class _PetugasSewaViewState extends State<PetugasSewaView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PetugasSewaController controller;
  late PetugasBumdesDashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PetugasSewaController>();
    dashboardController = Get.find<PetugasBumdesDashboardController>();

    _tabController = TabController(
      length: controller.statusFilters.length,
      vsync: this,
    );

    // Add listener to sync tab selection with controller's filter
    _tabController.addListener(_onTabChanged);

    // Listen to controller's filter changes
    ever(controller.selectedStatusFilter, _onFilterChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final selectedStatus = controller.statusFilters[_tabController.index];
      controller.setStatusFilter(selectedStatus);
    }
  }

  void _onFilterChanged(String status) {
    final index = controller.statusFilters.indexOf(status);
    if (index != -1 && index != _tabController.index) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        dashboardController.changeTab(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manajemen Sewa',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: AppColorsPetugas.navyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, size: 22),
              onPressed: () => _showFilterBottomSheet(),
              tooltip: 'Filter',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColorsPetugas.navyBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                tabs:
                    controller.statusFilters
                        .map(
                          (status) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Tab(text: status),
                          ),
                        )
                        .toList(),
                dividerColor: Colors.transparent,
              ),
            ),
          ),
        ),
        drawer: PetugasSideNavbar(controller: dashboardController),
        drawerEdgeDragWidth: 60,
        drawerScrimColor: Colors.black.withOpacity(0.6),
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            _buildSearchSection(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    controller.statusFilters.map((status) {
                      return _buildSewaListForStatus(status);
                    }).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Obx(
          () => PetugasBumdesBottomNavbar(
            selectedIndex: dashboardController.currentTabIndex.value,
            onItemTapped: (index) => dashboardController.changeTab(index),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          controller.setSearchQuery(value);
          controller.setOrderIdQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Cari nama warga atau ID pesanan...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: AppColorsPetugas.blueGrotto,
              size: 22,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
          suffixIcon: Icon(
            Icons.tune_rounded,
            color: AppColorsPetugas.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSewaListForStatus(String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColorsPetugas.blueGrotto,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat data...',
                style: TextStyle(
                  color: AppColorsPetugas.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      final filteredList =
          status == 'Semua'
              ? controller.filteredSewaList
              : status == 'Periksa Pembayaran'
              ? controller.sewaList
                  .where(
                    (sewa) =>
                        sewa['status'] == 'Periksa Pembayaran' ||
                        sewa['status'] == 'Pembayaran Denda' ||
                        sewa['status'] == 'Periksa Denda',
                  )
                  .toList()
              : controller.sewaList
                  .where((sewa) => sewa['status'] == status)
                  .toList();

      if (filteredList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColorsPetugas.babyBlueLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 70,
                  color: AppColorsPetugas.blueGrotto,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada sewa ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColorsPetugas.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                status == 'Semua'
                    ? 'Belum ada data sewa untuk kriteria yang dipilih'
                    : status == 'Periksa Pembayaran'
                    ? 'Belum ada data sewa yang perlu pembayaran diverifikasi atau memiliki denda'
                    : 'Belum ada data sewa dengan status "$status"',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorsPetugas.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadSewaData,
        color: AppColorsPetugas.blueGrotto,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final sewa = filteredList[index];
            return _buildSewaCard(context, sewa);
          },
        ),
      );
    });
  }

  Widget _buildSewaCard(BuildContext context, Map<String, dynamic> sewa) {
    final statusColor = controller.getStatusColor(sewa['status']);
    final status = sewa['status'];

    // Get appropriate icon for status
    IconData statusIcon;
    switch (status) {
      case 'Menunggu Pembayaran':
        statusIcon = Icons.payments_outlined;
        break;
      case 'Periksa Pembayaran':
        statusIcon = Icons.fact_check_outlined;
        break;
      case 'Diterima':
        statusIcon = Icons.check_circle_outlined;
        break;
      case 'Pembayaran Denda':
        statusIcon = Icons.money_off_csred_outlined;
        break;
      case 'Periksa Denda':
        statusIcon = Icons.assignment_late_outlined;
        break;
      case 'Dikembalikan':
        statusIcon = Icons.assignment_return_outlined;
        break;
      case 'Selesai':
        statusIcon = Icons.task_alt_outlined;
        break;
      case 'Dibatalkan':
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Get.to(() => PetugasDetailSewaView(sewa: sewa)),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Customer Circle Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColorsPetugas.babyBlueLight,
                      child: Text(
                        sewa['nama_warga'].substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorsPetugas.blueGrotto,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Customer details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sewa['nama_warga'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsPetugas.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 12,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '#${sewa['order_id']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColorsPetugas.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorsPetugas.blueGrotto.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.formatPrice(sewa['total_biaya']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColorsPetugas.blueGrotto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),

              // Asset details
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    // Asset icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColorsPetugas.babyBlueLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: AppColorsPetugas.blueGrotto,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Asset name and duration
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sewa['nama_aset'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColorsPetugas.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: AppColorsPetugas.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sewa['tanggal_mulai']} - ${sewa['tanggal_selesai']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColorsPetugas.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Chevron icon
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColorsPetugas.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return Wrap(
                spacing: 8,
                children:
                    controller.statusFilters.map((status) {
                      final isSelected =
                          status == controller.selectedStatusFilter.value;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: AppColorsPetugas.blueGrotto,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : AppColorsPetugas.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColorsPetugas.blueGrotto
                                    : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            controller.setStatusFilter(status);
                            Get.back();
                          }
                        },
                      );
                    }).toList(),
              );
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    controller.resetFilters();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColorsPetugas.blueGrotto),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(color: AppColorsPetugas.blueGrotto),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.applyFilters();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Terapkan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
