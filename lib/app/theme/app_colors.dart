import 'package:flutter/material.dart';

/// App color palette for consistent theming
class AppColors {
  // Primary Color and its shades - based on new palette from image
  static const Color primary = Color(0xFF3A6EA5); // Medium blue from image
  static const Color primaryLight = Color(0xFF92B4D7); // Light blue from image
  static const Color primaryDark = Color(
    0xFF0E2A47,
  ); // Dark navy blue from image
  static const Color primarySoft = Color(
    0xFFE7EEF6,
  ); // Very light blue from image

  // Additional blue variations for UI elements
  static const Color blueGrey = Color(
    0xFF607D8B,
  ); // Blue-grey for subtle elements
  static const Color skyBlue = Color(0xFF4FC3F7); // Sky blue for highlights
  static const Color royalBlue = Color(
    0xFF1976D2,
  ); // Royal blue for important actions
  static const Color navyBlue = Color(
    0xFF0D47A1,
  ); // Navy blue for dark backgrounds
  static const Color teal = Color(
    0xFF009688,
  ); // Teal for variety in the blue palette

  // Accent colors - complementary to the new palette
  static const Color accent = Color(0xFF4C81B6); // Accent blue from image
  static const Color accentLight = Color(
    0xFFA3C1DE,
  ); // Lighter accent based on image
  static const Color accentDark = Color(
    0xFF244D7A,
  ); // Darker accent based on image

  // Category/Feature colors - for different sections of the app
  static const Color rental = Color(0xFF5C6BC0); // Indigo for rental features
  static const Color subscription = Color(
    0xFF26A69A,
  ); // Teal for subscription features
  static const Color billing = Color(
    0xFF66BB6A,
  ); // Green for billing/payment features
  static const Color notification = Color(0xFFEF5350); // Red for notifications
  static const Color analytics = Color(
    0xFF7E57C2,
  ); // Purple for analytics features

