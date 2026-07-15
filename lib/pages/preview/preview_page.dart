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
    if (widget.prediction.confidence >= 0.6) {
      _loadRecipe();
      _loadNutrition();
    }
  }

  void _loadRecipe() {
    _recipeFuture =
        _mealRepository.getMealDetailByFoodName(widget.prediction.label);
  }

  void _loadNutrition() {
    _nutritionFuture =
        _geminiService.getNutritionEstimate(widget.prediction.label);
  }

  void _retryLoadRecipe() => setState(_loadRecipe);
  void _retryLoadNutrition() => setState(_loadNutrition);

  // ─── Image Widget ─────────────────────────────────────────────────────────

  Widget _buildImageContainer(double height) {
    return Container(
      height: height,
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
    );
  }

  // ─── Unrecognized State ────────────────────────────────────────────────────

  Widget _buildUnrecognizedFoodState(BuildContext context) {
    final isLandscape = AppSizes.isLandscape(context);
    final imgHeight = AppSizes.imageHeight(context);
    final hPad = AppSizes.horizontalPadding(context);

    final contentList = [
      UnrecognizedWarningCard(confidence: widget.prediction.confidence),
      const SizedBox(height: AppSizes.p16),
      SizedBox(
        height: AppSizes.buttonHeightLarge,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
            ),
          ),
          icon: const Icon(Icons.camera_alt),
          label: const Text(
            "Scan Lagi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];

    if (isLandscape) {
      // Landscape: gambar kiri, konten kanan
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: AppSizes.p16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildImageContainer(imgHeight),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: contentList,
              ),
            ),
          ],
        ),
      );
    }

    // Portrait
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageContainer(imgHeight),
          const SizedBox(height: AppSizes.p16),
          ...contentList,
        ],
      ),
    );
  }

  // ─── Success State ─────────────────────────────────────────────────────────

  Widget _buildSuccessLayout(BuildContext context) {
    final isLandscape = AppSizes.isLandscape(context);
    final imgHeight = AppSizes.imageHeight(context);
    final hPad = AppSizes.horizontalPadding(context);

    // Daftar kartu konten (sama untuk portrait & landscape)
    final cards = <Widget>[
      PrimaryPredictionCard(
        label: widget.prediction.label,
        confidence: widget.prediction.confidence,
      ),
      if (widget.topPredictions.isNotEmpty) ...[
        const SizedBox(height: AppSizes.p16),
        TopPredictionsList(predictions: widget.topPredictions),
      ],
      if (_nutritionFuture != null) ...[
        const SizedBox(height: AppSizes.p16),
        NutritionCard(
          nutritionFuture: _nutritionFuture,
          onRetry: _retryLoadNutrition,
        ),
      ],
      if (_recipeFuture != null) ...[
        const SizedBox(height: AppSizes.p16),
        RecipeCard(
          recipeFuture: _recipeFuture,
          foodLabel: widget.prediction.label,
          onRetry: _retryLoadRecipe,
        ),
      ],
      const SizedBox(height: AppSizes.p16),
      ScanAgainCard(onTap: () => Navigator.pop(context)),
    ];

    if (isLandscape) {
      // Landscape: gambar kiri pinned, konten kanan scrollable
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar di kiri — sticky
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(
                left: hPad,
                top: AppSizes.p16,
                bottom: AppSizes.p16,
              ),
              child: _buildImageContainer(imgHeight),
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          // Konten di kanan — scrollable
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.only(
                right: hPad,
                top: AppSizes.p16,
                bottom: AppSizes.p16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cards,
              ),
            ),
          ),
        ],
      );
    }

    // Portrait
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageContainer(imgHeight),
          const SizedBox(height: AppSizes.p16),
          ...cards,
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth * 2),
            child: SingleChildScrollView(
              child: isRecognized
                  ? _buildSuccessLayout(context)
                  : _buildUnrecognizedFoodState(context),
            ),
          ),
        ),
      ),
    );
  }
}