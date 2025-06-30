import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import 'petugas_detail_sewa_view.dart';
import '../../../data/models/rental_booking_model.dart';

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
    // Tambahkan controller untuk TextField agar bisa dikosongkan
    final TextEditingController searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
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
        controller: searchController,
        onChanged: (value) {
          controller.setSearchQuery(value);
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
          suffixIcon: Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColorsPetugas.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        searchController.clear();
                        controller.setSearchQuery('');
                      },
                    )
                    : SizedBox.shrink(),
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
              : status == 'Menunggu Pembayaran'
              ? controller.sewaList
                  .where(
                    (sewa) =>
                        sewa.status.toUpperCase() == 'MENUNGGU PEMBAYARAN' ||
                        sewa.status.toUpperCase() == 'PEMBAYARAN DENDA',
                  )
                  .toList()
              : status == 'Periksa Pembayaran'
              ? controller.sewaList
                  .where(
                    (sewa) =>
                        sewa.status.toUpperCase() == 'PERIKSA PEMBAYARAN' ||
                        sewa.status.toUpperCase() == 'PERIKSA PEMBAYARAN DENDA',
                  )
                  .toList()
              : status == 'Diterima'
              ? controller.sewaList
                  .where((sewa) => sewa.status.toUpperCase() == 'DITERIMA')
                  .toList()
              : status == 'Aktif'
              ? controller.sewaList
                  .where((sewa) => sewa.status.toUpperCase() == 'AKTIF')
                  .toList()
              : status == 'Dikembalikan'
              ? controller.sewaList
                  .where((sewa) => sewa.status.toUpperCase() == 'DIKEMBALIKAN')
                  .toList()
              : status == 'Selesai'
              ? controller.sewaList
                  .where((sewa) => sewa.status.toUpperCase() == 'SELESAI')
                  .toList()
              : status == 'Dibatalkan'
              ? controller.sewaList
                  .where((sewa) => sewa.status.toUpperCase() == 'DIBATALKAN')
                  .toList()
              : controller.sewaList
                  .where((sewa) => sewa.status == status)
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

  Widget _buildSewaCard(BuildContext context, SewaModel sewa) {
    final statusColor = controller.getStatusColor(sewa.status);
    final status = sewa.status;

    // Get appropriate icon for status
    IconData statusIcon = controller.getStatusIcon(status);

    // Flag untuk membedakan tipe pesanan
    final bool isAset = sewa.tipePesanan == 'tunggal';
    final bool isPaket = sewa.tipePesanan == 'paket';

    // Pilih nama aset/paket
    final String namaAsetAtauPaket =
        isAset
            ? (sewa.asetNama ?? '-')
            : (isPaket ? (sewa.paketNama ?? '-') : '-');
    // Pilih foto aset/paket jika ingin digunakan
    final String? fotoAsetAtauPaket =
        isAset ? sewa.asetFoto : (isPaket ? sewa.paketFoto : null);

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
              // Status header inside the card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Customer Circle Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColorsPetugas.babyBlueLight,
                      backgroundImage:
                          (sewa.wargaAvatar != null &&
                                  sewa.wargaAvatar.isNotEmpty)
                              ? NetworkImage(sewa.wargaAvatar)
                              : null,
                      child:
                          (sewa.wargaAvatar == null || sewa.wargaAvatar.isEmpty)
                              ? Text(
                                sewa.wargaNama.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsPetugas.blueGrotto,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),

                    // Customer details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sewa.wargaNama,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsPetugas.textPrimary,
                            ),
                          ),
                          Text(
                            'Tanggal Pesan: ' +
                                (sewa.tanggalPemesanan != null
                                    ? '${sewa.tanggalPemesanan.day.toString().padLeft(2, '0')}-${sewa.tanggalPemesanan.month.toString().padLeft(2, '0')}-${sewa.tanggalPemesanan.year}'
                                    : '-'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorsPetugas.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price - only show if total_tagihan > 0
                    if (sewa.totalTagihan > 0)
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
                          controller.formatPrice(sewa.totalTagihan),
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

              // Asset/Paket details
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    // Asset/Paket image or icon
                    if (fotoAsetAtauPaket != null &&
                        fotoAsetAtauPaket.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          fotoAsetAtauPaket,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.inventory_2_outlined,
                                size: 28,
                                color: AppColorsPetugas.blueGrotto,
                              ),
                        ),
                      )
                    else
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

                    // Asset/Paket name and duration
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaAsetAtauPaket,
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
                                _formatDateRange(sewa),
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

  String _formatDateRange(SewaModel sewa) {
    final startDate = sewa.waktuMulai;
    final endDate = sewa.waktuSelesai;

    // Format dates as dd-mm-yyyy
    String formattedStartDate =
        '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
    String formattedEndDate =
        '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}';

    // Check if rental unit is "jam" (hour)
    if (sewa.namaSatuanWaktu?.toLowerCase() == 'jam') {
      // Format as "dd-mm-yyyy icon jam 09.00-15.00"
      String startTime =
          '${startDate.hour.toString().padLeft(2, '0')}.${startDate.minute.toString().padLeft(2, '0')}';
      String endTime =
          '${endDate.hour.toString().padLeft(2, '0')}.${endDate.minute.toString().padLeft(2, '0')}';
      return '$formattedStartDate ⏱ $startTime-$endTime';
    }
    // If same day but not hourly, just show the date
    else if (startDate.day == endDate.day &&
        startDate.month == endDate.month &&
        startDate.year == endDate.year) {
      return formattedStartDate;
    }
    // Different days - show date range
    else {
      return '$formattedStartDate - $formattedEndDate';
    }
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
