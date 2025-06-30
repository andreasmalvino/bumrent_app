import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_detail_penyewa_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../controllers/petugas_penyewa_controller.dart';

class PetugasDetailPenyewaView extends GetView<PetugasDetailPenyewaController> {
  const PetugasDetailPenyewaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detail Penyewa',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the petugas_penyewa page
            Get.back();

            // Get the PetugasPenyewaController and refresh the data
            final penyewaController = Get.find<PetugasPenyewaController>();
            penyewaController.refreshData();
          },
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox.shrink();
            }

            final status =
                controller.penyewaDetail.value['status']
                    ?.toString()
                    .toLowerCase();

            if (status == 'pending') {
              return Row(
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.close_rounded,
                    color: Colors.red.shade100,
                    iconColor: Colors.red,
                    tooltip: 'Tolak',
                    onPressed: () => _showRejectDialog(context),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context: context,
                    icon: Icons.check_rounded,
                    color: Colors.green.shade100,
                    iconColor: Colors.green,
                    tooltip: 'Terima',
                    onPressed: () => _showApproveDialog(context),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            } else if (status == 'suspended') {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildActionButton(
                  context: context,
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green.shade100,
                  iconColor: Colors.green,
                  tooltip: 'Aktifkan',
                  onPressed: () => _showApproveDialog(context),
                ),
              );
            } else if (status == 'active') {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildActionButton(
                  context: context,
                  icon: Icons.block_rounded,
                  color: Colors.red.shade100,
                  iconColor: Colors.red,
                  tooltip: 'Nonaktifkan',
                  onPressed: () => _showSuspendDialog(context),
                ),
              );
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColorsPetugas.blueGrotto,
            ),
          );
        }

        final penyewa = controller.penyewaDetail.value;

        if (penyewa.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Data penyewa tidak ditemukan',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(penyewa),
              _buildInfoCards(penyewa),
              _buildRentalHistory(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> penyewa) {
    final status = penyewa['status']?.toString().toLowerCase();
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Aktif';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu Verifikasi';
        statusIcon = Icons.pending_rounded;
        break;
      case 'suspended':
        statusColor = Colors.red;
        statusText = 'Dinonaktifkan';
        statusIcon = Icons.block_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Tidak diketahui';
        statusIcon = Icons.help_rounded;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColorsPetugas.navyBlue, AppColorsPetugas.blueGrotto],
              stops: const [0.3, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorsPetugas.navyBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Hero(
                tag: 'avatar-${penyewa['user_id'] ?? ''}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColorsPetugas.babyBlueLight,
                    backgroundImage:
                        penyewa['avatar'] != null &&
                                penyewa['avatar'].toString().isNotEmpty
                            ? NetworkImage(penyewa['avatar'])
                            : null,
                    child:
                        penyewa['avatar'] == null ||
                                penyewa['avatar'].toString().isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                penyewa['nama_lengkap'] ?? 'Nama tidak tersedia',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Email
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      penyewa['email'] ?? 'Email tidak tersedia',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        Positioned(
          bottom: -20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 18, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(Map<String, dynamic> penyewa) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informasi Pribadi', Icons.person_rounded),
          const SizedBox(height: 16),

          // Personal Info Card
          _buildInfoCard(
            [
              _buildInfoItem(
                icon: Icons.credit_card_rounded,
                label: 'NIK',
                value: penyewa['nik'] ?? 'Tidak tersedia',
              ),
              _buildInfoItem(
                icon: Icons.phone_rounded,
                label: 'Nomor HP',
                value: penyewa['no_hp'] ?? 'Tidak tersedia',
              ),
              _buildInfoItem(
                icon: Icons.calendar_today_rounded,
                label: 'Tanggal Lahir',
                value: _formatBirthDate(penyewa['tanggal_lahir']),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.white],
              stops: const [0.0, 0.5],
            ),
            icon: Icons.person_rounded,
            iconColor: AppColorsPetugas.blueGrotto,
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Alamat', Icons.home_rounded),
          const SizedBox(height: 16),

          // Address Info Card
          _buildInfoCard(
            [
              _buildInfoItem(
                icon: Icons.location_on_rounded,
                label: 'Alamat',
                value: penyewa['alamat'] ?? 'Tidak tersedia',
              ),
              _buildInfoItem(
                icon: Icons.location_city_rounded,
                label: 'RT/RW',
                value: penyewa['rt_rw'] ?? 'Tidak tersedia',
              ),
              _buildInfoItem(
                icon: Icons.apartment_rounded,
                label: 'Kelurahan',
                value: penyewa['kelurahan'] ?? 'Tidak tersedia',
              ),
              _buildInfoItem(
                icon: Icons.map_rounded,
                label: 'Kecamatan',
                value: penyewa['kecamatan'] ?? 'Tidak tersedia',
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal.shade50, Colors.white],
              stops: const [0.0, 0.5],
            ),
            icon: Icons.home_rounded,
            iconColor: Colors.teal,
          ),

          // Keterangan (if available)
          if (penyewa['keterangan'] != null &&
              penyewa['keterangan'].toString().isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Keterangan', Icons.note_rounded),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    penyewa['status'] == 'suspended'
                        ? Colors.red.shade50
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                gradient:
                    penyewa['status'] == 'suspended'
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red.shade50, Colors.white],
                          stops: const [0.0, 0.7],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.amber.shade50, Colors.white],
                          stops: const [0.0, 0.7],
                        ),
                boxShadow: [
                  BoxShadow(
                    color:
                        penyewa['status'] == 'suspended'
                            ? Colors.red.withOpacity(0.1)
                            : Colors.amber.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    spreadRadius: 1,
                  ),
                ],
                border:
                    penyewa['status'] == 'suspended'
                        ? Border.all(color: Colors.red.shade200, width: 1)
                        : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          penyewa['status'] == 'suspended'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      penyewa['status'] == 'suspended'
                          ? Icons.warning_rounded
                          : Icons.note_rounded,
                      color:
                          penyewa['status'] == 'suspended'
                              ? Colors.red.shade700
                              : Colors.amber.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      penyewa['keterangan'],
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            penyewa['status'] == 'suspended'
                                ? Colors.red.shade900
                                : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorsPetugas.navyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColorsPetugas.navyBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColorsPetugas.blueGrotto),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorsPetugas.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    List<Widget> children, {
    Gradient? gradient,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColorsPetugas.babyBlueLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: AppColorsPetugas.blueGrotto),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalHistory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Riwayat Sewa', Icons.history_rounded),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo.shade50, Colors.white],
                stops: const [0.0, 0.6],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColorsPetugas.blueGrotto.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 18,
                            color: AppColorsPetugas.blueGrotto,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Aktivitas Sewa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorsPetugas.blueGrotto.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Obx(
                        () => Text(
                          'Total: ${controller.sewaHistory.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColorsPetugas.blueGrotto,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.sewaHistory.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada riwayat sewa',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Penyewa belum memiliki transaksi sewa',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.sewaHistory.length,
                    itemBuilder: (context, index) {
                      final sewa = controller.sewaHistory[index];
                      final aset = sewa['aset'] as Map<String, dynamic>?;
                      final tagihan =
                          sewa['tagihan_sewa'] as Map<String, dynamic>?;

                      // Extract tagihan values with null safety
                      final tagihanAwal = tagihan?['tagihan_awal'] ?? 0;
                      final denda = tagihan?['denda'] ?? 0;
                      final totalDibayar = tagihan?['tagihan_dibayar'] ?? 0;
                      final totalTagihan = tagihanAwal + denda;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.grey.shade50],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Asset image
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child:
                                            aset != null &&
                                                    aset['foto_utama'] != null
                                                ? Image.network(
                                                  aset['foto_utama'],
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        width: 70,
                                                        height: 70,
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                        ),
                                                      ),
                                                )
                                                : Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Asset details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            aset?['nama'] ??
                                                'Aset tidak tersedia',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(
                                                    sewa['waktu_mulai'],
                                                    sewa['waktu_selesai'],
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildStatusChip(sewa['status']),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColorsPetugas
                                                      .blueGrotto
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _formatCurrency(totalTagihan),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color:
                                                        AppColorsPetugas
                                                            .blueGrotto,
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status?.toUpperCase()) {
      case 'MENUNGGU PEMBAYARAN':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'Menunggu Pembayaran';
        icon = Icons.payment_outlined;
        break;
      case 'PERIKSA PEMBAYARAN':
        bgColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Periksa Pembayaran';
        icon = Icons.receipt_long_outlined;
        break;
      case 'DITERIMA':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Diterima';
        icon = Icons.check_circle_outline;
        break;
      case 'PEMBAYARAN DENDA':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Pembayaran Denda';
        icon = Icons.warning_amber_outlined;
        break;
      case 'PERIKSA PEMBAYARAN DENDA':
        bgColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        label = 'Periksa Pembayaran Denda';
        icon = Icons.receipt_outlined;
        break;
      case 'SELESAI':
        bgColor = Colors.teal[100]!;
        textColor = Colors.teal[800]!;
        label = 'Selesai';
        icon = Icons.task_alt_outlined;
        break;
      case 'DIBATALKAN':
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = 'Dibatalkan';
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = status ?? 'Tidak diketahui';
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic startDate, dynamic endDate) {
    try {
      final start = DateTime.parse(startDate.toString());
      final end = DateTime.parse(endDate.toString());

      final dateFormat = DateFormat('dd MMM yyyy');

      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return dateFormat.format(start);
      } else {
        return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
      }
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  String _formatBirthDate(dynamic birthDate) {
    if (birthDate == null || birthDate.toString().isEmpty) {
      return 'Tidak tersedia';
    }

    try {
      final date = DateTime.parse(birthDate.toString());
      final dateFormat = DateFormat('dd MMMM yyyy');
      return dateFormat.format(date);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp0';

    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    try {
      final value = double.parse(amount.toString());
      return formatter.format(value);
    } catch (e) {
      return 'Rp0';
    }
  }

  void _showApproveDialog(BuildContext context) {
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
                onPressed: () async {
                  Navigator.pop(context);

                  // Update status penyewa
                  await controller.updatePenyewaStatus(
                    'active',
                    'Akun diaktifkan oleh petugas',
                  );

                  // Navigate back to petugas_penyewa page
                  Get.back();

                  // Refresh the penyewa list
                  final penyewaController =
                      Get.find<PetugasPenyewaController>();
                  penyewaController.refreshData();
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

  void _showSuspendDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Penonaktifan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apakah Anda yakin ingin menonaktifkan sementara penyewa ini?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Alasan Penonaktifan',
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
                onPressed: () async {
                  Navigator.pop(context); // Tutup dialog terlebih dahulu

                  final reason =
                      reasonController.text.isNotEmpty
                          ? reasonController.text
                          : 'Dinonaktifkan oleh petugas';

                  // Update status penyewa
                  await controller.updatePenyewaStatus('suspended', reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Nonaktifkan'),
              ),
            ],
          ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Penolakan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apakah Anda yakin ingin menolak pendaftaran penyewa ini?',
                ),
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
                onPressed: () async {
                  Navigator.pop(context); // Tutup dialog terlebih dahulu

                  final reason =
                      reasonController.text.isNotEmpty
                          ? reasonController.text
                          : 'Ditolak oleh petugas';

                  // Update status penyewa
                  await controller.updatePenyewaStatus('dibatalkan', reason);

                  // Navigate back to petugas_penyewa page
                  Get.offNamed(Routes.PETUGAS_PENYEWA);

                  // Refresh the penyewa list
                  final penyewaController =
                      Get.find<PetugasPenyewaController>();
                  penyewaController.refreshData();
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
