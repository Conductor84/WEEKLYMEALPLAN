import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pedometer/pedometer.dart';

/// Tracks daily steps using the phone's built-in pedometer.
///
/// Tracking starts automatically in [init] and runs continuously in the
/// background – the caller never needs to call start or stop.
/// Steps reset at midnight and are persisted across app restarts.
class ExerciseService {
  static const String _boxName = 'exercise_data';

  /// Calories burned per step (typical average).
  static const double caloriesPerStep = 0.04;

  /// Notifier updated on every new step event so the UI can react without
  /// polling.
  static final ValueNotifier<int> todayStepsNotifier = ValueNotifier<int>(0);

  ExerciseService._();

  static Box<dynamic>? _box;
  static StreamSubscription<StepCount>? _stepSubscription;

  // ── Hive keys ──────────────────────────────────────────────────────────────

  static String _stepsKey(String dateStr) => 'steps_$dateStr';
  static String _baseKey(String dateStr) => 'base_$dateStr';

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Opens the Hive box and immediately begins listening to the pedometer.
  /// Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<dynamic>(_boxName);
    // Seed notifier with any persisted value from today.
    todayStepsNotifier.value = getTodaySteps();
    _startTracking();
  }

  static Box<dynamic> get _openBox {
    assert(_box != null && _box!.isOpen,
        'ExerciseService.init() must be called before use.');
    return _box!;
  }

  // ── Step tracking ──────────────────────────────────────────────────────────

  /// Starts listening to the pedometer stream.  Idempotent.
  static void _startTracking() {
    _stepSubscription?.cancel();
    _stepSubscription =
        Pedometer.stepCountStream.listen(_onStepCount, onError: _onError);
  }

  /// Called on every new step-count event from the OS.
  static void _onStepCount(StepCount event) {
    final today = _todayStr();
    final box = _openBox;

    // The OS pedometer reports a *cumulative* total since boot / last reset.
    // We store the first reading of the day as a baseline and compute the
    // daily delta on every subsequent update.
    final baseKey = _baseKey(today);
    final stepsKey = _stepsKey(today);

    // Use putIfAbsent-style pattern: only set baseline on the very first event
    // of the day (Dart's event loop is single-threaded so this is safe).
    if (!box.containsKey(baseKey)) {
      box.put(baseKey, event.steps);
    }

    final base = (box.get(baseKey) as int?) ?? event.steps;
    final dailySteps = max(0, event.steps - base);
    box.put(stepsKey, dailySteps);

    // Notify listeners so the UI can update without polling.
    todayStepsNotifier.value = dailySteps;
  }

  static void _onError(Object error) {
    // Pedometer not available on this device (emulator, denied permission, etc.)
    // Silently ignore – the UI will show 0 steps.
  }

  // ── Public read API ────────────────────────────────────────────────────────

  /// Today's step count.
  static int getTodaySteps() {
    final key = _stepsKey(_todayStr());
    return (_openBox.get(key) as int?) ?? 0;
  }

  /// Calories burned today from steps.
  static double getTodayCaloriesBurned() {
    return getTodaySteps() * caloriesPerStep;
  }

  /// Steps for any past date, formatted as 'yyyy-MM-dd'.
  static int getStepsForDate(String dateStr) {
    return (_openBox.get(_stepsKey(dateStr)) as int?) ?? 0;
  }

  /// Calories burned on any past date.
  static double getCaloriesBurnedForDate(String dateStr) {
    return getStepsForDate(dateStr) * caloriesPerStep;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
