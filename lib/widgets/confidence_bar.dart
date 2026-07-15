import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class ConfidenceBar extends StatelessWidget {
  final double confidence;

  const ConfidenceBar({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = confidence >= 0.75
        ? AppColors.primary
        : confidence >= 0.50
            ? AppColors.orange
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: confidence,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          backgroundColor: AppColors.borderGray,
          valueColor: AlwaysStoppedAnimation(progressColor),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          "${(confidence * 100).toStringAsFixed(2)}%",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}