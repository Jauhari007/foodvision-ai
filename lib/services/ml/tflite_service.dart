import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Prediction {
  final String label;
  final double confidence;

  Prediction({
    required this.label,
    required this.confidence,
  });
}

class TfliteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  List<int> get inputShape => _interpreter!.getInputTensor(0).shape;

  List<int> get outputShape => _interpreter!.getOutputTensor(0).shape;

  TensorType get inputType => _interpreter!.getInputTensor(0).type;

  TensorType get outputType => _interpreter!.getOutputTensor(0).type;

  List<String> get labels => _labels;

  Future<void> loadModel() async {
    try {
      debugPrint("Loading model...");

      _interpreter = await Interpreter.fromAsset(
        'assets/models/food_classifier.tflite',
      );

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
      debugPrint("Input Type : ${_interpreter!.getInputTensor(0).type}");
      debugPrint("Output Type: ${_interpreter!.getOutputTensor(0).type}");
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  Uint8List preprocessImage(File imageFile) {
    final bytes = imageFile.readAsBytesSync();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Gagal membaca gambar.");
    }

    final resized = img.copyResize(
      image,
      width: 192,
      height: 192,
    );

    return Uint8List.fromList(resized.getBytes());
  }

  Future<List<double>> inferImage(File imageFile) async {
    final input = preprocessImage(imageFile);

    final output = List.generate(
      1,
      (_) => List.filled(_labels.length, 0),
    );

    _interpreter!.run(input, output);

    return (output.first as List)
        .map((e) => (e as num).toDouble())
        .toList();
  }

    Prediction getTopPrediction(List<double> scores) {
    int bestIndex = 0;
    double bestScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    return Prediction(
      label: _labels[bestIndex],
      confidence: bestScore / 255.0,
    );
  }

  List<Prediction> getTop5Predictions(List<double> scores) {
    final predictions = List.generate(scores.length, (index) {
      return Prediction(
        label: _labels[index],
        confidence: scores[index] / 255.0,
      );
    });

    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    return predictions.take(5).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}