  // Background colors
  static const Color background = Color(0xFFF5F7FA); // Light background
  static const Color surface = Colors.white; // Surface color for cards
  static const Color surfaceLight = Color(
    0xFFF8FAFF,
  ); // Alternate surface color
  static const Color surfaceDark = Color(
    0xFFF0F2F5,
  ); // Darker surface for emphasis
  static const Color modalBackground = Color(
    0xFFFAFAFA,
  ); // Background for modal dialogs

  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50); // Primary text color
  static const Color textSecondary = Color(0xFF718093); // Secondary text color
  static const Color textLight = Color(
    0xFF95A5A6,
  ); // Light text color for hints
  static const Color textOnPrimary =
      Colors.white; // Text on primary color backgrounds
  static const Color textOnDark = Colors.white; // Text on dark backgrounds
  static const Color textLink = Color(0xFF2980B9); // Link text color

  // Functional colors
  static const Color success = Color(0xFF2ECC71); // Success/confirmation color
  static const Color warning = Color(0xFFF39C12); // Warning color
  static const Color error = Color(0xFFE74C3C); // Error color
  static const Color info = Color(0xFF3498DB); // Information color

  // Additional status colors
  static const Color pending = Color(0xFFFFA726); // Orange for pending status
  static const Color processing = Color(
    0xFF42A5F5,
  ); // Blue for processing status
  static const Color completed = Color(
    0xFF66BB6A,
  ); // Green for completed status
  static const Color cancelled = Color(0xFFEF5350); // Red for cancelled status
  static const Color neutral = Color(0xFF78909C); // Neutral for inactive status

  // Status colors with transparency
  static Color successLight = success.withOpacity(
    0.1,
  ); // Light success for backgrounds
  static Color warningLight = warning.withOpacity(
    0.1,
  ); // Light warning for backgrounds
  static Color errorLight = error.withOpacity(
    0.1,
  ); // Light error for backgrounds
  static Color infoLight = info.withOpacity(0.1); // Light info for backgrounds
  static Color pendingLight = pending.withOpacity(
    0.1,
  ); // Light pending for backgrounds
  static Color processingLight = processing.withOpacity(
    0.1,
  ); // Light processing for backgrounds
  static Color completedLight = completed.withOpacity(
    0.1,
  ); // Light completed for backgrounds
  static Color cancelledLight = cancelled.withOpacity(
    0.1,
  ); // Light cancelled for backgrounds
  static Color neutralLight = neutral.withOpacity(
    0.1,
  ); // Light neutral for backgrounds

  // Gradient colors based on image
  static const List<Color> primaryGradient = [
    Color(0xFF92B4D7), // Light blue
    Color(0xFF3A6EA5), // Medium blue
    Color(0xFF0E2A47), // Dark navy blue
  ];

  static const List<Color> accentGradient = [
    Color(0xFFA3C1DE), // Lighter blue
    Color(0xFF4C81B6), // Medium blue
  ];

  // Additional gradients for variety
  static const List<Color> sunsetGradient = [
    Color(0xFFFFA726), // Orange
    Color(0xFFEF5350), // Red
  ];

  static const List<Color> mintGradient = [
    Color(0xFF66BB6A), // Light green
    Color(0xFF26A69A), // Teal
  ];

  static const List<Color> skyGradient = [
    Color(0xFF4FC3F7), // Light blue
    Color(0xFF2196F3), // Blue
  ];

  // Divider and border colors
  static const Color divider = Color(0xFFECEFF1);
  static const Color border = Color(0xFFCFD8DC);
  static const Color borderLight = Color(0xFFE0E0E0); // Lighter border
  static const Color borderFocus = Color(
    0xFF90CAF9,
  ); // Border for focused elements

  // Shadow color
  static Color shadow = const Color(0xFF000000).withOpacity(0.1);
  static Color shadowStrong = const Color(
    0xFF000000,
  ).withOpacity(0.2); // Stronger shadow
  static Color shadowLight = const Color(
    0xFF000000,
  ).withOpacity(0.05); // Lighter shadow

  // Icon colors
  static const Color iconPrimary = Color(
    0xFF3A6EA5,
  ); // Medium blue from new palette
  static const Color iconLight = Color(
    0xFFA3C1DE,
  ); // Light blue from new palette
  static const Color iconGrey = Color(0xFF9E9E9E);
  static const Color iconSecondary = Color(0xFF607D8B); // Secondary icon color
  static const Color iconSuccess = Color(0xFF66BB6A); // Success icon color
  static const Color iconWarning = Color(0xFFFFA726); // Warning icon color
  static const Color iconError = Color(0xFFEF5350); // Error icon color

  // Button colors
  static const Color buttonText = Colors.white;
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonPrimary = Color(0xFF3A6EA5); // Primary button color
  static const Color buttonSecondary = Color(
    0xFF78909C,
  ); // Secondary button color
  static const Color buttonSuccess = Color(0xFF66BB6A); // Success button color
  static const Color buttonCancel = Color(0xFFEF5350); // Cancel button color

  // Input field colors
  static const Color inputBackground = Color(
    0xFFE7EEF6,
  ); // Very light blue from new palette
  static const Color inputBorder = Color(
    0xFFA3C1DE,
  ); // Light blue from new palette
  static const Color inputFocused = Color(
    0xFF3A6EA5,
  ); // Medium blue from new palette
  static const Color inputError = Color(
    0xFFFFCDD2,
  ); // Error background for inputs
  static const Color inputSuccess = Color(
    0xFFE8F5E9,
  ); // Success background for inputs

  // Chip and badge colors
  static const Color chipBackground = Color(
    0xFFE0E0E0,
  ); // Default chip background
  static const Color chipActive = Color(0xFFBBDEFB); // Active chip background
  static const Color badgeRed = Color(
    0xFFEF5350,
  ); // Red badge for notifications
  static const Color badgeGreen = Color(
    0xFF66BB6A,
  ); // Green badge for positive counts
  static const Color badgeBlue = Color(
    0xFF42A5F5,
  ); // Blue badge for neutral counts
  static const Color badgeGrey = Color(
    0xFF9E9E9E,
  ); // Grey badge for disabled items

  // Toggle and switch colors
  static const Color toggleActive = Color(0xFF3A6EA5); // Active toggle color
  static const Color toggleInactive = Color(
    0xFFBDBDBD,
  ); // Inactive toggle color
  static const Color switchTrackActive = Color(
    0xFFBBDEFB,
  ); // Active switch track
  static const Color switchTrackInactive = Color(
    0xFFE0E0E0,
  ); // Inactive switch track
}
