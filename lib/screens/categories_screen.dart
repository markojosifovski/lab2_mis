import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/meal_api_service.dart';
import '../widgets/category_card.dart';
import 'meals_by_category_screen.dart';
import 'meal_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final MealApiService _apiService = MealApiService();
  late Future<List<Category>> _futureCategories;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureCategories = _apiService.fetchCategories();
  }

  void _openRandomMeal() async {
    try {
      final randomMeal = await _apiService.fetchRandomMeal();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: randomMeal.idMeal),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка при вчитување рандом рецепт: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепти по категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Рандом рецепт',
            onPressed: _openRandomMeal,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Пребарај категорија',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Се појави грешка: ${snapshot.error}'));
                }
                final categories = snapshot.data ?? [];

                final filtered = categories.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  return c.strCategory
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Нема таква категорија.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    return CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MealsByCategoryScreen(
                              categoryName: category.strCategory,
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