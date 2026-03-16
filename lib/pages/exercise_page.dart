import 'package:flutter/material.dart';

import '../services/exercise_service.dart';

/// Page 6 – Exercise
///
/// Reads today's step count from the phone's native step counter
/// (Google Fit on Android / HealthKit on iOS), displays the step count
/// and the calories burned, and shows the running daily total.
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
          final calories = ExerciseService.todayCaloriesBurned;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── Header card ───────────────────────────────────────────
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 64,
                        color: cs.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Today\'s Steps',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatNumber(steps),
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Calories burned card ──────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          size: 32,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calories Burned',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${calories.toStringAsFixed(1)} cal',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Info cards ────────────────────────────────────────────
              _InfoCard(
                icon: Icons.info_outline,
                iconColor: cs.secondary,
                title: 'Calorie Calculation',
                body: '${_formatNumber(steps)} steps × 0.04 cal/step'
                    ' = ${calories.toStringAsFixed(1)} cal',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.sync,
                iconColor: Colors.teal,
                title: 'Daily Reset',
                body:
                    'Step count resets automatically at midnight each day.',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.link,
                iconColor: Colors.indigo,
                title: 'Weekly Planner Integration',
                body:
                    "Today's ${calories.toStringAsFixed(1)} cal burned are "
                    'automatically deducted from your daily calorie total '
                    'in the Weekly Planner.',
              ),

              // ── Permission note ───────────────────────────────────────
              if (steps == 0) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber,
                            color: Colors.amber.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No steps recorded yet.\n\n'
                            'Make sure the app has permission to access '
                            'physical activity data:\n'
                            '• Android: Activity Recognition\n'
                            '• iOS: Motion & Fitness',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatNumber(int n) {
    // Simple thousands separator
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── Helper widget ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
