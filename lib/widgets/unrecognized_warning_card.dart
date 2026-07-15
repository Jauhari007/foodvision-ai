import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/constants.dart';

class UnrecognizedWarningCard extends StatelessWidget {
  final double confidence;

  const UnrecognizedWarningCard({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (confidence * 100).toStringAsFixed(2);
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p32,
          horizontal: AppSizes.p24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_food,
              color: AppColors.redAccent,
              size: AppSizes.iconHuge,
            ),
            const SizedBox(height: AppSizes.p20),
            const Text(
              AppStrings.unrecognizedTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.warningTitle,
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              AppStrings.unrecognizedDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.warningDescription,
            ),
            const SizedBox(height: AppSizes.p28),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.p20),
            const Text(
              AppStrings.confidenceTitle,
              style: AppTextStyles.labelMuted,
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              "$confidencePercent%",
              style: AppTextStyles.confidenceBig,
            ),
            const SizedBox(height: AppSizes.p8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: AppColors.progressBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.redAccent),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
