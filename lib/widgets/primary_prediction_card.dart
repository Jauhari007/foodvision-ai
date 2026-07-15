import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/constants.dart';
import 'confidence_bar.dart';

class PrimaryPredictionCard extends StatelessWidget {
  final String label;
  final double confidence;

  const PrimaryPredictionCard({
    super.key,
    required this.label,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.mainResultTitle,
              style: AppTextStyles.mainPredictionHeader,
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              label,
              style: AppTextStyles.mainPredictionLabel,
            ),
            const SizedBox(height: AppSizes.p12),
            const Text(
              AppStrings.confidenceTitle,
              style: AppTextStyles.labelMuted,
            ),
            const SizedBox(height: AppSizes.p6),
            ConfidenceBar(
              confidence: confidence,
            ),
          ],
        ),
      ),
    );
  }
}
