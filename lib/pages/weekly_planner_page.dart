import 'dart:math';

import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../services/exercise_service.dart';
import '../services/meal_plan_service.dart';
import '../services/recipe_service.dart';
import '../services/settings_service.dart';

const List<String> kDays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

const List<String> kMealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

class WeeklyPlannerPage extends StatefulWidget {
  const WeeklyPlannerPage({super.key});

  @override
  State<WeeklyPlannerPage> createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  int _selectedWeek = 1;
  int _calorieLimit = 1050;
  Map<String, Recipe?> _recipeCache = {};
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _calorieLimit = SettingsService.getSettings().dailyCalorieLimit;
    // Rebuild when step count changes so exercise deduction stays live.
    ExerciseService.todayStepsNotifier.addListener(_onExerciseUpdate);
  }

  @override
  void dispose() {
    ExerciseService.todayStepsNotifier.removeListener(_onExerciseUpdate);
    super.dispose();
  }

  void _onExerciseUpdate() => setState(() {});

  Recipe? _getRecipe(String? recipeId) {
    if (recipeId == null) return null;
    _recipeCache[recipeId] ??= RecipeService.getRecipeById(recipeId);
    return _recipeCache[recipeId];
  }

  MealPlan _getMealPlan(String day, String mealType) {
    return MealPlanService.getMealPlan(_selectedWeek, day, mealType);
  }

  /// Net calories for a day = food calories − exercise calories burned (today only).
  ///
  /// Exercise calories are only deducted for the day that matches today's
  /// day-of-week name so the deduction tracks the phone's live step count.
  int _dailyCalories(String day) {
    int total = 0;
    for (final mt in kMealTypes) {
      final plan = _getMealPlan(day, mt);
      if (plan.recipeId != null) {
        final r = _getRecipe(plan.recipeId);
        if (r != null) total += r.totalCalories;
      }
    }

    // Deduct today's exercise calories for today's day of the week.
    // DateTime.weekday: Mon=1 … Sat=6, Sun=7  →  kDays index = weekday % 7
    final todayDayName = kDays[DateTime.now().weekday % 7];
    if (day == todayDayName) {
      final exerciseCals = ExerciseService.todayCaloriesBurned.round();
      total -= exerciseCals;
    }

    return total;
  }

  /// Extracts the primary protein identifier from a recipe.
  String? _proteinOf(Recipe recipe) {
    const map = {
      'chicken': ['chicken', 'wings'],
      'turkey': ['turkey'],
      'beef': ['beef'],
      'salmon': ['salmon'],
      'shrimp': ['shrimp'],
      'egg': ['egg whites', 'egg'],
      'tuna': ['tuna'],
      'protein_powder': ['protein powder'],
    };
    for (final ing in recipe.ingredients) {
      final lower = ing.name.toLowerCase();
      for (final entry in map.entries) {
        for (final kw in entry.value) {
          if (lower.contains(kw)) return entry.key;
        }
      }
    }
    return null;
  }

  Future<void> _autoGenerate() async {
    setState(() => _isGenerating = true);

    final breakfast = List<Recipe>.from(
        RecipeService.getRecipesByMealType('Breakfast'))
      ..shuffle(Random());
    final lunch =
        List<Recipe>.from(RecipeService.getRecipesByMealType('Lunch'))
          ..shuffle(Random());
    final dinner =
        List<Recipe>.from(RecipeService.getRecipesByMealType('Dinner'))
          ..shuffle(Random());
    final snack =
        List<Recipe>.from(RecipeService.getRecipesByMealType('Snack'))
          ..shuffle(Random());

    String? lastProtein;

    // counters track how many times we've pulled from each pool
    int bCount = 0, lCount = 0, dCount = 0, sCount = 0;

    Recipe? _pickNext(List<Recipe> pool, int count, String? avoidProtein) {
      if (pool.isEmpty) return null;
      // Try up to pool.length candidates to avoid same protein
      for (int i = 0; i < pool.length; i++) {
        final candidate = pool[(count + i) % pool.length];
        if (avoidProtein == null ||
            _proteinOf(candidate) != avoidProtein ||
            pool.length == 1) {
          return candidate;
        }
      }
      // Fallback: return the next one regardless
      return pool[count % pool.length];
    }

    for (final day in kDays) {
      for (final mealType in kMealTypes) {
        Recipe? picked;
        switch (mealType) {
          case 'Breakfast':
            picked = _pickNext(breakfast, bCount, lastProtein);
            if (picked != null) bCount++;
            break;
          case 'Lunch':
            picked = _pickNext(lunch, lCount, lastProtein);
            if (picked != null) lCount++;
            break;
          case 'Dinner':
            picked = _pickNext(dinner, dCount, lastProtein);
            if (picked != null) dCount++;
            break;
          default:
            picked = _pickNext(snack, sCount, lastProtein);
            if (picked != null) sCount++;
            break;
        }

        if (picked == null) continue;
        lastProtein = _proteinOf(picked);

        final plan = MealPlan(
          week: _selectedWeek,
          day: day,
          mealType: mealType,
          recipeId: picked.id,
        );
        await MealPlanService.saveMealPlan(plan);
      }
    }

    _recipeCache.clear();
    setState(() => _isGenerating = false);
  }

  Future<void> _pickRecipe(String day, String mealType) async {
    final allRecipes = RecipeService.getRecipesByMealType(mealType);

    final picked = await showDialog<Recipe?>(
      context: context,
      builder: (ctx) => _RecipePickerDialog(
        mealType: mealType,
        recipes: allRecipes,
      ),
    );
    if (picked != null) {
      final plan = MealPlan(
        week: _selectedWeek,
        day: day,
        mealType: mealType,
        recipeId: picked.id,
      );
      await MealPlanService.saveMealPlan(plan);
      _recipeCache.clear();
      setState(() {});
    }
  }

  Future<void> _clearSlot(String day, String mealType) async {
    await MealPlanService.clearMealPlan(_selectedWeek, day, mealType);
    _recipeCache.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Planner'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        actions: [
          _isGenerating
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton.icon(
                  onPressed: _autoGenerate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Auto-Generate'),
                ),
        ],
      ),
      body: Column(
        children: [
          // Week selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                final week = i + 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('Week $week'),
                      selected: _selectedWeek == week,
                      onSelected: (_) {
                        _recipeCache.clear();
                        setState(() => _selectedWeek = week);
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
          // Day list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: kDays.length,
              itemBuilder: (_, i) {
                final day = kDays[i];
                final todayDayName = kDays[DateTime.now().weekday % 7];
                final exerciseCals = day == todayDayName
                    ? ExerciseService.todayCaloriesBurned.round()
                    : 0;
                final calories = _dailyCalories(day);
                final isOver = calories > _calorieLimit;
                return _DayCard(
                  day: day,
                  calories: calories,
                  calorieLimit: _calorieLimit,
                  isOver: isOver,
                  exerciseCalsBurned: exerciseCals,
                  mealTypes: kMealTypes,
                  getMealPlan: (mt) => _getMealPlan(day, mt),
                  getRecipe: _getRecipe,
                  onTapSlot: (mt) => _pickRecipe(day, mt),
                  onClearSlot: (mt) => _clearSlot(day, mt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Day Card ─────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final String day;
  final int calories;
  final int calorieLimit;
  final bool isOver;
  final int exerciseCalsBurned;
  final List<String> mealTypes;
  final MealPlan Function(String) getMealPlan;
  final Recipe? Function(String?) getRecipe;
  final void Function(String) onTapSlot;
  final void Function(String) onClearSlot;

  const _DayCard({
    required this.day,
    required this.calories,
    required this.calorieLimit,
    required this.isOver,
    required this.exerciseCalsBurned,
    required this.mealTypes,
    required this.getMealPlan,
    required this.getRecipe,
    required this.onTapSlot,
    required this.onClearSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isOver
                  ? Colors.red.shade50
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(
                      isOver
                          ? Icons.warning_rounded
                          : Icons.local_fire_department,
                      size: 16,
                      color: isOver ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$calories / $calorieLimit cal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOver ? Colors.red : Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // Show exercise deduction row for today
                if (exerciseCalsBurned > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk,
                          size: 12, color: Colors.teal),
                      const SizedBox(width: 4),
                      Text(
                        '−$exerciseCalsBurned cal burned (exercise)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Meal slots
          ...mealTypes.map((mt) {
            final plan = getMealPlan(mt);
            final recipe = getRecipe(plan.recipeId);
            return _MealSlot(
              mealType: mt,
              recipe: recipe,
              onTap: () => onTapSlot(mt),
              onClear: recipe != null ? () => onClearSlot(mt) : null,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Meal Slot ────────────────────────────────────────────────────────────────

class _MealSlot extends StatelessWidget {
  final String mealType;
  final Recipe? recipe;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _MealSlot({
    required this.mealType,
    required this.recipe,
    required this.onTap,
    this.onClear,
  });

  Color _mealColor(BuildContext context) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.green;
      case 'Dinner':
        return Colors.indigo;
      case 'Snack':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _mealColor(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                mealType,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: recipe == null
                  ? Text(
                      'Tap to add',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                          fontSize: 13),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe!.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${recipe!.totalCalories} cal',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Recipe Picker Dialog ─────────────────────────────────────────────────────

class _RecipePickerDialog extends StatelessWidget {
  final String mealType;
  final List<Recipe> recipes;

  const _RecipePickerDialog({
    required this.mealType,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick $mealType'),
      content: SizedBox(
        width: double.maxFinite,
        child: recipes.isEmpty
            ? Text(
                'No $mealType recipes found.\nAdd recipes in the Recipe Maker.',
                textAlign: TextAlign.center,
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (_, i) {
                  final r = recipes[i];
                  return ListTile(
                    title: Text(r.name),
                    subtitle:
                        Text('${r.totalCalories} cal  •  ${r.mealType}'),
                    onTap: () => Navigator.pop(context, r),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
