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
import '../../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class OrderSewaPaketView extends GetView<OrderSewaPaketController> {
  const OrderSewaPaketView({super.key});

  // Function to show confirmation dialog
  void showOrderConfirmationDialog() {
    final paket = controller.paket.value!;
    final PaketModel? paketModel = paket is PaketModel ? paket : null;
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
                                paketModel?.nama ?? controller.getPaketNama(paket) ?? 'Paket tanpa nama',
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

                    // Total price info
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
                        side: BorderSide(color: AppColors.primary),
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
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () {
                                Get.back();
                                controller.submitOrder();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isSubmitting.value
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
                                'Pesan',
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
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: handleBackButtonPress,
        ),
        title: Text(
          'Pesan Paket',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : controller.paket.value == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Paket tidak ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Silakan kembali dan pilih paket lain',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: handleBackButtonPress,
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
                          child: Text('Kembali'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopSection(),
                        _buildPaketDetails(),
                        _buildPriceOptions(),
                        _buildDateSelection(context),
                        SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
      ),
      bottomSheet: Obx(
        () => controller.isLoading.value || controller.paket.value == null
            ? SizedBox.shrink()
            : _buildBottomBar(onTapPesan: showOrderConfirmationDialog),
      ),
    );
  }

  // Build top section with paket images
  Widget _buildTopSection() {
    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Photo gallery
          Obx(
            () => controller.isPhotosLoading.value
                ? Center(child: CircularProgressIndicator())
                : controller.paketImages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada foto',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : PhotoViewGallery.builder(
                        scrollPhysics: BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: CachedNetworkImageProvider(
                              controller.paketImages[index],
                            ),
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2,
                            heroAttributes: PhotoViewHeroAttributes(
                              tag: 'paket_image_$index',
                            ),
                          );
                        },
                        itemCount: controller.paketImages.length,
                        loadingBuilder: (context, event) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        backgroundDecoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        pageController: PageController(),
                      ),
          ),

          // Gradient overlay at the top for back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build paket details section
  Widget _buildPaketDetails() {
    final paket = controller.paket.value!;
    final PaketModel? paketModel = paket is PaketModel ? paket : null;

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paket name and availability badge
          Row(
            children: [
              Expanded(
                child: Text(
                  paketModel?.nama ?? controller.getPaketNama(paket) ?? 'Paket tanpa nama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Description
          Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            paketModel?.deskripsi ?? controller.getPaketDeskripsi(paket) ?? 'Tidak ada deskripsi untuk paket ini.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
    / /   B u i l d   p r i c e   o p t i o n s   s e c t i o n  
     W i d g e t   _ b u i l d P r i c e O p t i o n s ( )   {  
         f i n a l   p a k e t   =   c o n t r o l l e r . p a k e t . v a l u e ! ;  
         f i n a l   P a k e t M o d e l ?   p a k e t M o d e l   =   p a k e t   i s   P a k e t M o d e l   ?   p a k e t   :   n u l l ;  
         f i n a l   s a t u a n W a k t u S e w a   =   p a k e t M o d e l ? . s a t u a n W a k t u S e w a   ? ?   c o n t r o l l e r . g e t P a k e t S a t u a n W a k t u S e w a ( p a k e t ) ;  
  
         r e t u r n   C o n t a i n e r (  
             p a d d i n g :   E d g e I n s e t s . a l l ( 1 6 ) ,  
             c o l o r :   C o l o r s . w h i t e ,  
             m a r g i n :   E d g e I n s e t s . o n l y ( t o p :   8 ) ,  
             c h i l d :   C o l u m n (  
                 c r o s s A x i s A l i g n m e n t :   C r o s s A x i s A l i g n m e n t . s t a r t ,  
                 c h i l d r e n :   [  
                     T e x t (  
                         ' P i l i h   D u r a s i ' ,  
                         s t y l e :   T e x t S t y l e (  
                             f o n t S i z e :   1 6 ,  
                             f o n t W e i g h t :   F o n t W e i g h t . w 6 0 0 ,  
                             c o l o r :   A p p C o l o r s . t e x t P r i m a r y ,  
                         ) ,  
                     ) ,  
                     S i z e d B o x ( h e i g h t :   1 6 ) ,  
  
                     / /   P r i c e   o p t i o n s   g r i d  
                     G r i d V i e w . b u i l d e r (  
                         s h r i n k W r a p :   t r u e ,  
                         p h y s i c s :   N e v e r S c r o l l a b l e S c r o l l P h y s i c s ( ) ,  
                         g r i d D e l e g a t e :   S l i v e r G r i d D e l e g a t e W i t h F i x e d C r o s s A x i s C o u n t (  
                             c r o s s A x i s C o u n t :   2 ,  
                             c h i l d A s p e c t R a t i o :   2 . 5 ,  
                             c r o s s A x i s S p a c i n g :   1 2 ,  
                             m a i n A x i s S p a c i n g :   1 2 ,  
                         ) ,  
                         i t e m C o u n t :   s a t u a n W a k t u S e w a . l e n g t h ,  
                         i t e m B u i l d e r :   ( c o n t e x t ,   i n d e x )   {  
                             f i n a l   o p t i o n   =   s a t u a n W a k t u S e w a [ i n d e x ] ;  
                             f i n a l   i s S e l e c t e d   =   c o n t r o l l e r . s e l e c t e d S a t u a n W a k t u . v a l u e   ! =   n u l l   & &  
                                     c o n t r o l l e r . s e l e c t e d S a t u a n W a k t u . v a l u e ! [ ' i d ' ]   = =   o p t i o n [ ' i d ' ] ;  
  
                             r e t u r n   G e s t u r e D e t e c t o r (  
                                 o n T a p :   ( )   = >   c o n t r o l l e r . s e l e c t S a t u a n W a k t u ( o p t i o n ) ,  
                                 c h i l d :   A n i m a t e d C o n t a i n e r (  
                                     d u r a t i o n :   D u r a t i o n ( m i l l i s e c o n d s :   2 0 0 ) ,  
                                     d e c o r a t i o n :   B o x D e c o r a t i o n (  
                                         c o l o r :   i s S e l e c t e d   ?   A p p C o l o r s . p r i m a r y   :   C o l o r s . w h i t e ,  
                                         b o r d e r R a d i u s :   B o r d e r R a d i u s . c i r c u l a r ( 1 2 ) ,  
                                         b o r d e r :   B o r d e r . a l l (  
                                             c o l o r :   i s S e l e c t e d   ?   A p p C o l o r s . p r i m a r y   :   A p p C o l o r s . b o r d e r L i g h t ,  
                                             w i d t h :   1 ,  
                                         ) ,  
                                     ) ,  
                                     p a d d i n g :   E d g e I n s e t s . s y m m e t r i c ( h o r i z o n t a l :   1 6 ,   v e r t i c a l :   1 2 ) ,  
                                     c h i l d :   C o l u m n (  
                                         c r o s s A x i s A l i g n m e n t :   C r o s s A x i s A l i g n m e n t . s t a r t ,  
                                         m a i n A x i s A l i g n m e n t :   M a i n A x i s A l i g n m e n t . c e n t e r ,  
                                         c h i l d r e n :   [  
                                             T e x t (  
                                                 o p t i o n [ ' n a m a _ s a t u a n _ w a k t u ' ]   ? ?   ' D u r a s i ' ,  
                                                 s t y l e :   T e x t S t y l e (  
                                                     f o n t S i z e :   1 4 ,  
                                                     f o n t W e i g h t :   F o n t W e i g h t . w 5 0 0 ,  
                                                     c o l o r :   i s S e l e c t e d   ?   C o l o r s . w h i t e   :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                 ) ,  
                                             ) ,  
                                             S i z e d B o x ( h e i g h t :   4 ) ,  
                                             T e x t (  
                                                 c o n t r o l l e r . f o r m a t P r i c e ( d o u b l e . t r y P a r s e ( o p t i o n [ ' h a r g a ' ] . t o S t r i n g ( ) )   ? ?   0 ) ,  
                                                 s t y l e :   T e x t S t y l e (  
                                                     f o n t S i z e :   1 2 ,  
                                                     c o l o r :   i s S e l e c t e d   ?   C o l o r s . w h i t e . w i t h O p a c i t y ( 0 . 8 )   :   A p p C o l o r s . t e x t S e c o n d a r y ,  
                                                 ) ,  
                                             ) ,  
                                         ] ,  
                                     ) ,  
                                 ) ,  
                             ) ;  
                         } ,  
                     ) ,  
                 ] ,  
             ) ,  
         ) ;  
     }  
  
     / /   B u i l d   d a t e   s e l e c t i o n   s e c t i o n  
     W i d g e t   _ b u i l d D a t e S e l e c t i o n ( B u i l d C o n t e x t   c o n t e x t )   {  
         r e t u r n   O b x (  
             ( )   = >   c o n t r o l l e r . s e l e c t e d S a t u a n W a k t u . v a l u e   = =   n u l l  
                     ?   S i z e d B o x . s h r i n k ( )  
                     :   C o n t a i n e r (  
                             p a d d i n g :   E d g e I n s e t s . a l l ( 1 6 ) ,  
                             c o l o r :   C o l o r s . w h i t e ,  
                             m a r g i n :   E d g e I n s e t s . o n l y ( t o p :   8 ) ,  
                             c h i l d :   C o l u m n (  
                                 c r o s s A x i s A l i g n m e n t :   C r o s s A x i s A l i g n m e n t . s t a r t ,  
                                 c h i l d r e n :   [  
                                     T e x t (  
                                         c o n t r o l l e r . i s D a i l y R e n t a l ( )   ?   ' P i l i h   T a n g g a l '   :   ' P i l i h   W a k t u ' ,  
                                         s t y l e :   T e x t S t y l e (  
                                             f o n t S i z e :   1 6 ,  
                                             f o n t W e i g h t :   F o n t W e i g h t . w 6 0 0 ,  
                                             c o l o r :   A p p C o l o r s . t e x t P r i m a r y ,  
                                         ) ,  
                                     ) ,  
                                     S i z e d B o x ( h e i g h t :   1 6 ) ,  
  
                                     / /   D a t e   s e l e c t i o n   f o r   d a i l y   r e n t a l  
                                     i f   ( c o n t r o l l e r . i s D a i l y R e n t a l ( ) )  
                                         G e s t u r e D e t e c t o r (  
                                             o n T a p :   ( )   a s y n c   {  
                                                 / /   S h o w   d a t e   r a n g e   p i c k e r  
                                                 f i n a l   n o w   =   D a t e T i m e . n o w ( ) ;  
                                                 f i n a l   i n i t i a l S t a r t D a t e   =   c o n t r o l l e r . s e l e c t e d S t a r t D a t e . v a l u e   ? ?   n o w ;  
                                                 f i n a l   i n i t i a l E n d D a t e   =   c o n t r o l l e r . s e l e c t e d E n d D a t e . v a l u e   ? ?   n o w . a d d ( D u r a t i o n ( d a y s :   1 ) ) ;  
  
                                                 f i n a l   D a t e T i m e R a n g e ?   p i c k e d   =   a w a i t   s h o w D a t e R a n g e P i c k e r (  
                                                     c o n t e x t :   c o n t e x t ,  
                                                     i n i t i a l D a t e R a n g e :   D a t e T i m e R a n g e ( s t a r t :   i n i t i a l S t a r t D a t e ,   e n d :   i n i t i a l E n d D a t e ) ,  
                                                     f i r s t D a t e :   n o w ,  
                                                     l a s t D a t e :   n o w . a d d ( D u r a t i o n ( d a y s :   3 6 5 ) ) ,  
                                                     b u i l d e r :   ( c o n t e x t ,   c h i l d )   {  
                                                         r e t u r n   T h e m e (  
                                                             d a t a :   T h e m e D a t a . l i g h t ( ) . c o p y W i t h (  
                                                                 c o l o r S c h e m e :   C o l o r S c h e m e . l i g h t (  
                                                                     p r i m a r y :   A p p C o l o r s . p r i m a r y ,  
                                                                     o n P r i m a r y :   C o l o r s . w h i t e ,  
                                                                     s u r f a c e :   C o l o r s . w h i t e ,  
                                                                     o n S u r f a c e :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                 ) ,  
                                                                 d i a l o g B a c k g r o u n d C o l o r :   C o l o r s . w h i t e ,  
                                                             ) ,  
                                                             c h i l d :   c h i l d ! ,  
                                                         ) ;  
                                                     } ,  
                                                 ) ;  
  
                                                 i f   ( p i c k e d   ! =   n u l l )   {  
                                                     c o n t r o l l e r . s e l e c t D a t e R a n g e ( p i c k e d . s t a r t ,   p i c k e d . e n d ) ;  
                                                 }  
                                             } ,  
                                             c h i l d :   C o n t a i n e r (  
                                                 p a d d i n g :   E d g e I n s e t s . a l l ( 1 6 ) ,  
                                                 d e c o r a t i o n :   B o x D e c o r a t i o n (  
                                                     b o r d e r :   B o r d e r . a l l ( c o l o r :   A p p C o l o r s . b o r d e r L i g h t ) ,  
                                                     b o r d e r R a d i u s :   B o r d e r R a d i u s . c i r c u l a r ( 1 2 ) ,  
                                                 ) ,  
                                                 c h i l d :   R o w (  
                                                     c h i l d r e n :   [  
                                                         I c o n ( I c o n s . c a l e n d a r _ t o d a y ,   c o l o r :   A p p C o l o r s . p r i m a r y ) ,  
                                                         S i z e d B o x ( w i d t h :   1 2 ) ,  
                                                         E x p a n d e d (  
                                                             c h i l d :   T e x t (  
                                                                 c o n t r o l l e r . f o r m a t t e d D a t e R a n g e . v a l u e . i s E m p t y  
                                                                         ?   ' P i l i h   t a n g g a l   s e w a '  
                                                                         :   c o n t r o l l e r . f o r m a t t e d D a t e R a n g e . v a l u e ,  
                                                                 s t y l e :   T e x t S t y l e (  
                                                                     f o n t S i z e :   1 4 ,  
                                                                     c o l o r :   c o n t r o l l e r . f o r m a t t e d D a t e R a n g e . v a l u e . i s E m p t y  
                                                                             ?   A p p C o l o r s . t e x t S e c o n d a r y  
                                                                             :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                 ) ,  
                                                             ) ,  
                                                         ) ,  
                                                         I c o n ( I c o n s . a r r o w _ f o r w a r d _ i o s ,   s i z e :   1 6 ,   c o l o r :   A p p C o l o r s . t e x t S e c o n d a r y ) ,  
                                                     ] ,  
                                                 ) ,  
                                             ) ,  
                                         )  
                                     / /   T i m e   s e l e c t i o n   f o r   h o u r l y   r e n t a l  
                                     e l s e  
                                         C o l u m n (  
                                             c r o s s A x i s A l i g n m e n t :   C r o s s A x i s A l i g n m e n t . s t a r t ,  
                                             c h i l d r e n :   [  
                                                 / /   D a t e   s e l e c t i o n  
                                                 G e s t u r e D e t e c t o r (  
                                                     o n T a p :   ( )   a s y n c   {  
                                                         f i n a l   n o w   =   D a t e T i m e . n o w ( ) ;  
                                                         f i n a l   i n i t i a l D a t e   =   c o n t r o l l e r . s e l e c t e d S t a r t D a t e . v a l u e   ? ?   n o w ;  
  
                                                         f i n a l   D a t e T i m e ?   p i c k e d   =   a w a i t   s h o w D a t e P i c k e r (  
                                                             c o n t e x t :   c o n t e x t ,  
                                                             i n i t i a l D a t e :   i n i t i a l D a t e ,  
                                                             f i r s t D a t e :   n o w ,  
                                                             l a s t D a t e :   n o w . a d d ( D u r a t i o n ( d a y s :   3 0 ) ) ,  
                                                             b u i l d e r :   ( c o n t e x t ,   c h i l d )   {  
                                                                 r e t u r n   T h e m e (  
                                                                     d a t a :   T h e m e D a t a . l i g h t ( ) . c o p y W i t h (  
                                                                         c o l o r S c h e m e :   C o l o r S c h e m e . l i g h t (  
                                                                             p r i m a r y :   A p p C o l o r s . p r i m a r y ,  
                                                                             o n P r i m a r y :   C o l o r s . w h i t e ,  
                                                                             s u r f a c e :   C o l o r s . w h i t e ,  
                                                                             o n S u r f a c e :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                         ) ,  
                                                                         d i a l o g B a c k g r o u n d C o l o r :   C o l o r s . w h i t e ,  
                                                                     ) ,  
                                                                     c h i l d :   c h i l d ! ,  
                                                                 ) ;  
                                                             } ,  
                                                         ) ;  
  
                                                         i f   ( p i c k e d   ! =   n u l l )   {  
                                                             c o n t r o l l e r . s e l e c t D a t e ( p i c k e d ) ;  
                                                         }  
                                                     } ,  
                                                     c h i l d :   C o n t a i n e r (  
                                                         p a d d i n g :   E d g e I n s e t s . a l l ( 1 6 ) ,  
                                                         d e c o r a t i o n :   B o x D e c o r a t i o n (  
                                                             b o r d e r :   B o r d e r . a l l ( c o l o r :   A p p C o l o r s . b o r d e r L i g h t ) ,  
                                                             b o r d e r R a d i u s :   B o r d e r R a d i u s . c i r c u l a r ( 1 2 ) ,  
                                                         ) ,  
                                                         c h i l d :   R o w (  
                                                             c h i l d r e n :   [  
                                                                 I c o n ( I c o n s . c a l e n d a r _ t o d a y ,   c o l o r :   A p p C o l o r s . p r i m a r y ) ,  
                                                                 S i z e d B o x ( w i d t h :   1 2 ) ,  
                                                                 E x p a n d e d (  
                                                                     c h i l d :   T e x t (  
                                                                         c o n t r o l l e r . s e l e c t e d D a t e . v a l u e . i s E m p t y  
                                                                                 ?   ' P i l i h   t a n g g a l   s e w a '  
                                                                                 :   c o n t r o l l e r . s e l e c t e d D a t e . v a l u e ,  
                                                                         s t y l e :   T e x t S t y l e (  
                                                                             f o n t S i z e :   1 4 ,  
                                                                             c o l o r :   c o n t r o l l e r . s e l e c t e d D a t e . v a l u e . i s E m p t y  
                                                                                     ?   A p p C o l o r s . t e x t S e c o n d a r y  
                                                                                     :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                         ) ,  
                                                                     ) ,  
                                                                 ) ,  
                                                                 I c o n ( I c o n s . a r r o w _ f o r w a r d _ i o s ,   s i z e :   1 6 ,   c o l o r :   A p p C o l o r s . t e x t S e c o n d a r y ) ,  
                                                             ] ,  
                                                         ) ,  
                                                     ) ,  
                                                 ) ,  
                                                 S i z e d B o x ( h e i g h t :   1 6 ) ,  
  
                                                 / /   T i m e   r a n g e   s e l e c t i o n  
                                                 c o n t r o l l e r . s e l e c t e d D a t e . v a l u e . i s E m p t y  
                                                         ?   S i z e d B o x . s h r i n k ( )  
                                                         :   C o l u m n (  
                                                                 c r o s s A x i s A l i g n m e n t :   C r o s s A x i s A l i g n m e n t . s t a r t ,  
                                                                 c h i l d r e n :   [  
                                                                     T e x t (  
                                                                         ' P i l i h   J a m ' ,  
                                                                         s t y l e :   T e x t S t y l e (  
                                                                             f o n t S i z e :   1 4 ,  
                                                                             f o n t W e i g h t :   F o n t W e i g h t . w 5 0 0 ,  
                                                                             c o l o r :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                         ) ,  
                                                                     ) ,  
                                                                     S i z e d B o x ( h e i g h t :   1 2 ) ,  
                                                                     R o w (  
                                                                         c h i l d r e n :   [  
                                                                             / /   S t a r t   t i m e  
                                                                             E x p a n d e d (  
                                                                                 c h i l d :   G e s t u r e D e t e c t o r (  
                                                                                     o n T a p :   ( )   a s y n c   {  
                                                                                         / /   S h o w   t i m e   p i c k e r   f o r   s t a r t   t i m e   ( 8 - 2 0 )  
                                                                                         f i n a l   L i s t < i n t >   a v a i l a b l e H o u r s   =   L i s t . g e n e r a t e ( 1 3 ,   ( i )   = >   i   +   8 ) ;  
                                                                                         f i n a l   i n t ?   s e l e c t e d H o u r   =   a w a i t   s h o w D i a l o g < i n t > (  
                                                                                             c o n t e x t :   c o n t e x t ,  
                                                                                             b u i l d e r :   ( c o n t e x t )   = >   S i m p l e D i a l o g (  
                                                                                                 t i t l e :   T e x t ( ' P i l i h   J a m   M u l a i ' ) ,  
                                                                                                 c h i l d r e n :   a v a i l a b l e H o u r s . m a p ( ( h o u r )   {  
                                                                                                     r e t u r n   S i m p l e D i a l o g O p t i o n (  
                                                                                                         o n P r e s s e d :   ( )   = >   N a v i g a t o r . p o p ( c o n t e x t ,   h o u r ) ,  
                                                                                                         c h i l d :   T e x t ( ' $ h o u r : 0 0 ' ) ,  
                                                                                                     ) ;  
                                                                                                 } ) . t o L i s t ( ) ,  
                                                                                             ) ,  
                                                                                         ) ;  
  
                                                                                         i f   ( s e l e c t e d H o u r   ! =   n u l l )   {  
                                                                                             / /   I f   e n d   t i m e   i s   a l r e a d y   s e l e c t e d   a n d   l e s s   t h a n   s t a r t   t i m e ,   r e s e t   i t  
                                                                                             i f   ( c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   >   0   & &  
                                                                                                     c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   < =   s e l e c t e d H o u r )   {  
                                                                                                 c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   =   - 1 ;  
                                                                                             }  
                                                                                             c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e   =   s e l e c t e d H o u r ;  
                                                                                             i f   ( c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   >   0 )   {  
                                                                                                 c o n t r o l l e r . s e l e c t T i m e R a n g e (  
                                                                                                     c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e ,  
                                                                                                     c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e ,  
                                                                                                 ) ;  
                                                                                             }  
                                                                                         }  
                                                                                     } ,  
                                                                                     c h i l d :   C o n t a i n e r (  
                                                                                         p a d d i n g :   E d g e I n s e t s . a l l ( 1 2 ) ,  
                                                                                         d e c o r a t i o n :   B o x D e c o r a t i o n (  
                                                                                             b o r d e r :   B o r d e r . a l l ( c o l o r :   A p p C o l o r s . b o r d e r L i g h t ) ,  
                                                                                             b o r d e r R a d i u s :   B o r d e r R a d i u s . c i r c u l a r ( 8 ) ,  
                                                                                         ) ,  
                                                                                         c h i l d :   R o w (  
                                                                                             m a i n A x i s A l i g n m e n t :   M a i n A x i s A l i g n m e n t . c e n t e r ,  
                                                                                             c h i l d r e n :   [  
                                                                                                 I c o n ( I c o n s . a c c e s s _ t i m e ,   s i z e :   1 6 ,   c o l o r :   A p p C o l o r s . p r i m a r y ) ,  
                                                                                                 S i z e d B o x ( w i d t h :   8 ) ,  
                                                                                                 T e x t (  
                                                                                                     c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e   <   0  
                                                                                                             ?   ' J a m   M u l a i '  
                                                                                                             :   ' $ { c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e } : 0 0 ' ,  
                                                                                                     s t y l e :   T e x t S t y l e (  
                                                                                                         f o n t S i z e :   1 4 ,  
                                                                                                         c o l o r :   c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e   <   0  
                                                                                                                 ?   A p p C o l o r s . t e x t S e c o n d a r y  
                                                                                                                 :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                                                     ) ,  
                                                                                                 ) ,  
                                                                                             ] ,  
                                                                                         ) ,  
                                                                                     ) ,  
                                                                                 ) ,  
                                                                             ) ,  
                                                                             S i z e d B o x ( w i d t h :   1 6 ) ,  
                                                                             / /   E n d   t i m e  
                                                                             E x p a n d e d (  
                                                                                 c h i l d :   G e s t u r e D e t e c t o r (  
                                                                                     o n T a p :   ( )   a s y n c   {  
                                                                                         i f   ( c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e   <   0 )   {  
                                                                                             G e t . s n a c k b a r (  
                                                                                                 ' P e r h a t i a n ' ,  
                                                                                                 ' P i l i h   j a m   m u l a i   t e r l e b i h   d a h u l u ' ,  
                                                                                                 s n a c k P o s i t i o n :   S n a c k P o s i t i o n . B O T T O M ,  
                                                                                                 b a c k g r o u n d C o l o r :   A p p C o l o r s . w a r n i n g ,  
                                                                                                 c o l o r T e x t :   C o l o r s . w h i t e ,  
                                                                                             ) ;  
                                                                                             r e t u r n ;  
                                                                                         }  
  
                                                                                         / /   S h o w   t i m e   p i c k e r   f o r   e n d   t i m e   ( s t a r t + 1   t o   2 1 )  
                                                                                         f i n a l   L i s t < i n t >   a v a i l a b l e H o u r s   =   L i s t . g e n e r a t e (  
                                                                                             2 1   -   c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e ,  
                                                                                             ( i )   = >   i   +   c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e   +   1 ,  
                                                                                         ) ;  
                                                                                         f i n a l   i n t ?   s e l e c t e d H o u r   =   a w a i t   s h o w D i a l o g < i n t > (  
                                                                                             c o n t e x t :   c o n t e x t ,  
                                                                                             b u i l d e r :   ( c o n t e x t )   = >   S i m p l e D i a l o g (  
                                                                                                 t i t l e :   T e x t ( ' P i l i h   J a m   S e l e s a i ' ) ,  
                                                                                                 c h i l d r e n :   a v a i l a b l e H o u r s . m a p ( ( h o u r )   {  
                                                                                                     r e t u r n   S i m p l e D i a l o g O p t i o n (  
                                                                                                         o n P r e s s e d :   ( )   = >   N a v i g a t o r . p o p ( c o n t e x t ,   h o u r ) ,  
                                                                                                         c h i l d :   T e x t ( ' $ h o u r : 0 0 ' ) ,  
                                                                                                     ) ;  
                                                                                                 } ) . t o L i s t ( ) ,  
                                                                                             ) ,  
                                                                                         ) ;  
  
                                                                                         i f   ( s e l e c t e d H o u r   ! =   n u l l )   {  
                                                                                             c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   =   s e l e c t e d H o u r ;  
                                                                                             c o n t r o l l e r . s e l e c t T i m e R a n g e (  
                                                                                                 c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e ,  
                                                                                                 c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e ,  
                                                                                             ) ;  
                                                                                         }  
                                                                                     } ,  
                                                                                     c h i l d :   C o n t a i n e r (  
                                                                                         p a d d i n g :   E d g e I n s e t s . a l l ( 1 2 ) ,  
                                                                                         d e c o r a t i o n :   B o x D e c o r a t i o n (  
                                                                                             b o r d e r :   B o r d e r . a l l ( c o l o r :   A p p C o l o r s . b o r d e r L i g h t ) ,  
                                                                                             b o r d e r R a d i u s :   B o r d e r R a d i u s . c i r c u l a r ( 8 ) ,  
                                                                                         ) ,  
                                                                                         c h i l d :   R o w (  
                                                                                             m a i n A x i s A l i g n m e n t :   M a i n A x i s A l i g n m e n t . c e n t e r ,  
                                                                                             c h i l d r e n :   [  
                                                                                                 I c o n ( I c o n s . a c c e s s _ t i m e ,   s i z e :   1 6 ,   c o l o r :   A p p C o l o r s . p r i m a r y ) ,  
                                                                                                 S i z e d B o x ( w i d t h :   8 ) ,  
                                                                                                 T e x t (  
                                                                                                     c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   <   0  
                                                                                                             ?   ' J a m   S e l e s a i '  
                                                                                                             :   ' $ { c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e } : 0 0 ' ,  
                                                                                                     s t y l e :   T e x t S t y l e (  
                                                                                                         f o n t S i z e :   1 4 ,  
                                                                                                         c o l o r :   c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   <   0  
                                                                                                                 ?   A p p C o l o r s . t e x t S e c o n d a r y  
                                                                                                                 :   A p p C o l o r s . t e x t P r i m a r y ,  
                                                                                                     ) ,  
                                                                                                 ) ,  
                                                                                             ] ,  
                                                                                         ) ,  
                                                                                     ) ,  
                                                                                 ) ,  
                                                                             ) ,  
                                                                         ] ,  
                                                                     ) ,  
                                                                 ] ,  
                                                             ) ,  
                                             ] ,  
                                         ) ,  
                                 ] ,  
                             ) ,  
                         ) ,  
         ) ;  
     }  
  
     / /   B u i l d   b o t t o m   b a r   w i t h   t o t a l   p r i c e   a n d   o r d e r   b u t t o n  
     W i d g e t   _ b u i l d B o t t o m B a r ( { r e q u i r e d   V o i d C a l l b a c k   o n T a p P e s a n } )   {  
         r e t u r n   C o n t a i n e r (  
             p a d d i n g :   E d g e I n s e t s . s y m m e t r i c ( h o r i z o n t a l :   1 6 ,   v e r t i c a l :   1 2 ) ,  
             d e c o r a t i o n :   B o x D e c o r a t i o n (  
                 c o l o r :   C o l o r s . w h i t e ,  
                 b o x S h a d o w :   [  
                     B o x S h a d o w (  
                         c o l o r :   C o l o r s . b l a c k . w i t h O p a c i t y ( 0 . 0 5 ) ,  
                         b l u r R a d i u s :   1 0 ,  
                         o f f s e t :   O f f s e t ( 0 ,   - 5 ) ,  
                     ) ,  
                 ] ,  
             ) ,  
             c h i l d :   S a f e A r e a (  
                 c h i l d :   R o w (  
                     c h i l d r e n :   [  
                         / /   P r i c e   i n f o  
                         E x p a n d e d (  
                             c h i l d :   C o l u m n (  
                                 c r o s s A x i s A l i g n m e n t :   C r o s s A x i s A l i g n m e n t . s t a r t ,  
                                 m a i n A x i s S i z e :   M a i n A x i s S i z e . m i n ,  
                                 c h i l d r e n :   [  
                                     T e x t (  
                                         ' T o t a l ' ,  
                                         s t y l e :   T e x t S t y l e (  
                                             f o n t S i z e :   1 2 ,  
                                             c o l o r :   A p p C o l o r s . t e x t S e c o n d a r y ,  
                                         ) ,  
                                     ) ,  
                                     O b x (  
                                         ( )   = >   T e x t (  
                                             c o n t r o l l e r . f o r m a t P r i c e ( c o n t r o l l e r . t o t a l P r i c e . v a l u e ) ,  
                                             s t y l e :   T e x t S t y l e (  
                                                 f o n t S i z e :   1 8 ,  
                                                 f o n t W e i g h t :   F o n t W e i g h t . b o l d ,  
                                                 c o l o r :   A p p C o l o r s . p r i m a r y ,  
                                             ) ,  
                                         ) ,  
                                     ) ,  
                                 ] ,  
                             ) ,  
                         ) ,  
                         / /   O r d e r   b u t t o n  
                         O b x (  
                             ( )   = >   E l e v a t e d B u t t o n (  
                                 o n P r e s s e d :   c o n t r o l l e r . s e l e c t e d S a t u a n W a k t u . v a l u e   = =   n u l l   | |  
                                                 ( c o n t r o l l e r . i s D a i l y R e n t a l ( )   & &  
                                                         ( c o n t r o l l e r . s e l e c t e d S t a r t D a t e . v a l u e   = =   n u l l   | |  
                                                                 c o n t r o l l e r . s e l e c t e d E n d D a t e . v a l u e   = =   n u l l ) )   | |  
                                                 ( ! c o n t r o l l e r . i s D a i l y R e n t a l ( )   & &  
                                                         ( c o n t r o l l e r . s e l e c t e d S t a r t D a t e . v a l u e   = =   n u l l   | |  
                                                                 c o n t r o l l e r . s e l e c t e d S t a r t T i m e . v a l u e   <   0   | |  
                                                                 c o n t r o l l e r . s e l e c t e d E n d T i m e . v a l u e   <   0 ) )  
                                         ?   n u l l  
                                         :   o n T a p P e s a n ,  
                                 s t y l e :   E l e v a t e d B u t t o n . s t y l e F r o m (  
                                     b a c k g r o u n d C o l o r :   A p p C o l o r s . p r i m a r y ,  
                                     p a d d i n g :   E d g e I n s e t s . s y m m e t r i c ( h o r i z o n t a l :   2 4 ,   v e r t i c a l :   1 2 ) ,  
                                     s h a p e :   R o u n d e d R e c t a n g l e B o r d e r (  
                                         b o r d e r R a d i u s :   B o r d e r R a d i u s . c i r c u l a r ( 1 2 ) ,  
                                     ) ,  
                                 ) ,  
                                 c h i l d :   T e x t (  
                                     ' P e s a n   S e k a r a n g ' ,  
                                     s t y l e :   T e x t S t y l e (  
                                         f o n t S i z e :   1 6 ,  
                                         f o n t W e i g h t :   F o n t W e i g h t . w 6 0 0 ,  
                                         c o l o r :   C o l o r s . w h i t e ,  
                                     ) ,  
                                 ) ,  
                             ) ,  
                         ) ,  
                     ] ,  
                 ) ,  
             ) ,  
         ) ;  
     }  
 