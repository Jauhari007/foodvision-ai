import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/errors/app_exception.dart';
import '../models/nutrition_model.dart';

class GeminiService {
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');
  // Jangan hardcode API key di sini — gunakan --dart-define=GEMINI_API_KEY=xxx
  static const String _fallbackApiKey = '';

  // gemini-flash-latest — dikonfirmasi tersedia untuk API key ini
  static const String _modelName = 'gemini-flash-latest';
  static const Duration _timeout = Duration(seconds: 20);

  String get _apiKey => _envApiKey.isNotEmpty ? _envApiKey : _fallbackApiKey;

  GenerativeModel? _model;

  GeminiService() {
    final key = _apiKey;
    if (key.isNotEmpty) {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: key,
      );
    }
  }

  /// Mengestimasi informasi nutrisi makanan menggunakan Gemini API.
  /// Melempar [AppException.geminiFailed] atau [AppException.noInternet] jika gagal.
  Future<NutritionModel> getNutritionEstimate(String foodName) async {
    if (_apiKey.isEmpty) {
      throw AppException.geminiFailed(
        'API Key tidak disetel. Gunakan --dart-define=GEMINI_API_KEY=KUNCI_ANDA',
      );
    }

    if (_model == null) {
      throw AppException.geminiFailed('Model Gemini gagal diinisialisasi.');
    }

    final prompt =
        'Berikan estimasi informasi nutrisi untuk 1 porsi makanan berikut: "$foodName". '
        'Hasil kembalian HARUS berupa objek JSON valid dengan struktur: '
        '{"calories": "X kcal", "protein": "Y g", "fat": "Z g", "carbohydrate": "A g", "fiber": "B g"}. '
        'Kembalikan HANYA JSON tersebut tanpa teks pembuka atau penutup markdown.';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!
          .generateContent(content)
          .timeout(_timeout);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw AppException.geminiFailed('Tidak mendapatkan respons dari Gemini.');
      }

      // Sanitize: hapus markdown code block jika ada
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.replaceAll(RegExp(r'^```json\s*|```$'), '').trim();
      }

      final Map<String, dynamic> jsonMap = json.decode(cleanJson);
      return NutritionModel.fromJson(jsonMap);
    } on AppException {
      rethrow;
    } on SocketException {
      throw AppException.noInternet();
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException')) {
        throw AppException.timeout('Gemini');
      }
      if (msg.contains('SocketException') || msg.contains('network')) {
        throw AppException.noInternet();
      }
      throw AppException.geminiFailed(msg);
    }
  }
}
