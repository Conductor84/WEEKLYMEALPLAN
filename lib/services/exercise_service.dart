import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pedometer/pedometer.dart';

/// Reads the phone's native step counter, tracks daily steps and calories burned.
///
/// Steps are keyed by calendar date ('YYYY-MM-DD') so they reset automatically
/// at midnight. Calories burned = steps × [calPerStep].
class ExerciseService {
  static const double calPerStep = 0.04;
  static const String _boxName = 'exercise';

  ExerciseService._();

  static Box<String>? _box;
  static StreamSubscription<StepCount>? _subscription;

  /// Reactive notifier for today's step count – listen to rebuild UI.
  static final ValueNotifier<int> todayStepsNotifier = ValueNotifier(0);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    await _loadTodaySteps();
    _startListening();
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _box?.close();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Today's total step count.
  static int get todaySteps => todayStepsNotifier.value;

  /// Calories burned today (steps × [calPerStep]).
  static double get todayCaloriesBurned => todaySteps * calPerStep;

  // ── Private helpers ──────────────────────────────────────────────────────

  /// ISO-8601 date key for today.
  static String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Restores today's step count from Hive on app start.
  static Future<void> _loadTodaySteps() async {
    final json = _box?.get(_todayKey);
    if (json == null) return;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      todayStepsNotifier.value = (data['steps'] as num? ?? 0).toInt();
    } catch (_) {}
  }

  /// Subscribes to the platform step-count stream.
  ///
  /// Fails silently if the pedometer is unavailable (simulator, denied
  /// permissions, unsupported platform).
  static void _startListening() {
    try {
      _subscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (_) {
          // Pedometer unavailable — keep the persisted value.
        },
        cancelOnError: false,
      );
    } catch (_) {
      // Pedometer not supported on this platform.
    }
  }

  /// Processes a new [StepCount] event from the pedometer.
  ///
  /// The pedometer gives a *cumulative* count since device boot / health
  /// reset.  We store a per-day baseline so that daily steps =
  /// `event.steps - baseline`.  If the cumulative count is lower than the
  /// baseline (device rebooted), we treat the raw value as today's steps.
  static Future<void> _onStepCount(StepCount event) async {
    final box = _box;
    if (box == null) return;

    final key = _todayKey;
    final existingJson = box.get(key);

    if (existingJson == null) {
      // First pedometer event for today — record the baseline.
      await box.put(key, jsonEncode({'steps': 0, 'baseline': event.steps}));
      todayStepsNotifier.value = 0;
    } else {
      try {
        final data = jsonDecode(existingJson) as Map<String, dynamic>;
        final baseline = (data['baseline'] as num).toInt();
        final dailySteps = event.steps >= baseline
            ? event.steps - baseline
            : event.steps; // Baseline higher → device/health reset

        await box.put(
          key,
          jsonEncode({'steps': dailySteps, 'baseline': data['baseline']}),
        );
        todayStepsNotifier.value = dailySteps;
      } catch (_) {}
    }
  }
}
