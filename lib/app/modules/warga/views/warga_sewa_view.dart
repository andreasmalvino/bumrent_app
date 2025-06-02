import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../controllers/warga_sewa_controller.dart';
import '../views/warga_layout.dart';
import '../../../services/navigation_service.dart';
import '../../../widgets/app_drawer.dart';
import '../../../theme/app_colors.dart';

class WargaSewaView extends GetView<WargaSewaController> {
  const WargaSewaView({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Get.find<NavigationService>();

    return WargaLayout(
      drawer: AppDrawer(
        onNavItemTapped: controller.onNavItemTapped,
        onLogout: () {
          Get.find<NavigationService>().toLogin();
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Sewa Aset Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildTabBar(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              physics: const PageScrollPhysics(),
              dragStartBehavior: DragStartBehavior.start,
              children: [
                _buildBelumBayarTab(),
                _buildPendingTab(),
                _buildDiterimaTab(),
                _buildAktifTab(),
                _buildSelesaiTab(),
                _buildDibatalkanTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => controller.navigateToRentals(),
          backgroundColor: AppColors.primary,
          elevation: 0,
          icon: const Icon(
            Icons.add_circle_outline,
            size: 20,
            color: Colors.white,
          ),
          label: const Text(
            'Sewa Baru',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: controller.tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        isScrollable: true,
        tabs: [
          _buildTab(text: 'Belum Bayar', icon: Icons.payment_outlined),
          _buildTab(text: 'Pending', icon: Icons.pending_outlined),
          _buildTab(text: 'Diterima', icon: Icons.check_circle_outline),
          _buildTab(text: 'Aktif', icon: Icons.play_circle_outline),
          _buildTab(text: 'Selesai', icon: Icons.task_alt_outlined),
          _buildTab(text: 'Dibatalkan', icon: Icons.cancel_outlined),
        ],
      ),
    );
  }

  Widget _buildTab({required String text, required IconData icon}) {
    return Tab(
      height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPendingTab() {
    return Obx(() {
      // Show loading indicator while fetching data
      if (controller.isLoadingPending.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      // Check if there is any data to display
      if (controller.pendingRentals.isNotEmpty) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: controller.pendingRentals
                .map((rental) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildUnpaidRentalCard(rental),
                    ))
                .toList(),
          ),
        );
      }

      // Return empty state if no data
      return _buildTabContent(
        icon: Icons.pending_actions,
        title: 'Tidak ada pembayaran yang sedang diperiksa',
        subtitle: 'Tidak ada sewa yang sedang dalam verifikasi pembayaran',
        buttonText: 'Sewa Sekarang',
        onButtonPressed: () => controller.navigateToRentals(),
        color: AppColors.warning,
      );
    });
  }
  
  Widget _buildAktifTab() {
    return Obx(() {
      // Show loading indicator while fetching data
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      // Placeholder content for the Aktif tab
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tab Aktif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Konten tab Aktif akan ditampilkan di sini',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBelumBayarTab() {
    return Obx(() {
      // Show loading indicator while fetching data
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      // Check if there is any data to display
      if (controller.rentals.isNotEmpty) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Build a card for each rental item
              ...controller.rentals.map((rental) => Column(
                children: [
                  _buildUnpaidRentalCard(rental),
                  const SizedBox(height: 20),
                ],
              )).toList(),
              _buildTipsSection(),
            ],
          ),
        );
      }

      // Return empty state if no data
      return _buildTabContent(
        icon: Icons.payment_outlined,
        title: 'Belum ada pembayaran',
        subtitle: 'Tidak ada sewa yang menunggu pembayaran',
        buttonText: 'Sewa Sekarang',
        onButtonPressed: () => controller.navigateToRentals(),
        color: AppColors.primary,
      );
    });
  }

  Widget _buildUnpaidRentalCard(Map<String, dynamic> rental) {
    // Determine status color based on status
    final bool isPembayaranDenda = rental['status'] == 'PEMBAYARAN DENDA';
    final Color statusColor = isPembayaranDenda ? AppColors.error : AppColors.warning;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  isPembayaranDenda ? Icons.warning_amber_rounded : Icons.access_time_rounded,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  rental['status'] ?? 'MENUNGGU PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          // Asset details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset image with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: rental['imageUrl'] != null && rental['imageUrl'].toString().startsWith('http')
                    ? Image.network(
                        rental['imageUrl'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        rental['imageUrl'] ?? 'assets/images/gambar_pendukung.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(width: 16),
                // Asset details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental['name'] ?? 'Aset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.inventory_2_outlined,
                        text: '${rental['jumlahUnit'] ?? 0} Unit',
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: rental['tanggalSewa'] ?? '',
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        icon: Icons.schedule,
                        text: rental['rentangWaktu'] ?? '',
                      ),
                      const SizedBox(height: 12),
                      // Countdown timer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Bayar dalam ${rental['countdown'] ?? '00:59:59'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
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
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Price section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Bayar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rental['totalPrice'] ?? 'Rp 0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                // Pay button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rental['status'] == 'PEMBAYARAN DENDA' ? AppColors.error : AppColors.warning,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    rental['status'] == 'PEMBAYARAN DENDA' ? 'Bayar Denda' : 'Bayar Sekarang',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'Lihat Detail',
                    onPressed: () => controller.viewRentalDetail(rental),
                    iconColor: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.cancel_outlined,
                    label: 'Batalkan',
                    onPressed: () => controller.cancelRental(rental['id']),
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color iconColor,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: iconColor),
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildDiterimaTab() {
    return Obx(() {
      // Show loading indicator while fetching data
      if (controller.isLoadingAccepted.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      // Check if there is any data to display
      if (controller.acceptedRentals.isNotEmpty) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Build a card for each accepted rental item
              ...controller.acceptedRentals.map((rental) => Column(
                children: [
                  _buildDiterimaRentalCard(rental),
                  const SizedBox(height: 20),
                ],
              )).toList(),
              _buildTipsSectionDiterima(),
            ],
          ),
        );
      }

      // Return empty state if no data
      return _buildTabContent(
        icon: Icons.check_circle_outline,
        title: 'Belum ada sewa diterima',
        subtitle: 'Sewa yang sudah diterima akan muncul di sini',
        buttonText: 'Sewa Sekarang',
        onButtonPressed: () => controller.navigateToRentals(),
        color: AppColors.success,
      );
    });
  }

