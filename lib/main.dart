import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/recipe_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const WeeklyMealPlanApp());
}

Future<void> _initializeApp() async {
  await Hive.initFlutter();
  await RecipeService.init();
  await RecipeService.seedRecipes();
}

class WeeklyMealPlanApp extends StatelessWidget {
  const WeeklyMealPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekly Meal Plan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late final List<Recipe> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = RecipeService.getAllRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return ListTile(
            title: Text(recipe.name),
            subtitle: Text('${recipe.category} · ${recipe.totalCalories} cal'),
            trailing: Text(
              'P: ${recipe.macros.protein.toStringAsFixed(0)}g  '
              'C: ${recipe.macros.carbs.toStringAsFixed(0)}g  '
              'F: ${recipe.macros.fat.toStringAsFixed(0)}g',
              style: const TextStyle(fontSize: 11),
            ),
          );
        },
      ),
    );
  }
}
