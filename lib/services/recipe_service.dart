import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe.dart';
import 'recipe_seed.dart';

/// Manages recipe persistence using Hive.
class RecipeService {
  static const String _boxName = 'recipes';

  RecipeService._();

  static Box<String>? _box;

  /// Opens the Hive box. Must be called after [Hive.initFlutter].
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _openBox {
    assert(_box != null && _box!.isOpen,
        'RecipeService.init() must be called before use.');
    return _box!;
  }

  // ── Seeding ──────────────────────────────────────────────────────────────

  /// Populates the database with the 27 seed recipes if it is currently empty.
  ///
  /// Safe to call on every app launch – it is a no-op once the database
  /// contains at least one recipe.
  static Future<void> seedRecipes() async {
    final box = _openBox;
    if (box.isEmpty) {
      final seeds = RecipeSeed.getSeedRecipes();
      await box.putAll({
        for (final recipe in seeds) recipe.id: recipe.toJson(),
      });
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Returns all stored recipes.
  static List<Recipe> getAllRecipes() {
    return _openBox.values.map((json) => Recipe.fromJson(json)).toList();
  }

  /// Returns the recipe with [id], or `null` if not found.
  static Recipe? getRecipeById(String id) {
    final json = _openBox.get(id);
    if (json == null) return null;
    return Recipe.fromJson(json);
  }

  /// Returns all recipes belonging to [category] (e.g. "Breakfast").
  static List<Recipe> getRecipesByCategory(String category) {
    return getAllRecipes()
        .where((r) => r.category == category)
        .toList();
  }

  /// Returns all recipes with the given [mealType] (e.g. "Lunch", "Dinner").
  static List<Recipe> getRecipesByMealType(String mealType) {
    return getAllRecipes()
        .where((r) => r.mealType == mealType)
        .toList();
  }

  /// Saves (or overwrites) a recipe using its [Recipe.id] as key.
  static Future<void> saveRecipe(Recipe recipe) async {
    await _openBox.put(recipe.id, recipe.toJson());
  }

  /// Deletes the recipe with [id].
  static Future<void> deleteRecipe(String id) async {
    await _openBox.delete(id);
  }

  /// Deletes all recipes from the database.
  static Future<void> clearAll() async {
    await _openBox.clear();
  }

  /// Closes the Hive box. Call when the app is shutting down.
  static Future<void> dispose() async {
    await _box?.close();
  }
}
