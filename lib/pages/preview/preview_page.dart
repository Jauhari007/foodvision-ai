import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/meal_model.dart';
import '../../models/nutrition_model.dart';
import '../../models/prediction_model.dart';
import '../../repository/meal_repository.dart';
import '../../services/gemini_service.dart';
import '../../widgets/nutrition_card.dart';
import '../../widgets/primary_prediction_card.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/scan_again_card.dart';
import '../../widgets/top_predictions_list.dart';
import '../../widgets/unrecognized_warning_card.dart';

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

  Future<Meal?>? _recipeFuture;
  Future<NutritionModel>? _nutritionFuture;

  @override
  void initState() {
    super.initState();
    // Validate confidence: Only load recipe and nutrition if confidence >= 60% (0.60)
    if (widget.prediction.confidence >= 0.6) {
      _loadRecipe();
      _loadNutrition();
    }
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

  Widget _buildUnrecognizedFoodState() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Captured Image Container
          Container(
            height: AppSizes.imageContainerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.r16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r16),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p20),

          // 2. Warning Card
          UnrecognizedWarningCard(confidence: widget.prediction.confidence),
          const SizedBox(height: AppSizes.p20),

          // 3. Scan Lagi Button
          SizedBox(
            height: AppSizes.buttonHeightLarge,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Scan Lagi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Captured Image Container
          Container(
            height: AppSizes.imageContainerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.r16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r16),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.p20),

          // 2. Primary TFLite Inference Results Card
          PrimaryPredictionCard(
            label: widget.prediction.label,
            confidence: widget.prediction.confidence,
          ),

          const SizedBox(height: AppSizes.p20),

          // 3. Top 5 Predictions Section
          if (widget.topPredictions.isNotEmpty) ...[
            TopPredictionsList(predictions: widget.topPredictions),
            const SizedBox(height: AppSizes.p20),
          ],

          // 4. Gemini Nutrition Facts Card (FutureBuilder)
          if (_nutritionFuture != null) ...[
            NutritionCard(
              nutritionFuture: _nutritionFuture,
              onRetry: _retryLoadNutrition,
            ),
            const SizedBox(height: AppSizes.p20),
          ],

          // 5. MealDB Recipe Details Section (FutureBuilder)
          if (_recipeFuture != null) ...[
            RecipeCard(
              recipeFuture: _recipeFuture,
              foodLabel: widget.prediction.label,
              onRetry: _retryLoadRecipe,
            ),
            const SizedBox(height: AppSizes.p20),
          ],

          // 6. Scan Again Action Card
          ScanAgainCard(
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecognized = widget.prediction.confidence >= 0.6;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          "Hasil Prediksi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: isRecognized ? _buildSuccessLayout() : _buildUnrecognizedFoodState(),
      ),
    );
  }
}