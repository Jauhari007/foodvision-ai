import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/ml/tflite_service.dart';
import '../../../../providers/prediction_provider.dart';
import '../../../../models/meal_model.dart';

class TopPredictionsList extends StatelessWidget {
  final List<Prediction> predictions;

  const TopPredictionsList({
    super.key,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.analytics_outlined,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Top 5 Analisis Prediksi",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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

                // Color coding based on confidence levels
                final Color progressColor = prediction.confidence >= 0.75
                    ? Colors.green
                    : prediction.confidence >= 0.50
                        ? Colors.orange
                        : Colors.red;

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showRecipeSheet(context, prediction.label),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Rank Indicator
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.green.withAlpha((0.1 * 255).round()),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Food Name & Confidence Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: prediction.confidence,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation(
                                          progressColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "${confidencePercent.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: progressColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Action Icon (MealDB Preparation)
                        IconButton(
                          icon: const Icon(
                            Icons.menu_book,
                            color: Colors.green,
                            size: 20,
                          ),
                          tooltip: "Lihat Resep",
                          onPressed: () =>
                              _showRecipeSheet(context, prediction.label),
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

  void _showRecipeSheet(BuildContext context, String foodName) {
    // Start fetching recipes immediately
    final provider = Provider.of<PredictionProvider>(context, listen: false);
    provider.fetchRecipesForFood(foodName);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<PredictionProvider>(
          builder: (context, prov, child) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Resep MealDB: $foodName",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (prov.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                    )
                  else if (prov.isError)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Gagal mengambil resep: ${prov.errorMessage}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else if (prov.meals.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          "Tidak ada resep ditemukan di MealDB.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: prov.meals.length,
                        itemBuilder: (context, index) {
                          final meal = prov.meals[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: meal.thumbnailUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        meal.thumbnailUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : const Icon(Icons.restaurant),
                              title: Text(
                                meal.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${meal.category ?? 'Tanpa Kategori'} | ${meal.area ?? 'Asal Khas'}",
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.green,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _showRecipeDetailDialog(context, meal);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRecipeDetailDialog(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(meal.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (meal.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      meal.thumbnailUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                if (meal.category != null || meal.area != null)
                  Text(
                    "Kategori: ${meal.category ?? ''} (${meal.area ?? ''})",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 12),
                const Text(
                  "Instruksi Pembuatan:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(meal.instructions ?? "Tidak ada instruksi."),
              ],
            ),
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
