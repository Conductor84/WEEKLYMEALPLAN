import 'dart:convert';

/// Application-level user settings.
class AppSettings {
  int dailyCalorieLimit;

  AppSettings({this.dailyCalorieLimit = 1050});

  Map<String, dynamic> toMap() => {
        'dailyCalorieLimit': dailyCalorieLimit,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        dailyCalorieLimit:
            (map['dailyCalorieLimit'] as num? ?? 1050).toInt(),
      );

  String toJson() => jsonEncode(toMap());

  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
