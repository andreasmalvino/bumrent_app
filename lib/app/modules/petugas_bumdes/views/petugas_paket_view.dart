import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bumrent_app/app/modules/petugas_bumdes/controllers/petugas_paket_controller.dart';
import 'package:bumrent_app/app/routes/app_pages.dart';
import 'package:bumrent_app/app/data/models/paket_model.dart';
import '../widgets/petugas_bumdes_bottom_navbar.dart';
import '../widgets/petugas_side_navbar.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors_petugas.dart';

class PetugasPaketView extends GetView<PetugasPaketController> {
  const PetugasPaketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get dashboard controller for navigation
    final dashboardController = Get.find<PetugasBumdesDashboardController>();

    return WillPopScope(
      onWillPop: () async {
        // Saat back button ditekan, kembali ke dashboard
        dashboardController.changeTab(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manajemen Paket',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColorsPetugas.navyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.sort, size: 22),
              onPressed: () => _showSortingBottomSheet(context),
              tooltip: 'Urutkan',
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: PetugasSideNavbar(controller: dashboardController),
        drawerEdgeDragWidth: 60,
        drawerScrimColor: Colors.black.withOpacity(0.6),
        backgroundColor: AppColorsPetugas.babyBlueBright,
        body: Column(
          children: [_buildSearchBar(), Expanded(child: _buildPaketList())],
        ),
        bottomNavigationBar: Obx(
          () => PetugasBumdesBottomNavbar(
            selectedIndex: dashboardController.currentTabIndex.value,
            onItemTapped: (index) => dashboardController.changeTab(index),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed:
              () => Get.toNamed(
                Routes.PETUGAS_TAMBAH_PAKET,
                arguments: {'isEditing': false},
              ),
          label: Text(
            'Tambah Paket',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColorsPetugas.blueGrotto,
            ),
          ),
          icon: Icon(Icons.add, color: AppColorsPetugas.blueGrotto),
          backgroundColor: AppColorsPetugas.babyBlueBright,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColorsPetugas.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari paket...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.search,
            color: AppColorsPetugas.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColorsPetugas.babyBlueBright,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPaketList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColorsPetugas.blueGrotto,
            strokeWidth: 3,
          ),
        );
      }

      if (controller.filteredPackages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 80,
                color: AppColorsPetugas.babyBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada paket ditemukan',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorsPetugas.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed:
                    () => Get.toNamed(
                      Routes.PETUGAS_TAMBAH_PAKET,
                      arguments: {'isEditing': false},
                    ),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Paket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsPetugas.blueGrotto,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadPaketData,
        color: AppColorsPetugas.blueGrotto,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredPackages.length + 1,
          itemBuilder: (context, index) {
            if (index < controller.filteredPackages.length) {
              final paket = controller.filteredPackages[index];
              return _buildPaketCard(context, paket);
            } else {
              // Blank space at the end
              return const SizedBox(height: 80);
            }
          },
        ),
      );
    });
  }

  // Format price helper method
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    // If price is a string that can be parsed to a number
    if (price is String) {
      final number = double.tryParse(price) ?? 0;
      return number
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    // If price is already a number
    if (price is num) {
      return price
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    return '0';
  }

  // Helper method to get time unit name based on ID
  String _getTimeUnitName(dynamic unitId) {
    if (unitId == null) return 'unit';

    // Convert to string in case it's not already
    final unitIdStr = unitId.toString().toLowerCase();

    // Map of known time unit IDs to their display names
    final timeUnitMap = {
      '6eaa32d9-855d-4214-b5b5-5c73d3edd9c5': 'jam',
      '582b7e66-6869-4495-9856-cef4a46683b0': 'hari',
      // Add more mappings as needed
    };

    // If the unitId is a known ID, return the corresponding name
    if (timeUnitMap.containsKey(unitIdStr)) {
      return timeUnitMap[unitIdStr]!;
    }

    // Check if the unit is already a name (like 'jam' or 'hari')
    final knownUnits = ['jam', 'hari', 'minggu', 'bulan'];
    if (knownUnits.contains(unitIdStr)) {
      return unitIdStr;
    }

    // If the unit is a Map, try to extract the name from common fields
    if (unitId is Map) {
      return unitId['nama']?.toString().toLowerCase() ??
          unitId['name']?.toString().toLowerCase() ??
          unitId['satuan_waktu']?.toString().toLowerCase() ??
          'unit';
    }

    // Default fallback
    return 'unit';
  }

  // Helper method to log time unit details
  void _logTimeUnitDetails(
    String packageName,
    List<Map<String, dynamic>> timeUnits,
  ) {
    debugPrint('\n📦 [DEBUG] Package: $packageName');
    debugPrint('🔄 Found ${timeUnits.length} time units:');

    for (var i = 0; i < timeUnits.length; i++) {
      final unit = timeUnits[i];
      debugPrint('\n  ⏱️ Time Unit #${i + 1}:');

      // Log all available keys and values
      debugPrint('  ├─ All fields: $unit');

      // Log specific fields we're interested in
      unit.forEach((key, value) {
        debugPrint('  ├─ $key: $value (${value.runtimeType})');
      });

      // Special handling for satuan_waktu if it's a map
      if (unit['satuan_waktu'] is Map) {
        final satuanWaktu = unit['satuan_waktu'] as Map;
        debugPrint('  └─ satuan_waktu details:');
        satuanWaktu.forEach((k, v) {
          debugPrint('     ├─ $k: $v (${v.runtimeType})');
        });
      }
    }
    debugPrint('\n');
  }

  Widget _buildPaketCard(BuildContext context, dynamic paket) {
    // Handle both Map and PaketModel for backward compatibility
    final isPaketModel = paket is PaketModel;

    debugPrint('\n🔍 [_buildPaketCard] Paket type: ${paket.runtimeType}');
    debugPrint('📋 Paket data: $paket');

    // Extract status based on type
    final String status =
        isPaketModel
            ? (paket.status?.toString().capitalizeFirst ?? 'Tidak Diketahui')
            : (paket['status']?.toString().capitalizeFirst ??
                'Tidak Diketahui');

    debugPrint('🏷️ Extracted status: $status (isPaketModel: $isPaketModel)');

    // Extract availability based on type
    final bool isAvailable =
        isPaketModel
            ? (paket.kuantitas > 0)
            : ((paket['kuantitas'] as int?) ?? 0) > 0;

    final String nama =
        isPaketModel
            ? paket.nama
            : (paket['nama']?.toString() ?? 'Paket Tanpa Nama');

    // Debug package info
    debugPrint('\n📦 [PACKAGE] ${paket.runtimeType} - $nama');
    debugPrint('├─ isPaketModel: $isPaketModel');
    debugPrint('├─ Available: $isAvailable');

    // Get the first rental time unit price if available, otherwise use the base price
    final dynamic harga;
    if (isPaketModel) {
      if (paket.satuanWaktuSewa.isNotEmpty) {
        _logTimeUnitDetails(nama, paket.satuanWaktuSewa);

        // Get the first time unit with its price
        final firstUnit = paket.satuanWaktuSewa.first;
        final firstUnitPrice = firstUnit['harga'];

        debugPrint('💰 First time unit price: $firstUnitPrice');
        debugPrint('⏱️ First time unit ID: ${firstUnit['satuan_waktu_id']}');
        debugPrint('📝 First time unit details: $firstUnit');

        // Always use the first time unit's price if available
        harga = firstUnitPrice ?? 0;
      } else {
        debugPrint('⚠️ No time units found for package: $nama');
        debugPrint('ℹ️ Using base price: ${paket.harga}');
        harga = paket.harga;
      }
    } else {
      // For non-PaketModel (Map) data
      if (isPaketModel && paket.satuanWaktuSewa.isNotEmpty) {
        final firstUnit = paket.satuanWaktuSewa.first;
        final firstUnitPrice = firstUnit['harga'];
        debugPrint('💰 [MAP] First time unit price: $firstUnitPrice');
        harga = firstUnitPrice ?? 0;
      } else {
        debugPrint('⚠️ [MAP] No time units found for package: $nama');
        debugPrint('ℹ️ [MAP] Using base price: ${paket['harga']}');
        harga = paket['harga'] ?? 0;
      }
    }

    debugPrint('💵 Final price being used: $harga\n');

    // Get the main photo URL
    final String? foto =
        isPaketModel
            ? (paket.images?.isNotEmpty == true
                ? paket.images!.first
                : paket.foto_paket)
            : (paket['foto_paket']?.toString() ??
                (paket['foto'] is String ? paket['foto'] : null));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsPetugas.shadowColor,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPaketDetails(context, paket),
            child: Row(
              children: [
                // Paket image or icon
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child:
                        foto != null && foto.isNotEmpty
                            ? Image.network(
                              foto,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: AppColorsPetugas.babyBlueLight,
                                    child: Center(
                                      child: Icon(
                                        _getPaketIcon(
                                          _getTimeUnitName(
                                            isPaketModel
                                                ? (paket
                                                        .satuanWaktuSewa
                                                        .isNotEmpty
                                                    ? paket
                                                            .satuanWaktuSewa
                                                            .first['satuan_waktu_id'] ??
                                                        'hari'
                                                    : 'hari')
                                                : (paket['satuanWaktuSewa'] !=
                                                            null &&
                                                        paket['satuanWaktuSewa']
                                                            .isNotEmpty
                                                    ? paket['satuanWaktuSewa'][0]['satuan_waktu_id']
                                                            ?.toString() ??
                                                        'hari'
                                                    : 'hari'),
                                          ),
                                        ),
                                        color: AppColorsPetugas.navyBlue
                                            .withOpacity(0.5),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                            )
                            : Container(
                              color: AppColorsPetugas.babyBlueLight,
                              child: Center(
                                child: Icon(
                                  _getPaketIcon(
                                    _getTimeUnitName(
                                      isPaketModel
                                          ? (paket.satuanWaktuSewa.isNotEmpty
                                              ? paket
                                                      .satuanWaktuSewa
                                                      .first['satuan_waktu_id'] ??
                                                  'hari'
                                              : 'hari')
                                          : (paket['satuanWaktuSewa'] != null &&
                                                  paket['satuanWaktuSewa']
                                                      .isNotEmpty
                                              ? paket['satuanWaktuSewa'][0]['satuan_waktu_id']
                                                      ?.toString() ??
                                                  'hari'
                                              : 'hari'),
                                    ),
                                  ),
                                  color: AppColorsPetugas.navyBlue.withOpacity(
                                    0.5,
                                  ),
                                  size: 32,
                                ),
                              ),
                            ),
                  ),
                ),

                // Paket info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name and price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Package name
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColorsPetugas.navyBlue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Prices with time units
                              Builder(
                                builder: (context) {
                                  final List<Map<String, dynamic>> timeUnits =
                                      [];

                                  // Get all time units
                                  if (isPaketModel &&
                                      paket.satuanWaktuSewa.isNotEmpty) {
                                    timeUnits.addAll(paket.satuanWaktuSewa);
                                  } else if (!isPaketModel &&
                                      paket['satuanWaktuSewa'] != null &&
                                      paket['satuanWaktuSewa'].isNotEmpty) {
                                    timeUnits.addAll(
                                      List<Map<String, dynamic>>.from(
                                        paket['satuanWaktuSewa'],
                                      ),
                                    );
                                  }

                                  // If no time units, show nothing
                                  if (timeUnits.isEmpty)
                                    return const SizedBox.shrink();

                                  // Filter out time units with price 0 or null
                                  final validTimeUnits =
                                      timeUnits.where((unit) {
                                        final price =
                                            unit['harga'] is int
                                                ? unit['harga']
                                                : int.tryParse(
                                                      unit['harga']
                                                              ?.toString() ??
                                                          '0',
                                                    ) ??
                                                    0;
                                        return price > 0;
                                      }).toList();

                                  if (validTimeUnits.isEmpty)
                                    return const SizedBox.shrink();

                                  return Column(
                                    children:
                                        validTimeUnits
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final index = entry.key;
                                              final unit = entry.value;
                                              final unitPrice =
                                                  unit['harga'] is int
                                                      ? unit['harga']
                                                      : int.tryParse(
                                                            unit['harga']
                                                                    ?.toString() ??
                                                                '0',
                                                          ) ??
                                                          0;
                                              final unitName = _getTimeUnitName(
                                                unit['satuan_waktu_id'],
                                              );
                                              final isFirst = index == 0;

                                              if (unitPrice <= 0)
                                                return const SizedBox.shrink();

                                              return Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Rp ${_formatPrice(unitPrice)}/$unitName',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColorsPetugas
                                                                .textSecondary,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })
                                            .where(
                                              (widget) => widget is! SizedBox,
                                            )
                                            .toList(),
                                  );
                                },
                              ),
                              if (!isPaketModel &&
                                  paket['harga'] != null &&
                                  (paket['harga'] is int
                                          ? paket['harga']
                                          : int.tryParse(
                                                paket['harga']?.toString() ??
                                                    '0',
                                              ) ??
                                              0) >
                                      0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatPrice(paket['harga'])}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColorsPetugas.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                status.toLowerCase() == 'tersedia'
                                    ? AppColorsPetugas.successLight
                                    : status.toLowerCase() == 'pemeliharaan'
                                    ? AppColorsPetugas.warningLight
                                    : AppColorsPetugas.errorLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  status.toLowerCase() == 'tersedia'
                                      ? AppColorsPetugas.success
                                      : status.toLowerCase() == 'pemeliharaan'
                                      ? AppColorsPetugas.warning
                                      : AppColorsPetugas.error,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  status.toLowerCase() == 'tersedia'
                                      ? AppColorsPetugas.success
                                      : status.toLowerCase() == 'pemeliharaan'
                                      ? AppColorsPetugas.warning
                                      : AppColorsPetugas.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Action icons
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            // Edit icon
                            GestureDetector(
                              onTap:
                                  () => Get.toNamed(
                                    Routes.PETUGAS_TAMBAH_PAKET,
                                    arguments: {
                                      'isEditing': true,
                                      'paket': paket,
                                    },
                                  ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColorsPetugas.babyBlueBright,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColorsPetugas.blueGrotto
                                        .withOpacity(0.5),
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColorsPetugas.blueGrotto,
                                  size: 16,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Delete icon
                            GestureDetector(
                              onTap:
                                  () => _showDeleteConfirmation(context, paket),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColorsPetugas.errorLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColorsPetugas.error.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: AppColorsPetugas.error,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Add this helper method to get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColorsPetugas.success;
      case 'tidak aktif':
      case 'nonaktif':
        return AppColorsPetugas.error;
      case 'dalam perbaikan':
      case 'maintenance':
        return AppColorsPetugas.warning;
      case 'tersedia':
        return AppColorsPetugas.success;
      case 'pemeliharaan':
        return AppColorsPetugas.warning;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaketIcon(String? timeUnit) {
    if (timeUnit == null) return Icons.access_time;

    switch (timeUnit.toLowerCase()) {
      case 'jam':
        return Icons.access_time;
      case 'hari':
        return Icons.calendar_today;
      case 'minggu':
        return Icons.date_range;
      case 'bulan':
        return Icons.calendar_month;
      case 'tahun':
        return Icons.calendar_view_month;
      default:
        return Icons.access_time;
    }
  }

  void _showSortingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Urutkan Paket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsPetugas.navyBlue,
                ),
              ),
              const SizedBox(height: 16),
              ...controller.sortOptions.map((option) {
                return Obx(() {
                  final isSelected = option == controller.sortBy.value;
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: controller.sortBy.value,
                    activeColor: AppColorsPetugas.blueGrotto,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSortBy(value);
                        Navigator.pop(context);
                      }
                    },
                  );
                });
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showPaketDetails(BuildContext context, dynamic paket) {
    // Handle both Map and PaketModel for backward compatibility
    final isPaketModel = paket is PaketModel;
    final String nama =
        isPaketModel
            ? paket.nama
            : (paket['nama']?.toString() ?? 'Paket Tanpa Nama');
    final String? deskripsi =
        isPaketModel ? paket.deskripsi : paket['deskripsi']?.toString();
    final bool isAvailable =
        isPaketModel
            ? (paket.kuantitas > 0)
            : ((paket['kuantitas'] as int?) ?? 0) > 0;
    final dynamic harga =
        isPaketModel
            ? (paket.satuanWaktuSewa.isNotEmpty
                ? paket.satuanWaktuSewa.first['harga']
                : paket.harga)
            : (paket['harga'] ?? 0);
    // Items are not part of the PaketModel, so we'll use an empty list
    final List<Map<String, dynamic>> items = [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nama,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColorsPetugas.blueGrotto),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailItem(
                              'Harga',
                              'Rp ${_formatPrice(harga)}',
                            ),
                            _buildDetailItem(
                              'Status',
                              isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                            ),
                            _buildDetailItem('Deskripsi', deskripsi ?? '-'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Item dalam Paket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsPetugas.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColorsPetugas.babyBlue,
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: AppColorsPetugas.blueGrotto,
                                size: 16,
                              ),
                            ),
                            title: Text(item['nama']),
                            trailing: Text(
                              '${item['jumlah']} unit',
                              style: TextStyle(
                                color: AppColorsPetugas.blueGrotto,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.toNamed(
                          Routes.PETUGAS_TAMBAH_PAKET,
                          arguments: paket,
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColorsPetugas.blueGrotto,
                        side: BorderSide(color: AppColorsPetugas.blueGrotto),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, paket);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsPetugas.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColorsPetugas.blueGrotto),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColorsPetugas.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditPaketDialog(BuildContext context, {dynamic paket}) {
    // Handle both Map and PaketModel for backward compatibility
    final isPaketModel = paket is PaketModel;
    final String? id = isPaketModel ? paket.id : paket?['id'];
    final String title = id == null ? 'Tambah Paket' : 'Edit Paket';
    final isEditing = paket != null;

    // This would be implemented with proper form validation in a real app
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: AppColorsPetugas.navyBlue),
          ),
          content: const Text(
            'Form pengelolaan paket akan ditampilkan di sini dengan field untuk nama, kategori, harga, deskripsi, status, dan item-item dalam paket.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, we would save the form data
                Get.snackbar(
                  isEditing ? 'Paket Diperbarui' : 'Paket Ditambahkan',
                  isEditing
                      ? 'Paket berhasil diperbarui'
                      : 'Paket baru berhasil ditambahkan',
                  backgroundColor: AppColorsPetugas.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.blueGrotto,
              ),
              child: Text(isEditing ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic paket) {
    // Handle both Map and PaketModel for backward compatibility
    final isPaketModel = paket is PaketModel;
    final String id = isPaketModel ? paket.id : (paket['id']?.toString() ?? '');
    final String nama =
        isPaketModel ? paket.nama : (paket['nama']?.toString() ?? 'Paket');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus',
            style: TextStyle(color: AppColorsPetugas.navyBlue),
          ),
          content: Text('Apakah Anda yakin ingin menghapus paket "$nama"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deletePaket(id);
                Get.snackbar(
                  'Paket Dihapus',
                  'Paket berhasil dihapus dari sistem',
                  backgroundColor: AppColorsPetugas.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPetugas.error,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
