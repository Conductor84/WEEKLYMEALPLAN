import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';

/// Manages application settings using Hive.
class SettingsService {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'app_settings';

  SettingsService._();

  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _openBox {
    assert(_box != null && _box!.isOpen,
        'SettingsService.init() must be called before use.');
    return _box!;
  }

  static AppSettings getSettings() {
    final json = _openBox.get(_settingsKey);
    if (json == null) return AppSettings();
    return AppSettings.fromJson(json);
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _openBox.put(_settingsKey, settings.toJson());
  }
}