  Widget _buildDiterimaRentalCard(Map<String, dynamic> rental) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  rental['status'] ?? 'DITERIMA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Asset details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset image with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: rental['imageUrl'] != null && rental['imageUrl'].toString().startsWith('http')
                    ? Image.network(
                        rental['imageUrl'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        rental['imageUrl'] ?? 'assets/images/gambar_pendukung.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(width: 16),
                // Asset details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental['name'] ?? 'Aset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.inventory_2_outlined,
                        text: '${rental['jumlahUnit'] ?? 0} Unit',
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: rental['tanggalSewa'] ?? '',
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        icon: Icons.schedule,
                        text: rental['rentangWaktu'] ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Price section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Bayar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rental['totalPrice'] ?? 'Rp 0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'Lihat Detail',
                    onPressed: () => controller.viewRentalDetail(rental),
                    iconColor: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.cancel_outlined,
                    label: 'Batalkan',
                    onPressed: () => controller.cancelRental(rental['id']),
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelesaiTab() {
    return Obx(() {
      if (controller.isLoadingCompleted.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.completedRentals.isEmpty) {
        return _buildTabContent(
          icon: Icons.check_circle_outline,
          title: 'Belum Ada Sewa Selesai',
          subtitle: 'Anda belum memiliki riwayat sewa yang telah selesai',
          buttonText: 'Lihat Aset',
          onButtonPressed: () => Get.toNamed('/warga-aset'),
          color: AppColors.info,
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: controller.completedRentals
              .map((rental) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildSelesaiRentalCard(rental),
                  ))
              .toList(),
        ),
      );
    });
  }

  Widget _buildSelesaiRentalCard(Map<String, dynamic> rental) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.task_alt_outlined, size: 18, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  rental['status'] ?? 'SELESAI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),

          // Asset details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset image with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: rental['imageUrl'] != null && rental['imageUrl'].toString().startsWith('http')
                    ? Image.network(
                        rental['imageUrl'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        rental['imageUrl'] ?? 'assets/images/gambar_pendukung.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(width: 16),
                // Asset details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental['name'] ?? 'Aset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rental['jumlahUnit'] ?? 0} Unit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        text: rental['rentangWaktu'] ?? '-',
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        text: rental['duration'] ?? '-',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
            height: 1,
          ),

          // Price section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      rental['totalPrice'] ?? 'Rp 0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'Lihat Detail',
                    onPressed: () => controller.viewRentalDetail(rental),
                    iconColor: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDibatalkanTab() {
    return Obx(() {
      if (controller.isLoadingCancelled.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.cancelledRentals.isEmpty) {
        return _buildTabContent(
          icon: Icons.cancel_outlined,
          title: 'Belum Ada Sewa Dibatalkan',
          subtitle: 'Anda belum memiliki riwayat sewa yang dibatalkan',
          buttonText: 'Lihat Aset',
          onButtonPressed: () => Get.toNamed('/warga-aset'),
          color: AppColors.error,
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: controller.cancelledRentals
              .map((rental) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildDibatalkanRentalCard(rental),
                  ))
              .toList(),
        ),
      );
    });
  }

  Widget _buildDibatalkanRentalCard(Map<String, dynamic> rental) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                const SizedBox(width: 8),
                Text(
                  rental['status'] ?? 'DIBATALKAN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          // Asset details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset image with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: rental['imageUrl'] != null && rental['imageUrl'].toString().startsWith('http')
                    ? Image.network(
                        rental['imageUrl'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        rental['imageUrl'] ?? 'assets/images/gambar_pendukung.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(width: 16),
                // Asset details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental['name'] ?? 'Aset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rental['jumlahUnit'] ?? 0} Unit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        text: rental['rentangWaktu'] ?? '-',
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        text: rental['duration'] ?? '-',
                      ),
                      if (rental['alasanPembatalan'] != null && rental['alasanPembatalan'] != '-')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildInfoRow(
                            icon: Icons.info_outline,
                            text: 'Alasan: ${rental['alasanPembatalan']}',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
            height: 1,
          ),

          // Price section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      rental['totalPrice'] ?? 'Rp 0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.info_outline,
                        label: 'Lihat Detail',
                        onPressed: () => controller.viewRentalDetail(rental),
                        iconColor: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.refresh,
                        label: 'Pesan Kembali',
                        onPressed: () {},
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
    required Color color,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 60, color: color),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tips section
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Tips & Informasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.schedule,
            title: 'Pembayaran dalam 1 jam',
            description:
                'Lakukan pembayaran dalam 1 jam untuk menghindari pembatalan otomatis.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.info),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSectionDiterima() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Tips & Informasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.access_time,
            title: 'Pengembalian Tepat Waktu',
            description:
                'Lakukan pengembalian aset sebelum waktu sewa berakhir agar tidak dikenakan denda.',
          ),
        ],
      ),
    );
  }
}
