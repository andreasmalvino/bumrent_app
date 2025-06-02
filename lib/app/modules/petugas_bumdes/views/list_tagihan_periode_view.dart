import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_tagihan_periode_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors_petugas.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class ListTagihanPeriodeView extends GetView<ListTagihanPeriodeController> {
  const ListTagihanPeriodeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get dashboard controller for navigation
    final dashboardController = Get.find<PetugasBumdesDashboardController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Riwayat Tagihan',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      drawer: PetugasSideNavbar(controller: dashboardController),
      drawerEdgeDragWidth: 60,
      drawerScrimColor: Colors.black.withOpacity(0.6),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), Expanded(child: _buildPeriodeList())],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final pelanggan = controller.pelangganData.value;
            final nama = pelanggan['nama'] ?? 'Pelanggan';

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColorsPetugas.babyBlueBright,
                  child: Text(
                    nama.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          'Pelanggan ${controller.serviceName.value}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Aktif',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Riwayat Tagihan Bulanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daftar periode tagihan dan status pembayaran',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodeList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredPeriodeList.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredPeriodeList.length,
        itemBuilder: (context, index) {
          final periode = controller.filteredPeriodeList[index];
          return _buildPeriodeCard(periode);
        },
      );
    });
  }

  Widget _buildPeriodeCard(Map<String, dynamic> periode) {
    final statusColor = Color(
      controller.getStatusColor(periode['status_pembayaran']),
    );
    final isCurrent = periode['is_current'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border:
            isCurrent
                ? Border.all(color: AppColorsPetugas.blueGrotto, width: 2)
                : null,
      ),
      child: InkWell(
        onTap: () {
          Get.snackbar(
            'Informasi',
            'Detail tagihan untuk periode ini tidak tersedia',
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(8),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isCurrent
                        ? AppColorsPetugas.babyBlueBright.withOpacity(0.3)
                        : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColorsPetugas.babyBlueBright,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          periode['bulan'].substring(0, 3),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColorsPetugas.navyBlue,
                          ),
                        ),
                        Text(
                          periode['tahun'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorsPetugas.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Periode ${controller.getPeriodeString(periode)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Jatuh tempo: 20 ${periode['bulan']} ${periode['tahun']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          periode['status_pembayaran'].toLowerCase() == 'lunas'
                              ? Icons.check_circle
                              : Icons.pending,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          periode['status_pembayaran'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nominal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        periode['nominal'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (periode['status_pembayaran'].toLowerCase() == 'lunas')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tanggal Bayar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          periode['tanggal_pembayaran'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.payment,
                        size: 16,
                        color: AppColorsPetugas.blueGrotto,
                      ),
                      label: Text(
                        'Bayar Sekarang',
                        style: TextStyle(color: AppColorsPetugas.blueGrotto),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: AppColorsPetugas.blueGrotto),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColorsPetugas.babyBlueBright.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Periode Berjalan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada riwayat tagihan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pelanggan belum memiliki riwayat tagihan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showPeriodeDetails(Map<String, dynamic> periode) {
    final statusColor = Color(
      controller.getStatusColor(periode['status_pembayaran']),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColorsPetugas.navyBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          periode['bulan'].substring(0, 3),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColorsPetugas.navyBlue,
                          ),
                        ),
                        Text(
                          periode['tahun'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorsPetugas.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Tagihan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periode ${controller.getPeriodeString(periode)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              periode['status_pembayaran'].toLowerCase() ==
                                      'lunas'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              periode['status_pembayaran'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Informasi Tagihan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Pelanggan',
                    value:
                        controller.pelangganData.value['nama'] ?? 'Pelanggan',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Periode',
                    value: controller.getPeriodeString(periode),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Nominal',
                    value: periode['nominal'],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.event,
                    label: 'Jatuh Tempo',
                    value: '20 ${periode['bulan']} ${periode['tahun']}',
                  ),
                  if (periode['status_pembayaran'].toLowerCase() ==
                      'lunas') ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Informasi Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.date_range,
                      label: 'Tanggal Pembayaran',
                      value: periode['tanggal_pembayaran'],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.payment,
                      label: 'Metode Pembayaran',
                      value: periode['metode_pembayaran'],
                    ),
                    if (periode['keterangan'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.info_outline,
                        label: 'Keterangan',
                        value: periode['keterangan'],
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          label: const Text('Tutup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsPetugas.navyBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsPetugas.babyBlueBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColorsPetugas.navyBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
