import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';

class AppBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Get navigation service to sync with drawer
    final navigationService = Get.find<NavigationService>();

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_rounded,
              activeIcon: Icons.home_rounded,
              label: 'Beranda',
              isSelected: navigationService.currentNavIndex.value == 0,
              onTap: () {
                if (navigationService.currentNavIndex.value != 0) {
                  onItemTapped(0);
                  navigationService.setNavIndex(0);
                  Get.offAllNamed(Routes.WARGA_DASHBOARD);
                }
              },
            ),
            _buildNavItem(
              context: context,
              icon: Icons.inventory_outlined,
              activeIcon: Icons.inventory_rounded,
              label: 'Sewa',
              isSelected: navigationService.currentNavIndex.value == 1,
              onTap: () {
                if (navigationService.currentNavIndex.value != 1) {
                  onItemTapped(1);
                  navigationService.toWargaSewa();
                }
              },
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
              isSelected: navigationService.currentNavIndex.value == 2,
              onTap: () {
                if (navigationService.currentNavIndex.value != 2) {
                  onItemTapped(2);
                  navigationService.toProfile();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Modern navigation item for bottom bar
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final tabWidth = MediaQuery.of(context).size.width / 3; // Changed to 3 tabs

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: tabWidth,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated scale effect when selected
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 0),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label with animated opacity
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.grey.shade500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
