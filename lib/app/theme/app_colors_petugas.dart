import 'package:flutter/material.dart';

/// Kelas yang menyimpan konstanta warna untuk aplikasi petugas BUMDes
class AppColorsPetugas {
  // Warna Utama
  static const Color navyBlue = Color(0xFF05445E);
  static const Color blueGrotto = Color(0xFF189AB4);
  static const Color blueGreen = Color(0xFF75E6DA);
  static const Color babyBlue = Color(0xFFD4F1F4);
  static const Color babyBlueLight = Color(0xFFEAF6F6);
  static const Color babyBlueBright = Color(
    0xFFF5FCFC,
  ); // Extra light blue for subtle backgrounds

  // Gradien
  static List<Color> primaryGradient = [navyBlue, blueGrotto];

  static List<Color> secondaryGradient = [blueGrotto, blueGreen];

  // Warna Fungsional
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Warna Shadow
  static Color shadowColor = navyBlue.withOpacity(0.1);

  // Warna Text
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF718093);
  static const Color textLight = Color(0xFFAAAAAA);

  // Shade variations (lebih terang dan lebih gelap)
  static const Color navyBlueDark = Color(
    0xFF02323F,
  ); // Lebih gelap dari Navy Blue
  static const Color navyBlueLight = Color(
    0xFF0A5F7F,
  ); // Lebih terang dari Navy Blue

  static const Color blueGrottoDark = Color(
    0xFF107A8F,
  ); // Lebih gelap dari Blue Grotto
  static const Color blueGrottoLight = Color(
    0xFF24B6D3,
  ); // Lebih terang dari Blue Grotto

  static const Color blueGreenDark = Color(
    0xFF4ECDBE,
  ); // Lebih gelap dari Blue Green
  static const Color blueGreenLight = Color(
    0xFF9EEFEA,
  ); // Lebih terang dari Blue Green

  static const Color babyBlueDark = Color(
    0xFFAFE3EA,
  ); // Lebih gelap dari Baby Blue

  // Gradient colors
  static const List<Color> fullGradient = [
    navyBlue,
    blueGrotto,
    blueGreen,
    babyBlue,
  ];

  // Functional colors
  static const Color primary = navyBlue; // Primary color
  static const Color primaryLight = navyBlueLight;
  static const Color accent = blueGrotto; // Accent color
  static const Color accentLight = blueGrottoLight;
  static const Color background = babyBlue; // Background color
  static const Color surface = Colors.white; // Surface color for cards
  static const Color primarySoft =
      babyBlueLight; // Very light version for backgrounds

  // Functional status colors
  static Color successLight = success.withOpacity(0.1);
  static Color warningLight = warning.withOpacity(0.1);
  static Color errorLight = error.withOpacity(0.1);
  static Color infoLight = info.withOpacity(0.1);

  // Text colors
  static const Color textOnPrimary =
      Colors.white; // Text on primary color backgrounds
  static const Color textOnDark = Colors.white; // Text on dark backgrounds

  // Border and divider colors
  static const Color divider = Color(0xFFECEFF1);
  static const Color border = blueGreen;
  static Color shadow = navyBlue.withOpacity(0.1);
  static Color shadowStrong = navyBlue.withOpacity(0.2);

  // Button colors
  static const Color buttonPrimary = navyBlue;
  static const Color buttonSecondary = blueGrotto;
  static const Color buttonAccent = blueGreen;
  static const Color buttonText = Colors.white;
}
