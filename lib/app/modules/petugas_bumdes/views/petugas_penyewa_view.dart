import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_penyewa_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../../../routes/app_routes.dart';

class PetugasPenyewaView extends StatefulWidget {
  const PetugasPenyewaView({Key? key}) : super(key: key);

  @override
  State<PetugasPenyewaView> createState() => _PetugasPenyewaViewState();
}

class _PetugasPenyewaViewState extends State<PetugasPenyewaView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PetugasPenyewaController controller;
  late PetugasBumdesDashboardController dashboardController;

  final List<String> tabTitles = ['Verifikasi', 'Aktif', 'Ditangguhkan'];

  @override
  void initState() {
    super.initState();
    controller = Get.find<PetugasPenyewaController>();
    dashboardController = Get.find<PetugasBumdesDashboardController>();

    _tabController = TabController(length: 3, vsync: this);

    // Add listener to sync tab selection with controller's filter
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      controller.changeTab(_tabController.index);
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
            'Daftar Penyewa',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: AppColorsPetugas.navyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
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
                    tabTitles
                        .map(
                          (title) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Tab(text: title),
                          ),
                        )
                        .toList(),
                dividerColor: Colors.transparent,
              ),
            ),
          ),
          actions: [
            // Tambahkan indikator refresh
            Obx(
              () =>
                  controller.isRefreshing.value
                      ? Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
        drawer: PetugasSideNavbar(controller: dashboardController),
        drawerEdgeDragWidth: 60,
        drawerScrimColor: Colors.black.withOpacity(0.6),
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    [0, 1, 2].map((index) {
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

                        if (controller.filteredPenyewaList.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              await controller.refreshPenyewaList();
                            },
                            color: AppColorsPetugas.blueGrotto,
                            child: _buildEmptyStateWithScrollView(),
                          );
                        }

                        return _buildPenyewaList();
                      });
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

  Widget _buildSearchBar() {
    // Add controller for TextField so it can be cleared
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
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari nama atau email...',
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
                        controller.updateSearchQuery('');
                      },
                    )
                    : SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Obx(() {
            String message = 'Belum ada data penyewa';

            if (controller.searchQuery.isNotEmpty) {
              message = 'Tidak ada hasil yang cocok dengan pencarian';
            } else {
              switch (controller.currentTabIndex.value) {
                case 0:
                  message = 'Tidak ada penyewa yang menunggu verifikasi';
                  break;
                case 1:
                  message = 'Tidak ada penyewa aktif';
                  break;
                case 2:
                  message = 'Tidak ada penyewa yang ditangguhkan';
                  break;
              }
            }

            return Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Data penyewa akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan empty state dengan ScrollView untuk mendukung RefreshIndicator
  Widget _buildEmptyStateWithScrollView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(Get.context!).size.height * 0.7,
          child: _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildPenyewaList() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshPenyewaList();
      },
      color: AppColorsPetugas.blueGrotto,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredPenyewaList.length,
        itemBuilder: (context, index) {
          final penyewa = controller.filteredPenyewaList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with avatar and badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorsPetugas.babyBlueLight.withOpacity(
                            0.2,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColorsPetugas.babyBlueLight,
                                backgroundImage:
                                    penyewa['avatar'] != null &&
                                            penyewa['avatar']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(penyewa['avatar'])
                                        : null,
                                child:
                                    penyewa['avatar'] == null ||
                                            penyewa['avatar'].toString().isEmpty
                                        ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Name and email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    penyewa['nama_lengkap'] ??
                                        'Nama tidak tersedia',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsPetugas.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          penyewa['email'] ??
                                              'Email tidak tersedia',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(penyewa['status']),
                          ],
                        ),
                      ),

                      // Content section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show additional info only for Aktif and Ditangguhkan tabs
                            if (controller.currentTabIndex.value != 0) ...[
                              Row(
                                children: [
                                  _buildInfoChip(
                                    Icons.credit_card_outlined,
                                    'NIK: ${penyewa['nik'] ?? 'Tidak tersedia'}',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.phone_outlined,
                                    penyewa['no_hp'] ?? 'No. HP tidak tersedia',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoTile(
                                    'Total Sewa',
                                    penyewa['total_sewa']?.toString() ?? '0',
                                    Icons.shopping_bag_outlined,
                                    AppColorsPetugas.blueGrotto,
                                  ),
                                  if (controller.currentTabIndex.value == 1 ||
                                      controller.currentTabIndex.value == 2)
                                    _buildActionChip(
                                      label: 'Lihat Detail',
                                      color: AppColorsPetugas.blueGrotto,
                                      icon: Icons.visibility,
                                      onTap: () {
                                        Get.toNamed(
                                          Routes.PETUGAS_DETAIL_PENYEWA,
                                          arguments: {
                                            'userId': penyewa['user_id'],
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],

                            // Add "Detail" button for Verifikasi tab
                            if (controller.currentTabIndex.value == 0) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildActionChip(
                                      label: 'Lihat Detail & Verifikasi',
                                      color: AppColorsPetugas.blueGrotto,
                                      icon: Icons.visibility,
                                      onTap: () {
                                        Get.toNamed(
                                          Routes.PETUGAS_DETAIL_PENYEWA,
                                          arguments: {
                                            'userId': penyewa['user_id'],
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status?.toLowerCase()) {
      case 'active':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Aktif';
        break;
      case 'pending':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'Menunggu';
        break;
      case 'suspended':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Dinonaktifkan';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = 'Tidak diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Aktivasi'),
            content: const Text(
              'Apakah Anda yakin ingin mengaktifkan penyewa ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.updatePenyewaStatus(
                    userId,
                    'active',
                    'Akun diaktifkan oleh petugas',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aktifkan'),
              ),
            ],
          ),
    );
  }

  void _showRejectDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Penolakan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Apakah Anda yakin ingin menolak penyewa ini?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Alasan Penolakan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final reason =
                      reasonController.text.isNotEmpty
                          ? reasonController.text
                          : 'Ditolak oleh petugas';
                  controller.updatePenyewaStatus(userId, 'suspended', reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tolak'),
              ),
            ],
          ),
    );
  }
}
