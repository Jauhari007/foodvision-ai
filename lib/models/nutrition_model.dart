class NutritionModel {
  final String calories;
  final String protein;
  final String fat;
  final String carbohydrate;
  final String fiber;

  NutritionModel({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.fiber,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      calories: json['calories'] ?? '0 kcal',
      protein: json['protein'] ?? '0 g',
      fat: json['fat'] ?? '0 g',
      carbohydrate: json['carbohydrate'] ?? '0 g',
      fiber: json['fiber'] ?? '0 g',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
      'fiber': fiber,
    };
  }
}
