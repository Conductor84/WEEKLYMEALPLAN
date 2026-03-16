import 'dart:convert';

/// Represents a single ingredient line in a recipe.
class RecipeIngredient {
  final double quantity;
  final String unit;
  final String name;

  const RecipeIngredient({
    required this.quantity,
    required this.unit,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
        'quantity': quantity,
        'unit': unit,
        'name': name,
      };

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) =>
      RecipeIngredient(
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String,
        name: map['name'] as String,
      );

  @override
  String toString() => '$quantity $unit $name'.trim();
}

/// Nutritional macros for a recipe (per serving).
class Macros {
  final double protein;
  final double carbs;
  final double fat;

  const Macros({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() => {
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory Macros.fromMap(Map<String, dynamic> map) => Macros(
        protein: (map['protein'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
      );
}

/// A recipe with full ingredient and nutritional information.
class Recipe {
  final String id;
  final String name;

  /// One of "Breakfast", "Main", or "Snack".
  final String category;

  /// Free-form meal type label (e.g. "Lunch", "Dinner", "Post-Workout").
  final String mealType;

  final List<RecipeIngredient> ingredients;
  final int totalCalories;
  final Macros macros;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.mealType,
    required this.ingredients,
    required this.totalCalories,
    required this.macros,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'mealType': mealType,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'totalCalories': totalCalories,
        'macros': macros.toMap(),
      };

  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        mealType: map['mealType'] as String,
        ingredients: (map['ingredients'] as List<dynamic>)
            .map((i) => RecipeIngredient.fromMap(
                Map<String, dynamic>.from(i as Map)))
            .toList(),
        totalCalories: (map['totalCalories'] as num).toInt(),
        macros:
            Macros.fromMap(Map<String, dynamic>.from(map['macros'] as Map)),
      );

  String toJson() => jsonEncode(toMap());

  factory Recipe.fromJson(String source) =>
      Recipe.fromMap(jsonDecode(source) as Map<String, dynamic>);

  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    String? mealType,
    List<RecipeIngredient>? ingredients,
    int? totalCalories,
    Macros? macros,
  }) =>
      Recipe(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        mealType: mealType ?? this.mealType,
        ingredients: ingredients ?? this.ingredients,
        totalCalories: totalCalories ?? this.totalCalories,
        macros: macros ?? this.macros,
      );
}
