import 'dart:convert';

/// A single item on the grocery list.
class GroceryItem {
  final String id;
  String name;
  String category;
  double? quantity;
  String? unit;
  bool isChecked;
  bool isManual;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    this.isChecked = false,
    this.isManual = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'isChecked': isChecked,
        'isManual': isManual,
      };

  factory GroceryItem.fromMap(Map<String, dynamic> map) => GroceryItem(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        quantity: (map['quantity'] as num?)?.toDouble(),
        unit: map['unit'] as String?,
        isChecked: map['isChecked'] as bool? ?? false,
        isManual: map['isManual'] as bool? ?? false,
      );

  String toJson() => jsonEncode(toMap());

  factory GroceryItem.fromJson(String source) =>
      GroceryItem.fromMap(jsonDecode(source) as Map<String, dynamic>);

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    bool? isChecked,
    bool? isManual,
  }) =>
      GroceryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        isChecked: isChecked ?? this.isChecked,
        isManual: isManual ?? this.isManual,
      );
}

/// Grocery store category order.
const List<String> kGroceryCategories = [
  'Dairy',
  'Frozen',
  'Drinks',
  'Cleaning',
  'Pantry',
  'Meat',
  'Spices',
  'Canned Goods',
  'Condiments',
  'Produce',
  'Other',
];

/// Maps an ingredient name to its best-guess grocery store category.
String categorizeIngredient(String name) {
  final lower = name.toLowerCase();

  // Produce
  if (RegExp(
          r'avocado|tomato|cucumber|spinach|bell pepper|onion|garlic|lemon|lime|asparagus|broccoli|carrot|sweet potato|green bean|lettuce|greens|cabbage|cilantro|ginger|raspberry|berry|fruit|zucchini|squash|green onion|slaw')
      .hasMatch(lower)) {
    return 'Produce';
  }
  // Meat
  if (RegExp(r'chicken|turkey|beef|salmon|shrimp|wing|tuna|pork|steak|ground')
      .hasMatch(lower)) {
    return 'Meat';
  }
  // Frozen
  if (lower.contains('frozen')) {
    return 'Frozen';
  }
  // Dairy
  if (RegExp(r'\begg\b|eggs|cheese|cheddar|feta|yogurt|milk|cream|butter')
      .hasMatch(lower)) {
    return 'Dairy';
  }
  // Pantry
  if (RegExp(r'\brice\b|pasta|spaghetti|quinoa|oat|bread|keto wrap|wrap|chia|almond|protein powder|stevia|flour|sugar|honey')
      .hasMatch(lower)) {
    return 'Pantry';
  }
  // Spices
  if (RegExp(
          r'salt|pepper|cumin|paprika|oregano|sesame oil|olive oil|sesame seeds|soy sauce')
      .hasMatch(lower)) {
    return 'Spices';
  }
  // Canned Goods
  if (RegExp(r'tomato sauce|salsa|hummus|bean|chickpea|chick pea|canned')
      .hasMatch(lower)) {
    return 'Canned Goods';
  }
  // Condiments
  if (RegExp(
          r'mayo|mustard|dijon|ketchup|ranch|dressing|bbq|relish|guacamole|balsamic|vinegar')
      .hasMatch(lower)) {
    return 'Condiments';
  }
  // Drinks
  if (RegExp(r'juice|soda|water|coffee|tea|drink').hasMatch(lower)) {
    return 'Drinks';
  }

  return 'Other';
}
