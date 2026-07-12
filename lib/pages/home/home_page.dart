import 'package:flutter/material.dart';
import 'dart:io';

import '../../services/image_service.dart';
import '../preview/preview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageService _imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'FoodVision AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              "FoodVision AI",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Identifikasi makanan menggunakan Artificial Intelligence.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                final navigator = Navigator.of(context);

                final File? image = await _imageService.pickImageFromGallery();

                if (!mounted || image == null) return;

                navigator.push(
                    MaterialPageRoute(
                    builder: (_) => PreviewPage(imageFile: image),
                    ),
                );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text("Pilih dari Galeri"),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                final navigator = Navigator.of(context);

                final File? image = await _imageService.pickImageFromCamera();

                if (!mounted || image == null) return;

                navigator.push(
                    MaterialPageRoute(
                    builder: (_) => PreviewPage(imageFile: image),
                    ),
                );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ambil dari Kamera"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}