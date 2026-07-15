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
  bool _isModelLoading = true;

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
      if (!_tfliteService.isModelLoaded) {
        ErrorHandler.showSnackBar(
          ScaffoldMessenger.of(context),
          'Model AI gagal dimuat. Coba tutup dan buka ulang aplikasi.',
          isWarning: true,
        );
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );
  }

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
      if (mounted) ErrorHandler.showSnackBar(messenger, AppException.unknown(e.toString()).userMessage);
    } finally {
      _isPickingImage = false;
    }
  }

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
      if (mounted) ErrorHandler.showSnackBar(messenger, AppException.unknown(e.toString()).userMessage);
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _runInferenceAndNavigate(
    NavigatorState navigator,
    ScaffoldMessengerState scaffoldMessenger,
    File image,
  ) async {
    if (mounted) _showLoadingDialog(navigator.context);
    try {
      final result = await _tfliteService.inferImageInBackground(image);
      if (mounted) navigator.pop();
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
      if (mounted) navigator.pop();
      if (mounted) ErrorHandler.showFromException(scaffoldMessenger, e);
    } catch (e) {
      if (mounted) navigator.pop();
      if (mounted) ErrorHandler.showSnackBar(scaffoldMessenger, AppException.inferenceFailed(e.toString()).userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = AppSizes.isLandscape(context);
    final isTablet = AppSizes.isTablet(context);
    final hPad = AppSizes.horizontalPadding(context);

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              // Batas max-width agar di tablet konten tidak terlalu lebar
              constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: AppSizes.p20,
                ),
                child: isLandscape
                    ? _buildLandscapeLayout(isTablet)
                    : _buildPortraitLayout(isTablet),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Layout portrait: icon atas, tombol bawah
  Widget _buildPortraitLayout(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isTablet ? AppSizes.p32 : AppSizes.p20),
        Icon(
          Icons.restaurant_menu,
          size: AppSizes.homeIconSize(context),
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.p16),
        Text(AppStrings.appName, style: AppTextStyles.homeTitle),
        const SizedBox(height: AppSizes.p8),
        const Text(
          "Identifikasi makanan menggunakan Artificial Intelligence.",
          textAlign: TextAlign.center,
          style: AppTextStyles.homeSubtitle,
        ),
        if (_isModelLoading) _buildModelLoadingIndicator(),
        SizedBox(height: isTablet ? AppSizes.p48 : AppSizes.p40),
        _buildButtons(),
        const SizedBox(height: AppSizes.p20),
      ],
    );
  }

  /// Layout landscape: icon kiri, konten kanan
  Widget _buildLandscapeLayout(bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kiri: icon & title
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: isTablet ? 80 : 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.p12),
              Text(AppStrings.appName, style: AppTextStyles.homeTitle),
              const SizedBox(height: AppSizes.p6),
              const Text(
                "Identifikasi makanan\ndengan AI",
                textAlign: TextAlign.center,
                style: AppTextStyles.homeSubtitle,
              ),
              if (_isModelLoading) _buildModelLoadingIndicator(),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.p24),
        // Kanan: tombol
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: AppSizes.p12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(width: AppSizes.p8),
          Text(
            'Memuat model AI...',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppSizes.buttonHeightLarge,
          child: ElevatedButton.icon(
            onPressed: _isModelLoading ? null : _onPickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text(AppStrings.selectGallery),
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        SizedBox(
          height: AppSizes.buttonHeightLarge,
          child: ElevatedButton.icon(
            onPressed: _isModelLoading ? null : _onPickFromCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text(AppStrings.takePhoto),
          ),
        ),
      ],
    );
  }
}