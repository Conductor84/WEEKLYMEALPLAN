import 'package:hive_flutter/hive_flutter.dart';

/// Centralized Hive database management.
///
/// Call [init] once at app startup (before any other service). It initializes
/// Hive and opens every box used by the app so that individual services can
/// retrieve their boxes synchronously via [Hive.box].
class HiveService {
  HiveService._();

  static const List<String> _boxNames = [
    'recipes',
    'ingredients',
    'meal_plans',
    'grocery_items',
    'settings',
    'exercise',
  ];

  /// Initializes Hive and opens all required boxes.
  ///
  /// Must be called before any other service [init] method.
  static Future<void> init() async {
    await Hive.initFlutter();
    for (final name in _boxNames) {
      if (!Hive.isBoxOpen(name)) {
        await Hive.openBox<String>(name);
      }
    }
  }
}
