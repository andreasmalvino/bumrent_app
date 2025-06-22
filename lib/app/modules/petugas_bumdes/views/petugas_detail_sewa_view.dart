import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_sewa_controller.dart';
import '../../../theme/app_colors_petugas.dart';
import '../../../data/models/rental_booking_model.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/aset_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetugasDetailSewaView extends StatefulWidget {
  final SewaModel sewa;
  PetugasDetailSewaView({Key? key, required this.sewa}) : super(key: key);

  @override
  State<PetugasDetailSewaView> createState() => _PetugasDetailSewaViewState();
}

class _PetugasDetailSewaViewState extends State<PetugasDetailSewaView> {
  late SewaModel sewa;
  final PetugasSewaController controller = Get.find<PetugasSewaController>();
  final Rx<File?> selectedDamageImage = Rx<File?>(null);
  final Rx<bool> hasImage = false.obs;

  @override
  void initState() {
    super.initState();
    sewa = widget.sewa;
  }

  Future<void> refreshSewaData() async {
    // Fetch the latest sewa detail from Supabase
    final updated = await AsetProvider().getSewaAsetWithAsetData(sewa.id);
    if (updated != null) {
      // Fetch tagihan_sewa
      final tagihan = await AsetProvider().getTagihanSewa(sewa.id);
      // Fetch warga_desa
      String userId = updated['user_id'] ?? '';
      Map<String, dynamic>? warga;
      if (userId.isNotEmpty) {
        final wargaList =
            await AsetProvider().client
                .from('warga_desa')
                .select('user_id, nama_lengkap, no_hp, avatar')
                .eq('user_id', userId)
                .maybeSingle();
        warga = wargaList;
      }
      // Merge all data for SewaModel
      final merged = <String, dynamic>{
        ...updated,
        if (tagihan != null) ...{
          'total_tagihan': tagihan['total_tagihan'],
          'denda': tagihan['denda'],
          'dibayar': tagihan['tagihan_dibayar'],
        },
        if (warga != null) ...{
          'warga_nama': warga['nama_lengkap'],
          'warga_no_hp': warga['no_hp'],
          'warga_avatar': warga['avatar'],
        },
      };
      // Ensure asset/package name and image are present
      if ((merged['tipe_pesanan'] == 'tunggal' ||
              merged['tipe_pesanan'] == null) &&
          merged['aset_id'] != null) {
        final aset = updated['aset_detail'] ?? {};
        merged['aset_nama'] = aset['nama'] ?? '';
        // Always fetch foto_aset for aset_id
        final fotoResp =
            await AsetProvider().client
                .from('foto_aset')
                .select('foto_aset')
                .eq('id_aset', merged['aset_id'])
                .limit(1)
                .maybeSingle();
        merged['aset_foto'] = fotoResp != null ? fotoResp['foto_aset'] : '';
      } else if (merged['tipe_pesanan'] == 'paket' &&
          merged['paket_id'] != null) {
        // Fetch paket name and photo if missing
        final paketId = merged['paket_id'];
        final paketResp =
            await AsetProvider().client
                .from('paket')
                .select('id, nama')
                .eq('id', paketId)
                .maybeSingle();
        merged['paket_nama'] = paketResp != null ? paketResp['nama'] : '';
        // Fetch first photo for paket
        final fotoResp =
            await AsetProvider().client
                .from('foto_aset')
                .select('foto_aset')
                .eq('id_paket', paketId)
                .limit(1)
                .maybeSingle();
        merged['paket_foto'] = fotoResp != null ? fotoResp['foto_aset'] : '';
      }
      setState(() {
        sewa = SewaModel.fromJson(merged);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

    // Trigger fetch paket detail dan log debug saat halaman dibuka (hanya jika paket)
    if (isPaket && sewa.paketId != null && sewa.paketId!.isNotEmpty) {
      controller.getPaketItems(sewa.paketId!).then((items) {
        debugPrint('[DEBUG] --- Paket Detail (on page open) ---');
        for (var item in items) {
          debugPrint(
            '[DEBUG] Paket Detail Item: nama_aset=${item['nama_aset']}, kuantitas=${item['kuantitas']}',
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Detail Sewa #${sewa.id}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
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
                      controller.formatPrice(sewa.totalTagihan),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Order ID and Date Range
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Icon(
                    //       Icons.calendar_today_rounded,
                    //       size: 14,
                    //       color: AppColorsPetugas.textSecondary,
                    //     ),
                    //     const SizedBox(width: 6),
                    //     Text(
                    //       '${sewa.waktuMulai.toIso8601String().substring(0, 10)} - ${sewa.waktuSelesai.toIso8601String().substring(0, 10)}',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         color: AppColorsPetugas.textSecondary,
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
                              backgroundImage:
                                  (sewa.wargaAvatar != null &&
                                          sewa.wargaAvatar.isNotEmpty)
                                      ? NetworkImage(sewa.wargaAvatar)
                                      : null,
                              child:
                                  (sewa.wargaAvatar == null ||
                                          sewa.wargaAvatar.isEmpty)
                                      ? Text(
                                        (sewa.wargaNama != null &&
                                                sewa.wargaNama.isNotEmpty)
                                            ? sewa.wargaNama
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : '-',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColorsPetugas.blueGrotto,
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sewa.wargaNama,
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
                                        sewa.wargaNoHp,
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
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),

                        // Asset info
                        Row(
                          children: [
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaAsetAtauPaket,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColorsPetugas.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${sewa.kuantitas} unit',
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

                  // Jika paket, tampilkan detail paket di bawah asset info card
                  if (isPaket)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: _buildInfoCard(
                        title: 'Detail Paket',
                        titleIcon: Icons.inventory_2_outlined,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: controller.getPaketItems(sewa.paketId ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  'Gagal memuat detail paket',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            final items = snapshot.data ?? [];
                            if (items.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text('Tidak ada item dalam paket'),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nama Aset',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColorsPetugas.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Kuantitas',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColorsPetugas.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['nama_aset'] ?? '-',
                                            style: TextStyle(
                                              color:
                                                  AppColorsPetugas
                                                      .textSecondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item['kuantitas'].toString(),
                                          style: TextStyle(
                                            color:
                                                AppColorsPetugas.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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
                          value: DateFormat(
                            'dd-MM-yyyy HH:mm:ss',
                          ).format(sewa.waktuMulai),
                        ),
                        _buildDetailRow(
                          icon: Icons.event_rounded,
                          label: 'Tanggal Selesai',
                          value: DateFormat(
                            'dd-MM-yyyy HH:mm:ss',
                          ).format(sewa.waktuSelesai),
                        ),
                        FutureBuilder<Map<String, dynamic>?>(
                          future: AsetProvider().getTagihanSewa(sewa.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer_rounded,
                                      size: 16,
                                      color: AppColorsPetugas.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Durasi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColorsPetugas.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return _buildDetailRow(
                                icon: Icons.timer_rounded,
                                label: 'Durasi',
                                value: '-',
                              );
                            }
                            final tagihan = snapshot.data!;
                            final durasi = tagihan['durasi']?.toString() ?? '-';
                            final satuan =
                                tagihan['satuan_waktu']?.toString() ?? '';
                            return _buildDetailRow(
                              icon: Icons.timer_rounded,
                              label: 'Durasi',
                              value: durasi != '-' ? '$durasi $satuan' : '-',
                            );
                          },
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
                        FutureBuilder<Map<String, dynamic>?>(
                          future: AsetProvider().getTagihanSewa(sewa.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildDetailRow(
                                icon: Icons.inventory_2_outlined,
                                label: 'Tagihan Awal',
                                value: 'Memuat...',
                              );
                            }
                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data == null) {
                              return _buildDetailRow(
                                icon: Icons.inventory_2_outlined,
                                label: 'Tagihan Awal',
                                value: '-',
                              );
                            }
                            final tagihan = snapshot.data!;
                            final tagihanAwal = tagihan['tagihan_awal'] ?? 0;
                            final totalTagihan = tagihan['total_tagihan'] ?? 0;
                            final dibayar = tagihan['tagihan_dibayar'] ?? 0;
                            return Column(
                              children: [
                                _buildDetailRow(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Tagihan Awal',
                                  value: controller.formatPrice(tagihanAwal),
                                ),
                                _buildDetailRow(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Denda',
                                  value: controller.formatPrice(
                                    tagihan['denda'] ?? 0,
                                  ),
                                  valueColor: Colors.red[700],
                                  valueBold: true,
                                ),
                                _buildDetailRow(
                                  icon: Icons.payments,
                                  label: 'Dibayar',
                                  value: controller.formatPrice(dibayar),
                                ),
                                _buildDetailRow(
                                  icon: Icons.attach_money,
                                  label: 'Total Tagihan',
                                  value: controller.formatPrice(totalTagihan),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Pisahkan detail denda
                  if (sewa.denda != null && sewa.denda != 0) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: AsetProvider().getTagihanSewa(sewa.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildInfoCard(
                            title: 'Detail Denda',
                            titleIcon: Icons.warning_amber_rounded,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return _buildInfoCard(
                            title: 'Detail Denda',
                            titleIcon: Icons.warning_amber_rounded,
                            child: const Text('Tidak ada detail denda'),
                          );
                        }
                        final tagihan = snapshot.data!;
                        return _buildInfoCard(
                          title: 'Detail Denda',
                          titleIcon: Icons.warning_amber_rounded,
                          child: _buildDendaDetailCard(tagihan),
                        );
                      },
                    ),
                  ],

                  // Bukti Pembayaran dengan TabBar
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Bukti Pembayaran',
                    titleIcon: Icons.receipt_rounded,
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TabBar(
                                isScrollable: true,
                                labelColor: AppColorsPetugas.navyBlue,
                                unselectedLabelColor:
                                    AppColorsPetugas.textSecondary,
                                indicator: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                indicatorSize: TabBarIndicatorSize.label,
                                overlayColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                                padding: EdgeInsets.zero,
                                tabs: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    child: const Text('Sewa'),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    child: const Text('Denda'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 180,
                            child: TabBarView(
                              children: [
                                // Tab Sewa: tampilkan foto pembayaran tagihan awal
                                FutureBuilder<List<String>>(
                                  future: _fetchBuktiPembayaranSewa(sewa.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Tidak ada bukti pembayaran sewa',
                                        ),
                                      );
                                    }
                                    final images = snapshot.data!;
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(width: 12),
                                      itemBuilder: (context, idx) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (_) => Stack(
                                                      children: [
                                                        Dialog(
                                                          backgroundColor:
                                                              Colors.black,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          child: InteractiveViewer(
                                                            child: Center(
                                                              child: Image.network(
                                                                images[idx],
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                                errorBuilder:
                                                                    (
                                                                      c,
                                                                      e,
                                                                      s,
                                                                    ) => Container(
                                                                      color:
                                                                          Colors
                                                                              .grey[900],
                                                                      child: const Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        color:
                                                                            Colors.white,
                                                                        size:
                                                                            80,
                                                                      ),
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 24,
                                                          right: 24,
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                              size: 32,
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                            child: Image.network(
                                              images[idx],
                                              width: 140,
                                              height: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (c, e, s) => Container(
                                                    width: 140,
                                                    height: 140,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                // Tab Denda: tampilkan foto pembayaran denda
                                FutureBuilder<List<String>>(
                                  future: _fetchBuktiPembayaranDenda(sewa.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Tidak ada bukti pembayaran denda',
                                        ),
                                      );
                                    }
                                    final images = snapshot.data!;
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(width: 12),
                                      itemBuilder: (context, idx) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (_) => Stack(
                                                      children: [
                                                        Dialog(
                                                          backgroundColor:
                                                              Colors.black,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          child: InteractiveViewer(
                                                            child: Center(
                                                              child: Image.network(
                                                                images[idx],
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                                errorBuilder:
                                                                    (
                                                                      c,
                                                                      e,
                                                                      s,
                                                                    ) => Container(
                                                                      color:
                                                                          Colors
                                                                              .grey[900],
                                                                      child: const Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        color:
                                                                            Colors.white,
                                                                        size:
                                                                            80,
                                                                      ),
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 24,
                                                          right: 24,
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                              size: 32,
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                            child: Image.network(
                                              images[idx],
                                              width: 140,
                                              height: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (c, e, s) => Container(
                                                    width: 140,
                                                    height: 140,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Opsi pembayaran tepat setelah bukti pembayaran jika status MENUNGGU PEMBAYARAN
                  if (status == 'MENUNGGU PEMBAYARAN') ...[
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(sewa: sewa),
                  ],

                  // Payment Options (for specific statuses selain MENUNGGU PEMBAYARAN)
                  if (status == 'PERIKSA PEMBAYARAN') ...[
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(sewa: sewa, isPenalty: false),
                  ] else if (status == 'PEMBAYARAN DENDA' ||
                      status == 'PERIKSA PEMBAYARAN DENDA') ...[
                    const SizedBox(height: 16),
                    _buildPaymentOptionsCard(sewa: sewa, isPenalty: true),
                  ],

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          (sewa.status == 'DIKEMBALIKAN')
              ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showAddPenaltyDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Tambah Denda'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          controller.completeSewa(sewa.id);
                          await refreshSewaData();
                          Get.snackbar(
                            'Sewa Selesai',
                            'Status sewa telah diubah menjadi SELESAI',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsPetugas.navyBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Selesaikan Sewa'),
                      ),
                    ),
                  ],
                ),
              )
              : (sewa.status == 'AKTIF')
              ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.markAsReturned(sewa.id);
                      await refreshSewaData();
                      Get.snackbar(
                        'Pengembalian Dikonfirmasi',
                        'Status sewa telah diubah menjadi DIKEMBALIKAN',
                        backgroundColor: Colors.teal,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Konfirmasi Pengembalian'),
                  ),
                ),
              )
              : ((sewa.status == 'MENUNGGU PEMBAYARAN' ||
                  sewa.status == 'PERIKSA PEMBAYARAN'))
              ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          controller.rejectSewa(sewa.id);
                          await refreshSewaData();
                          Get.snackbar(
                            'Sewa Dibatalkan',
                            'Status sewa telah diubah menjadi DIBATALKAN',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Batalkan Sewa'),
                      ),
                    ),
                    // Jika ada tombol lain, tambahkan di sini (misal, opsi pembayaran)
                  ],
                ),
              )
              : null,
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
    final status = sewa.status;

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
        controller.approveSewa(sewa.id); // Reusing existing method
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
        controller.approveSewa(sewa.id);
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
        controller.requestPenaltyPayment(sewa.id);
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
        controller.markPenaltyForInspection(sewa.id);
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
        controller.completeSewa(sewa.id);
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
        controller.rejectSewa(sewa.id);
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
    final status = sewa.status;

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
                                controller.markAsReturned(sewa.id);
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
                                controller.requestPenaltyPayment(sewa.id);
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
        controller.completeSewa(sewa.id);
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
                  controller.completeSewa(sewa.id);
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
    required SewaModel sewa,
  }) {
    final status = sewa.status;
    final isFullPayment = controller.getIsFullPayment(sewa.id);
    final nominalController = controller.getNominalController(sewa.id);

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
          // Full Payment Option (Button) - Only show when not verifying
          if (!isVerifying)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    nominalController.text = sewa.totalTagihan.toString();
                  },
                  icon: Icon(
                    Icons.payments_outlined,
                    color: AppColorsPetugas.blueGrotto,
                  ),
                  label: Text(
                    isPenalty ? 'Pembayaran Denda Penuh' : 'Pembayaran Penuh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColorsPetugas.blueGrotto,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColorsPetugas.blueGrotto,
                      width: 2,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: AppColorsPetugas.blueGrotto,
                  ),
                ),
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
          Obx(() {
            final selectedMethod = controller.getPaymentMethod(sewa.id).value;
            return Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap:
                        !isVerifying
                            ? () {
                              controller.setPaymentMethod(sewa.id, 'Tunai');
                            }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              selectedMethod == 'Tunai'
                                  ? AppColorsPetugas.blueGrotto
                                  : AppColorsPetugas.babyBlue,
                          width: selectedMethod == 'Tunai' ? 2 : 1,
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
                                  selectedMethod == 'Tunai'
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
                              controller.setPaymentMethod(sewa.id, 'Transfer');
                            }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              selectedMethod == 'Transfer'
                                  ? AppColorsPetugas.blueGrotto
                                  : AppColorsPetugas.babyBlue,
                          width: selectedMethod == 'Transfer' ? 2 : 1,
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
                                  selectedMethod == 'Transfer'
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
            );
          }),

          const SizedBox(height: 20),

          // Nominal Pembayaran
          TextFormField(
            controller: nominalController,
            keyboardType: TextInputType.number,
            enabled: !isVerifying,
            decoration: InputDecoration(
              hintText: sewa.totalTagihan.toString(),
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

          const SizedBox(height: 20),

          // Confirm Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final nominal = int.tryParse(nominalController.text) ?? 0;
                if (nominal > sewa.totalTagihan) {
                  Get.snackbar(
                    'Nominal Tidak Valid',
                    'Nominal tidak boleh melebihi total tagihan',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                final metode = controller.getPaymentMethod(sewa.id).value;
                await controller.confirmPembayaranTagihan(
                  sewaAsetId: sewa.id,
                  nominal: nominal,
                  metodePembayaran: metode,
                );
                await refreshSewaData();
              },
              icon: const Icon(Icons.check_circle_outline),
              label: Text(isVerifying ? 'Verifikasi' : 'Konfirmasi Pembayaran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.blueGrotto,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
                        onTap: () async {
                          // Show bottom sheet to choose image source
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Ambil Foto'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image = await picker
                                            .pickImage(
                                              source: ImageSource.camera,
                                              imageQuality: 80,
                                            );
                                        if (image != null) {
                                          selectedDamageImage.value = File(
                                            image.path,
                                          );
                                          hasImage.value = true;
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Pilih dari Galeri'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image = await picker
                                            .pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 80,
                                            );
                                        if (image != null) {
                                          selectedDamageImage.value = File(
                                            image.path,
                                          );
                                          hasImage.value = true;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child:
                            hasImage.value && selectedDamageImage.value != null
                                ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          selectedDamageImage.value!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
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
                    onPressed: () async {
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

                      // 1. Upload image to Supabase Storage (foto.denda)
                      String? fotoUrl;
                      if (selectedDamageImage.value != null) {
                        final file = File(selectedDamageImage.value!.path);
                        fotoUrl = await AsetProvider().uploadFileToStorage(
                          file,
                        );
                      }

                      // 2. Update tagihan_sewa (denda, keterangan, foto_kerusakan)
                      final tagihan = await AsetProvider().getTagihanSewa(
                        sewa.id,
                      );
                      if (tagihan != null && tagihan['id'] != null) {
                        await AsetProvider().client
                            .from('tagihan_sewa')
                            .update({
                              'denda':
                                  int.tryParse(penaltyAmountController.text) ??
                                  0,
                              'keterangan': descriptionController.text,
                              'foto_kerusakan': fotoUrl ?? '',
                            })
                            .eq('id', tagihan['id']);
                      }

                      // 3. Update status sewa_aset ke PEMBAYARAN DENDA
                      await AsetProvider().updateSewaAsetStatus(
                        sewaAsetId: sewa.id,
                        status: 'PEMBAYARAN DENDA',
                      );

                      Get.back(); // Close the dialog
                      await refreshSewaData();

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

  Widget _buildDendaDetailCard(Map<String, dynamic> tagihanSewa) {
    final alasan = tagihanSewa['keterangan']?.toString() ?? '-';
    final nominal =
        tagihanSewa['denda'] != null && tagihanSewa['denda'] != 0
            ? 'Rp ${NumberFormat('#,###').format(tagihanSewa['denda'])}'
            : '-';
    final fotoKerusakan = tagihanSewa['foto_kerusakan']?.toString() ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              icon: Icons.text_snippet_outlined,
              label: 'Alasan Denda',
              value: alasan,
            ),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Nominal Denda',
              value: nominal,
              valueColor: Colors.red[700],
              valueBold: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Foto Bukti Kerusakan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (fotoKerusakan.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  fotoKerusakan,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                ),
              )
            else
              const Text('Tidak ada foto kerusakan'),
          ],
        ),
      ),
    );
  }

  // Tambahkan fungsi helper untuk fetch bukti pembayaran sewa
  Future<List<String>> _fetchBuktiPembayaranSewa(String sewaId) async {
    try {
      final supabase = Supabase.instance.client;
      // Ambil tagihan_sewa_id dari tagihan_sewa (berdasarkan sewa.id)
      final tagihan =
          await supabase
              .from('tagihan_sewa')
              .select('id')
              .eq('sewa_aset_id', sewaId)
              .maybeSingle();
      if (tagihan == null || tagihan['id'] == null) return [];
      final tagihanSewaId = tagihan['id'];
      // Ambil foto pembayaran dengan jenis_pembayaran = 'tagihan awal'
      final fotoList = await supabase
          .from('foto_pembayaran')
          .select('foto_pembayaran')
          .eq('tagihan_sewa_id', tagihanSewaId)
          .eq('jenis_pembayaran', 'tagihan awal');
      if (fotoList == null || fotoList.isEmpty) return [];
      return List<String>.from(
        fotoList
            .map((e) => e['foto_pembayaran'])
            .where((url) => url != null && url.toString().isNotEmpty),
      );
    } catch (e) {
      debugPrint('Error fetching bukti pembayaran sewa: $e');
      return [];
    }
  }

  // Tambahkan fungsi helper untuk fetch bukti pembayaran denda
  Future<List<String>> _fetchBuktiPembayaranDenda(String sewaId) async {
    try {
      final supabase = Supabase.instance.client;
      // Ambil tagihan_sewa_id dari tagihan_sewa (berdasarkan sewa.id)
      final tagihan =
          await supabase
              .from('tagihan_sewa')
              .select('id')
              .eq('sewa_aset_id', sewaId)
              .maybeSingle();
      if (tagihan == null || tagihan['id'] == null) return [];
      final tagihanSewaId = tagihan['id'];
      // Ambil foto pembayaran dengan jenis_pembayaran = 'denda'
      final fotoList = await supabase
          .from('foto_pembayaran')
          .select('foto_pembayaran')
          .eq('tagihan_sewa_id', tagihanSewaId)
          .eq('jenis_pembayaran', 'denda');
      if (fotoList == null || fotoList.isEmpty) return [];
      return List<String>.from(
        fotoList
            .map((e) => e['foto_pembayaran'])
            .where((url) => url != null && url.toString().isNotEmpty),
      );
    } catch (e) {
      debugPrint('Error fetching bukti pembayaran denda: $e');
      return [];
    }
  }
}
