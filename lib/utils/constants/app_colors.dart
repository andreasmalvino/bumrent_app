import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0062CC);
  static const Color primaryLight = Color(0xFF4DA6FF);
  static const Color primarySoft = Color(0xFFE3F2FD); // Light blue, 10% opacity of primary
  
  // Secondary Colors
  static const Color secondary = Color(0xFF34C759);
  static const Color secondaryDark = Color(0xFF248A3D);
  static const Color secondaryLight = Color(0xFF5DDC7F);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  // Grayscale
  static const Color black = Color(0xFF000000);
  static const Color gray1 = Color(0xFF1C1C1E);
  static const Color gray2 = Color(0xFF2C2C2E);
  static const Color gray3 = Color(0xFF48484A);
  static const Color gray4 = Color(0xFF8E8E93);
  static const Color gray5 = Color(0xFFAEAEB2);
  static const Color gray6 = Color(0xFFC7C7CC);
  static const Color gray7 = Color(0xFFD1D1D6);
  static const Color gray8 = Color(0xFFE5E5EA);
  static const Color gray9 = Color(0xFFF2F2F7);
  static const Color white = Color(0xFFFFFFFF);
  
  // UI Elements
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderDark = Color(0xFFD1D1D6);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color disabled = Color(0xFFD1D1D6);
  static const Color placeholder = Color(0xFFC7C7CC);
  
  // Surface Colors (for cards, sheets, menus, etc.)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA); // Very light gray, slightly lighter than backgroundSecondary
  
  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF48484A);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFFAEAEB2);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF2F2F7);
  static const Color backgroundTertiary = Color(0xFFE5E5EA);
  
  // Overlay Colors
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayLight = Color(0x33FFFFFF);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  
  // Transparent
  static const Color transparent = Color(0x00000000);
  
  // Other UI Colors
  static const Color divider = Color(0xFFE5E5EA);
  static const Color highlight = Color(0x1A000000);
  static const Color splash = Color(0x1A000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondary, secondaryDark],
  );
}
