import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_plan.dart';

/// Manages meal plan persistence using Hive.
class MealPlanService {
  static const String _boxName = 'meal_plans';

  MealPlanService._();

  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _openBox {
    assert(_box != null && _box!.isOpen,
        'MealPlanService.init() must be called before use.');
    return _box!;
  }

  /// Returns the meal plan for the given slot, or an empty one if not set.
  static MealPlan getMealPlan(int week, String day, String mealType) {
    final key = 'w${week}_${day}_$mealType';
    final json = _openBox.get(key);
    if (json == null) {
      return MealPlan(week: week, day: day, mealType: mealType);
    }
    return MealPlan.fromJson(json);
  }

  /// Returns all meal plans for a given week.
  static List<MealPlan> getMealPlansForWeek(int week) {
    return _openBox.values
        .map((json) => MealPlan.fromJson(json))
        .where((mp) => mp.week == week)
        .toList();
  }

  /// Returns all meal plans across all weeks.
  static List<MealPlan> getAllMealPlans() {
    return _openBox.values.map((json) => MealPlan.fromJson(json)).toList();
  }

  /// Saves (or overwrites) a meal plan slot.
  static Future<void> saveMealPlan(MealPlan plan) async {
    await _openBox.put(plan.key, plan.toJson());
  }

  /// Clears the recipe from a single meal slot.
  static Future<void> clearMealPlan(int week, String day, String mealType) async {
    final key = 'w${week}_${day}_$mealType';
    final plan = MealPlan(week: week, day: day, mealType: mealType);
    await _openBox.put(key, plan.toJson());
  }

  /// Clears all meal plans for the given week.
  static Future<void> clearWeek(int week) async {
    final keys = _openBox.keys
        .where((k) => (k as String).startsWith('w${week}_'))
        .toList();
    await _openBox.deleteAll(keys);
  }
}
