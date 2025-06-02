import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/warga/controllers/warga_dashboard_controller.dart';
import '../routes/app_routes.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

class AppDrawer extends StatelessWidget {
  final Function(int) onNavItemTapped;
  final VoidCallback onLogout;

  const AppDrawer({
    Key? key,
    required this.onNavItemTapped,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationService = Get.find<NavigationService>();

    // Safely check if WargaDashboardController is registered
    final bool hasController = Get.isRegistered<WargaDashboardController>();
    // Only find the controller if it's registered to avoid errors
    final controller =
        hasController ? Get.find<WargaDashboardController>() : null;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate drawer width - 80% of screen width but max 320pt
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = math.min(screenWidth * 0.8, 320.0);

    // Modern, narrower drawer with clean UI
    return Drawer(
      width: drawerWidth, // 80% width with 320pt max
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Compact, modern header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with white border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child:
                          hasController
                              ? Obx(() {
                                final avatarUrl = controller!.userAvatar.value;
                                return CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child:
                                        avatarUrl != null &&
                                                avatarUrl.isNotEmpty
                                            ? Image.network(
                                              avatarUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Text(
                                                  controller
                                                          .userName
                                                          .value
                                                          .isNotEmpty
                                                      ? controller
                                                          .userName
                                                          .value[0]
                                                          .toUpperCase()
                                                      : 'W',
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                );
                                              },
                                            )
                                            : Text(
                                              controller
                                                      .userName
                                                      .value
                                                      .isNotEmpty
                                                  ? controller.userName.value[0]
                                                      .toUpperCase()
                                                  : 'W',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                  ),
                                );
                              })
                              : CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(width: 16),
                    // User info with better typography
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          hasController
                              ? Obx(
                                () => Text(
                                  controller!.userName.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                              : const Text(
                                'Pengguna Warga',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          const SizedBox(height: 2),
                          hasController
                              ? Obx(
                                () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    controller!.userRole.value,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Warga',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
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

          // Menu items
          Expanded(
            child: Container(
              color: Colors.white,
              child: Obx(
                () => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),

                    // Navigation Section Label
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 8),
                      child: Text(
                        'NAVIGASI',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Navigation Items
                    _buildDrawerItem(
                      icon: Icons.home_rounded,
                      title: 'Beranda',
                      subtitle: 'Aksi cepat dan aset aktif',
                      isSelected: navigationService.currentNavIndex.value == 0,
                      onTap: () {
                        Navigator.pop(context);
                        if (navigationService.currentNavIndex.value != 0) {
                          navigationService.setNavIndex(0);
                          Get.offAllNamed(Routes.WARGA_DASHBOARD);
                        }
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.inventory_2_rounded,
                      title: 'Sewa Aset Saya',
                      subtitle: 'List sewa dan status',
                      isSelected: navigationService.currentNavIndex.value == 1,
                      onTap: () {
                        Navigator.pop(context);
                        if (navigationService.currentNavIndex.value != 1) {
                          navigationService.toWargaSewa();
                        }
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.person,
                      title: 'Profil Saya',
                      subtitle: 'Pengaturan akun dan profil',
                      isSelected: navigationService.currentNavIndex.value == 2,
                      onTap: () {
                        Navigator.pop(context);
                        if (navigationService.currentNavIndex.value != 2) {
                          navigationService.toProfile();
                        }
                      },
                    ),

                    const Divider(height: 32),

                    // Settings Section Label
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 8),
                      child: Text(
                        'PENGATURAN',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Settings Items
                    _buildDrawerItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Informasi dan bantuan',
                      showTrailing: false,
                      onTap: () {
                        Navigator.pop(context);
                        // Show about dialog
                        showAboutDialog(
                          context: context,
                          applicationName: 'BumRent App',
                          applicationVersion: '1.0.0',
                          applicationIcon: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          children: [
                            const Text(
                              'Aplikasi penyewaan dan berlangganan aset milik BUMDes untuk warga desa.',
                            ),
                          ],
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      subtitle: 'Keluar dari aplikasi',
                      iconColor: Colors.red.shade400,
                      showTrailing: false,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom copyright section with BumRent App logo
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2025 BumRent App',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern drawer menu item with subtitle
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    bool isSelected = false,
    bool showTrailing = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryLight.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color:
              iconColor ??
              (isSelected ? AppColors.primary : Colors.grey.shade700),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              )
              : null,
      trailing:
          showTrailing && isSelected
              ? Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              )
              : null,
      onTap: onTap,
    );
  }

  // Modern logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
