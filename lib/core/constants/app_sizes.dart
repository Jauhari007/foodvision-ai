import 'package:flutter/material.dart';

class AppSizes {
  // Padding & Margin
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p28 = 28.0;
  static const double p30 = 30.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Icon Sizes
  static const double iconSmall = 14.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconExtraLarge = 36.0;
  static const double iconHuge = 80.0;
  static const double iconGigantic = 100.0;

  // Border Radius
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;

  // Heights & Widths
  static const double buttonHeightNormal = 48.0;
  static const double buttonHeightLarge = 55.0;
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 36.0;
  static const double imageContainerHeight = 260.0;
  static const double thumbSize = 100.0;

  // --- Responsive Helpers ---

  /// Lebar layar saat ini
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Tinggi layar saat ini
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Apakah layar dalam mode landscape
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Apakah perangkat tablet (lebar >= 600px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  /// Tinggi gambar preview proporsional terhadap layar.
  /// Portrait: 28% tinggi layar. Landscape: 55% lebar layar.
  /// Dibatasi min 160 dan max 360.
  static double imageHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLand = MediaQuery.orientationOf(context) == Orientation.landscape;
    final raw = isLand ? size.width * 0.38 : size.height * 0.28;
    return raw.clamp(160.0, 360.0);
  }

  /// Padding horizontal halaman — lebih besar di tablet.
  static double horizontalPadding(BuildContext context) =>
      isTablet(context) ? 32.0 : 20.0;

  /// Padding vertikal halaman
  static double verticalPadding(BuildContext context) =>
      isTablet(context) ? 24.0 : 16.0;

  /// Batas maksimum lebar konten — untuk tablet agar tidak terlalu lebar.
  static const double contentMaxWidth = 600.0;

  /// Ukuran icon home yang responsif
  static double homeIconSize(BuildContext context) =>
      isTablet(context) ? 80.0 : 72.0;
}
