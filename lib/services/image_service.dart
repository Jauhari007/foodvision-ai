import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) return null;

      return await cropImage(File(pickedFile.path));
    } catch (e) {
      throw Exception('Gagal mengambil gambar dari galeri: $e');
    }
  }

  Future<File?> pickImageFromCamera() async { 
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (pickedFile == null) return null;

      return await cropImage(File(pickedFile.path));
    } catch (e) {
      throw Exception('Gagal mengambil gambar dari kamera: $e');
    }
  }

  Future<File?> cropImage(File imageFile) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFF4CAF50),
          toolbarWidgetColor: Color(0xFFFFFFFF),
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile == null) return null;

    return File(croppedFile.path);
  }
}