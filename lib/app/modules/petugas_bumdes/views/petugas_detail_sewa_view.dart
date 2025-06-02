import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';
import '../../../theme/app_colors_petugas.dart';

class PetugasDetailSewaView extends StatelessWidget {
  final Map<String, dynamic> sewa;
  final PetugasSewaController controller = Get.find<PetugasSewaController>();

  PetugasDetailSewaView({Key? key, required this.sewa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      case 'Selesai':
        statusIcon = Icons.task_alt_outlined;
        break;
      case 'Dibatalkan':
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusIcon = Icons.help_outline_rounded;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Detail Sewa #${sewa['order_id']}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showDownloadOptions(context),
            tooltip: 'Unduh Bukti',
          ),
          _buildActionMenu(context),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar Extension with Status
          SliverToBoxAdapter(
            child: Container(
              color: AppColorsPetugas.navyBlue,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Status Pill
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 18, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price Tag
                    Text(
                      controller.formatPrice(sewa['total_biaya']),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Order ID and Date Range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColorsPetugas.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${sewa['tanggal_mulai']} - ${sewa['tanggal_selesai']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorsPetugas.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warga & Asset info card
                  _buildInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Warga info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColorsPetugas.babyBlueLight,
                              child: Text(
                                sewa['nama_warga']
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsPetugas.blueGrotto,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sewa['nama_warga'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsPetugas.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 14,
                                        color: AppColorsPetugas.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '0812-3456-7890', // Placeholder
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColorsPetugas.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),

                        // Asset info
                        Row(
                          children: [
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sewa['nama_aset'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColorsPetugas.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '1 unit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColorsPetugas.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rental Details Card
                  _buildInfoCard(
                    title: 'Detail Sewa',
                    titleIcon: Icons.receipt_long_rounded,
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Tanggal Mulai',
                          value: sewa['tanggal_mulai'],
                        ),
                        _buildDetailRow(
                          icon: Icons.event_rounded,
                          label: 'Tanggal Selesai',
                          value: sewa['tanggal_selesai'],
                        ),
                        _buildDetailRow(
                          icon: Icons.timer_rounded,
                          label: 'Durasi',
                          value: '7 hari', // Placeholder
                        ),
                        _buildDetailRow(
                          icon: Icons.schedule_rounded,
                          label: 'Status',
                          value: status,
                          valueColor: statusColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Billing Details Card (replacing Payment Details)
                  _buildInfoCard(
                    title: 'Detail Tagihan',
                    titleIcon: Icons.receipt_long_rounded,
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Tagihan Sewa',
                          value: controller.formatPrice(sewa['total_biaya']),
                        ),
                        _buildDetailRow(
                          icon: Icons.warning_amber_rounded,
                          label: 'Denda',
                          value: controller.formatPrice(sewa['denda'] ?? 0),
                        ),
                        _buildDetailRow(
                          icon: Icons.payments_outlined,
                          label: 'Tagihan Dibayar',
                          value: controller.formatPrice(sewa['dibayar'] ?? 0),
                          valueColor: AppColorsPetugas.blueGrotto,
                          valueBold: true,
                        ),
                        // Add Total row when status is "Menunggu Pembayaran"
                        if (status == 'Menunggu Pembayaran')
                          _buildDetailRow(
                            icon: Icons.summarize_rounded,
                            label: 'Total',
                            value: controller.formatPrice(
                              (sewa['total_biaya'] ?? 0) +
                                  (sewa['denda'] ?? 0) -
                                  (sewa['dibayar'] ?? 0),
                            ),
                            valueColor: AppColorsPetugas.navyBlue,
                            valueBold: true,
                          ),
                      ],
                    ),
                  ),

                  // Payment Options (only for Menunggu Pembayaran status)
                  if (status == 'Menunggu Pembayaran') ...[
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(),
                  ],

                  // Payment Proof and Options (for Periksa Pembayaran status)
                  if (status == 'Periksa Pembayaran') ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Bukti Pembayaran',
                      titleIcon: Icons.receipt_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColorsPetugas.babyBlue,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/bukti_transfer.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Open image in fullscreen or larger view
                                // Implement image viewer here
                                Get.snackbar(
                                  'Lihat Bukti Transfer',
                                  'Membuka bukti transfer dalam tampilan penuh',
                                  backgroundColor: AppColorsPetugas.blueGrotto,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: const Icon(Icons.zoom_in),
                              label: const Text('Lihat Bukti Transfer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsPetugas.babyBlue
                                    .withOpacity(0.8),
                                foregroundColor: AppColorsPetugas.navyBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(),
                  ],

                  // Penalty Details and Payment Options (for Pembayaran Denda status)
                  if (status == 'Pembayaran Denda') ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Detail Denda',
                      titleIcon: Icons.warning_amber_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.text_snippet_outlined,
                            label: 'Alasan Denda',
                            value: 'Kerusakan pada aset saat pengembalian',
                          ),
                          _buildDetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tanggal Pelaporan',
                            value: '20 Maret 2025',
                          ),
                          _buildDetailRow(
                            icon: Icons.money_outlined,
                            label: 'Nominal Denda',
                            value: controller.formatPrice(25000),
                            valueColor: Colors.deepOrange,
                            valueBold: true,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bukti Kerusakan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColorsPetugas.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColorsPetugas.babyBlue,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/kerusakan.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: AppColorsPetugas.babyBlueBright,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Gambar tidak tersedia',
                                            style: TextStyle(
                                              color:
                                                  AppColorsPetugas
                                                      .textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Lihat Bukti Kerusakan',
                                  'Membuka gambar dalam tampilan penuh',
                                  backgroundColor: AppColorsPetugas.blueGrotto,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: const Icon(Icons.zoom_in),
                              label: const Text('Lihat Bukti Kerusakan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsPetugas.babyBlue
                                    .withOpacity(0.8),
                                foregroundColor: AppColorsPetugas.navyBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(isPenalty: true),
                  ],

                  // Penalty Details, Payment Proof, and Payment Options (for Periksa Denda status)
                  if (status == 'Periksa Denda') ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Detail Denda',
                      titleIcon: Icons.warning_amber_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.text_snippet_outlined,
                            label: 'Alasan Denda',
                            value: 'Kerusakan pada aset saat pengembalian',
                          ),
                          _buildDetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tanggal Pelaporan',
                            value: '20 Maret 2025',
                          ),
                          _buildDetailRow(
                            icon: Icons.money_outlined,
                            label: 'Nominal Denda',
                            value: controller.formatPrice(25000),
                            valueColor: Colors.deepOrange,
                            valueBold: true,
                          ),
                          _buildDetailRow(
                            icon: Icons.calendar_month_rounded,
                            label: 'Tanggal Pembayaran',
                            value: '22 Maret 2025',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bukti Kerusakan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColorsPetugas.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColorsPetugas.babyBlue,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/kerusakan.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: AppColorsPetugas.babyBlueBright,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Gambar tidak tersedia',
                                            style: TextStyle(
                                              color:
                                                  AppColorsPetugas
                                                      .textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Lihat Bukti Kerusakan',
                                  'Membuka gambar dalam tampilan penuh',
                                  backgroundColor: AppColorsPetugas.blueGrotto,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: const Icon(Icons.zoom_in),
                              label: const Text('Lihat Bukti Kerusakan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsPetugas.babyBlue
                                    .withOpacity(0.8),
                                foregroundColor: AppColorsPetugas.navyBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Bukti Pembayaran Denda',
                      titleIcon: Icons.receipt_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColorsPetugas.babyBlue,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/bukti_transfer.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: AppColorsPetugas.babyBlueBright,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Gambar tidak tersedia',
                                            style: TextStyle(
                                              color:
                                                  AppColorsPetugas
                                                      .textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Lihat Bukti Transfer',
                                  'Membuka bukti transfer dalam tampilan penuh',
                                  backgroundColor: AppColorsPetugas.blueGrotto,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: const Icon(Icons.zoom_in),
                              label: const Text('Lihat Bukti Transfer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsPetugas.babyBlue
                                    .withOpacity(0.8),
                                foregroundColor: AppColorsPetugas.navyBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(
                      isPenalty: true,
                      isVerifying: true,
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildInfoCard({
    required Widget child,
    String? title,
    IconData? titleIcon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(
                      titleIcon,
                      size: 18,
                      color: AppColorsPetugas.blueGrotto,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColorsPetugas.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColorsPetugas.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? AppColorsPetugas.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    final status = sewa['status'];

    // Determine available actions based on status
    List<PopupMenuEntry<String>> menuItems = [];

    if (status == 'Menunggu Pembayaran') {
      menuItems.add(
        PopupMenuItem(
          value: 'check_payment',
          child: _buildMenuItemContent(
            icon: Icons.fact_check_outlined,
            text: 'Periksa Pembayaran',
            color: Colors.amber.shade700,
          ),
        ),
      );
    } else if (status == 'Periksa Pembayaran') {
      menuItems.add(
        PopupMenuItem(
          value: 'approve',
          child: _buildMenuItemContent(
            icon: Icons.check_circle_outline,
            text: 'Terima Pengajuan',
            color: Colors.green.shade600,
          ),
        ),
      );
    } else if (status == 'Diterima') {
      menuItems.add(
        PopupMenuItem(
          value: 'request_penalty',
          child: _buildMenuItemContent(
            icon: Icons.money_off_csred_outlined,
            text: 'Minta Pembayaran Denda',
            color: Colors.deepOrange,
          ),
        ),
      );
    } else if (status == 'Pembayaran Denda') {
      menuItems.add(
        PopupMenuItem(
          value: 'check_penalty',
          child: _buildMenuItemContent(
            icon: Icons.assignment_late_outlined,
            text: 'Periksa Pembayaran Denda',
            color: Colors.red.shade600,
          ),
        ),
      );
    } else if (status == 'Periksa Denda') {
      menuItems.add(
        PopupMenuItem(
          value: 'complete',
          child: _buildMenuItemContent(
            icon: Icons.task_alt_outlined,
            text: 'Selesaikan Sewa',
            color: Colors.purple,
          ),
        ),
      );
    } else if (status == 'Dikembalikan') {
      menuItems.add(
        PopupMenuItem(
          value: 'complete',
          child: _buildMenuItemContent(
            icon: Icons.task_alt_outlined,
            text: 'Selesaikan Sewa',
            color: Colors.purple,
          ),
        ),
      );
    }

    // Always add cancel option if not already completed or canceled
    if (status != 'Selesai' && status != 'Dibatalkan') {
      menuItems.add(
        PopupMenuItem(
          value: 'cancel',
          child: _buildMenuItemContent(
            icon: Icons.cancel_outlined,
            text: 'Batalkan Sewa',
            color: Colors.red,
          ),
        ),
      );
    }

    // If no actions available, return empty container
    if (menuItems.isEmpty) {
      return Container();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => menuItems,
      onSelected: (value) => _handleMenuAction(value),
    );
  }

  Widget _buildMenuItemContent({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(text),
      ],
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'check_payment':
        // Update status to "Periksa Pembayaran"
        controller.approveSewa(sewa['id']); // Reusing existing method
        Get.back();
        Get.snackbar(
          'Status Diubah',
          'Status pengajuan diubah menjadi Periksa Pembayaran',
          backgroundColor: Colors.amber.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'approve':
        // Update status to "Diterima"
        controller.approveSewa(sewa['id']);
        Get.back();
        Get.snackbar(
          'Pengajuan Diterima',
          'Pengajuan sewa aset telah disetujui',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'request_penalty':
        // Update status to "Pembayaran Denda"
        controller.requestPenaltyPayment(sewa['id']);
        Get.back();
        Get.snackbar(
          'Permintaan Denda',
          'Permintaan pembayaran denda telah dikirim',
          backgroundColor: Colors.deepOrange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'check_penalty':
        // Update status to "Periksa Denda"
        controller.markPenaltyForInspection(sewa['id']);
        Get.back();
        Get.snackbar(
          'Status Diubah',
          'Status pengajuan diubah menjadi Periksa Denda',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'complete':
        // Update status to "Selesai"
        controller.completeSewa(sewa['id']);
        Get.back();
        Get.snackbar(
          'Sewa Selesai',
          'Aset telah dikembalikan dan sewa telah selesai',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'cancel':
        // Update status to "Dibatalkan"
        controller.rejectSewa(sewa['id']);
        Get.back();
        Get.snackbar(
          'Sewa Dibatalkan',
          'Sewa aset telah dibatalkan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }

  Widget? _buildBottomActionBar() {
    final status = sewa['status'];

    // Button text and actions based on status
    String? buttonText;
    VoidCallback? onPressed;
    Color? buttonColor;
    IconData? buttonIcon;

    if (status == 'Menunggu Pembayaran') {
      // Remove the "Periksa Pembayaran" button for "Menunggu Pembayaran" status
      return null;
    } else if (status == 'Periksa Pembayaran') {
      // Remove the "Terima Pengajuan Sewa" button for "Periksa Pembayaran" status
      return null;
    } else if (status == 'Diterima') {
      buttonText = 'Konfirmasi Pengembalian';
      buttonIcon = Icons.assignment_return_outlined;
      buttonColor = Colors.blue.shade700;
      onPressed = () {
        // Show confirmation dialog
        Get.dialog(
          AlertDialog(
            title: const Text('Konfirmasi Pengembalian'),
            content: const Text(
              'Apakah Anda yakin aset telah dikembalikan oleh penyewa?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Batal',
                  style: TextStyle(color: AppColorsPetugas.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Close dialog
                  Get.back();

                  // Request penalty or complete the rental
                  showModalBottomSheet(
                    context: Get.context!,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Status Pengembalian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColorsPetugas.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Pilih status pengembalian aset:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColorsPetugas.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Return Without Penalty Option
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              title: const Text('Pengembalian Normal'),
                              subtitle: const Text(
                                'Aset dikembalikan dalam kondisi baik',
                              ),
                              onTap: () {
                                Get.back();
                                controller.markAsReturned(sewa['id']);
                                Get.back();
                                Get.snackbar(
                                  'Aset Dikembalikan',
                                  'Status sewa diubah menjadi Dikembalikan',
                                  backgroundColor: Colors.teal,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Return With Penalty Option
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              title: const Text('Pengembalian Dengan Denda'),
                              subtitle: const Text(
                                'Aset rusak/telat/tidak sesuai ketentuan',
                              ),
                              onTap: () {
                                Get.back();
                                controller.requestPenaltyPayment(sewa['id']);
                                Get.back();
                                Get.snackbar(
                                  'Denda Diterapkan',
                                  'Permintaan pembayaran denda telah dikirim',
                                  backgroundColor: Colors.deepOrange,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPetugas.blueGrotto,
                ),
                child: const Text('Konfirmasi'),
              ),
            ],
          ),
        );
      };
    } else if (status == 'Periksa Denda') {
      buttonText = 'Selesaikan Sewa';
      buttonIcon = Icons.task_alt_outlined;
      buttonColor = Colors.purple;
      onPressed = () {
        controller.completeSewa(sewa['id']);
        Get.back();
        Get.snackbar(
          'Sewa Selesai',
          'Sewa aset telah selesai',
          backgroundColor: Colors.purple,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      };
    } else if (status == 'Dikembalikan') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Add Penalty Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddPenaltyDialog();
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('Tambah Denda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Complete Rental Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.completeSewa(sewa['id']);
                  Get.back();
                  Get.snackbar(
                    'Sewa Selesai',
                    'Sewa aset telah selesai',
                    backgroundColor: Colors.purple,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Selesaikan Sewa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No button for other statuses
    if (buttonText == null) return null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(buttonIcon),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unduh Bukti Sewa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih format dokumen yang ingin diunduh',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorsPetugas.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // PDF option
              _buildDownloadOption(
                context: context,
                icon: Icons.picture_as_pdf_outlined,
                title: 'PDF',
                subtitle: 'Dokumen lengkap bukti sewa',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Mengunduh PDF',
                    'Bukti sewa dalam format PDF sedang diunduh',
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Image option
              _buildDownloadOption(
                context: context,
                icon: Icons.image_outlined,
                title: 'Gambar (JPG)',
                subtitle: 'Tampilan bukti sewa sebagai gambar',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Mengunduh Gambar',
                    'Bukti sewa dalam format JPG sedang diunduh',
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Excel option
              _buildDownloadOption(
                context: context,
                icon: Icons.table_chart_outlined,
                title: 'Excel (XLSX)',
                subtitle: 'Data sewa dalam format spreadsheet',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Mengunduh Excel',
                    'Data sewa dalam format XLSX sedang diunduh',
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColorsPetugas.babyBlue),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColorsPetugas.babyBlueBright,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColorsPetugas.blueGrotto, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColorsPetugas.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColorsPetugas.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColorsPetugas.blueGrotto,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionsCard({
    bool isPenalty = false,
    bool isVerifying = false,
  }) {
    final status = sewa['status'];
    final isFullPayment = true.obs;

    // Set title based on context
    String cardTitle = 'Opsi Pembayaran';
    if (isPenalty) {
      cardTitle =
          isVerifying ? 'Verifikasi Pembayaran Denda' : 'Opsi Pembayaran Denda';
    } else if (isVerifying) {
      cardTitle = 'Verifikasi Pembayaran';
    }

    return _buildInfoCard(
      title: cardTitle,
      titleIcon: Icons.payment_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Payment Option (Radio Button) - Only show when not verifying
          if (!isVerifying)
            Obx(
              () => Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: isFullPayment.value,
                    onChanged: (value) {
                      isFullPayment.value = true;
                      // Set payment amount to full rental fee
                    },
                    activeColor: AppColorsPetugas.blueGrotto,
                  ),
                  Text(
                    isPenalty ? 'Pembayaran Denda Penuh' : 'Pembayaran Penuh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColorsPetugas.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

          // Payment Method Selection - Modified when verifying
          Text(
            isVerifying ? 'Metode Pembayaran Diterima' : 'Metode Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsPetugas.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Payment Method Options
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap:
                      !isVerifying
                          ? () {
                            // Handle cash payment selection
                          }
                          : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isVerifying && sewa['payment_method'] != 'cash'
                              ? Colors.white
                              : AppColorsPetugas.babyBlueBright,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isVerifying && sewa['payment_method'] == 'cash'
                                ? AppColorsPetugas.blueGrotto
                                : AppColorsPetugas.babyBlue,
                        width:
                            isVerifying && sewa['payment_method'] == 'cash'
                                ? 2
                                : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: AppColorsPetugas.blueGrotto,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tunai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isVerifying && sewa['payment_method'] == 'cash'
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                            color: AppColorsPetugas.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap:
                      !isVerifying
                          ? () {
                            // Handle transfer payment selection
                          }
                          : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isVerifying && sewa['payment_method'] != 'transfer'
                              ? Colors.white
                              : AppColorsPetugas.babyBlueBright,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isVerifying && sewa['payment_method'] == 'transfer'
                                ? AppColorsPetugas.blueGrotto
                                : AppColorsPetugas.babyBlue,
                        width:
                            isVerifying && sewa['payment_method'] == 'transfer'
                                ? 2
                                : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: AppColorsPetugas.blueGrotto,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Transfer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isVerifying &&
                                        sewa['payment_method'] == 'transfer'
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                            color: AppColorsPetugas.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Amount Input Field
          Text(
            isPenalty
                ? isVerifying
                    ? 'Nominal Denda Dibayarkan'
                    : 'Nominal Pembayaran Denda'
                : isVerifying
                ? 'Nominal Dibayarkan'
                : 'Nominal Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsPetugas.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextFormField(
              keyboardType: TextInputType.number,
              initialValue:
                  isFullPayment.value
                      ? isPenalty
                          ? '25000' // Hardcoded penalty amount
                          : ((sewa['total_biaya'] ?? 0) +
                                  (sewa['denda'] ?? 0) -
                                  (sewa['dibayar'] ?? 0))
                              .toString()
                      : isVerifying
                      ? (sewa['paid_amount'] ?? 0).toString()
                      : null,
              enabled: !isVerifying,
              decoration: InputDecoration(
                hintText:
                    isPenalty
                        ? 'Masukkan nominal pembayaran denda'
                        : 'Masukkan nominal pembayaran',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColorsPetugas.babyBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColorsPetugas.babyBlue),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle payment confirmation or verification
                if (isVerifying && isPenalty) {
                  // Verify penalty payment
                  controller.completeSewa(sewa['id']);
                  Get.back();
                  Get.snackbar(
                    'Pembayaran Denda Diverifikasi',
                    'Status sewa diubah menjadi Selesai',
                    backgroundColor: Colors.purple,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else if (isVerifying) {
                  // Verify regular payment
                  controller.approveSewa(sewa['id']);
                  Get.back();
                  Get.snackbar(
                    'Pembayaran Diverifikasi',
                    'Pengajuan sewa aset telah disetujui',
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else if (isPenalty) {
                  // Handle penalty payment
                  controller.markPenaltyForInspection(sewa['id']);
                  Get.back();
                  Get.snackbar(
                    'Pembayaran Denda Dikonfirmasi',
                    'Status diubah menjadi Periksa Denda',
                    backgroundColor: Colors.deepOrange,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  // Confirm regular payment
                  controller.approveSewa(sewa['id']);
                  Get.back();
                  Get.snackbar(
                    'Pembayaran Dikonfirmasi',
                    'Status pengajuan diubah menjadi Periksa Pembayaran',
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              icon: Icon(
                isVerifying
                    ? isPenalty
                        ? Icons.task_alt_outlined
                        : Icons.check_circle_outline
                    : isPenalty
                    ? Icons.warning_amber_rounded
                    : Icons.payments_outlined,
              ),
              label: Text(
                isVerifying
                    ? isPenalty
                        ? 'Verifikasi Pembayaran Denda'
                        : 'Verifikasi Pembayaran'
                    : isPenalty
                    ? 'Konfirmasi Pembayaran Denda'
                    : 'Konfirmasi Pembayaran',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isVerifying && isPenalty
                        ? Colors.purple
                        : isVerifying
                        ? Colors.green.shade600
                        : isPenalty
                        ? Colors.deepOrange
                        : AppColorsPetugas.blueGrotto,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPenaltyDialog() {
    // TextEditingControllers for form inputs
    final penaltyAmountController = TextEditingController();
    final descriptionController = TextEditingController();
    // Image file value (to be updated when capturing an image)
    final Rx<bool> hasImage = false.obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.deepOrange,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tambah Denda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      color: AppColorsPetugas.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Penalty Amount Field
                Text(
                  'Nominal Denda',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorsPetugas.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: penaltyAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nominal denda',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColorsPetugas.babyBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColorsPetugas.babyBlue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                Text(
                  'Keterangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorsPetugas.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Masukkan keterangan denda',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColorsPetugas.babyBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColorsPetugas.babyBlue),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Image Upload
                Text(
                  'Bukti Kerusakan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorsPetugas.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColorsPetugas.babyBlue),
                      color:
                          hasImage.value
                              ? Colors.transparent
                              : AppColorsPetugas.babyBlueBright,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          // This would open the camera in a real implementation
                          // Using a snackbar here as a placeholder
                          Get.snackbar(
                            'Membuka Kamera',
                            'Implementasi kamera akan dibuka di sini',
                            backgroundColor: AppColorsPetugas.blueGrotto,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );

                          // Simulate taking a photo for the UI
                          hasImage.value = true;
                        },
                        borderRadius: BorderRadius.circular(8),
                        child:
                            hasImage.value
                                ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // This would be the actual image preview
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          'assets/images/damage_preview.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            // Fallback if image not found
                                            return Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 60,
                                                color:
                                                    AppColorsPetugas.blueGrotto,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Edit overlay
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: AppColorsPetugas.blueGrotto,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Klik untuk ambil foto bukti',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColorsPetugas.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Validate inputs
                      if (penaltyAmountController.text.isEmpty) {
                        Get.snackbar(
                          'Peringatan',
                          'Nominal denda harus diisi',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      // Process the penalty
                      Get.back(); // Close the dialog

                      // Update status to Pembayaran Denda
                      controller.requestPenaltyPayment(sewa['id']);
                      Get.back(); // Return from the detail page

                      Get.snackbar(
                        'Denda Diterapkan',
                        'Permintaan pembayaran denda telah dikirim',
                        backgroundColor: Colors.deepOrange,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Konfirmasi Denda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
