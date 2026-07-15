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
    final isTablet = AppSizes.isTablet(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? AppSizes.p32 : AppSizes.p24,
          horizontal: isTablet ? AppSizes.p32 : AppSizes.p20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_food,
              color: AppColors.redAccent,
              // Icon lebih kecil di layar sempit
              size: isTablet ? AppSizes.iconHuge : 60.0,
            ),
            const SizedBox(height: AppSizes.p16),
            const Text(
              AppStrings.unrecognizedTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.warningTitle,
            ),
            const SizedBox(height: AppSizes.p10),
            Text(
              AppStrings.unrecognizedDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.warningDescription,
            ),
            const SizedBox(height: AppSizes.p20),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.p16),
            const Text(
              AppStrings.confidenceTitle,
              style: AppTextStyles.labelMuted,
            ),
            const SizedBox(height: AppSizes.p8),
            // FittedBox mencegah overflow teks besar di layar kecil
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "$confidencePercent%",
                style: AppTextStyles.confidenceBig,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: AppColors.progressBackground,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.redAccent),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
