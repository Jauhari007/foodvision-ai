import 'package:flutter/material.dart';

class ConfidenceBar extends StatelessWidget {
  final double confidence;

  const ConfidenceBar({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: confidence,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation(
            confidence >= 0.75
                ? Colors.green
                : confidence >= 0.50
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${(confidence * 100).toStringAsFixed(2)}%",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}