import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
List<int> get inputShape => _interpreter!.getInputTensor(0).shape;

List<int> get outputShape => _interpreter!.getOutputTensor(0).shape;

TensorType get inputType => _interpreter!.getInputTensor(0).type;

TensorType get outputType => _interpreter!.getOutputTensor(0).type;

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
    debugPrint(
        "Input Shape : ${_interpreter!.getInputTensor(0).shape}");

    debugPrint(
        "Output Shape: ${_interpreter!.getOutputTensor(0).shape}");

    debugPrint(
        "Input Type : ${_interpreter!.getInputTensor(0).type}");

    debugPrint(
        "Output Type: ${_interpreter!.getOutputTensor(0).type}");
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrint(s.toString());
  }
}
}