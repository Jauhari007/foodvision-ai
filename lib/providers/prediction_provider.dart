import 'package:flutter/material.dart';

import '../core/errors/app_exception.dart';
import '../models/meal_model.dart';
import '../repository/meal_repository.dart';

enum MealFetchStatus { idle, loading, success, error }

class PredictionProvider extends ChangeNotifier {
  final MealRepository _mealRepository = MealRepository();

  List<Meal> _meals = [];
  MealFetchStatus _status = MealFetchStatus.idle;
  AppException? _error;

  List<Meal> get meals => _meals;
  MealFetchStatus get status => _status;
  AppException? get error => _error;

  bool get isLoading => _status == MealFetchStatus.loading;
  bool get isSuccess => _status == MealFetchStatus.success;
  bool get isError => _status == MealFetchStatus.error;

  /// Pesan error yang dapat ditampilkan ke user.
  String? get errorMessage => _error?.userMessage;

  /// Mengambil daftar resep yang cocok dengan nama makanan.
  Future<void> fetchRecipesForFood(String foodName) async {
    _status = MealFetchStatus.loading;
    _error = null;
    _meals = [];
    notifyListeners();

    try {
      final results = await _mealRepository.searchMeals(foodName);
      _meals = results;
      _status = MealFetchStatus.success;
    } on AppException catch (e) {
      _error = e;
      _status = MealFetchStatus.error;
    } catch (e) {
      _error = AppException.unknown(e.toString());
      _status = MealFetchStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Mereset state provider.
  void clear() {
    _meals = [];
    _status = MealFetchStatus.idle;
    _error = null;
    notifyListeners();
  }
}
