import '../models/meal_model.dart';
import '../services/meal_service.dart';

class MealRepository {
  final MealService _mealService = MealService();

  /// Fetches a meal recipe details by food name using chained API calls.
  /// 1. Searches for the food name to find the first matching meal's ID.
  /// 2. Looks up the full details using the retrieved ID.
  /// 3. Returns the parsed Meal model.
  Future<Meal?> getMealDetailByFoodName(String name) async {
    // Step 1: Search meal by name and get first idMeal
    final String? idMeal = await _mealService.searchMealIdByName(name);
    if (idMeal == null || idMeal.isEmpty) {
      return null;
    }

    // Step 2: Lookup details using the ID
    final Map<String, dynamic>? rawMeal = await _mealService.lookupMealById(idMeal);
    if (rawMeal == null) {
      return null;
    }

    // Step 3: Parse and return
    return Meal.fromJson(rawMeal);
  }

  /// Searches for meals matching the query and returns a list of parsed Meal models.
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final List<dynamic> rawMeals = await _mealService.searchMealsByName(query);
      return rawMeals
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar resep dari repositori: $e');
    }
  }
}
