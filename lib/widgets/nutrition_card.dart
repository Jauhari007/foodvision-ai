import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/errors/app_exception.dart';
import '../models/nutrition_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/constants.dart';
import 'nutrient_mini_card.dart';

class NutritionCard extends StatelessWidget {
  final Future<NutritionModel>? nutritionFuture;
  final VoidCallback onRetry;

  const NutritionCard({
    super.key,
    required this.nutritionFuture,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (nutritionFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<NutritionModel>(
      future: nutritionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _NutritionLoadingState();
        }

        if (snapshot.hasError) {
          return _NutritionErrorState(
            error: snapshot.error.toString(),
            onRetry: onRetry,
          );
        }

        final nutrition = snapshot.data;
        if (nutrition == null) {
          return const SizedBox.shrink();
        }

        return _NutritionSuccessState(nutrition: nutrition);
      },
    );
  }
}

class _NutritionLoadingState extends StatelessWidget {
  const _NutritionLoadingState();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.p24,
          horizontal: AppSizes.p16,
        ),
        child: Column(
          children: [
            SpinKitThreeBounce(
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(height: AppSizes.p12),
            Text(
              AppStrings.nutritionLoading,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _NutritionErrorState({
    required this.error,
    required this.onRetry,
  });

  String _resolveMessage(String raw) {
    // Jika error sudah berupa AppException, gunakan pesan user-friendly-nya
    if (raw.contains('AppException')) {
      if (raw.contains(AppErrorType.noInternet.name)) {
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      }
      if (raw.contains(AppErrorType.timeout.name)) {
        return 'Permintaan ke Gemini habis waktu. Coba lagi.';
      }
      if (raw.contains(AppErrorType.geminiFailed.name)) {
        return 'Estimasi nutrisi dari Gemini tidak tersedia saat ini.';
      }
    }
    if (raw.contains('API Key') || raw.contains('GEMINI_API_KEY')) {
      return AppStrings.nutritionErrorApiKey;
    }
    return AppStrings.nutritionErrorTitle;
  }

  @override
  Widget build(BuildContext context) {
    final displayError = _resolveMessage(error);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.orangeAccent,
              size: AppSizes.iconExtraLarge,
            ),
            const SizedBox(height: AppSizes.p8),
            const Text(
              AppStrings.nutritionErrorTitle,
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              displayError,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMediumMuted,
            ),
            const SizedBox(height: AppSizes.p12),
            SizedBox(
              height: AppSizes.buttonHeightSmall,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text(
                  AppStrings.retryLabel,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionSuccessState extends StatelessWidget {
  final NutritionModel nutrition;

  const _NutritionSuccessState({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.primary,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.p8),
            Text(
              AppStrings.geminiNutritionTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p12),
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              children: [
                // Highlighted Calories
                Container(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withAlpha((0.08 * 255).round()),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.orange,
                        size: AppSizes.iconLarge,
                      ),
                      const SizedBox(width: AppSizes.p8),
                      const Text(
                        AppStrings.energyLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Text(
                        nutrition.calories,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p16),
                
                // 2x2 Grid of other nutrients
                Row(
                  children: [
                    Expanded(
                      child: NutrientMiniCard(
                        title: AppStrings.proteinLabel,
                        value: nutrition.protein,
                        icon: Icons.fitness_center,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: NutrientMiniCard(
                        title: AppStrings.carbsLabel,
                        value: nutrition.carbohydrate,
                        icon: Icons.grain,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  children: [
                    Expanded(
                      child: NutrientMiniCard(
                        title: AppStrings.fatLabel,
                        value: nutrition.fat,
                        icon: Icons.opacity,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: NutrientMiniCard(
                        title: AppStrings.fiberLabel,
                        value: nutrition.fiber,
                        icon: Icons.spa,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p10),
                const Text(
                  AppStrings.servingNotice,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
