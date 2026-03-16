import 'dart:convert';

/// Represents a single meal slot assignment in the weekly planner.
class MealPlan {
  final int week;
  final String day;
  final String mealType;
  String? recipeId;

  MealPlan({
    required this.week,
    required this.day,
    required this.mealType,
    this.recipeId,
  });

  /// Unique Hive key for this meal slot.
  String get key => 'w${week}_${day}_$mealType';

  Map<String, dynamic> toMap() => {
        'week': week,
        'day': day,
        'mealType': mealType,
        'recipeId': recipeId,
      };

  factory MealPlan.fromMap(Map<String, dynamic> map) => MealPlan(
        week: (map['week'] as num).toInt(),
        day: map['day'] as String,
        mealType: map['mealType'] as String,
        recipeId: map['recipeId'] as String?,
      );

  String toJson() => jsonEncode(toMap());

  factory MealPlan.fromJson(String source) =>
      MealPlan.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
