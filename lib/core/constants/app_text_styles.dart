import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle dialogTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle dialogSubtitle = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle homeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle homeSubtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textMuted,
  );

  static const TextStyle warningTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static final TextStyle warningDescription = TextStyle(
    fontSize: 14,
    color: AppColors.greyS600,
    height: 1.5,
  );

  static const TextStyle labelMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  static const TextStyle confidenceBig = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.redAccent,
  );

  static final TextStyle mainPredictionHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.greyS600,
    letterSpacing: 0.5,
  );

  static const TextStyle mainPredictionLabel = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle bold15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyMediumMuted = TextStyle(
    fontSize: 13,
    color: Colors.black54,
  );
}
