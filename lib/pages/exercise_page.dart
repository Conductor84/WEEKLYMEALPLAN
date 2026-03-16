import 'package:flutter/material.dart';

import '../services/exercise_service.dart';

/// Displays today's step count and calories burned from exercise.
///
/// Step tracking is managed entirely by [ExerciseService] – this page only
/// reads and displays the data.  No start/stop calls are needed here.
class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: ExerciseService.todayStepsNotifier,
        builder: (context, steps, _) {
          final caloriesBurned = steps * ExerciseService.caloriesPerStep;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatCard(
                    icon: Icons.directions_walk,
                    iconColor: Colors.blue,
                    label: "Today's Steps",
                    value: steps.toString(),
                    unit: 'steps',
                  ),
                  const SizedBox(height: 24),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    label: 'Calories Burned',
                    value: caloriesBurned.toStringAsFixed(0),
                    unit: 'kcal',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Steps are tracked automatically\nthroughout the day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calories deducted from your\ndaily planner totals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  Text(unit,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
