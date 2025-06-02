import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';

class PetugasBumdesBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const PetugasBumdesBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Aset',
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.category_outlined,
            activeIcon: Icons.category,
            label: 'Paket',
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart,
            label: 'Sewa',
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
        ],
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
    final primaryColor = AppColors.primary;
    final tabWidth = MediaQuery.of(context).size.width / 4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: SizedBox(
          width: tabWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicator line at top
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2,
                width: tabWidth * 0.5,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

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
                  size: 22,
                ),
              ),

              const SizedBox(height: 4),

              // Label with animated opacity
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.grey.shade500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
