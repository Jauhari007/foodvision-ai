import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/errors/app_exception.dart';
import '../models/prediction_model.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  Uint8List? _modelBytes;

  bool get isModelLoaded => _modelBytes != null && _labels.isNotEmpty;

  List<String> get labels => _labels;

  /// Memuat model TFLite dan label dari assets.
  /// Melempar [AppException.modelNotLoaded] jika gagal.
  Future<void> loadModel() async {
    try {
      debugPrint("Loading model...");

      final byteData = await rootBundle.load('assets/models/food_classifier.tflite');
      _modelBytes = byteData.buffer.asUint8List();

      _interpreter = Interpreter.fromBuffer(_modelBytes!);
      debugPrint("Interpreter OK");

      final labelData = await rootBundle.loadString(
        'assets/labels/probability-labels-en.txt',
      );
      debugPrint("Label OK");

      _labels = labelData
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      debugPrint("Jumlah label: ${_labels.length}");
      debugPrint("MODEL BERHASIL DIMUAT");
      debugPrint("Input Shape : ${_interpreter!.getInputTensor(0).shape}");
      debugPrint("Output Shape: ${_interpreter!.getOutputTensor(0).shape}");
    } catch (e, s) {
      debugPrint("Gagal memuat model: $e");
      debugPrint(s.toString());
      // Reset state agar isModelLoaded tetap false
      _modelBytes = null;
      _labels = [];
      _interpreter = null;
      // Tidak melempar exception — UI akan menangani model belum siap
    }
  }

  /// Menjalankan seluruh pipeline inferensi di background Isolate.
  /// Melempar [AppException] dengan tipe spesifik sesuai kegagalan.
  Future<InferenceResult> inferImageInBackground(File imageFile) async {
    // Cek model sudah dimuat
    if (!isModelLoaded) {
      throw AppException.modelNotLoaded();
    }

    final imagePath = imageFile.path;
    final modelBytes = _modelBytes!;
    final labelsList = List<String>.from(_labels);

    try {
      return await Isolate.run(() {
        // 1. Decode image
        final Uint8List fileBytes;
        try {
          fileBytes = File(imagePath).readAsBytesSync();
        } catch (e) {
          throw AppException.imageBroken();
        }

        final image = img.decodeImage(fileBytes);
        if (image == null) {
          throw AppException.imageBroken();
        }

        // 2. Resize image
        final resized = img.copyResize(image, width: 192, height: 192);

        // 3. Preprocessing
        final inputBytes = Uint8List.fromList(resized.getBytes());

        // 4. Load Interpreter dari buffer di background Isolate
        final Interpreter interpreter;
        try {
          interpreter = Interpreter.fromBuffer(modelBytes);
        } catch (e) {
          throw AppException.inferenceFailed('Gagal membuat interpreter: $e');
        }

        // 5. Run inference
        final output = List.generate(
          1,
          (_) => List.filled(labelsList.length, 0),
        );

        try {
          interpreter.run(inputBytes, output);
        } catch (e) {
          interpreter.close();
          throw AppException.inferenceFailed('Gagal menjalankan inferensi: $e');
        }

        interpreter.close();

        final scores = (output.first as List)
            .map((e) => (e as num).toDouble())
            .toList();

        // 6. Extract Top Prediction
        int bestIndex = 0;
        double bestScore = scores[0];
        for (int i = 1; i < scores.length; i++) {
          if (scores[i] > bestScore) {
            bestScore = scores[i];
            bestIndex = i;
          }
        }
        final topPrediction = Prediction(
          label: labelsList[bestIndex],
          confidence: bestScore / 255.0,
        );

        // 7. Extract Top-5 Predictions
        final allPredictions = List.generate(scores.length, (index) {
          return Prediction(
            label: labelsList[index],
            confidence: scores[index] / 255.0,
          );
        });
        allPredictions.sort((a, b) => b.confidence.compareTo(a.confidence));
        final top5Predictions = allPredictions.take(5).toList();

        return InferenceResult(
          topPrediction: topPrediction,
          top5Predictions: top5Predictions,
        );
      });
    } on AppException {
      rethrow; // Teruskan AppException yang sudah dibuat di Isolate
    } catch (e) {
      throw AppException.inferenceFailed(e.toString());
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
