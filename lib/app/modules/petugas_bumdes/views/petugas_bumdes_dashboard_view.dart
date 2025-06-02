import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../../../theme/app_colors_petugas.dart';

class PetugasBumdesDashboardView
    extends GetView<PetugasBumdesDashboardController> {
  const PetugasBumdesDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Mencegah navigasi kembali dengan tombol back
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(_getTitle())),
          backgroundColor: AppColorsPetugas.navyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
        drawer: PetugasSideNavbar(controller: controller),
        drawerEdgeDragWidth: 60,
        drawerScrimColor: Colors.black.withOpacity(0.6),
        body: Obx(() => _getTabContent()),
        bottomNavigationBar: Obx(
          () => PetugasBumdesBottomNavbar(
            selectedIndex: controller.currentTabIndex.value,
            onItemTapped: (index) => controller.changeTab(index),
          ),
        ),
        floatingActionButton: Obx(() {
          // Show FAB only on specific tabs
          if (controller.currentTabIndex.value == 1 || // Aset
              controller.currentTabIndex.value == 2) {
            // Paket
            return FloatingActionButton(
              onPressed: () => _showAddItemDialog(context),
              backgroundColor: AppColorsPetugas.babyBlueBright,
              child: Icon(Icons.add, color: AppColorsPetugas.blueGrotto),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  String _getTitle() {
    switch (controller.currentTabIndex.value) {
      case 0:
        return 'Dashboard Petugas BUMDES';
      case 1:
        return 'Manajemen Aset';
      case 2:
        return 'Manajemen Paket';
      case 3:
        return 'Permintaan Sewa';
      case 4:
        return 'Profil BUMDes';
      default:
        return 'Dashboard Petugas BUMDES';
    }
  }

  Widget _getTabContent() {
    switch (controller.currentTabIndex.value) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildAsetTab();
      case 2:
        return _buildPaketTab();
      case 3:
        return _buildSewaTab();
      case 4:
        return _buildBumdesTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // Detail Status Sewa Aset section with improved header
          _buildSectionHeader(
            'Detail Status Sewa Aset',
            AppColorsPetugas.navyBlue,
            Icons.shopping_cart_outlined,
          ),
          _buildDetailedStatusBreakdown(),

          const SizedBox(height: 24),

          // Revenue Statistics Section with improved header
          _buildSectionHeader(
            'Statistik Pendapatan',
            AppColorsPetugas.success,
            Icons.account_balance_wallet_outlined,
          ),
          _buildRevenueStatistics(),
          const SizedBox(height: 16),
          _buildRevenueSources(),
          const SizedBox(height: 16),
          _buildRevenueTrend(),

          // Add some padding at the bottom for better scrolling
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shadowColor: AppColorsPetugas.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColorsPetugas.navyBlue.withOpacity(0.05)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsPetugas.navyBlue.withOpacity(0.8),
              AppColorsPetugas.blueGrotto,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Petugas BUMDES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.userEmail.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_chart_outlined_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pantau sewa aset dengan mudah melalui dashboard Anda',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
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

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatusBreakdown() {
    return Card(
      elevation: 2,
      shadowColor: AppColorsPetugas.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use a responsive grid layout for better display on different screen sizes
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
              children: [
                _buildSourceItem(
                  'Menunggu Pembayaran',
                  controller.menungguPembayaranCount.value.toString(),
                  controller.menungguPembayaranCount.value,
                  AppColorsPetugas.warning,
                ),
                _buildSourceItem(
                  'Periksa Pembayaran',
                  controller.periksaPembayaranCount.value.toString(),
                  controller.periksaPembayaranCount.value,
                  AppColorsPetugas.info,
                ),
                _buildSourceItem(
                  'Diterima',
                  controller.diterimaCount.value.toString(),
                  controller.diterimaCount.value,
                  AppColorsPetugas.success,
                ),
                _buildSourceItem(
                  'Pembayaran Denda',
                  controller.pembayaranDendaCount.value.toString(),
                  controller.pembayaranDendaCount.value,
                  AppColorsPetugas.error,
                ),
                _buildSourceItem(
                  'Periksa Denda',
                  controller.periksaPembayaranDendaCount.value.toString(),
                  controller.periksaPembayaranDendaCount.value,
                  AppColorsPetugas.info,
                ),
                _buildSourceItem(
                  'Selesai',
                  controller.selesaiCount.value.toString(),
                  controller.selesaiCount.value,
                  AppColorsPetugas.success,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Modern visualization with improved progress bar
            _buildDetailedStatusProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceItem(
    String title,
    String value,
    int percentage,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insert_chart_outlined_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                color: AppColorsPetugas.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatusProgressBar() {
    // Calculate the total count for all detailed statuses
    final total =
        controller.menungguPembayaranCount.value +
        controller.periksaPembayaranCount.value +
        controller.diterimaCount.value +
        controller.pembayaranDendaCount.value +
        controller.periksaPembayaranDendaCount.value +
        controller.selesaiCount.value;

    // Calculate percentages for each status (avoid division by zero)
    final menungguPercent =
        total > 0 ? controller.menungguPembayaranCount.value / total : 0.0;
    final periksaPercent =
        total > 0 ? controller.periksaPembayaranCount.value / total : 0.0;
    final diterimaPercent =
        total > 0 ? controller.diterimaCount.value / total : 0.0;
    final dendaPercent =
        total > 0 ? controller.pembayaranDendaCount.value / total : 0.0;
    final periksaDendaPercent =
        total > 0 ? controller.periksaPembayaranDendaCount.value / total : 0.0;
    final selesaiPercent =
        total > 0 ? controller.selesaiCount.value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribusi Status Sewa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColorsPetugas.navyBlue,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            // Background for the progress bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // Actual progress bar segments
            Row(
              children: [
                _buildModernProgressSegment(
                  menungguPercent,
                  AppColorsPetugas.warning,
                  isFirst: true,
                ),
                _buildModernProgressSegment(
                  periksaPercent,
                  AppColorsPetugas.info,
                ),
                _buildModernProgressSegment(
                  diterimaPercent,
                  AppColorsPetugas.success,
                ),
                _buildModernProgressSegment(
                  dendaPercent,
                  AppColorsPetugas.error,
                ),
                _buildModernProgressSegment(
                  periksaDendaPercent,
                  AppColorsPetugas.blueGrotto,
                ),
                _buildModernProgressSegment(
                  selesaiPercent,
                  AppColorsPetugas.blueGreen,
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Use grid layout for legends
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCompactStatusLegend(
              'Menunggu',
              AppColorsPetugas.warning,
              menungguPercent,
            ),
            _buildCompactStatusLegend(
              'Periksa',
              AppColorsPetugas.info,
              periksaPercent,
            ),
            _buildCompactStatusLegend(
              'Diterima',
              AppColorsPetugas.success,
              diterimaPercent,
            ),
            _buildCompactStatusLegend(
              'Denda',
              AppColorsPetugas.error,
              dendaPercent,
            ),
            _buildCompactStatusLegend(
              'Cek Denda',
              AppColorsPetugas.blueGrotto,
              periksaDendaPercent,
            ),
            _buildCompactStatusLegend(
              'Selesai',
              AppColorsPetugas.blueGreen,
              selesaiPercent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernProgressSegment(
    double percentage,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Flexible(
      flex: (percentage * 100).round(),
      child:
          percentage > 0
              ? Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(6) : Radius.zero,
                    right: isLast ? const Radius.circular(6) : Radius.zero,
                  ),
                ),
              )
              : const SizedBox(), // Empty container when percentage is 0
    );
  }

  Widget _buildCompactStatusLegend(
    String text,
    Color color,
    double percentage,
  ) {
    final count = (percentage * 100).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$text ${count > 0 ? '($count%)' : ''}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: count > 20 ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueStatistics() {
    return Card(
      elevation: 2,
      shadowColor: AppColorsPetugas.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColorsPetugas.success.withOpacity(0.05)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pendapatan Bulan Ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColorsPetugas.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Text(
                          controller.totalPendapatanBulanIni.value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColorsPetugas.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    controller.isKenaikanPositif.value
                                        ? AppColorsPetugas.success.withOpacity(
                                          0.1,
                                        )
                                        : AppColorsPetugas.error.withOpacity(
                                          0.1,
                                        ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    controller.isKenaikanPositif.value
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 14,
                                    color:
                                        controller.isKenaikanPositif.value
                                            ? AppColorsPetugas.success
                                            : AppColorsPetugas.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.persentaseKenaikan.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          controller.isKenaikanPositif.value
                                              ? AppColorsPetugas.success
                                              : AppColorsPetugas.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'dari bulan lalu',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColorsPetugas.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorsPetugas.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColorsPetugas.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColorsPetugas.success,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            _buildRevenueSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildRevenueQuickInfo(
            'Pendapatan Sewa',
            controller.pendapatanSewa.value,
            AppColorsPetugas.navyBlue,
            Icons.shopping_cart_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueQuickInfo(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsPetugas.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSources() {
    return Card(
      elevation: 2,
      shadowColor: AppColorsPetugas.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sumber Pendapatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColorsPetugas.navyBlue,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Revenue Donut Chart
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorsPetugas.navyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Sewa Aset',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColorsPetugas.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Text(
                                controller.pendapatanSewa.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsPetugas.navyBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '100% dari total pendapatan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTrend() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

    return Card(
      elevation: 2,
      shadowColor: AppColorsPetugas.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren Pendapatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColorsPetugas.navyBlue,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: Obx(() {
                // Get the trend data from controller
                final List<double> trendData = controller.trendPendapatan;
                final double maxValue = trendData.reduce(
                  (curr, next) => curr > next ? curr : next,
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Y-axis labels
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${maxValue.toStringAsFixed(1)}M',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsPetugas.textSecondary,
                          ),
                        ),
                        Text(
                          '${(maxValue * 0.75).toStringAsFixed(1)}M',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsPetugas.textSecondary,
                          ),
                        ),
                        Text(
                          '${(maxValue * 0.5).toStringAsFixed(1)}M',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsPetugas.textSecondary,
                          ),
                        ),
                        Text(
                          '${(maxValue * 0.25).toStringAsFixed(1)}M',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsPetugas.textSecondary,
                          ),
                        ),
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsPetugas.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Chart bars
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                  top: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                color: Colors.grey.shade50.withOpacity(0.3),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(trendData.length, (
                                  index,
                                ) {
                                  final percentage =
                                      trendData[index] / maxValue;
                                  final isLastMonth =
                                      index == trendData.length - 1;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 35,
                                        height: 170 * percentage,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors:
                                                isLastMonth
                                                    ? [
                                                      AppColorsPetugas.success,
                                                      AppColorsPetugas.success
                                                          .withOpacity(0.7),
                                                    ]
                                                    : [
                                                      AppColorsPetugas
                                                          .blueGrotto
                                                          .withOpacity(0.9),
                                                      AppColorsPetugas
                                                          .blueGrotto
                                                          .withOpacity(0.5),
                                                    ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  isLastMonth
                                                      ? AppColorsPetugas.success
                                                          .withOpacity(0.3)
                                                      : AppColorsPetugas
                                                          .blueGrotto
                                                          .withOpacity(0.2),
                                              blurRadius: 4,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                right: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(trendData.length, (
                                index,
                              ) {
                                final isLastMonth =
                                    index == trendData.length - 1;

                                return Container(
                                  width: 35,
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    months[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isLastMonth
                                              ? AppColorsPetugas.success
                                              : AppColorsPetugas.textSecondary,
                                      fontWeight:
                                          isLastMonth
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final isAsetTab = controller.currentTabIndex.value == 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah ${isAsetTab ? 'Aset' : 'Paket'} Baru'),
          content: Text(
            'Formulir untuk menambahkan ${isAsetTab ? 'aset' : 'paket'} baru akan ditampilkan di sini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement add item functionality
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColorsPetugas.navyBlue,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                controller.logout(); // Lakukan logout
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Build individual tab methods
  Widget _buildAsetTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColorsPetugas.blueGrotto.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manajemen Aset',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola semua aset BUMDes',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaketTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: AppColorsPetugas.navyBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manajemen Paket',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola paket aset untuk sewa',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSewaTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColorsPetugas.blueGrotto.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Permintaan Sewa',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola permintaan sewa dari warga',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBumdesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 80,
            color: AppColorsPetugas.navyBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Profil BUMDes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola informasi dan data BUMDes',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for creating pie/donut chart segments
class _SweepClipper extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;

  _SweepClipper({required this.startAngle, required this.sweepAngle});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Convert angles from degrees to radians
    final startRad = startAngle * (3.14159 / 180);
    final endRad = (startAngle + sweepAngle) * (3.14159 / 180);

    final path = Path();

    // Move to center
    path.moveTo(center.dx, center.dy);

    // Line to start point on the circle
    path.lineTo(
      center.dx + radius * cos(startRad),
      center.dy + radius * sin(startRad),
    );

    // Arc to end point
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepAngle * (3.14159 / 180),
      false,
    );

    // Close path back to center
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_SweepClipper oldClipper) {
    return oldClipper.startAngle != startAngle ||
        oldClipper.sweepAngle != sweepAngle;
  }
}
