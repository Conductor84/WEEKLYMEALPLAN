import 'package:flutter/material.dart';

import 'weekly_planner_page.dart';
import 'grocery_list_page.dart';
import 'recipe_maker_page.dart';
import 'ingredients_page.dart';
import 'exercise_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Meal Plan'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NavButton(
              icon: Icons.calendar_month,
              label: 'Weekly Planner',
              color: cs.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const WeeklyPlannerPage()),
              ),
            ),
            const SizedBox(height: 16),
            _NavButton(
              icon: Icons.shopping_cart,
              label: 'Grocery List',
              color: cs.secondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GroceryListPage()),
              ),
            ),
            const SizedBox(height: 16),
            _NavButton(
              icon: Icons.restaurant_menu,
              label: 'Recipes',
              color: cs.tertiary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RecipeMakerPage()),
              ),
            ),
            const SizedBox(height: 16),
            _NavButton(
              icon: Icons.egg_alt,
              label: 'Ingredients',
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const IngredientsPage()),
              ),
            ),
            const SizedBox(height: 16),
            _NavButton(
              icon: Icons.directions_walk,
              label: 'Exercise',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ExercisePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
