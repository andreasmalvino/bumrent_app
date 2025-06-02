import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sewa_aset_controller.dart';
import '../controllers/order_sewa_aset_controller.dart';
import '../../../routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_colors.dart';

class SewaAsetView extends GetView<SewaAsetController> {
  const SewaAsetView({super.key});

  @override
  Widget build(BuildContext context) {
    // Handle hot reload by checking if controller needs to be reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called after the widget tree is built
      controller.handleHotReload();
    });

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press here
        debugPrint('🔙 Back button pressed - navigating to WargaDashboard');
        controller.onBackPressed();
        return false; // We handle the navigation ourselves
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Sewa Aset',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              debugPrint(
                '🔙 Back button clicked - navigating to WargaDashboard',
              );
              controller.onBackPressed();
            },
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Cari aset...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onChanged: (value) {
                  controller.filterAsets(value);
                },
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: TabBar(
                controller: controller.tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF92B4D7), // Light blue
                      Color(0xFF3A6EA5), // Medium blue
                      Color(0xFF0E2A47), // Dark navy blue
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF3A6EA5,
                      ).withOpacity(0.3), // Medium blue with opacity
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(
                  0xFF718093,
                ), // Text secondary color
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined),
                        const SizedBox(width: 8),
                        const Text('Aset Tunggal'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined),
                        const SizedBox(width: 8),
                        const Text('Paket'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Obx(() {
                bool isFirstTab = controller.currentTabIndex.value == 0;
                final assetCount = controller.filteredAsets.length;
                final paketCount = controller.filteredPakets.length;

                return Row(
                  children: [
                    Icon(
                      isFirstTab ? Icons.inventory_2 : Icons.category,
                      size: 20,
                      color: const Color(0xFF3A6EA5), // Primary blue
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFirstTab ? 'Daftar Aset Tersedia' : 'Paket Sewa',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A6EA5), // Primary blue
                      ),
                    ),
                    const Spacer(),
                    if (isFirstTab)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF92B4D7,
                          ).withOpacity(0.2), // Light blue with opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$assetCount aset',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3A6EA5), // Primary blue
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF92B4D7,
                          ).withOpacity(0.2), // Light blue with opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$paketCount paket',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3A6EA5), // Primary blue
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  // Aset Tunggal tab content
                  _buildAsetTunggalTab(),

                  // Paket tab content
                  _buildPaketTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Aset Tunggal tab content
  Widget _buildAsetTunggalTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF3A6EA5),
              ), // Primary blue
              const SizedBox(height: 16),
              Text(
                'Memuat daftar aset...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      if (controller.filteredAsets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                'Tidak ada aset yang ditemukan',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba gunakan kata kunci lain',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadAsets,
        color: const Color(0xFF3A6EA5), // Primary blue
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.50, // Make cards taller to avoid overflow
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.filteredAsets.length,
          itemBuilder: (context, index) {
            final aset = controller.filteredAsets[index];
            return _buildGridAsetCard(aset);
          },
        ),
      );
    });
  }

  // Paket tab content
  Widget _buildPaketTab() {
    return Obx(() {
      if (controller.isLoadingPakets.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF3A6EA5),
                ), // Primary blue
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat data paket...',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      if (controller.filteredPakets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                'Tidak ada paket yang ditemukan',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba gunakan kata kunci lain',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.50, // Make cards taller to avoid overflow
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.filteredPakets.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final paket = controller.filteredPakets[index];
            final List<dynamic> satuanWaktuSewa =
                paket['satuanWaktuSewa'] ?? [];

            // Find the lowest price
            int lowestPrice =
                satuanWaktuSewa.isEmpty
                    ? 0
                    : satuanWaktuSewa
                        .map<int>((sws) => sws['harga'] ?? 0)
                        .reduce((a, b) => a < b ? a : b);

            // Get image URL or default
            String imageUrl = paket['gambar_url'] ?? '';

            return GestureDetector(
              onTap: () => _showPaketDetailModal(paket),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.purple,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),

                    // Content section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Package name
                            Text(
                              paket['nama'] ?? 'Paket',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Status availability
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tersedia',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Package pricing - show all pricing options with scrolling
                            if (satuanWaktuSewa.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    ...satuanWaktuSewa.map((sws) {
                                      // Pastikan data yang ditampilkan valid
                                      final harga = sws['harga'] ?? 0;
                                      final namaSatuan =
                                          sws['nama_satuan_waktu'] ?? 'Satuan';
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Rp ${_formatNumber(harga)}",
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              "/$namaSatuan",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Mulai dari Rp ${NumberFormat('#,###').format(lowestPrice)}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const Spacer(),

                            // Remove the items count badge and replace with direct Order button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showPaketDetailModal(paket),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(double.infinity, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Pesan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _showPaketDetailModal(Map<String, dynamic> paket) {
    final List<dynamic> satuanWaktuSewa = paket['satuanWaktuSewa'] ?? [];

    // Sort pricing options by price
    satuanWaktuSewa.sort(
      (a, b) => (a['harga'] ?? 0).compareTo(b['harga'] ?? 0),
    );

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Paket',
                  style: Theme.of(
                    Get.context!,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                children: [
                  // Package image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl:
                            paket['gambar_url'] ??
                            'https://placehold.co/600x400/png?text=Paket',
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.purple,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tidak ada gambar tersedia',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Package name
                  Text(
                    paket['nama'] ?? 'Paket',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Item count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${paket['jumlah_item'] ?? 0} item dalam paket ini',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paket['deskripsi'] ?? 'Deskripsi tidak tersedia',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  // Items in package
                  const Text(
                    'Aset dalam Paket',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var item in (paket['items'] ?? []))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['aset_nama'] ?? 'Item',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  'x${item['jumlah'] ?? 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing options
                  const Text(
                    'Pilihan Harga',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (satuanWaktuSewa.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Harga belum tersedia untuk paket ini',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: satuanWaktuSewa.length,
                      itemBuilder: (context, index) {
                        final sws = satuanWaktuSewa[index];
                        final String namaSatuanWaktu =
                            sws['nama_satuan_waktu'] ?? 'Jam';
                        final int harga = sws['harga'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Per $namaSatuanWaktu',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Min. ${sws['durasi_min'] ?? 1} ${namaSatuanWaktu.toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rp ${NumberFormat('#,###').format(harga)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  Text(
                                    'per ${namaSatuanWaktu.toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Order button
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (satuanWaktuSewa.isEmpty) {
                      Get.snackbar(
                        'Tidak Dapat Memesan',
                        'Pilihan harga belum tersedia untuk paket ini',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                      );
                      return;
                    }

                    _showOrderPaketForm(paket, satuanWaktuSewa);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pesan Paket Ini',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderPaketForm(
    Map<String, dynamic> paket,
    List<dynamic> satuanWaktuSewa,
  ) {
    // Selected pricing option
    final Rx<Map<String, dynamic>?> selectedSWS = Rx<Map<String, dynamic>?>(
      satuanWaktuSewa.isNotEmpty ? satuanWaktuSewa[0] : null,
    );

    // Duration
    final RxInt duration = RxInt(selectedSWS.value?['durasi_min'] ?? 1);

    // Calculate total price
    final calculateTotal = () {
      if (selectedSWS.value == null) return 0;
      return (selectedSWS.value!['harga'] ?? 0) * duration.value;
    };
    final RxInt totalPrice = RxInt(calculateTotal());

    // Update total when duration or pricing option changes
    ever(duration, (_) => totalPrice.value = calculateTotal());
    ever(selectedSWS, (_) {
      duration.value = selectedSWS.value?['durasi_min'] ?? 1;
      totalPrice.value = calculateTotal();
    });

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Form Pemesanan Paket',
                  style: Theme.of(
                    Get.context!,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                children: [
                  // Package name
                  const Text(
                    'Paket yang Dipilih',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  paket['gambar_url'] ??
                                  'https://placehold.co/600x400/png?text=Paket',
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.purple,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tidak ada gambar tersedia',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paket['nama'] ?? 'Paket',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${paket['jumlah_item'] ?? 0} item dalam paket',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing option
                  const Text(
                    'Pilih Satuan Waktu',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: satuanWaktuSewa.length,
                      itemBuilder: (context, index) {
                        final sws = satuanWaktuSewa[index];
                        final bool isSelected = selectedSWS.value == sws;

                        return GestureDetector(
                          onTap: () => selectedSWS.value = sws,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.purple[50] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.purple
                                        : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color:
                                      isSelected
                                          ? Colors.purple
                                          : Colors.grey[400],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Per ${sws['nama_satuan_waktu'] ?? 'Jam'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Min. ${sws['durasi_min'] ?? 1} ${(sws['nama_satuan_waktu'] ?? 'jam').toLowerCase()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Rp ${NumberFormat('#,###').format(sws['harga'] ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? Colors.purple
                                            : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  const Text(
                    'Durasi Sewa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final minDuration = selectedSWS.value?['durasi_min'] ?? 1;
                    final namaSatuanWaktu =
                        selectedSWS.value?['nama_satuan_waktu'] ?? 'Jam';

                    return Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (duration.value > minDuration) {
                                  duration.value--;
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '${duration.value} ${namaSatuanWaktu.toLowerCase()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => duration.value++,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Minimum ${minDuration} ${namaSatuanWaktu.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),

                  // Total price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => Text(
                            'Rp ${NumberFormat('#,###').format(totalPrice.value)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close the form

                  // Navigate to order_sewa_paket page
                  // Get the navigation service from the controller
                  final navigationService = controller.navigationService;
                  
                  // Store the selected parameters in a controller or pass as arguments
                  Get.toNamed(
                    Routes.ORDER_SEWA_PAKET,
                    arguments: {
                      'paketId': paket['id'],
                      'satuanWaktuSewaId': selectedSWS.value?['id'] ?? '',
                      'durasi': duration.value,
                      'totalHarga': totalPrice.value,
                      'paketData': paket,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Konfirmasi Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsetCard(aset) {
    // Add debug information for this asset
    debugPrint('📦 Building card for aset: ${aset.id} - ${aset.nama}');
    if (aset.id == null || aset.id.isEmpty) {
      debugPrint('⚠️ WARNING: Aset has no ID!');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  aset.imageUrl != null
                      ? Image.network(
                        aset.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
            ),
          ),

          // Asset details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset name
                Text(
                  aset.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Status availability
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tersedia',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tampilkan harga dan satuan waktu dari join
                if (aset.satuanWaktuSewa.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...aset.satuanWaktuSewa.map((sws) {
                        // Pastikan data yang ditampilkan valid
                        final harga = sws['harga'] ?? 0;
                        final namaSatuan = sws['nama_satuan_waktu'] ?? 'Satuan';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Rp ${_formatNumber(harga)}",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                " / $namaSatuan",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.formatPrice(aset.harga),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " / Jam",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Order button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (aset.id == null || aset.id.isEmpty) {
                        debugPrint('⚠️ Cannot navigate: Aset has no ID!');
                        Get.snackbar(
                          'Error',
                          'ID aset tidak valid',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      _showOrderPage(aset);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(double.infinity, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Grid-style asset card with a more compact layout
  Widget _buildGridAsetCard(aset) {
    debugPrint('📦 Building grid card for aset: ${aset.id} - ${aset.nama}');
    if (aset.id == null || aset.id.isEmpty) {
      debugPrint('⚠️ WARNING: Aset has no ID!');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.0,
              child:
                  aset.imageUrl != null
                      ? Image.network(
                        aset.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
            ),
          ),

          // Asset details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset name
                  Text(
                    aset.nama,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Status availability and price in same row to save space
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tersedia',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price - show only first price option
                  if (aset.satuanWaktuSewa.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ...aset.satuanWaktuSewa.map((sws) {
                            // Pastikan data yang ditampilkan valid
                            final harga = sws['harga'] ?? 0;
                            final namaSatuan =
                                sws['nama_satuan_waktu'] ?? 'Satuan';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Rp ${_formatNumber(harga)}",
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    "/$namaSatuan",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.formatPrice(aset.harga),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            " / Jam",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Order button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (aset.id == null || aset.id.isEmpty) {
                          debugPrint('⚠️ Cannot navigate: Aset has no ID!');
                          Get.snackbar(
                            'Error',
                            'ID aset tidak valid',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        _showOrderPage(aset);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: const Size(double.infinity, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Pesan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk navigasi ke halaman order aset
  void _showOrderPage(aset) {
    // Debug print untuk memastikan ID aset valid
    print('🚀 Navigating to order page with asset ID: ${aset.id}');
    print('🔍 Asset object: ${aset.toJson()}');

    // Make sure the asset ID is not empty
    if (aset.id == null || aset.id.isEmpty) {
      Get.snackbar(
        'Error',
        'ID aset tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Use the static navigation method to ensure consistent behavior
    OrderSewaAsetController.navigateToOrderPage(aset.id);
  }

  // Helper to format numbers for display
  String _formatNumber(dynamic number) {
    if (number == null) return '0';

    // Ensure we're working with a String
    final numStr = number.toString();

    try {
      // Format with thousand separators
      return NumberFormat('#,###').format(int.parse(numStr));
    } catch (e) {
      return numStr;
    }
  }
}
