import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/nutrition_model.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  GenerativeModel? _model;

  GeminiService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
    }
  }

  /// Estimates the nutrition facts of a food name using Gemini API.
  Future<NutritionModel> getNutritionEstimate(String foodName) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'API Key Gemini belum disetel. Silakan jalankan aplikasi menggunakan '
        'flag --dart-define=GEMINI_API_KEY=KUNCI_ANDA untuk mengaktifkan fitur ini.'
      );
    }

    if (_model == null) {
      throw Exception('Model Gemini gagal diinisialisasi.');
    }

    final prompt = 'Berikan estimasi informasi nutrisi untuk 1 porsi makanan berikut: "$foodName". '
        'Hasil kembalian HARUS berupa objek JSON valid dengan struktur: '
        '{"calories": "X kcal", "protein": "Y g", "fat": "Z g", "carbohydrate": "A g", "fiber": "B g"}. '
        'Kembalikan HANYA JSON tersebut tanpa teks pembuka atau penutup markdown.';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Tidak mendapatkan respon dari Gemini.');
      }

      // Sanitize the response content just in case the model returns markdown code block
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.replaceAll(RegExp(r'^```json\s*|```$'), '').trim();
      }

      final Map<String, dynamic> jsonMap = json.decode(cleanJson);
      return NutritionModel.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Gagal mendapatkan estimasi nutrisi dari Gemini: $e');
    }
  }
}
