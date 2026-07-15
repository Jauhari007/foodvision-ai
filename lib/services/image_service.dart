import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../core/errors/app_exception.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Membuka galeri dan mengembalikan [File] gambar yang dipilih.
  /// Mengembalikan null jika user membatalkan.
  /// Melempar [AppException.galleryFailed] jika terjadi error.
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) return null; // User membatalkan — bukan error

      return await _cropImage(File(pickedFile.path));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.galleryFailed(e.toString());
    }
  }

  /// Membuka kamera dan mengembalikan [File] gambar yang diambil.
  /// Mengembalikan null jika user membatalkan.
  /// Melempar [AppException.cameraFailed] jika terjadi error.
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (pickedFile == null) return null; // User membatalkan — bukan error

      return await _cropImage(File(pickedFile.path));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.cameraFailed(e.toString());
    }
  }

  /// Membuka layar crop gambar.
  /// Mengembalikan null jika user membatalkan crop.
  Future<File?> _cropImage(File imageFile) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF4CAF50),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      // Crop gagal — kembalikan gambar original tanpa crop
      debugPrint('Crop image warning: $e');
      return imageFile;
    }
  }
}