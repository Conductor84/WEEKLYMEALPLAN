import 'dart:convert';

/// Represents a trackable ingredient with calorie and protein data.
class Ingredient {
  final String id;
  final String name;
  final double caloriesPerUnit;
  final String unit;
  final double proteinPerUnit;

  const Ingredient({
    required this.id,
    required this.name,
    required this.caloriesPerUnit,
    required this.unit,
    this.proteinPerUnit = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'caloriesPerUnit': caloriesPerUnit,
        'unit': unit,
        'proteinPerUnit': proteinPerUnit,
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        id: map['id'] as String,
        name: map['name'] as String,
        caloriesPerUnit: (map['caloriesPerUnit'] as num).toDouble(),
        unit: map['unit'] as String,
        proteinPerUnit: (map['proteinPerUnit'] as num? ?? 0).toDouble(),
      );

  String toJson() => jsonEncode(toMap());

  factory Ingredient.fromJson(String source) =>
      Ingredient.fromMap(jsonDecode(source) as Map<String, dynamic>);

  Ingredient copyWith({
    String? id,
    String? name,
    double? caloriesPerUnit,
    String? unit,
    double? proteinPerUnit,
  }) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        caloriesPerUnit: caloriesPerUnit ?? this.caloriesPerUnit,
        unit: unit ?? this.unit,
        proteinPerUnit: proteinPerUnit ?? this.proteinPerUnit,
      );
}
