import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/weekly_planner_page.dart';
import 'pages/grocery_list_page.dart';
import 'pages/recipe_maker_page.dart';
import 'pages/ingredients_page.dart';
import 'pages/exercise_page.dart';
import 'services/hive_service.dart';
import 'services/grocery_service.dart';
import 'services/ingredient_service.dart';
import 'services/meal_plan_service.dart';
import 'services/recipe_service.dart';
import 'services/settings_service.dart';
import 'services/exercise_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const WeeklyMealPlanApp());
}

Future<void> _initializeApp() async {
  // HiveService must run first – it initialises Hive and opens all boxes.
  await HiveService.init();
  await RecipeService.init();
  await IngredientService.init();
  await MealPlanService.init();
  await GroceryService.init();
  await SettingsService.init();
  await ExerciseService.init();
  await RecipeService.seedRecipes();
  await IngredientService.seedIngredients();
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
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    WeeklyPlannerPage(),
    GroceryListPage(),
    RecipeMakerPage(),
    IngredientsPage(),
    ExercisePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Grocery',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.egg_alt_outlined),
            selectedIcon: Icon(Icons.egg_alt),
            label: 'Ingredients',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: 'Exercise',
          ),
        ],
      ),
    );
  }
}
