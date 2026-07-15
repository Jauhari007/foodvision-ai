class Meal {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnailUrl;
  final String? youtubeUrl;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.tags = const [],
    this.ingredients = const [],
    this.measures = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measures dynamically
    final ingredientsList = <String>[];
    final measuresList = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final X = json['strMeasure$i'] as String?;

      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredientsList.add(ingredient.trim());
        measuresList.add(X?.trim() ?? '');
      }
    }

    // Extract tags
    final tagsString = json['strTags'] as String?;
    final tagsList = tagsString != null && tagsString.trim().isNotEmpty
        ? tagsString.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      thumbnailUrl: json['strMealThumb'],
      youtubeUrl: json['strYoutube'],
      tags: tagsList,
      ingredients: ingredientsList,
      measures: measuresList,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnailUrl,
      'strYoutube': youtubeUrl,
      'strTags': tags.join(','),
    };

    for (int i = 0; i < ingredients.length; i++) {
      data['strIngredient${i + 1}'] = ingredients[i];
      data['strMeasure${i + 1}'] = measures.length > i ? measures[i] : '';
    }

    return data;
  }
}
