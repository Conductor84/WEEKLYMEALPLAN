import 'package:hive_flutter/hive_flutter.dart';

import '../models/ingredient.dart';

/// Manages ingredient persistence using Hive.
class IngredientService {
  static const String _boxName = 'ingredients';

  IngredientService._();

  static Box<String>? _box;

  static Future<void> init() async {
    _box = Hive.box<String>(_boxName);
  }

  static Box<String> get _openBox {
    assert(_box != null && _box!.isOpen,
        'IngredientService.init() must be called before use.');
    return _box!;
  }

  static List<Ingredient> getAllIngredients() {
    return _openBox.values
        .map((json) => Ingredient.fromJson(json))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static Ingredient? getIngredientById(String id) {
    final json = _openBox.get(id);
    if (json == null) return null;
    return Ingredient.fromJson(json);
  }

  static Future<void> saveIngredient(Ingredient ingredient) async {
    await _openBox.put(ingredient.id, ingredient.toJson());
  }

  static Future<void> deleteIngredient(String id) async {
    await _openBox.delete(id);
  }

  /// Seeds common ingredients if the database is empty.
  /// Safe to call on every app launch – no-op once data exists.
  static Future<void> seedIngredients() async {
    final box = _openBox;
    if (box.isNotEmpty) return;

    const seeds = [
      // Proteins
      Ingredient(id: 'ing_001', name: 'Egg', caloriesPerUnit: 70, unit: 'large', proteinPerUnit: 6),
      Ingredient(id: 'ing_002', name: 'Egg Whites', caloriesPerUnit: 25, unit: 'cup', proteinPerUnit: 7),
      Ingredient(id: 'ing_003', name: 'Hard Boiled Eggs', caloriesPerUnit: 70, unit: 'large', proteinPerUnit: 6),
      Ingredient(id: 'ing_004', name: 'Chicken Breast', caloriesPerUnit: 165, unit: 'oz', proteinPerUnit: 31),
      Ingredient(id: 'ing_005', name: 'Ground Turkey', caloriesPerUnit: 170, unit: 'oz', proteinPerUnit: 22),
      Ingredient(id: 'ing_006', name: 'Ground Beef', caloriesPerUnit: 215, unit: 'oz', proteinPerUnit: 20),
      Ingredient(id: 'ing_007', name: 'Salmon', caloriesPerUnit: 200, unit: 'oz', proteinPerUnit: 28),
      Ingredient(id: 'ing_008', name: 'Shrimp', caloriesPerUnit: 90, unit: 'oz', proteinPerUnit: 18),
      Ingredient(id: 'ing_009', name: 'Tuna', caloriesPerUnit: 120, unit: 'oz', proteinPerUnit: 26),
      Ingredient(id: 'ing_010', name: 'Chicken Wings', caloriesPerUnit: 200, unit: 'oz', proteinPerUnit: 17),
      Ingredient(id: 'ing_011', name: 'Protein Powder', caloriesPerUnit: 120, unit: 'scoop', proteinPerUnit: 25),
      // Dairy
      Ingredient(id: 'ing_012', name: 'Greek Yogurt', caloriesPerUnit: 100, unit: 'cup', proteinPerUnit: 17),
      Ingredient(id: 'ing_013', name: 'Cheddar Cheese', caloriesPerUnit: 110, unit: 'oz', proteinPerUnit: 7),
      Ingredient(id: 'ing_014', name: 'Feta Cheese', caloriesPerUnit: 75, unit: 'oz', proteinPerUnit: 4),
      Ingredient(id: 'ing_015', name: 'Almond Milk', caloriesPerUnit: 40, unit: 'cup', proteinPerUnit: 1),
      // Produce
      Ingredient(id: 'ing_016', name: 'Avocado', caloriesPerUnit: 120, unit: 'medium', proteinPerUnit: 1.5),
      Ingredient(id: 'ing_017', name: 'Bell Peppers', caloriesPerUnit: 25, unit: 'cup', proteinPerUnit: 1),
      Ingredient(id: 'ing_018', name: 'Frozen Spinach', caloriesPerUnit: 30, unit: 'cup', proteinPerUnit: 3),
      Ingredient(id: 'ing_019', name: 'Broccoli', caloriesPerUnit: 30, unit: 'cup', proteinPerUnit: 2.5),
      Ingredient(id: 'ing_020', name: 'Asparagus', caloriesPerUnit: 27, unit: 'cup', proteinPerUnit: 3),
      Ingredient(id: 'ing_021', name: 'Sweet Potato', caloriesPerUnit: 115, unit: 'medium', proteinPerUnit: 2),
      Ingredient(id: 'ing_022', name: 'Onion', caloriesPerUnit: 45, unit: 'medium', proteinPerUnit: 1),
      Ingredient(id: 'ing_023', name: 'Garlic', caloriesPerUnit: 5, unit: 'clove', proteinPerUnit: 0.2),
      Ingredient(id: 'ing_024', name: 'Cherry Tomato', caloriesPerUnit: 30, unit: 'cup', proteinPerUnit: 1.5),
      Ingredient(id: 'ing_025', name: 'Raspberry', caloriesPerUnit: 65, unit: 'cup', proteinPerUnit: 1.5),
      Ingredient(id: 'ing_026', name: 'Cucumber', caloriesPerUnit: 16, unit: 'cup', proteinPerUnit: 0.7),
      // Pantry
      Ingredient(id: 'ing_027', name: 'Brown Rice', caloriesPerUnit: 215, unit: 'cup', proteinPerUnit: 5),
      Ingredient(id: 'ing_028', name: 'Quinoa', caloriesPerUnit: 220, unit: 'cup', proteinPerUnit: 8),
      Ingredient(id: 'ing_029', name: 'Almonds', caloriesPerUnit: 160, unit: 'oz', proteinPerUnit: 6),
      Ingredient(id: 'ing_030', name: 'Chia Seeds', caloriesPerUnit: 60, unit: 'tbsp', proteinPerUnit: 3),
      // Canned / Condiments
      Ingredient(id: 'ing_031', name: 'Salsa', caloriesPerUnit: 15, unit: 'cup', proteinPerUnit: 0.5),
      Ingredient(id: 'ing_032', name: 'Tomato Sauce', caloriesPerUnit: 40, unit: 'cup', proteinPerUnit: 2),
      Ingredient(id: 'ing_033', name: 'Hummus', caloriesPerUnit: 50, unit: 'tbsp', proteinPerUnit: 2),
      // Spices / Oils
      Ingredient(id: 'ing_034', name: 'Olive Oil', caloriesPerUnit: 120, unit: 'tbsp', proteinPerUnit: 0),
      Ingredient(id: 'ing_035', name: 'Soy Sauce', caloriesPerUnit: 10, unit: 'tbsp', proteinPerUnit: 1),
    ];

    await box.putAll({
      for (final ing in seeds) ing.id: ing.toJson(),
    });
  }
}
