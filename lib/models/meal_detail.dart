class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});
}

class MealDetail {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String? strYoutube;
  final List<Ingredient> ingredients;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredients,
    this.strYoutube,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] ?? '') as String;
      final measure = (json['strMeasure$i'] ?? '') as String;

      if (name.trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: name.trim(),
          measure: measure.trim(),
        ));
      }
    }

    return MealDetail(
      idMeal: json['idMeal'] as String,
      strMeal: json['strMeal'] as String,
      strCategory: (json['strCategory'] ?? '') as String,
      strArea: (json['strArea'] ?? '') as String,
      strInstructions: (json['strInstructions'] ?? '') as String,
      strMealThumb: json['strMealThumb'] as String,
      strYoutube: json['strYoutube'] as String?,
      ingredients: ingredients,
    );
  }
}