import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/order_sewa_paket_controller.dart';
import '../../../data/models/paket_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_logs/flutter_logs.dart';
import '../../../../utils/constants/app_colors.dart';
import 'package:intl/intl.dart';

class OrderSewaPaketView extends GetView<OrderSewaPaketController> {
  const OrderSewaPaketView({super.key});

  // Build package items details section
  Widget _buildPackageItemsDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Detail Paket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // Show badge with number of items
                Obx(
                  () =>
                      controller.paketItems.isNotEmpty
                          ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${controller.paketItems.length} item',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Container with items list
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              // Show loading indicator
              if (controller.isPaketItemsLoading.value) {
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              // Show empty state
              if (controller.paketItems.isEmpty) {
                return Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada item dalam paket',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show items list
              return ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.paketItems.length,
                separatorBuilder:
                    (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                itemBuilder: (context, index) {
                  final item = controller.paketItems[index];
                  final aset = item['aset'];
                  final kuantitas = item['kuantitas'] ?? 1;
                  final asetNama =
                      aset != null
                          ? aset['nama'] ?? 'Item tidak diketahui'
                          : 'Item tidak diketahui';

                  // Get asset image URL - use the first photo from semua_foto if available
                  final String? imageUrl = item['foto_aset']?.toString().isNotEmpty == true 
                      ? item['foto_aset'].toString()
                      : aset != null ? aset['foto_url'] : null;

                  // Get asset name - prefer nama_aset from the item, fall back to aset['nama']
                  final String displayName = item['nama_aset']?.toString().isNotEmpty == true
                      ? item['nama_aset'].toString()
                      : asetNama;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Item image
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: imageUrl == null
                                ? AppColors.primarySoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.inventory_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 16),

                        // Item name and info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Aset dalam paket',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'x$kuantitas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Build price options section
  Widget _buildPriceOptions() {
    final paket = controller.paket.value!;
    final PaketModel? paketModel = paket is PaketModel ? paket : null;
    
    // Get the satuanWaktuSewa from the paket model
    final satuanWaktuSewa = paketModel?.satuanWaktuSewa ?? [];
    
    // Create default options for hourly and daily
    Map<String, dynamic> hourlyOption = {
      'id': 'hourly',
      'nama_satuan_waktu': 'per Jam',
      'harga': 0,
      'type': 'hourly',
    };
    
    Map<String, dynamic> dailyOption = {
      'id': 'daily',
      'nama_satuan_waktu': 'per Hari',
      'harga': 0,
      'type': 'daily',
    };
    
    // Find and update hourly and daily options from satuanWaktuSewa if they exist
    for (var option in satuanWaktuSewa) {
      final namaSatuan = (option['nama_satuan_waktu'] ?? '').toString().toLowerCase();
      if (namaSatuan.contains('jam')) {
        hourlyOption = Map<String, dynamic>.from(option);
        hourlyOption['type'] = 'hourly';
      } else if (namaSatuan.contains('hari')) {
        dailyOption = Map<String, dynamic>.from(option);
        dailyOption['type'] = 'daily';
      }
    }
    
    // Always include both options in the list
    final List<Map<String, dynamic>> availableOptions = [
      hourlyOption,
      dailyOption,
    ];
    
    // Count available options
    final availableOptionsCount = availableOptions.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Opsi Durasi Sewa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Show number of available options
                availableOptionsCount == 1
                    ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '1 opsi tersedia',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$availableOptionsCount opsi tersedia',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Always show hourly option
                _buildDurationOption(
                  option: availableOptions.firstWhere(
                    (opt) => opt['type'] == 'hourly',
                    orElse: () => {'type': 'hourly', 'nama_satuan_waktu': 'per Jam', 'harga': 0},
                  ),
                  isFirst: true,
                  isLast: false,
                ),
                
                // Always show daily option
                _buildDurationOption(
                  option: availableOptions.firstWhere(
                    (opt) => opt['type'] == 'daily',
                    orElse: () => {'type': 'daily', 'nama_satuan_waktu': 'per Hari', 'harga': 0},
                  ),
                  isFirst: false,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each duration option
  Widget _buildDurationOption({
    required Map<String, dynamic> option,
    required bool isFirst,
    required bool isLast,
  }) {
    // Determine which icon and display name to use based on the rental type
    final String type = option['type'] ?? '';
    final String durationName = option['nama_satuan_waktu'] ?? '';
    final double price = double.tryParse(option['harga']?.toString() ?? '0') ?? 0;
    final bool isEnabled = price > 0;
    
    IconData durationIcon;
    String durationDisplayName;

    if (type == 'hourly' || durationName.toLowerCase().contains('jam')) {
      durationIcon = Icons.access_time_rounded;
      durationDisplayName = 'Sewa per Jam';
    } else if (type == 'daily' || durationName.toLowerCase().contains('hari')) {
      durationIcon = Icons.calendar_today_rounded;
      durationDisplayName = 'Sewa per Hari';
    } else {
      durationIcon = Icons.timelapse_rounded;
      durationDisplayName = durationName.isNotEmpty ? durationName : 'Sewa';
    }

    final String formattedPrice = controller.formatPrice(price);
    
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: InkWell(
        onTap: isEnabled ? () {
          if (controller.selectedSatuanWaktu.value?['id'] != option['id']) {
            HapticFeedback.lightImpact();
            controller.selectSatuanWaktu(option);
          }
        } : null,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(16) : Radius.zero,
          bottom: isLast ? Radius.circular(16) : Radius.zero,
        ),
        child: Obx(() {
          final bool isSelected = controller.selectedSatuanWaktu.value?['id'] == option['id'];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primarySoft 
                  : (isEnabled ? Colors.white : Colors.grey[100]),
              borderRadius: BorderRadius.vertical(
                top: isFirst ? Radius.circular(16) : Radius.zero,
                bottom: isLast ? Radius.circular(16) : Radius.zero,
              ),
              border: !isLast
                  ? Border(
                      bottom: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    )
                  : null,
              boxShadow: isSelected && isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    durationIcon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        durationDisplayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? AppColors.primary 
                              : (isEnabled ? AppColors.textPrimary : AppColors.textSecondary),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isEnabled ? formattedPrice : 'Tidak tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
                          color: isSelected 
                              ? AppColors.primary.withOpacity(0.9)
                              : (isEnabled ? AppColors.textSecondary : AppColors.textTertiary),
                          fontStyle: isEnabled ? null : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Checkmark indicator or unavailable indicator
                isEnabled
                    ? AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: isSelected
                            ? Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                      )
                    : Icon(
                        Icons.block,
                        color: Colors.grey[400],
                        size: 20,
                      ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Function to show confirmation dialog
  void showOrderConfirmationDialog() {
    final paket = controller.paket.value!;
    final PaketModel? paketModel = paket is PaketModel ? paket : null;
    final totalPrice = controller.totalPrice.value;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with success icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Konfirmasi Pesanan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),

              // Subtitle
              Text(
                'Periksa detail pesanan Anda',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Order details
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    // Paket name
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paket',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                paketModel?.nama ??
                                    controller.getPaketNama(paket) ??
                                    'Paket tanpa nama',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: AppColors.divider),

                    // Package Items section
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Paket',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Obx(() {
                                if (controller.isPaketItemsLoading.value) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                if (controller.paketItems.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Text(
                                      'Tidak ada item dalam paket ini',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: controller.paketItems.length,
                                  separatorBuilder:
                                      (context, index) => Divider(
                                        height: 16,
                                        color: AppColors.divider.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = controller.paketItems[index];
                                    final aset = item['aset'];
                                    final kuantitas = item['kuantitas'] ?? 1;
                                    final String assetName =
                                        aset['nama'] ?? 'Item tidak dikenal';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon for list item
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.primarySoft
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.inventory_2_outlined,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 12),

                                          // Asset name
                                          Expanded(
                                            child: Text(
                                              assetName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),

                                          // Quantity
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceLight,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.borderLight,
                                              ),
                                            ),
                                            child: Text(
                                              '$kuantitas',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
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
                    Divider(height: 24, color: AppColors.divider),

                    // Duration info
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  controller.getFormattedDuration(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: AppColors.divider),

                    // Total price info
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Harga',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  controller.formatPrice(
                                    controller.totalPrice.value,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
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
              SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderDark),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.isSubmitting.value
                                ? null
                                : () {
                                  Get.back();
                                  controller.submitOrder();
                                },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            controller.isSubmitting.value
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build date selection section
  Widget _buildDateSelection(BuildContext context) {
    return Obx(
      () =>
          controller.selectedSatuanWaktu.value == null
              ? SizedBox.shrink()
              : Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Pilih Waktu Sewa',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        // Information badge
                        _buildInfoBadge(
                          controller.isDailyRental() ? 'Harian' : 'Per Jam',
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Show different UI based on rental type (hourly or daily)
                    controller.isDailyRental()
                        ? _buildDailyRentalDateSelection(context)
                        : _buildHourlyRentalDateSelection(context),
                  ],
                ),
              ),
    );
  }

  void onTapPesan() {
    showOrderConfirmationDialog();
  }

  // Helper method to build info badge
  Widget _buildInfoBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Hourly rental date and time selection UI
  Widget _buildHourlyRentalDateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date picker button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => controller.pickDate(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF92B4D7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.date_range_rounded,
                        color: Color(0xFF3A6EA5),
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Sewa',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.selectedStartDate.value == null
                                ? 'Pilih tanggal sewa'
                                : controller.formattedSelectedDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3A6EA5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 24),

        // Time selection section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Pilih Jam',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Show selected time range if any
                    Obx(
                      () =>
                          controller.formattedTimeRange.value.isNotEmpty
                              ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  controller.formattedTimeRange.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                              : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1, color: Colors.grey[200]),

              // Time selection grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTimeGrid(),
              ),

              // Show selected duration
              Obx(
                () =>
                    controller.formattedTimeRange.value.isNotEmpty
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Durasi: ${controller.duration.value} jam',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                        : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Daily rental date selection UI
  Widget _buildTimeGrid() {
    // Create rows of hours, with 4 hours per row
    final List<Widget> rows = [];
    final hours = controller.availableHours;

    // Create rows of 4 hours each
    for (int i = 0; i < hours.length; i += 4) {
      final rowItems = <Widget>[];

      // Add up to 4 hours for this row
      for (int j = 0; j < 4 && i + j < hours.length; j++) {
        final hour = hours[i + j];
        rowItems.add(Expanded(child: _buildTimeButton(hour)));

        // Add spacing between buttons
        if (j < 3 && i + j + 1 < hours.length) {
          rowItems.add(SizedBox(width: 8));
        }
      }

      rows.add(Row(children: rowItems));

      // Add spacing between rows
      if (i + 4 < hours.length) {
        rows.add(SizedBox(height: 12));
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: rows),
    );
  }

  Widget _buildTimeButton(int hour) {
    return Obx(() {
      // Check if hour is disabled based on inventory availability
      final bool isDisabled = controller.isHourDisabled(hour);

      // Get selection states
      final bool isStartTime = controller.selectedStartTime.value == hour;
      final bool isEndTime = controller.selectedEndTime.value == hour;
      final bool isSelected = isStartTime || isEndTime;
      final bool isInRange =
          controller.selectedStartTime.value >= 0 &&
          controller.selectedEndTime.value >= 0 &&
          hour > controller.selectedStartTime.value &&
          hour < controller.selectedEndTime.value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              isDisabled
                  ? null
                  : () {
                    // Add haptic feedback when selecting an hour
                    HapticFeedback.selectionClick();
                    controller.selectTime(hour);
                  },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isDisabled
                      ? Colors.grey[200]
                      : isSelected
                      ? AppColors.primary
                      : isInRange
                      ? AppColors.primarySoft
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDisabled
                        ? Colors.grey[300]!
                        : isSelected
                        ? AppColors.primary
                        : isInRange
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$hour:00',
                style: TextStyle(
                  color:
                      isDisabled
                          ? Colors.grey[500]
                          : isSelected
                          ? Colors.white
                          : isInRange
                          ? AppColors.primary
                          : Colors.grey[800],
                  fontWeight:
                      isSelected || isInRange
                          ? FontWeight.bold
                          : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDailyRentalDateSelection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range picker button
          InkWell(
            onTap: () => controller.pickDateRange(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF92B4D7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.date_range_rounded,
                        color: Color(0xFF3A6EA5),
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rentang Tanggal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.formattedDateRange.value.isNotEmpty
                                ? controller.formattedDateRange.value
                                : 'Pilih tanggal sewa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  controller.formattedDateRange.value.isNotEmpty
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  controller.formattedDateRange.value.isNotEmpty
                                      ? Color(0xFF3A6EA5)
                                      : Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // Display selected duration
          Obx(
            () =>
                controller.formattedDateRange.value.isNotEmpty
                    ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF92B4D7).withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFF3A6EA5),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Durasi: ${controller.duration.value} hari',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3A6EA5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Build summary section
  Widget _buildSummary() {
    return Obx(
      () =>
          controller.selectedSatuanWaktu.value == null ||
                  (controller.isDailyRental() &&
                      (controller.selectedStartDate.value == null ||
                          controller.selectedEndDate.value == null)) ||
                  (!controller.isDailyRental() &&
                      (controller.selectedStartDate.value == null ||
                          controller.selectedStartTime.value < 0 ||
                          controller.selectedEndTime.value < 0))
              ? SizedBox.shrink()
              : Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                margin: EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  controller.formatPrice(
                                    controller.totalPrice.value,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Order button
                        Obx(
                          () => ElevatedButton(
                            onPressed:
                                controller.selectedSatuanWaktu.value == null ||
                                        (controller.isDailyRental() &&
                                            (controller
                                                        .selectedStartDate
                                                        .value ==
                                                    null ||
                                                controller
                                                        .selectedEndDate
                                                        .value ==
                                                    null)) ||
                                        (!controller.isDailyRental() &&
                                            (controller
                                                        .selectedStartDate
                                                        .value ==
                                                    null ||
                                                controller
                                                        .selectedStartTime
                                                        .value <
                                                    0 ||
                                                controller
                                                        .selectedEndTime
                                                        .value <
                                                    0))
                                    ? null
                                    : onTapPesan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Pesan Sekarang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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

  @override
  Widget build(BuildContext context) {
    final paket = controller.paket.value;

    // If no paket, return loading
    if (paket == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Detail Paket'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final PaketModel? paketModel = paket is PaketModel ? paket : null;
    final String paketNama =
        paketModel?.nama ??
        controller.getPaketNama(paket) ??
        'Paket Tanpa Nama';
    final String? paketDeskripsi =
        paketModel?.deskripsi ?? controller.getPaketDeskripsi(paket);

    // Function to handle back button press
    void handleBackButtonPress() {
      debugPrint('🔙 Back button pressed - returning to previous page');
      try {
        // First try to use navigation service if available
        if (Get.isRegistered<NavigationService>()) {
          Get.find<NavigationService>().back();
        } else {
          // Fallback to direct navigation
          Get.back();
        }
      } catch (e) {
        debugPrint('⚠️ Error handling back button: $e');
        // Last resort fallback
        Get.back();
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      // No AppBar - we'll use a custom back button
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top image section with gallery and back button
                Stack(
                  children: [
                    // Image gallery with rounded corners
                    SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          if (controller.paketImages.isNotEmpty) {
                            controller.openImageGallery(
                              context,
                              controller.paketImages.toList(),
                              0,
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: Obx(() {
                            // Show loading indicator when images are being loaded
                            if (controller.isPhotosLoading.value) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }

                            if (controller.paketImages.isEmpty) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Tidak ada foto',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return CachedNetworkImage(
                              imageUrl: controller.paketImages[0],
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.broken_image_rounded,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Gagal memuat foto',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            );
                          }),
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Back button
                    Positioned(
                      top: 40,
                      left: 16,
                      child: GestureDetector(
                        onTap: handleBackButtonPress,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Navigation arrows - only show if more than 1 photo
                    Obx(
                      () =>
                          controller.paketImages.length > 1
                              ? Positioned.fill(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 16),
                                      child: IconButton(
                                        icon: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (controller
                                                  .currentPhotoIndex
                                                  .value >
                                              0) {
                                            controller
                                                .currentPhotoIndex
                                                .value--;
                                          } else {
                                            controller.currentPhotoIndex.value =
                                                controller.paketImages.length -
                                                1;
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 16),
                                      child: IconButton(
                                        icon: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (controller
                                                  .currentPhotoIndex
                                                  .value <
                                              controller.paketImages.length -
                                                  1) {
                                            controller
                                                .currentPhotoIndex
                                                .value++;
                                          } else {
                                            controller.currentPhotoIndex.value =
                                                0;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : SizedBox.shrink(),
                    ),

                    // Photo counter in top right
                    Obx(
                      () =>
                          controller.paketImages.length > 1
                              ? Positioned(
                                top: 40,
                                right: 16,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "${controller.currentPhotoIndex.value + 1}/${controller.paketImages.length}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              : SizedBox.shrink(),
                    ),

                    // Zoom indicator overlay
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                // Paket info
                Container(
                  padding: EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Package name
                      Text(
                        paketNama,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 24),

                      // Description with card styling
                      if (paketDeskripsi != null && paketDeskripsi.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 120),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Deskripsi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  paketDeskripsi,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Package items details section
                _buildPackageItemsDetails(),

                // Price options
                _buildPriceOptions(),

                // Date selection
                _buildDateSelection(context),

                // Summary and order button
                _buildSummary(),

                // Space for bottom sheet
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
