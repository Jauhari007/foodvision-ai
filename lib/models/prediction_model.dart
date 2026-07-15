class Prediction {
  final String label;
  final double confidence;

  Prediction({
    required this.label,
    required this.confidence,
  });
}

class InferenceResult {
  final Prediction topPrediction;
  final List<Prediction> top5Predictions;

  InferenceResult({
    required this.topPrediction,
    required this.top5Predictions,
  });
}