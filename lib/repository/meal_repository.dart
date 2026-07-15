import '../core/errors/app_exception.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';

class MealRepository {
  final MealService _mealService = MealService();

  // Mapping label ML ke nama resep MealDB jika berbeda
  static const Map<String, String> _synonyms = {
    'satay': 'satee',
    'sate': 'satee',
    'fried rice': 'nasi goreng',
    'ramen': 'laksa',
    'sushi': 'sushi',
    'dumpling': 'wonton',
  };

  /// Mengambil detail resep berdasarkan nama makanan.
  /// Meneruskan [AppException] dari service layer tanpa membungkus ulang.
  Future<Meal?> getMealDetailByFoodName(String name) async {
    final cleanName = name.trim().toLowerCase();

    String searchKeyword = name;
    if (_synonyms.containsKey(cleanName)) {
      searchKeyword = _synonyms[cleanName]!;
    }

    // Step 1: Cari berdasarkan keyword (termasuk sinonim)
    String? idMeal = await _mealService.searchMealIdByName(searchKeyword);

    // Fallback ke nama asli jika sinonim gagal
    if ((idMeal == null || idMeal.isEmpty) && searchKeyword != name) {
      idMeal = await _mealService.searchMealIdByName(name);
    }

    // Progressive fallback: coba kata-kata individual
    if (idMeal == null || idMeal.isEmpty) {
      final words = cleanName.split(' ');
      if (words.length > 1) {
        for (final word in words) {
          if (word.length > 3 && word != 'with' && word != 'and') {
            idMeal = await _mealService.searchMealIdByName(word);
            if (idMeal != null && idMeal.isNotEmpty) break;
          }
        }
      }
    }

    if (idMeal == null || idMeal.isEmpty) return null;

    // Step 2: Lookup detail menggunakan ID
    final Map<String, dynamic>? rawMeal =
        await _mealService.lookupMealById(idMeal);

    if (rawMeal == null) return null;

    return Meal.fromJson(rawMeal);
  }

  /// Mencari daftar resep berdasarkan query.
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final List<dynamic> rawMeals =
          await _mealService.searchMealsByName(query);
      return rawMeals
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow; // Teruskan AppException agar UI dapat menampilkan pesan yang tepat
    } catch (e) {
      throw AppException.mealDbFailed(e.toString());
    }
  }
}
