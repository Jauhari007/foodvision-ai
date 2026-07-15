import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';

class MealDbService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Searches for meals matching the food name/query from MealDB API.
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        if (mealsJson == null) {
          return [];
        }

        return mealsJson
            .map((json) => Meal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal memuat resep: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi ke MealDB: $e');
    }
  }
}
