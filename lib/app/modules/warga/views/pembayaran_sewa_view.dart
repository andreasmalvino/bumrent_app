import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:get/get.dart';
import '../controllers/pembayaran_sewa_controller.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';

class PembayaranSewaView extends GetView<PembayaranSewaController> {
  const PembayaranSewaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: TabBar(
                controller: controller.tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Ringkasan'),
                  Tab(text: 'Detail Tagihan'),
                  Tab(text: 'Pembayaran'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildSummaryTab(),
                _buildBillingTab(),
                _buildPaymentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // First Tab - Summary Tab (renamed from Order Details)
  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(),
            const SizedBox(height: 16),
            _buildPaymentSummaryCard(),
            const SizedBox(height: 16),
            _buildOrderProgressTimeline(),
          ],
        ),
      ),
    );
  }

  // Second Tab - Billing Tab (new tab)
  Widget _buildBillingTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () =>
                  controller.isLoading.value
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Memuat data tagihan...',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            _buildInvoiceIdCard(),
                            const SizedBox(height: 16),
                            _buildTagihanAwalCard(),
                            const SizedBox(height: 16),
                            _buildDendaCard(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Third Tab - Payment Tab (renamed from Payment Instructions)
  Widget _buildPaymentTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentTypeSelection(),
            const SizedBox(height: 24),
            Obx(() {
              // Show payment method selection only after selecting a payment type
              if (controller.selectedPaymentType.value.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentMethodSelection(),
                    const SizedBox(height: 24),
                    if (controller.paymentMethod.value == 'transfer')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTransferInstructions(),
                          const SizedBox(height: 24),
                          _buildPaymentProofUpload(),
                        ],
                      )
                    else if (controller.paymentMethod.value == 'cash')
                      _buildCashInstructions()
                    else
                      _buildSelectPaymentMethodPrompt(),
                  ],
                );
              } else {
                // Prompt to select payment type first
                return _buildSelectPaymentTypePrompt();
              }
            }),
        ],
      ),
      ),
    );
  }

  // Order Status Card
  Widget _buildOrderStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Obx(
                    () => Text(
                      controller.orderDetails.value['status'] ??
                          'MENUNGGU PEMBAYARAN',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'ID Pesanan',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                controller.orderDetails.value['id'] ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  'Batas waktu pembayaran: ',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Obx(
                  () => Text(
                    controller.orderDetails.value['status'] == 'DIBATALKAN'
                        ? 'Dibatalkan'
                        : controller.remainingTime.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Modern Order Progress Timeline
  Widget _buildOrderProgressTimeline() {
    final steps = [
      {
        'title': 'Menunggu Pembayaran',
        'description': 'Segera lakukan pembayaran untuk melanjutkan pesanan',
        'icon': Icons.payment,
        'step': 0,
      },
      {
        'title': 'Memeriksa Pembayaran',
        'description': 'Pembayaran sedang diverifikasi oleh petugas',
        'icon': Icons.receipt_long,
        'step': 1,
      },
      {
        'title': 'Diterima',
        'description': 'Pesanan Anda telah diterima dan dikonfirmasi',
        'icon': Icons.check_circle,
        'step': 2,
      },
      {
        'title': 'Pengembalian',
        'description': 'Proses pengembalian aset sewa',
        'icon': Icons.assignment_return,
        'step': 3,
      },
      {
        'title': 'Pembayaran Denda',
        'description': 'Pembayaran denda jika ada kerusakan atau keterlambatan',
        'icon': Icons.money,
        'step': 4,
      },
      {
        'title': 'Memeriksa Pembayaran Denda',
        'description': 'Verifikasi pembayaran denda oleh petugas',
        'icon': Icons.fact_check,
        'step': 5,
      },
      {
        'title': 'Selesai',
        'description': 'Pesanan sewa telah selesai',
        'icon': Icons.task_alt,
        'step': 6,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Progress Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              final currentStep = controller.currentStep.value;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final stepNumber = step['step'] as int;
                  final isActive = currentStep >= stepNumber;
                  final isCompleted = currentStep > stepNumber;
                  final isLast = index == steps.length - 1;

                  // Determine the appropriate colors
                  final Color iconColor =
                      isActive
                          ? (isCompleted
                              ? AppColors.success
                              : AppColors.primary)
                          : Colors.grey[300]!;

                  final Color lineColor =
                      isCompleted ? AppColors.success : Colors.grey[300]!;

                  final Color bgColor =
                      isActive
                          ? (isCompleted
                              ? AppColors.successLight
                              : AppColors.primarySoft)
                          : Colors.grey[100]!;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: iconColor, width: 2),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : step['icon'] as IconData,
                              color: iconColor,
                              size: 18,
                            ),
                          ),
                          if (!isLast)
                            Container(width: 2, height: 40, color: lineColor),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color:
                                    isActive
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['description'] as String,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (!isLast) const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 18,
                        )
                      else if (currentStep == stepNumber)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Saat ini',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ID Tagihan Card
  Widget _buildInvoiceIdCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'ID Tagihan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.tagihanSewa.value['id'] ?? '-',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      // Copy to clipboard functionality would go here
                      ScaffoldMessenger.of(Get.context!).showSnackBar(
                        const SnackBar(
                          content: Text('ID Tagihan disalin ke clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    color: Colors.deepPurple,
                    tooltip: 'Salin ID Tagihan',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tagihan Awal Card (renamed from BillingDetailsCard)
  Widget _buildTagihanAwalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.receipt, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Tagihan Awal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name from aset.nama
                  _buildDetailItem(
                    'Item',
                    controller.sewaAsetDetails.value['aset_detail'] != null
                        ? controller
                                .sewaAsetDetails
                                .value['aset_detail']['nama'] ??
                            '-'
                        : controller.tagihanSewa.value['nama_aset'] ??
                            controller.orderDetails.value['item_name'] ??
                            '-',
                  ),
                  // Quantity from sewa_aset.kuantitas
                  _buildDetailItem(
                    'Jumlah',
                    '${controller.sewaAsetDetails.value['kuantitas'] ?? controller.orderDetails.value['quantity'] ?? 0} unit',
                  ),
                  // Waktu Sewa with sub-points for Waktu Mulai and Waktu Selesai
                  _buildDetailItemWithSubpoints(
                    'Waktu Sewa',
                    [
                      {
                        'label': 'Waktu Mulai',
                        'value': _formatDateTime(controller.sewaAsetDetails.value['waktu_mulai']),
                      },
                      {
                        'label': 'Waktu Selesai',
                        'value': _formatDateTime(controller.sewaAsetDetails.value['waktu_selesai']),
                      },
                    ],
                  ),
                  _buildDetailItem(
                    'Durasi',
                    controller.tagihanSewa.value['durasi'] != null
                        ? '${controller.tagihanSewa.value['durasi']} ${controller.tagihanSewa.value['satuan_waktu'] ?? ''}'
                        : controller.orderDetails.value['duration'] ?? '-',
                  ),
                  const Divider(height: 32),
                  _buildDetailItem(
                    'Harga per Unit',
                    'Rp ${controller.tagihanSewa.value['harga_sewa'] ?? controller.orderDetails.value['price_per_unit'] ?? 0}',
                    isImportant: false,
                  ),
                  _buildDetailItem(
                    'Total Harga',
                    'Rp ${controller.tagihanSewa.value['tagihan_awal'] ?? controller.orderDetails.value['total_price'] ?? 0}',
                    isImportant: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Denda Card
  Widget _buildDendaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Denda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              // Get values from tagihan_sewa table
              final denda = controller.tagihanSewa.value['denda'];
              final keterangan = controller.tagihanSewa.value['keterangan'];
              final fotoKerusakan = controller.tagihanSewa.value['foto_kerusakan'];
              
              debugPrint('Tagihan Denda: $denda');
              debugPrint('Tagihan Keterangan: $keterangan');
              debugPrint('Tagihan Foto Kerusakan: $fotoKerusakan');

              // Always show the denda amount, using "-" when it's null or zero
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show denda amount
                  _buildDetailItem(
                    'Jumlah Denda',
                    denda != null && denda != 0
                        ? 'Rp ${NumberFormat('#,###').format(denda)}'
                        : '-',
                    isImportant: true,
                    valueColor:
                        denda != null && denda != 0
                            ? Colors.red[700]
                            : Colors.grey[700],
                  ),

                  // Show keterangan if it exists
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keterangan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            (keterangan != null &&
                                    keterangan.toString().isNotEmpty)
                                ? keterangan.toString()
                                : (denda != null && denda != 0
                                    ? 'Terdapat denda untuk penyewaan ini.'
                                    : 'Tidak ada denda untuk penyewaan ini.'),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Supporting Image - always show if denda exists
                  if (denda != null && denda != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gambar Pendukung:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onTap: () {
                                // Show fullscreen image when tapped
                                // Use the BuildContext from the current widget tree
                                _showFullScreenImage(Get.context!, fotoKerusakan);
                              },
                              child: Hero(
                                tag: 'damage-photo-${fotoKerusakan ?? 'default'}',
                                child: fotoKerusakan != null && fotoKerusakan.toString().isNotEmpty && fotoKerusakan.toString().startsWith('http')
                                  ? Image.network(
                                      fotoKerusakan.toString(),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint('Error loading image: $error');
                                        return Image.asset(
                                          'assets/images/gambar_pendukung.jpg',
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/gambar_pendukung.jpg',
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to format rental period from ISO timestamps
  String _formatRentalPeriod(String? startTime, String? endTime) {
    debugPrint('🏷️ _formatRentalPeriod called with:');
    debugPrint('  startTime: $startTime');
    debugPrint('  endTime: $endTime');

    // Get satuan_waktu from tagihan
    final satuanWaktu = controller.tagihanSewa.value['satuan_waktu'] ?? 'jam';
    debugPrint('  satuan_waktu: $satuanWaktu');

    // Also debug the entire sewaAsetDetails object
    debugPrint('🔍 Current sewaAsetDetails data:');
    controller.sewaAsetDetails.value.forEach((key, value) {
      debugPrint('  $key: $value');
    });

    if (startTime == null || endTime == null) {
      debugPrint('⚠️ startTime or endTime is null, using fallback value:');
      debugPrint(
        '  Fallback: ${controller.orderDetails.value['rental_period']}',
      );
      return controller.orderDetails.value['rental_period'] ?? '-';
    }

    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);

      debugPrint('✅ Successfully parsed dates:');
      debugPrint('  start: $start');
      debugPrint('  end: $end');

      // Format based on satuan_waktu
      String formattedPeriod;

      if (satuanWaktu.toLowerCase() == 'hari') {
        // Format for daily rentals: "22 April 2025, 06:00 - 23 April 2025, 21:00"
        final startDateStr =
            "${start.day} ${_getMonthName(start.month)} ${start.year}";
        final startTimeStr =
            "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";
        final endDateStr = "${end.day} ${_getMonthName(end.month)} ${end.year}";
        final endTimeStr =
            "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";

        formattedPeriod =
            "$startDateStr, $startTimeStr - $endDateStr, $endTimeStr";
      } else {
        // Format for hourly rentals: "24 April 2023, 10:00 - 12:00"
        final dateStr =
            "${start.day} ${_getMonthName(start.month)} ${start.year}";
        final startTimeStr =
            "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";
        final endTimeStr =
            "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";

        formattedPeriod = "$dateStr, $startTimeStr - $endTimeStr";
      }

      debugPrint(
        '✅ Formatted period: $formattedPeriod (satuan_waktu: $satuanWaktu)',
      );
      return formattedPeriod;
    } catch (e) {
      debugPrint('❌ Error formatting rental period: $e');
      debugPrint('  Stack trace: ${StackTrace.current}');
      return controller.orderDetails.value['rental_period'] ?? '-';
    }
  }

  // Helper method to get month name in Indonesian
  String _getMonthName(int month) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return monthNames[month - 1];
  }

  // Show fullscreen image dialog
  void _showFullScreenImage(BuildContext context, dynamic imageUrl) {
    final String imageSource = (imageUrl != null && 
                               imageUrl.toString().isNotEmpty && 
                               imageUrl.toString().startsWith('http'))
        ? imageUrl.toString()
        : '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Fullscreen image with Hero animation
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Hero(
                  tag: 'damage-photo-${imageUrl ?? 'default'}',
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: imageSource.isNotEmpty
                          ? Image.network(
                              imageSource,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Error loading fullscreen image: $error');
                                return Image.asset(
                                  'assets/images/gambar_pendukung.jpg',
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/gambar_pendukung.jpg',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ),
              
              // Close button at the top right
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Detail Item Helper
  Widget _buildDetailItem(
    String label,
    String value, {
    bool isImportant = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isImportant ? Colors.black : Colors.grey[700],
              fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isImportant ? 16 : 14,
              fontWeight: isImportant ? FontWeight.bold : FontWeight.w500,
              color:
                  valueColor ??
                  (isImportant ? Colors.deepPurple : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Payment Type Selection (Tagihan Awal or Denda)
  Widget _buildPaymentTypeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pilih Jenis Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              // Get tagihan awal value
              final tagihanAwal =
                  controller.tagihanSewa.value['tagihan_awal'] ??
                  controller.orderDetails.value['total_price'] ??
                  0;

              // Get denda value
              final denda = controller.sewaAsetDetails.value['denda'] ?? 0;

              return Column(
                children: [
                  _buildPaymentTypeOption(
                    icon: Icons.receipt,
                    title: 'Pembayaran Tagihan Awal',
                    amount: 'Rp ${NumberFormat('#,###').format(tagihanAwal)}',
                    type: 'tagihan_awal',
                    description: 'Pembayaran untuk tagihan sewa aset',
                    isSelected:
                        controller.selectedPaymentType.value == 'tagihan_awal',
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentTypeOption(
                    icon: Icons.warning_amber_rounded,
                    title: 'Pembayaran Denda',
                    amount: 'Rp ${NumberFormat('#,###').format(denda)}',
                    type: 'denda',
                    description: 'Pembayaran untuk denda yang diberikan',
                    isDisabled: denda == 0,
                    isSelected: controller.selectedPaymentType.value == 'denda',
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Payment Type Option
  Widget _buildPaymentTypeOption({
    required IconData icon,
    required String title,
    required String amount,
    required String type,
    required String description,
    bool isDisabled = false,
    bool isSelected = false,
  }) {
    final Color cardColor =
        isDisabled
            ? Colors.grey[100]!
            : isSelected
            ? AppColors.primarySoft
            : Colors.white;

    final Color borderColor =
        isDisabled
            ? Colors.grey[300]!
            : isSelected
            ? AppColors.primary
            : Colors.grey[200]!;

    final Color iconBgColor =
        isDisabled
            ? Colors.grey[200]!
            : isSelected
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.surfaceLight;

    final Color iconColor =
        isDisabled
            ? Colors.grey[400]!
            : isSelected
            ? AppColors.primary
            : AppColors.textSecondary;

    return InkWell(
      onTap:
          isDisabled
              ? null
              : () {
                controller.selectPaymentType(type);
                // Reset payment method when changing payment type
                controller.paymentMethod.value = '';
              },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          isDisabled ? Colors.grey[500] : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDisabled ? Colors.grey[500] : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Dipilih',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Payment Method Selection
  Widget _buildPaymentMethodSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPaymentMethodOption(
              icon: Icons.account_balance,
              title: 'Transfer Bank',
              description: 'Transfer melalui rekening bank',
              value: 'transfer',
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildPaymentMethodOption(
              icon: Icons.payments,
              title: 'Bayar Tunai',
              description: 'Bayar langsung di kantor BUMDes',
              value: 'cash',
            ),
          ],
        ),
      ),
    );
  }

  // Payment Method Option
  Widget _buildPaymentMethodOption({
    required IconData icon,
    required String title,
    required String description,
    required String value,
  }) {
    final isSelected = controller.paymentMethod.value == value;

    return Obx(
      () => InkWell(
        onTap: () => controller.selectPaymentMethod(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: controller.paymentMethod.value,
                onChanged: (val) => controller.selectPaymentMethod(val!),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Transfer Instructions
  Widget _buildTransferInstructions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instruksi Transfer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.bankAccounts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return Column(
                children: controller.bankAccounts.map((account) {
                  return Column(
                    children: [
                      _buildBankAccount(
                        bankName: account['nama_bank'] ?? 'Bank',
                        accountNumber: account['no_rekening'] ?? '',
                        accountName: account['nama_akun'] ?? '',
                        bankLogo: 'assets/images/bank_logo.png',
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildTransferStep(
              icon: Icons.account_balance,
              title: 'Transfer ke rekening BUMDes',
              description: 'Lakukan transfer sesuai nominal yang tertera',
            ),
            _buildTransferStep(
              icon: Icons.camera_alt,
              title: 'Ambil bukti pembayaran',
              description:
                  'Simpan bukti transfer/screenshot sebagai bukti pembayaran',
            ),
            _buildTransferStep(
              icon: Icons.upload_file,
              title: 'Unggah bukti pembayaran',
              description: 'Unggah foto bukti pembayaran pada form di bawah',
            ),
            _buildTransferStep(
              icon: Icons.check_circle,
              title: 'Tunggu konfirmasi',
              description: 'Pembayaran Anda akan dikonfirmasi oleh petugas',
            ),
            _buildTransferStep(
              icon: Icons.receipt_long,
              title: 'Dapatkan struk pembayaran',
              description:
                  'Setelah dikonfirmasi, akan dibuatkan struk pembayaran',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // Show image source options (camera or gallery)
  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.blue[700]),
                  ),
                  title: const Text('Kamera'),
                  subtitle: const Text('Ambil foto dengan kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.takePhoto();
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library, color: Colors.green[700]),
                  ),
                  title: const Text('Galeri'),
                  subtitle: const Text('Pilih foto dari galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.selectPhotoFromGallery();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Bank Account Widget
  Widget _buildBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String bankLogo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Replace this with an actual image when available
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(child: Text('BCA')),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountName,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                accountNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Copy to clipboard functionality
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  
                  // Show feedback to user
                  final scaffoldMessenger = ScaffoldMessenger.of(Get.context!);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Nomor rekening $accountNumber disalin ke clipboard'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green[700],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Salin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Transfer:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              GestureDetector(
                onTap: () {
                  // Get the total price
                  final totalPrice = controller.orderDetails.value['total_price'] ?? 0;
                  // Format the total price as a number without 'Rp' prefix
                  final formattedPrice = totalPrice.toString();
                  
                  // Copy to clipboard
                  Clipboard.setData(ClipboardData(text: formattedPrice));
                  
                  // Show feedback to user
                  final scaffoldMessenger = ScaffoldMessenger.of(Get.context!);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Nominal Rp $formattedPrice disalin ke clipboard'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green[700],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Rp ${controller.orderDetails.value['total_price'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: Colors.deepPurple[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Transfer Step Widget
  Widget _buildTransferStep({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(width: 2, height: 32, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              SizedBox(height: isLast ? 0 : 16),
            ],
          ),
        ),
      ],
    );
  }

  // Payment Proof Upload
  Widget _buildPaymentProofUpload() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.photo_camera, size: 24),
                SizedBox(width: 8),
                Text(
                  'Unggah Bukti Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Display all existing images
                  ...List.generate(
                    controller.paymentProofImages.length,
                    (index) => _buildImageItem(index),
                  ),
                  // Add photo button
                  _buildAddPhotoButton(),
                ],
              );
            }),
            const SizedBox(height: 16),
            // Upload button
            Obx(() {
              // Disable button if there are no changes or if upload is in progress
              final bool isDisabled = controller.isUploading.value || !controller.hasUnsavedChanges.value;
              
              return ElevatedButton.icon(
                onPressed: isDisabled ? null : controller.uploadPaymentProof,
                icon: controller.isUploading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(controller.isUploading.value 
                    ? 'Menyimpan...' 
                    : (controller.hasUnsavedChanges.value ? 'Simpan' : 'Tidak Ada Perubahan')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  // Gray out button when disabled
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              );
            }),
            // Upload progress indicator
            Obx(() {
              if (controller.isUploading.value) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mengunggah bukti pembayaran... ${(controller.uploadProgress.value * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
  
  // Build individual image item with remove button
  Widget _buildImageItem(int index) {
    final image = controller.paymentProofImages[index];
    return Stack(
      children: [
        // Make the container tappable to show full-screen image
        GestureDetector(
          onTap: () => controller.showFullScreenImage(image),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: controller.getImageWidget(image),
            ),
          ),
        ),
        // Close/remove button remains the same
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => controller.removeImage(image),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build add photo button
  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: () => _showImageSourceOptions(Get.context!),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 8),
            Text(
              'Tambah Foto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cash Payment Instructions
  Widget _buildCashInstructions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instruksi Pembayaran Tunai',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pembayaran tunai dapat dilakukan di kantor BUMDes dengan menunjukkan ID pesanan.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCashStep(
              number: 1,
              title: 'Datang ke kantor BUMDes',
              description: 'Alamat: Jl. Merdeka No. 123, Desa Maju Jaya',
            ),
            _buildCashStep(
              number: 2,
              title: 'Tunjukkan ID pesanan',
              description:
                  'ID Pesanan: ${controller.orderDetails.value['id'] ?? '-'}',
            ),
            _buildCashStep(
              number: 3,
              title: 'Lakukan pembayaran tunai',
              description:
                  'Total: Rp ${controller.orderDetails.value['total_price'] ?? 0}',
            ),
            _buildCashStep(
              number: 4,
              title: 'Dapatkan struk pembayaran',
              description:
                  'Setelah dikonfirmasi, akan dibuatkan struk pembayaran',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // Cash Step Widget
  Widget _buildCashStep({
    required int number,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 32, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              SizedBox(height: isLast ? 0 : 16),
            ],
          ),
        ),
      ],
    );
  }

  // Select Payment Type Prompt
  Widget _buildSelectPaymentTypePrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Pilih jenis pembayaran terlebih dahulu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Select Payment Method Prompt
  Widget _buildSelectPaymentMethodPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Pilih metode pembayaran terlebih dahulu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Payment Summary Card
  Widget _buildPaymentSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Ringkasan Tagihan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              // Get values from the tagihan_sewa data
              final tagihanAwal =
                  controller.tagihanSewa.value['tagihan_awal'] ??
                  controller.orderDetails.value['total_price'] ??
                  0;

              // Get denda from tagihan_sewa
              final denda = controller.tagihanSewa.value['denda'] ?? 0;
              
              // Get total dibayarkan from tagihan_dibayar
              final dibayarkan = controller.tagihanSewa.value['tagihan_dibayar'] ?? 0;
              
              debugPrint('Tagihan Awal: $tagihanAwal');
              debugPrint('Denda: $denda');
              debugPrint('Total Dibayarkan: $dibayarkan');

              // Calculate sisa tagihan
              final totalTagihan = tagihanAwal + denda;
              final sisaTagihan = totalTagihan - dibayarkan;

              return Column(
                children: [
                  _buildDetailItem(
                    'Tagihan Awal',
                    'Rp ${NumberFormat('#,###').format(tagihanAwal)}',
                  ),
                  _buildDetailItem(
                    'Denda',
                    'Rp ${NumberFormat('#,###').format(denda)}',
                  ),
                  const Divider(height: 24),
                  _buildDetailItem(
                    'Total Tagihan',
                    'Rp ${NumberFormat('#,###').format(totalTagihan)}',
                    isImportant: true,
                  ),
                  _buildDetailItem(
                    'Total Dibayarkan',
                    'Rp ${NumberFormat('#,###').format(dibayarkan)}',
                    valueColor: Colors.green[700],
                  ),
                  const Divider(height: 24),
                  _buildDetailItem(
                    'Sisa Tagihan',
                    'Rp ${NumberFormat('#,###').format(sisaTagihan)}',
                    isImportant: true,
                    valueColor: Colors.red[700],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to build detail item with subpoints
  Widget _buildDetailItemWithSubpoints(String label, List<Map<String, String>> subpoints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main label
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Subpoints with indentation
          ...subpoints.map((subpoint) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        subpoint['label'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        subpoint['value'] ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Helper method to format date time for display
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '-';
    }

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _getMonthName(dateTime.month);
      final year = dateTime.year.toString();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return "$day $month $year, $hour:$minute";
    } catch (e) {
      debugPrint('❌ Error formatting date time: $e');
      return dateTimeStr;
    }
  }
}
