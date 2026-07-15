import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prediction_model.dart';
import '../providers/prediction_provider.dart';
import '../models/meal_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/constants.dart';

class TopPredictionsList extends StatelessWidget {
  final List<Prediction> predictions;

  const TopPredictionsList({
    super.key,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.p8),
            Expanded(
              child: Text(
                AppStrings.top5PredictionsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.p8,
              horizontal: AppSizes.p4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: predictions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                final confidencePercent = prediction.confidence * 100;

                final Color progressColor = prediction.confidence >= 0.75
                    ? AppColors.primary
                    : prediction.confidence >= 0.50
                        ? AppColors.orange
                        : AppColors.error;

                return InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  onTap: () => _showRecipeSheet(context, prediction.label),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p12,
                      vertical: AppSizes.p10,
                    ),
                    child: Row(
                      children: [
                        // Rank Indicator
                        CircleAvatar(
                          radius: 13,
                          backgroundColor:
                              AppColors.primary.withAlpha((0.1 * 255).round()),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.p10),

                        // Food Name & Confidence Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                // Mencegah overflow nama makanan panjang
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: AppSizes.p4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppSizes.r4),
                                      child: LinearProgressIndicator(
                                        value: prediction.confidence,
                                        minHeight: 5,
                                        backgroundColor:
                                            AppColors.progressBackground,
                                        valueColor: AlwaysStoppedAnimation(
                                            progressColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.p8),
                                  Text(
                                    "${confidencePercent.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: progressColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.p4),
                        // Tombol resep
                        IconButton(
                          icon: const Icon(
                            Icons.menu_book,
                            color: AppColors.primary,
                            size: AppSizes.iconMedium,
                          ),
                          tooltip: "Lihat Resep",
                          onPressed: () =>
                              _showRecipeSheet(context, prediction.label),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet resep dengan DraggableScrollableSheet agar bisa di-expand/collapse
  void _showRecipeSheet(BuildContext context, String foodName) {
    final provider = Provider.of<PredictionProvider>(context, listen: false);
    provider.fetchRecipesForFood(foodName);

    showModalBottomSheet(
      context: context,
      // isScrollControlled + DraggableScrollableSheet → tidak overflow keyboard
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<PredictionProvider>(
              builder: (context, prov, _) {
                return Column(
                  children: [
                    // Handle bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant, color: AppColors.primary),
                          const SizedBox(width: AppSizes.p8),
                          Expanded(
                            child: Text(
                              "Resep MealDB: $foodName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    const Divider(height: 1),
                    // Konten scrollable
                    Expanded(
                      child: _buildSheetContent(context, prov, scrollController),
                    ),
                    // Padding bottom agar aman dari navbar / keyboard
                    SizedBox(
                        height: MediaQuery.viewInsetsOf(context).bottom +
                            MediaQuery.paddingOf(context).bottom),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    PredictionProvider prov,
    ScrollController scrollController,
  ) {
    if (prov.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    if (prov.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.redAccent),
              const SizedBox(height: AppSizes.p12),
              Text(
                prov.errorMessage ?? 'Gagal mengambil resep.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (prov.meals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
              SizedBox(height: AppSizes.p12),
              Text(
                "Tidak ada resep ditemukan di MealDB.",
                style: TextStyle(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p8,
      ),
      itemCount: prov.meals.length,
      itemBuilder: (context, index) {
        final meal = prov.meals[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: AppSizes.p6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p12,
              vertical: AppSizes.p4,
            ),
            leading: meal.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                    child: Image.network(
                      meal.thumbnailUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : const Icon(Icons.restaurant),
            title: Text(
              meal.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${meal.category ?? 'Tanpa Kategori'} | ${meal.area ?? 'Asal Khas'}",
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () {
              Navigator.pop(context);
              _showRecipeDetailDialog(context, meal);
            },
          ),
        );
      },
    );
  }

  void _showRecipeDetailDialog(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          title: Text(
            meal.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          content: LayoutBuilder(
            builder: (context, constraints) {
              // Tinggi konten dialog dibatasi agar tidak overflow layar
              final maxH = MediaQuery.sizeOf(context).height * 0.55;
              return SizedBox(
                width: constraints.maxWidth,
                height: maxH,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (meal.thumbnailUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          child: Image.network(
                            meal.thumbnailUrl!,
                            width: double.infinity,
                            // Tinggi thumbnail proporsional
                            height: (MediaQuery.sizeOf(context).width * 0.5)
                                .clamp(140.0, 220.0),
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, _) => const SizedBox(),
                          ),
                        ),
                      const SizedBox(height: AppSizes.p12),
                      if (meal.category != null || meal.area != null)
                        Text(
                          "Kategori: ${meal.category ?? ''} (${meal.area ?? ''})",
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: AppSizes.p12),
                      const Text(
                        "Instruksi Pembuatan:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p6),
                      Text(
                        meal.instructions ?? "Tidak ada instruksi.",
                        style: const TextStyle(height: 1.5, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}
