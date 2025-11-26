import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final uri = Uri.parse('$_baseUrl/categories.php');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Неуспешно вчитување на категории');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final categoriesJson = data['categories'] as List<dynamic>;

    return categoriesJson
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final uri = Uri.parse('$_baseUrl/filter.php?c=$category');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Неуспешно вчитување на јадења');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final mealsJson = data['meals'] as List<dynamic>?;

    if (mealsJson == null) return [];

    return mealsJson
        .map((json) => MealSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Пребарување на јадења по име, но враќаме само оние од дадената категорија.
  Future<List<MealSummary>> searchMealsInCategory(
      String category, String query) async {
    if (query.trim().isEmpty) {
      return fetchMealsByCategory(category);
    }

    final uri = Uri.parse('$_baseUrl/search.php?s=$query');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Неуспешно пребарување на јадења');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final mealsJson = data['meals'] as List<dynamic>?;

    if (mealsJson == null) return [];

    // search.php враќа целосни објекти – ги филтрираме по category
    final filtered = mealsJson.where((m) {
      final map = m as Map<String, dynamic>;
      final cat = (map['strCategory'] ?? '') as String;
      return cat.toLowerCase() == category.toLowerCase();
    }).toList();

    return filtered
        .map((json) => MealSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Неуспешно вчитување на детал за јадење');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final mealsJson = data['meals'] as List<dynamic>;
    final mealJson = mealsJson.first as Map<String, dynamic>;

    return MealDetail.fromJson(mealJson);
  }

  Future<MealDetail> fetchRandomMeal() async {
    final uri = Uri.parse('$_baseUrl/random.php');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Неуспешно вчитување рандом јадење');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final mealsJson = data['meals'] as List<dynamic>;
    final mealJson = mealsJson.first as Map<String, dynamic>;

    return MealDetail.fromJson(mealJson);
  }
}