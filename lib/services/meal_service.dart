import 'dart:convert';
import 'package:http/http.dart' as http;

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Searches for a list of meals matching the query name.
  Future<List<dynamic>> searchMealsByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(name)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['meals'] ?? [];
      } else {
        throw Exception('Gagal melakukan pencarian resep: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi saat pencarian MealDB: $e');
    }
  }

  /// Searches for a meal by its name and returns the `idMeal` of the first result if available.
  Future<String?> searchMealIdByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(name)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];

        if (meals != null && meals.isNotEmpty) {
          final firstMeal = meals.first as Map<String, dynamic>;
          return firstMeal['idMeal'] as String?;
        }
        return null;
      } else {
        throw Exception('Gagal melakukan pencarian resep: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi saat pencarian MealDB: $e');
    }
  }

  /// Looks up full meal details by its unique `idMeal`.
  Future<Map<String, dynamic>?> lookupMealById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];

        if (meals != null && meals.isNotEmpty) {
          return meals.first as Map<String, dynamic>;
        }
        return null;
      } else {
        throw Exception('Gagal memuat detail resep: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi saat lookup MealDB: $e');
    }
  }
}
