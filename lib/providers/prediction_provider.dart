import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/mealdb_service.dart';

enum MealFetchStatus { idle, loading, success, error }

class PredictionProvider extends ChangeNotifier {
  final MealDbService _mealDbService = MealDbService();

  List<Meal> _meals = [];
  MealFetchStatus _status = MealFetchStatus.idle;
  String? _errorMessage;

  List<Meal> get meals => _meals;
  MealFetchStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == MealFetchStatus.loading;
  bool get isSuccess => _status == MealFetchStatus.success;
  bool get isError => _status == MealFetchStatus.error;

  /// Fetches recipes matching the given food name and notifies listeners of state updates.
  Future<void> fetchRecipesForFood(String foodName) async {
    _status = MealFetchStatus.loading;
    _errorMessage = null;
    _meals = [];
    notifyListeners();

    try {
      final results = await _mealDbService.searchMeals(foodName);
      _meals = results;
      _status = MealFetchStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = MealFetchStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Resets the provider state.
  void clear() {
    _meals = [];
    _status = MealFetchStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
