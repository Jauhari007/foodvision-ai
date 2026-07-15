import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/errors/app_exception.dart';
import '../models/meal_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/constants.dart';

class RecipeCard extends StatelessWidget {
  final Future<Meal?>? recipeFuture;
  final String foodLabel;
  final VoidCallback onRetry;

  const RecipeCard({
    super.key,
    required this.recipeFuture,
    required this.foodLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (recipeFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Meal?>(
      future: recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _RecipeLoadingState();
        }

        if (snapshot.hasError) {
          return _RecipeErrorState(
            error: snapshot.error.toString(),
            onRetry: onRetry,
          );
        }

        final meal = snapshot.data;
        if (meal == null) {
          return _RecipeEmptyState(foodLabel: foodLabel);
        }

        return _RecipeSuccessState(meal: meal);
      },
    );
  }
}

class _RecipeLoadingState extends StatelessWidget {
  const _RecipeLoadingState();

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
          vertical: AppSizes.p32,
          horizontal: AppSizes.p16,
        ),
        child: Column(
          children: [
            SpinKitThreeBounce(
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(height: AppSizes.p16),
            Text(
              AppStrings.recipeLoading,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _RecipeErrorState({
    required this.error,
    required this.onRetry,
  });

  String _resolveMessage(String raw) {
    if (raw.contains(AppErrorType.noInternet.name)) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';
    }
    if (raw.contains(AppErrorType.timeout.name)) {
      return 'Permintaan ke MealDB habis waktu. Coba lagi dalam beberapa saat.';
    }
    if (raw.contains(AppErrorType.mealDbFailed.name)) {
      return 'Gagal mengambil data resep dari MealDB. Coba lagi.';
    }
    return AppStrings.connectionFailed;
  }

  IconData _resolveIcon(String raw) {
    if (raw.contains(AppErrorType.noInternet.name)) return Icons.wifi_off_rounded;
    if (raw.contains(AppErrorType.timeout.name)) return Icons.timer_off_outlined;
    return Icons.cloud_off;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          children: [
            Icon(
              _resolveIcon(error),
              color: AppColors.redAccent,
              size: 48,
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              _resolveMessage(error),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            SizedBox(
              height: AppSizes.buttonHeightMedium,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(AppStrings.retryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeEmptyState extends StatelessWidget {
  final String foodLabel;

  const _RecipeEmptyState({required this.foodLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p24,
          horizontal: AppSizes.p20,
        ),
        child: Column(
          children: [
            Icon(
              Icons.menu_book,
              color: AppColors.greyS400,
              size: 48,
            ),
            const SizedBox(height: AppSizes.p12),
            const Text(
              AppStrings.recipeNotFound,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSizes.p6),
            Text(
              AppStrings.recipeNotFoundDesc.replaceFirst('{label}', foodLabel),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.greyS600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeSuccessState extends StatelessWidget {
  final Meal meal;

  const _RecipeSuccessState({required this.meal});

  @override
  Widget build(BuildContext context) {
    final steps = meal.instructions
            ?.split(RegExp(r'\r?\n'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s.length > 3)
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.restaurant_menu,
              color: AppColors.primary,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.p8),
            Text(
              AppStrings.recipeDetailTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p12),
        Card(
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recipe Image Thumbnail & Main Meta
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (meal.thumbnailUrl != null)
                      Container(
                        width: AppSizes.thumbSize,
                        height: AppSizes.thumbSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          child: Image.network(
                            meal.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: AppSizes.thumbSize,
                        height: AppSizes.thumbSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                        child: const Icon(Icons.restaurant, color: AppColors.primary, size: 40),
                      ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          if (meal.category != null)
                            _buildInfoBadge(
                              icon: Icons.category_outlined,
                              label: meal.category!,
                              color: AppColors.primary,
                            ),
                          const SizedBox(height: AppSizes.p4),
                          if (meal.area != null)
                            _buildInfoBadge(
                              icon: Icons.public_outlined,
                              label: meal.area!,
                              color: AppColors.blue,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Tags
              if (meal.tags.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tags",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: meal.tags.map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: AppColors.primary.withAlpha((0.1 * 255).round()),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Ingredients and Measures Section
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bahan-bahan (Ingredients)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meal.ingredients.length,
                      itemBuilder: (context, idx) {
                        final ing = meal.ingredients[idx];
                        final meas = meal.measures.length > idx ? meal.measures[idx] : '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: AppSizes.p8),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              Text(
                                meas,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greyS600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Instructions Section
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Instruksi Pembuatan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    if (steps.isEmpty)
                      Text(
                        meal.instructions ?? "Tidak ada instruksi pembuatan.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: steps.length,
                        itemBuilder: (context, sIdx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.primary.withAlpha((0.1 * 255).round()),
                                  child: Text(
                                    "${sIdx + 1}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.p10),
                                Expanded(
                                  child: Text(
                                    steps[sIdx],
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textDark,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
