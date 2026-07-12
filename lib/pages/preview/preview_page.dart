import 'dart:io';

import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final File imageFile;

  const PreviewPage({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Gambar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Gambar berhasil dipilih dan di-crop.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}