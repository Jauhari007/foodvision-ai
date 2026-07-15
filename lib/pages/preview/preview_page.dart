import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../services/ml/tflite_service.dart';
import '../../widgets/confidence_bar.dart';
import '../../models/meal_model.dart';
import '../../models/nutrition_model.dart';
import '../../repository/meal_repository.dart';
import '../../services/gemini_service.dart';
import 'widgets/top_predictions_list.dart';

class PreviewPage extends StatefulWidget {
  final File imageFile;
  final Prediction prediction;
  final List<Prediction> topPredictions;

  const PreviewPage({
    super.key,
    required this.imageFile,
    required this.prediction,
    this.topPredictions = const [],
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final MealRepository _mealRepository = MealRepository();
  final GeminiService _geminiService = GeminiService();

  late Future<Meal?> _recipeFuture;
  late Future<NutritionModel> _nutritionFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    _loadNutrition();
  }

  void _loadRecipe() {
    _recipeFuture = _mealRepository.getMealDetailByFoodName(widget.prediction.label);
  }

  void _loadNutrition() {
    _nutritionFuture = _geminiService.getNutritionEstimate(widget.prediction.label);
  }

  void _retryLoadRecipe() {
    setState(() {
      _loadRecipe();
    });
  }

  void _retryLoadNutrition() {
    setState(() {
      _loadNutrition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Hasil Prediksi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Captured Image Container
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.06 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    widget.imageFile,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Primary TFLite Inference Results Card
              Card(
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hasil Prediksi Utama",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.prediction.label,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Tingkat Kepercayaan (Confidence)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ConfidenceBar(
                        confidence: widget.prediction.confidence,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Top 5 Predictions Section
              if (widget.topPredictions.isNotEmpty) ...[
                TopPredictionsList(predictions: widget.topPredictions),
                const SizedBox(height: 20),
              ],

              // 4. Gemini Nutrition Facts Card (FutureBuilder)
              FutureBuilder<NutritionModel>(
                future: _nutritionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildNutritionLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _buildNutritionErrorState(snapshot.error.toString());
                  }

                  final nutrition = snapshot.data;
                  if (nutrition == null) {
                    return const SizedBox.shrink();
                  }

                  return _buildNutritionSuccessState(nutrition);
                },
              ),

              const SizedBox(height: 20),

              // 5. MealDB Recipe Details Section (FutureBuilder)
              FutureBuilder<Meal?>(
                future: _recipeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildRecipeLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _buildRecipeErrorState(snapshot.error.toString());
                  }

                  final meal = snapshot.data;
                  if (meal == null) {
                    return _buildRecipeEmptyState();
                  }

                  return _buildRecipeSuccessState(meal);
                },
              ),

              const SizedBox(height: 20),

              // 6. Scan Again Action Card
              Card(
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Ingin memindai makanan lain?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text(
                            "Scan Lagi",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Gemini Nutrition UI State Builders ---

  Widget _buildNutritionLoadingState() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            SpinKitThreeBounce(
              color: Colors.green,
              size: 24,
            ),
            SizedBox(height: 12),
            Text(
              "Mengestimasi informasi nutrisi via Gemini...",
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

  Widget _buildNutritionErrorState(String error) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orangeAccent,
              size: 36,
            ),
            const SizedBox(height: 8),
            const Text(
              "Estimasi Nutrisi Tertunda",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error.contains('API Key')
                  ? 'Kunci API Gemini tidak ditemukan. Jalankan dengan flag --dart-define=GEMINI_API_KEY=KUNCI_ANDA'
                  : error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: _retryLoadNutrition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text("Coba Lagi", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSuccessState(NutritionModel nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Estimasi Nilai Gizi (Gemini AI)",
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Highlighted Calories
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha((0.08 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "Energi:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nutrition.calories,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 2x2 Grid of other nutrients
                Row(
                  children: [
                    // Protein
                    Expanded(
                      child: _buildNutrientMiniCard(
                        title: "Protein",
                        value: nutrition.protein,
                        icon: Icons.fitness_center,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Carbs
                    Expanded(
                      child: _buildNutrientMiniCard(
                        title: "Karbohidrat",
                        value: nutrition.carbohydrate,
                        icon: Icons.grain,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Fat
                    Expanded(
                      child: _buildNutrientMiniCard(
                        title: "Lemak",
                        value: nutrition.fat,
                        icon: Icons.opacity,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Fiber
                    Expanded(
                      child: _buildNutrientMiniCard(
                        title: "Serat",
                        value: nutrition.fiber,
                        icon: Icons.spa,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "*Nilai di atas merupakan estimasi per 1 porsi saji.",
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.06 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha((0.15 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- MealDB Recipe UI State Builders ---

  Widget _buildRecipeLoadingState() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            SpinKitThreeBounce(
              color: Colors.green,
              size: 28,
            ),
            SizedBox(height: 16),
            Text(
              "Mencari informasi resep di MealDB...",
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

  Widget _buildRecipeErrorState(String error) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              "Koneksi Gagal",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: _retryLoadRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Coba Lagi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeEmptyState() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            Icon(
              Icons.menu_book,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              "Resep Tidak Ditemukan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Maaf, kami tidak berhasil menemukan resep pencocokan untuk '${widget.prediction.label}' di basis data MealDB.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSuccessState(Meal meal) {
    // Formatting the recipe instructions steps
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
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Detail Resep Makanan",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recipe Image Thumbnail & Main Meta
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (meal.thumbnailUrl != null)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.05 * 255).round()),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant, color: Colors.green, size: 40),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (meal.category != null)
                            _buildInfoBadge(
                              icon: Icons.category_outlined,
                              label: meal.category!,
                              color: Colors.green,
                            ),
                          const SizedBox(height: 4),
                          if (meal.area != null)
                            _buildInfoBadge(
                              icon: Icons.public_outlined,
                              label: meal.area!,
                              color: Colors.blue,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tags",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                color: Colors.green,
                              ),
                            ),
                            backgroundColor: Colors.green.withAlpha((0.1 * 255).round()),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bahan-bahan (Ingredients)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                meas,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Instruksi Pembuatan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (steps.isEmpty)
                      Text(
                        meal.instructions ?? "Tidak ada instruksi pembuatan.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
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
                                  backgroundColor: Colors.green.withAlpha((0.1 * 255).round()),
                                  child: Text(
                                    "${sIdx + 1}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    steps[sIdx],
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
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