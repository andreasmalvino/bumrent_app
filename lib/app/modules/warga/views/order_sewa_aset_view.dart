import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/order_sewa_aset_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_logs/flutter_logs.dart';
import '../../../theme/app_colors.dart';

class OrderSewaAsetView extends GetView<OrderSewaAsetController> {
  const OrderSewaAsetView({super.key});

  @override
  Widget build(BuildContext context) {
    // Handle hot reload by checking if controller needs to be reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called after the widget tree is built
      controller.handleHotReload();

      // Ensure navigation service is registered for back button functionality
      if (!Get.isRegistered<NavigationService>()) {
        Get.put(NavigationService());
        debugPrint('✅ Created new NavigationService instance in view');
      }
    });

    // Function to handle back button press
    void handleBackButtonPress() {
      debugPrint('🔙 Back button pressed - navigating to SewaAsetView');
      try {
        // First try to use the controller's method
        controller.onBackPressed();
      } catch (e) {
        debugPrint('⚠️ Error handling back via controller: $e');
        // Fallback to direct navigation
        Get.back();
      }
    }

    // Function to show confirmation dialog
    void showOrderConfirmationDialog() {
      final aset = controller.aset.value!;
      final totalPrice = controller.totalPrice.value;

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
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
                      // Aset name
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aset',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  aset.nama ?? 'Aset tanpa nama',
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
                                    controller.isDailyRental()
                                        ? controller.formattedDateRange.value
                                        : '${controller.selectedDate.value}, ${controller.formattedTimeRange.value}',
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

                      // Quantity info
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jumlah Unit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        '${controller.jumlahUnit.value} unit',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.pesanSekarang();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Pesan Sekarang',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Bersihkan controller saat pengguna keluar dari halaman dengan tombol back perangkat
        controller.clearData();
        debugPrint('🧹 Controller data cleared by WillPopScope');
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 24),
                  Text(
                    'Memuat data aset...',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (controller.aset.value == null) {
            // Jika aset masih null setelah loading selesai, coba muat ulang dari storage
            if (!controller.isLoading.value) {
              debugPrint(
                '⚠️ Asset is null after loading, trying to recover...',
              );
              Future.microtask(() => controller.handleHotReload());

              // Tampilkan loading indicator sementara untuk mencoba recovery
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 24),
                    Text(
                      'Memuat data aset...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Data aset tidak ditemukan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: handleBackButtonPress,
                    icon: Icon(Icons.arrow_back),
                    label: Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                // Main content with scroll
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top section with image and back button
                      _buildTopSection(),

                      // Asset details
                      _buildAssetDetails(),

                      // Price options
                      _buildPriceOptions(),

                      // Date and time selection
                      _buildDateSelection(context),

                      // Add spacing at the bottom for the fixed total price bar
                      SizedBox(height: 100),
                    ],
                  ),
                ),

                // Back button positioned at the top - updated to match reference image
                Positioned(
                  top: 20,
                  left: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: handleBackButtonPress,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.iconPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Fixed bottom bar for total price and order button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomBar(
                    onTapPesan: showOrderConfirmationDialog,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopSection() {
    final aset = controller.aset.value!;
    return Stack(
      children: [
        // Image carousel
        SizedBox(
          height: 320,
          width: double.infinity,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe right
                controller.previousPhoto();
              } else if (details.primaryVelocity! < 0) {
                // Swipe left
                controller.nextPhoto();
              }
            },
            // Add onTap handler for the image
            onTap: () {
              debugPrint(
                "📸 Image tapped - attempting to open fullscreen viewer",
              );
              try {
                final imageUrl = controller.getCurrentPhotoUrl();
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  debugPrint("📸 Current image URL: $imageUrl");
                  debugPrint(
                    "📸 Total photos: ${controller.assetPhotos.length}",
                  );

                  // Extract all image URLs from the assetPhotos collection
                  final List<String> photoUrls = [];
                  for (var photo in controller.assetPhotos) {
                    final url = photo.fotoAset;
                    if (url.isNotEmpty) {
                      photoUrls.add(url);
                      debugPrint("📸 Added photo URL: $url");
                    }
                  }

                  if (photoUrls.isEmpty) {
                    debugPrint("📸 No valid photo URLs found");
                    return;
                  }

                  debugPrint(
                    "📸 About to navigate to fullscreen viewer with ${photoUrls.length} photos",
                  );

                  // Navigate to full screen image viewer using GetX
                  Get.to(
                    () => FullScreenImageViewer(
                      imageUrls: photoUrls,
                      initialIndex: controller.currentPhotoIndex.value,
                    ),
                    fullscreenDialog: true,
                    transition: Transition.fade,
                  );

                  debugPrint("📸 Navigation initiated");
                } else {
                  debugPrint("📸 No valid current image URL");
                }
              } catch (e) {
                debugPrint("📸 ERROR in image tap handler: $e");
                Get.snackbar(
                  'Error',
                  'Failed to open image viewer',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                  duration: const Duration(seconds: 2),
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

                final imageUrl = controller.getCurrentPhotoUrl();
                if (imageUrl == null || imageUrl.isEmpty) {
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
                  imageUrl: imageUrl,
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
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Zoom indicator overlay
        Positioned(
          bottom: 16,
          right: 16,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.zoom_in, color: Colors.white, size: 24),
            ),
          ),
        ),

        // Navigation arrows - only show if we have more than 1 photo
        Obx(() {
          // Only show arrows if we have more than 1 photo AND they belong to the current package
          final bool shouldShowArrows =
              controller.assetPhotos.length > 1 &&
              (!controller.isPaket.value ||
                  (controller.isPaket.value &&
                      controller.assetPhotos.isNotEmpty &&
                      controller.assetPhotos.first.idAset ==
                          controller.paketId.value));

          return shouldShowArrows
              ? Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        onPressed: controller.previousPhoto,
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
                        onPressed: controller.nextPhoto,
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox.shrink();
        }),

        // Image indicators - only show if we have more than 1 photo
        Obx(() {
          // Only show indicators if we have more than 1 photo AND they belong to the current package
          final bool shouldShowIndicators =
              controller.assetPhotos.length > 1 &&
              (!controller.isPaket.value ||
                  (controller.isPaket.value &&
                      controller.assetPhotos.isNotEmpty &&
                      controller.assetPhotos.first.idAset ==
                          controller.paketId.value));

          return shouldShowIndicators
              ? Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.assetPhotos.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width:
                          index == controller.currentPhotoIndex.value ? 24 : 10,
                      height: 10,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color:
                            index == controller.currentPhotoIndex.value
                                ? AppColors.primary
                                : AppColors.primaryLight.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              )
              : SizedBox.shrink();
        }),

        // Photo counter
        Obx(() {
          // Only show counter if we have more than 1 photo AND they belong to the current package
          final bool shouldShowCounter =
              controller.assetPhotos.length > 1 &&
              (!controller.isPaket.value ||
                  (controller.isPaket.value &&
                      controller.assetPhotos.isNotEmpty &&
                      controller.assetPhotos.first.idAset ==
                          controller.paketId.value));

          return shouldShowCounter
              ? Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${controller.currentPhotoIndex.value + 1}/${controller.assetPhotos.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              : SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildAssetDetails() {
    final aset = controller.aset.value!;

    // Set jumlahUnit to 1 when isPaket is true
    if (controller.isPaket.value) {
      controller.jumlahUnit.value = 1;
    }

    return Container(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset name with availability indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  aset.nama ?? 'Aset tanpa nama',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tersedia',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Description with card styling - Wrapped in Container with consistent padding
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
                    aset.deskripsi ?? 'Tidak ada deskripsi untuk aset ini.',
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

          SizedBox(height: 24),

          // Package Details Card - Only shown when isPaket is true
          Obx(
            () =>
                controller.isPaket.value
                    ? Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
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
                                    Icons.inventory_2_outlined,
                                    color: AppColors.primary,
                                    size: 18,
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
                              SizedBox(height: 16),

                              // Package Items List
                              Obx(() {
                                if (controller.isPaketItemsLoaded.value ==
                                    false) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }

                                if (controller.paketItems.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Tidak ada item dalam paket ini',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children:
                                      controller.paketItems.map((item) {
                                        final asetData =
                                            item['aset']
                                                as Map<String, dynamic>?;
                                        final String asetId =
                                            asetData?['id'] ?? '';
                                        final String asetName =
                                            asetData?['nama'] ??
                                            'Aset tidak diketahui';
                                        final int quantity =
                                            item['kuantitas'] is int
                                                ? item['kuantitas']
                                                : 1;

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.borderLight,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Asset Image
                                              FutureBuilder<String?>(
                                                future: _getAsetImageUrl(
                                                  asetId,
                                                ),
                                                builder: (context, snapshot) {
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      debugPrint(
                                                        "📸 Package item image tapped - attempting to open fullscreen viewer for asset ID: $asetId",
                                                      );
                                                      try {
                                                        // Get all photos for this asset
                                                        final photos =
                                                            await controller
                                                                .asetProvider
                                                                .getAsetPhotos(
                                                                  asetId,
                                                                );
                                                        if (photos.isEmpty) {
                                                          debugPrint(
                                                            "📸 No photos found for asset ID: $asetId",
                                                          );
                                                          return;
                                                        }

                                                        // Extract valid photo URLs
                                                        final List<String>
                                                        photoUrls = [];
                                                        for (var photo
                                                            in photos) {
                                                          final url =
                                                              photo.fotoAset;
                                                          if (url.isNotEmpty) {
                                                            photoUrls.add(url);
                                                            debugPrint(
                                                              "📸 Added photo URL: $url",
                                                            );
                                                          }
                                                        }

                                                        if (photoUrls.isEmpty) {
                                                          debugPrint(
                                                            "📸 No valid photo URLs found",
                                                          );
                                                          return;
                                                        }

                                                        debugPrint(
                                                          "📸 About to navigate to fullscreen viewer with ${photoUrls.length} photos",
                                                        );

                                                        // Navigate to full screen image viewer using GetX
                                                        Get.to(
                                                          () =>
                                                              FullScreenImageViewer(
                                                                imageUrls:
                                                                    photoUrls,
                                                                initialIndex: 0,
                                                              ),
                                                          fullscreenDialog:
                                                              true,
                                                          transition:
                                                              Transition.fade,
                                                        );

                                                        debugPrint(
                                                          "📸 Navigation initiated",
                                                        );
                                                      } catch (e) {
                                                        debugPrint(
                                                          "📸 ERROR in package item image tap handler: $e",
                                                        );
                                                        Get.snackbar(
                                                          'Error',
                                                          'Failed to open image viewer',
                                                          snackPosition:
                                                              SnackPosition
                                                                  .BOTTOM,
                                                          backgroundColor:
                                                              Colors
                                                                  .red
                                                                  .shade100,
                                                          colorText:
                                                              Colors
                                                                  .red
                                                                  .shade900,
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 60,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        color:
                                                            AppColors
                                                                .surfaceLight,
                                                      ),
                                                      child:
                                                          snapshot.connectionState ==
                                                                  ConnectionState
                                                                      .waiting
                                                              ? Center(
                                                                child: SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color:
                                                                        AppColors
                                                                            .primary,
                                                                  ),
                                                                ),
                                                              )
                                                              : snapshot.data !=
                                                                  null
                                                              ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                child: CachedNetworkImage(
                                                                  imageUrl:
                                                                      snapshot
                                                                          .data!,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  placeholder:
                                                                      (
                                                                        context,
                                                                        url,
                                                                      ) => Center(
                                                                        child: SizedBox(
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              20,
                                                                          child: CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            color:
                                                                                AppColors.primary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  errorWidget:
                                                                      (
                                                                        context,
                                                                        url,
                                                                        error,
                                                                      ) => Icon(
                                                                        Icons
                                                                            .image_not_supported_outlined,
                                                                        color:
                                                                            AppColors.textLight,
                                                                      ),
                                                                ),
                                                              )
                                                              : Icon(
                                                                Icons
                                                                    .image_not_supported_outlined,
                                                                color:
                                                                    AppColors
                                                                        .textLight,
                                                              ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(width: 12),

                                              // Asset Name and Quantity
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      asetName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors
                                                                .textPrimary,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      '$quantity unit',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors
                                                                .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    )
                    : SizedBox.shrink(),
          ),

          // Jumlah Unit card - Only shown when isPaket is false
          Obx(
            () =>
                controller.isPaket.value
                    ? SizedBox.shrink() // Hide the card when isPaket is true
                    : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
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
                                    Icons.inventory_2_outlined,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Jumlah Unit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              Row(
                                children: [
                                  // Decrease button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap:
                                          controller.jumlahUnit.value <= 1
                                              ? null
                                              : () {
                                                HapticFeedback.lightImpact();
                                                controller.decreaseUnit();
                                              },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.jumlahUnit.value <= 1
                                                  ? Colors.grey[200]
                                                  : Color(
                                                    0xFF92B4D7,
                                                  ).withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 20,
                                            color:
                                                controller.jumlahUnit.value <= 1
                                                    ? Colors.grey[400]
                                                    : Color(0xFF3A6EA5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Text field for manual input
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Obx(() {
                                        final textController =
                                            TextEditingController(
                                              text:
                                                  controller.jumlahUnit.value
                                                      .toString(),
                                            );
                                        // Posisi kursor di akhir teks
                                        textController.selection =
                                            TextSelection.fromPosition(
                                              TextPosition(
                                                offset:
                                                    textController.text.length,
                                              ),
                                            );

                                        return TextField(
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          controller: textController,
                                          onTap: () {
                                            // Pilih semua teks saat di-tap
                                            textController
                                                .selection = TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  textController.text.length,
                                            );
                                          },
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 12,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Color(0xFF3A6EA5),
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Color(0xFF3A6EA5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          onSubmitted: (value) {
                                            controller.updateUnitFromInput(
                                              value,
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                  ),

                                  // Increase button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap:
                                          controller.jumlahUnit.value >=
                                                  controller.maxUnit.value
                                              ? null
                                              : () {
                                                HapticFeedback.lightImpact();
                                                controller.increaseUnit();
                                              },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.jumlahUnit.value >=
                                                      controller.maxUnit.value
                                                  ? Colors.grey[200]
                                                  : Color(
                                                    0xFF92B4D7,
                                                  ).withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 20,
                                            color:
                                                controller.jumlahUnit.value >=
                                                        controller.maxUnit.value
                                                    ? Colors.grey[400]
                                                    : Color(0xFF3A6EA5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              // Maximum unit info
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Maksimal ${controller.maxUnit.value} unit',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Tooltip(
                                      message:
                                          'Jumlah unit yang tersedia untuk disewa',
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOptions() {
    final aset = controller.aset.value!;

    // Filter for hourly and daily options
    final hourlyOption = aset.satuanWaktuSewa.firstWhereOrNull(
      (element) =>
          element['nama_satuan_waktu']?.toString().toLowerCase().contains(
            'jam',
          ) ??
          false,
    );

    final dailyOption = aset.satuanWaktuSewa.firstWhereOrNull(
      (element) =>
          element['nama_satuan_waktu']?.toString().toLowerCase().contains(
            'hari',
          ) ??
          false,
    );

    // Count available options to handle the case when only one option is available
    final availableOptionsCount =
        (hourlyOption != null ? 1 : 0) + (dailyOption != null ? 1 : 0);

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
                    : SizedBox.shrink(),
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
                // Only show hourly option if it exists
                if (hourlyOption != null)
                  InkWell(
                    onTap: () {
                      // Only perform action if this is not already selected
                      if (controller.selectedSatuanWaktu.value?['id'] !=
                          hourlyOption['id']) {
                        HapticFeedback.lightImpact();
                        controller.selectSatuanWaktu(hourlyOption);
                      }
                    },
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                      // If this is the only option, also round bottom corners
                      bottom:
                          dailyOption == null
                              ? Radius.circular(16)
                              : Radius.zero,
                    ),
                    child: Obx(() {
                      bool isSelected =
                          controller.selectedSatuanWaktu.value?['id'] ==
                          hourlyOption['id'];

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primarySoft
                                  : AppColors.surface,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                            // If this is the only option, also round bottom corners
                            bottom:
                                dailyOption == null
                                    ? Radius.circular(16)
                                    : Radius.zero,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.primary.withOpacity(0.2)
                                        : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primary.withOpacity(0.3)
                                          : AppColors.borderLight,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.access_time_rounded,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
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
                                    'Sewa per Jam',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    controller.formatPrice(
                                      hourlyOption['harga'] ?? 0,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: isSelected ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.textOnPrimary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                // Add divider only if both options exist
                if (hourlyOption != null && dailyOption != null)
                  Divider(height: 1, thickness: 1, color: Colors.grey[200]),

                // Only show daily option if it exists
                if (dailyOption != null)
                  InkWell(
                    onTap: () {
                      // Only perform action if this is not already selected
                      if (controller.selectedSatuanWaktu.value?['id'] !=
                          dailyOption['id']) {
                        HapticFeedback.lightImpact();
                        controller.selectSatuanWaktu(dailyOption);
                      }
                    },
                    borderRadius: BorderRadius.vertical(
                      // If this is the only option, also round top corners
                      top:
                          hourlyOption == null
                              ? Radius.circular(16)
                              : Radius.zero,
                      bottom: Radius.circular(16),
                    ),
                    child: Obx(() {
                      bool isSelected =
                          controller.selectedSatuanWaktu.value?['id'] ==
                          dailyOption['id'];

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primarySoft
                                  : AppColors.surface,
                          borderRadius: BorderRadius.vertical(
                            // If this is the only option, also round top corners
                            top:
                                hourlyOption == null
                                    ? Radius.circular(16)
                                    : Radius.zero,
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.primary.withOpacity(0.2)
                                        : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primary.withOpacity(0.3)
                                          : AppColors.borderLight,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sewa per Hari',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    controller.formatPrice(
                                      dailyOption['harga'] ?? 0,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: isSelected ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.textOnPrimary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                // Show message when no options are available (should never happen, but just in case)
                if (availableOptionsCount == 0)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada opsi durasi tersedia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Silakan pilih aset lain yang memiliki opsi durasi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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

  Widget _buildDateSelection(BuildContext context) {
    return Container(
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
              Obx(
                () =>
                    controller.isDailyRental()
                        ? _buildInfoBadge('Harian')
                        : _buildInfoBadge('Per Jam'),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Show different UI based on rental type (hourly or daily)
          Obx(
            () =>
                controller.isDailyRental()
                    ? _buildDailyRentalDateSelection(context)
                    : _buildHourlyRentalDateSelection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF92B4D7).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3A6EA5),
        ),
      ),
    );
  }

  // Date selection for daily rentals
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

  // Date and time selection for hourly rentals
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
                            controller.selectedDate.value,
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
                            color: Color(0xFF92B4D7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF3A6EA5),
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
                            color: Colors.grey[900],
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
                                  color: Color(0xFF92B4D7).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  controller.formattedTimeRange.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3A6EA5),
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
                child: Obx(() => _buildTimeGrid()),
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
                                'Durasi: ${controller.duration.value} jam',
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
        ),
      ],
    );
  }

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
        rows.add(SizedBox(height: 8));
      }
    }

    return Column(children: rows);
  }

  Widget _buildTimeButton(int hour) {
    bool isSelected =
        controller.startHour.value <= hour && hour < controller.endHour.value;
    bool isDisabled = controller.isHourDisabled(hour);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            isDisabled
                ? null
                : () {
                  // Add haptic feedback when selecting an hour
                  HapticFeedback.selectionClick();
                  controller.selectHour(hour);
                },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 48,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Color(0xFF3A6EA5)
                    : isDisabled
                    ? Colors.grey[200]
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? Color(0xFF3A6EA5)
                      : isDisabled
                      ? Colors.grey[300]!
                      : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              controller.formatHour(hour),
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : isDisabled
                        ? Colors.grey[500]
                        : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar({required Function onTapPesan}) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.formatPrice(controller.totalPrice.value),
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
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () => onTapPesan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Pesan Sekarang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getAsetImageUrl(String asetId) async {
    try {
      if (asetId.isEmpty) return null;

      final photos = await controller.asetProvider.getAsetPhotos(asetId);
      if (photos.isNotEmpty && photos.first.fotoAset != null) {
        return photos.first.fotoAset;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading asset image: $e');
      return null;
    }
  }
}

// Full Screen Image Viewer Widget
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex =
        widget.initialIndex < widget.imageUrls.length ? widget.initialIndex : 0;
    pageController = PageController(initialPage: currentIndex);

    debugPrint("📸 FullScreenImageViewer initialized");
    debugPrint("📸 Images count: ${widget.imageUrls.length}");
    debugPrint("📸 Initial index: $currentIndex");

    // Log the first few URLs
    for (int i = 0; i < widget.imageUrls.length && i < 3; i++) {
      debugPrint("📸 Image URL $i: ${widget.imageUrls[i]}");
    }

    // Hide status bar for immersive view
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // Hide all system UI
    ).catchError((error) {
      debugPrint("📸 Error setting system UI mode: $error");
    });
  }

  @override
  void dispose() {
    // Restore status bar when exiting
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values, // Restore all system UI
    ).catchError((error) {
      debugPrint("📸 Error restoring system UI mode: $error");
    });

    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Ensure UI is restored on back button press
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Photo Gallery
              GestureDetector(
                onTap: () {
                  // Add tap functionality to close when tapping on image
                  Navigator.of(context).pop();
                },
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    final imageUrl = widget.imageUrls[index];
                    debugPrint("📸 Building image at index $index: $imageUrl");

                    return PhotoViewGalleryPageOptions(
                      imageProvider: CachedNetworkImageProvider(imageUrl),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 2.0,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: "photo_$index",
                      ),
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("📸 Error loading image: $error");
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white70,
                                  size: 50,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Gagal memuat gambar',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  itemCount: widget.imageUrls.length,
                  loadingBuilder:
                      (context, event) => Center(
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          child: CircularProgressIndicator(
                            value:
                                event == null
                                    ? 0
                                    : event.cumulativeBytesLoaded /
                                        (event.expectedTotalBytes ?? 1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  pageController: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                      debugPrint("📸 Page changed to index: $index");
                    });
                  },
                ),
              ),

              // Close button
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
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

              // Image counter
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${currentIndex + 1}/${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
