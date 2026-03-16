import 'package:hive_flutter/hive_flutter.dart';

import '../models/ingredient.dart';

/// Manages ingredient persistence using Hive.
class IngredientService {
  static const String _boxName = 'ingredients';

  IngredientService._();

  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
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
}
