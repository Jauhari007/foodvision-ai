class PredictionResult {
  final String label;
  final double confidence;

  PredictionResult({
    required this.label,
    required this.confidence,
  });

  double get confidencePercentage => confidence * 100;
}