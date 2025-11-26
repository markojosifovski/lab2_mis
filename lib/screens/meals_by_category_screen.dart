import 'package:flutter/material.dart';

import '../models/meal_summary.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_grid_item.dart';
import 'meal_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final String categoryName;

  const MealsByCategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  final MealApiService _apiService = MealApiService();
  late Future<List<MealSummary>> _futureMeals;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureMeals = _apiService.fetchMealsByCategory(widget.categoryName);
  }

  Future<void> _onSearchChanged(String value) async {
    setState(() {
      _searchQuery = value;
    });

    if (value.trim().isEmpty) {
      setState(() {
        _futureMeals =
            _apiService.fetchMealsByCategory(widget.categoryName);
      });
    } else {
      setState(() {
        _futureMeals = _apiService.searchMealsInCategory(
          widget.categoryName,
          value.trim(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Категорија: ${widget.categoryName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пребарај јадење',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MealSummary>>(
              future: _futureMeals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Се појави грешка: ${snapshot.error}'));
                }

                final meals = snapshot.data ?? [];

                if (meals.isEmpty) {
                  return const Center(child: Text('Нема јадења.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return MealGridItem(
                      meal: meal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(
                              mealId: meal.idMeal,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}