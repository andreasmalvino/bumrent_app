import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app_bottom_navbar.dart';
import '../../../services/navigation_service.dart';
import '../../../routes/app_routes.dart';

/// A wrapper layout that provides a persistent bottom navigation bar
/// and a content area for warga user pages.
class WargaLayout extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const WargaLayout({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Access the navigation service
    final navigationService = Get.find<NavigationService>();

    // Single Scaffold that contains all components
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.grey.shade100,
      appBar: appBar,
      // Drawer configuration for proper overlay
      drawer: drawer,
      drawerEdgeDragWidth: 60, // Wider drag area for easier access
      drawerEnableOpenDragGesture: true,
      // Higher opacity ensures good contrast & visibility when drawer opens
      drawerScrimColor: Colors.black.withOpacity(0.6),
      // Main body content
      body: body,
      // Bottom navigation bar
      bottomNavigationBar: AppBottomNavbar(
        selectedIndex: navigationService.currentNavIndex.value,
        onItemTapped: (index) => _handleNavigation(index, navigationService),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  // Handle navigation for bottom navbar
  void _handleNavigation(int index, NavigationService navigationService) {
    if (navigationService.currentNavIndex.value == index) {
      return; // Don't do anything if already on this tab
    }

    navigationService.setNavIndex(index);

    // Navigate to the appropriate page
    switch (index) {
      case 0:
        Get.offAllNamed(Routes.WARGA_DASHBOARD);
        break;
      case 1:
        navigationService.toWargaSewa();
        break;
      case 2:
        navigationService.toProfile();
        break;
    }
  }
}
