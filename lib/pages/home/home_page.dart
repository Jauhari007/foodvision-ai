import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../services/image_service.dart';
import '../../services/tflite_service.dart';
import '../../widgets/loading_dialog.dart';
import '../preview/preview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageService _imageService = ImageService();
  final TfliteService _tfliteService = TfliteService();
  bool _isPickingImage = false;
  bool _isModelLoading = true; // Flag saat model sedang dimuat

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() => _isModelLoading = true);
    await _tfliteService.loadModel();
    if (mounted) {
      setState(() => _isModelLoading = false);

      // Beri tahu user jika model gagal dimuat
      if (!_tfliteService.isModelLoaded) {
        ErrorHandler.showSnackBar(
          ScaffoldMessenger.of(context),
          'Model AI gagal dimuat. Coba tutup dan buka ulang aplikasi.',
          isWarning: true,
        );
      }
    }
  }

  /// Menampilkan loading dialog yang tidak bisa di-dismiss selama inferensi.
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );
  }

  /// Menangani pemilihan gambar dari galeri dengan error handling.
  Future<void> _onPickFromGallery() async {
    if (_isPickingImage) return;
    if (!_tfliteService.isModelLoaded) {
      ErrorHandler.showSnackBar(
        ScaffoldMessenger.of(context),
        AppException.modelNotLoaded().userMessage,
        isWarning: true,
      );
      return;
    }

    _isPickingImage = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final File? image = await _imageService.pickImageFromGallery();
      if (!mounted || image == null) return;

      await _runInferenceAndNavigate(navigator, messenger, image);
    } on AppException catch (e) {
      if (mounted) ErrorHandler.showFromException(messenger, e);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(
          messenger,
          AppException.unknown(e.toString()).userMessage,
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  /// Menangani pengambilan gambar dari kamera dengan error handling.
  Future<void> _onPickFromCamera() async {
    if (_isPickingImage) return;
    if (!_tfliteService.isModelLoaded) {
      ErrorHandler.showSnackBar(
        ScaffoldMessenger.of(context),
        AppException.modelNotLoaded().userMessage,
        isWarning: true,
      );
      return;
    }

    _isPickingImage = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final File? image = await _imageService.pickImageFromCamera();
      if (!mounted || image == null) return;

      await _runInferenceAndNavigate(navigator, messenger, image);
    } on AppException catch (e) {
      if (mounted) ErrorHandler.showFromException(messenger, e);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(
          messenger,
          AppException.unknown(e.toString()).userMessage,
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  /// Menjalankan inferensi di background dan navigasi ke PreviewPage.
  Future<void> _runInferenceAndNavigate(
    NavigatorState navigator,
    ScaffoldMessengerState scaffoldMessenger,
    File image,
  ) async {
    if (mounted) _showLoadingDialog(navigator.context);

    try {
      final result = await _tfliteService.inferImageInBackground(image);

      debugPrint("Inferensi selesai: ${result.topPrediction.label}");
      debugPrint(
        "Confidence: ${(result.topPrediction.confidence * 100).toStringAsFixed(2)}%",
      );

      if (mounted) navigator.pop(); // Tutup loading dialog

      navigator.push(
        MaterialPageRoute(
          builder: (_) => PreviewPage(
            imageFile: image,
            prediction: result.topPrediction,
            topPredictions: result.top5Predictions,
          ),
        ),
      );
    } on AppException catch (e) {
      if (mounted) navigator.pop(); // Tutup loading dialog
      if (mounted) ErrorHandler.showFromException(scaffoldMessenger, e);
    } catch (e) {
      if (mounted) navigator.pop();
      if (mounted) {
        ErrorHandler.showSnackBar(
          scaffoldMessenger,
          AppException.inferenceFailed(e.toString()).userMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.p30),

            const Icon(
              Icons.restaurant_menu,
              size: AppSizes.iconGigantic,
              color: AppColors.primary,
            ),

            const SizedBox(height: AppSizes.p20),

            const Text(
              AppStrings.appName,
              style: AppTextStyles.homeTitle,
            ),

            const SizedBox(height: AppSizes.p10),

            const Text(
              "Identifikasi makanan menggunakan Artificial Intelligence.",
              textAlign: TextAlign.center,
              style: AppTextStyles.homeSubtitle,
            ),

            // Status model sedang dimuat
            if (_isModelLoading) ...[
              const SizedBox(height: AppSizes.p16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Memuat model AI...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // Tombol Pilih dari Galeri
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightLarge,
              child: ElevatedButton.icon(
                onPressed: _isModelLoading ? null : _onPickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text(AppStrings.selectGallery),
              ),
            ),

            const SizedBox(height: AppSizes.p16),

            // Tombol Ambil dari Kamera
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightLarge,
              child: ElevatedButton.icon(
                onPressed: _isModelLoading ? null : _onPickFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text(AppStrings.takePhoto),
              ),
            ),

            const SizedBox(height: AppSizes.p30),
          ],
        ),
      ),
    );
  }
}