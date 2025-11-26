import 'package:flutter/material.dart';

import '../models/meal_detail.dart';
import '../services/meal_api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService _apiService = MealApiService();
  late Future<MealDetail> _futureMeal;

  @override
  void initState() {
    super.initState();
    _futureMeal = _apiService.fetchMealDetail(widget.mealId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детален рецепт'),
      ),
      body: FutureBuilder<MealDetail>(
        future: _futureMeal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Се појави грешка: ${snapshot.error}'));
          }

          final meal = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // слика
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    meal.strMealThumb,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),

                // име
                Text(
                  meal.strMeal,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  '${meal.strCategory} • ${meal.strArea}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Состојки:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                ...meal.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          '${ing.name} - ${ing.measure}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 16),

                const Text(
                  'Инструкции:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal.strInstructions,
                  style: const TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 16),

                if (meal.strYoutube != null &&
                    meal.strYoutube!.trim().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YouTube линк:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        meal.strYoutube!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}