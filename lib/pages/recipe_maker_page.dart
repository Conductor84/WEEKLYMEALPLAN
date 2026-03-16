import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../services/ingredient_service.dart';
import '../services/recipe_service.dart';

class RecipeMakerPage extends StatefulWidget {
  const RecipeMakerPage({super.key});

  @override
  State<RecipeMakerPage> createState() => _RecipeMakerPageState();
}

class _RecipeMakerPageState extends State<RecipeMakerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _refreshRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshRecipes() {
    setState(() {
      _recipes = RecipeService.getAllRecipes();
    });
  }

  Future<void> _showRecipeForm([Recipe? existing]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _RecipeFormPage(
          existing: existing,
          onSaved: _refreshRecipes,
        ),
      ),
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: Text('Delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await RecipeService.deleteRecipe(recipe.id);
      _refreshRecipes();
    }
  }

  void _showRecipeDetail(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecipeDetailSheet(
        recipe: recipe,
        onEdit: () {
          Navigator.pop(context);
          _showRecipeForm(recipe);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteRecipe(recipe);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Maker'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Create'),
            Tab(icon: Icon(Icons.menu_book), text: 'View Recipes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Create tab
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64, color: cs.primary.withAlpha(128)),
                  const SizedBox(height: 16),
                  Text(
                    'Create a new recipe',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showRecipeForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('New Recipe'),
                  ),
                ],
              ),
            ),
          ),
          // View tab
          _recipes.isEmpty
              ? const Center(
                  child: Text(
                    'No recipes yet.\nSwitch to Create tab to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _recipes.length,
                  itemBuilder: (_, i) {
                    final recipe = _recipes[i];
                    return _RecipeCard(
                      recipe: recipe,
                      onTap: () => _showRecipeDetail(recipe),
                      onEdit: () => _showRecipeForm(recipe),
                      onDelete: () => _deleteRecipe(recipe),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// ─── Recipe Card ─────────────────────────────────────────────────────────────

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _categoryColor(BuildContext context) {
    switch (recipe.mealType) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.green;
      case 'Dinner':
        return Colors.indigo;
      case 'Snack':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.mealType,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.totalCalories} cal  •  '
                      'P:${recipe.macros.protein.toStringAsFixed(0)}g  '
                      'C:${recipe.macros.carbs.toStringAsFixed(0)}g  '
                      'F:${recipe.macros.fat.toStringAsFixed(0)}g',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recipe Detail Sheet ──────────────────────────────────────────────────────

class _RecipeDetailSheet extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecipeDetailSheet({
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, sc) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: sc,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recipe.mealType,
                    style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Macros card
            Card(
              color: cs.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MacroChip(
                        label: 'Calories',
                        value: '${recipe.totalCalories}',
                        unit: 'cal'),
                    _MacroChip(
                        label: 'Protein',
                        value: recipe.macros.protein.toStringAsFixed(0),
                        unit: 'g'),
                    _MacroChip(
                        label: 'Carbs',
                        value: recipe.macros.carbs.toStringAsFixed(0),
                        unit: 'g'),
                    _MacroChip(
                        label: 'Fat',
                        value: recipe.macros.fat.toStringAsFixed(0),
                        unit: 'g'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Ingredients',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ing) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6),
                    const SizedBox(width: 8),
                    Text('${_fmtQty(ing.quantity)} ${ing.unit} ${ing.name}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Recipe'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtQty(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toString();
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroChip(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value$unit',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// ─── Recipe Form Page ─────────────────────────────────────────────────────────

class _RecipeFormPage extends StatefulWidget {
  final Recipe? existing;
  final VoidCallback onSaved;

  const _RecipeFormPage({this.existing, required this.onSaved});

  @override
  State<_RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<_RecipeFormPage> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  String _mealType = 'Breakfast';
  final List<_IngredientLine> _lines = [];
  List<Ingredient> _savedIngredients = [];

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  static const _units = [
    'g', 'oz', 'cup', 'cups', 'tbsp', 'tsp', 'ml', 'large',
    'medium', 'small', 'scoop', 'piece', 'pieces', 'slice', 'slices',
    'clove', 'cloves', 'other'
  ];

  @override
  void initState() {
    super.initState();
    _savedIngredients = IngredientService.getAllIngredients();
    if (widget.existing != null) {
      final r = widget.existing!;
      _nameCtrl.text = r.name;
      _mealType = r.mealType;
      _calCtrl.text = r.totalCalories > 0 ? r.totalCalories.toString() : '';
      _proteinCtrl.text = r.macros.protein > 0
          ? r.macros.protein.toStringAsFixed(0)
          : '';
      _lines.addAll(r.ingredients.map((ri) => _IngredientLine(
            ingredientId: ri.ingredientId,
            name: ri.name,
            quantity: ri.quantity,
            unit: ri.unit,
          )));
    }
    if (_lines.isEmpty) _lines.add(_IngredientLine());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    super.dispose();
  }

  int _calculateCalories() {
    int total = 0;
    for (final line in _lines) {
      if (line.ingredientId != null) {
        final ing = _savedIngredients
            .where((i) => i.id == line.ingredientId)
            .firstOrNull;
        if (ing != null) {
          total += (line.quantity * ing.caloriesPerUnit).round();
        }
      }
    }
    return total;
  }

  double _calculateProtein() {
    double total = 0;
    for (final line in _lines) {
      if (line.ingredientId != null) {
        final ing = _savedIngredients
            .where((i) => i.id == line.ingredientId)
            .firstOrNull;
        if (ing != null) {
          total += line.quantity * ing.proteinPerUnit;
        }
      }
    }
    return total;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a recipe name')));
      return;
    }
    final validLines =
        _lines.where((l) => l.name.isNotEmpty && l.quantity > 0).toList();
    if (validLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient')));
      return;
    }

    final ingredients = validLines
        .map((l) => RecipeIngredient(
              ingredientId: l.ingredientId,
              name: l.name,
              quantity: l.quantity,
              unit: l.unit,
            ))
        .toList();

    final autoCal = _calculateCalories();
    final autoProtein = _calculateProtein();
    final manualCal = int.tryParse(_calCtrl.text.trim());
    final manualProtein = double.tryParse(_proteinCtrl.text.trim());

    final totalCalories = autoCal > 0 ? autoCal : (manualCal ?? 0);
    final totalProtein = autoProtein > 0 ? autoProtein : (manualProtein ?? 0);

    final category =
        (_mealType == 'Breakfast' || _mealType == 'Snack') ? _mealType : 'Main';

    final recipe = Recipe(
      id: widget.existing?.id ?? 'rec_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      category: category,
      mealType: _mealType,
      ingredients: ingredients,
      totalCalories: totalCalories,
      macros: Macros(
        protein: totalProtein,
        carbs: widget.existing?.macros.carbs ?? 0,
        fat: widget.existing?.macros.fat ?? 0,
      ),
    );

    await RecipeService.saveRecipe(recipe);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final autoCal = _calculateCalories();
    final autoProtein = _calculateProtein();
    final hasAutoCalc = autoCal > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Recipe' : 'Edit Recipe'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Recipe Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Category
            Text('Category',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: cs.primary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _mealTypes.map((t) {
                return ChoiceChip(
                  label: Text(t),
                  selected: _mealType == t,
                  onSelected: (_) => setState(() => _mealType = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Auto-calc display
            if (hasAutoCalc) ...[
              Card(
                color: cs.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Auto Calories: $autoCal cal',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Protein: ${autoProtein.toStringAsFixed(1)}g',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Manual calories / protein override
            if (!hasAutoCalc) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _calCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Calories',
                        border: OutlineInputBorder(),
                        suffixText: 'cal',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _proteinCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Protein',
                        border: OutlineInputBorder(),
                        suffixText: 'g',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Ingredients header
            Row(
              children: [
                Text('Ingredients',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _lines.add(_IngredientLine())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            ..._lines.asMap().entries.map((e) {
              final idx = e.key;
              final line = e.value;
              return _IngredientLineWidget(
                key: ValueKey(idx),
                line: line,
                savedIngredients: _savedIngredients,
                units: _units,
                onChanged: () => setState(() {}),
                onRemove: _lines.length > 1
                    ? () => setState(() => _lines.removeAt(idx))
                    : null,
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ingredient Line Data ─────────────────────────────────────────────────────

class _IngredientLine {
  String? ingredientId;
  String name;
  double quantity;
  String unit;

  _IngredientLine({
    this.ingredientId,
    this.name = '',
    this.quantity = 1,
    this.unit = 'g',
  });
}

// ─── Ingredient Line Widget ───────────────────────────────────────────────────

class _IngredientLineWidget extends StatefulWidget {
  final _IngredientLine line;
  final List<Ingredient> savedIngredients;
  final List<String> units;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const _IngredientLineWidget({
    super.key,
    required this.line,
    required this.savedIngredients,
    required this.units,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_IngredientLineWidget> createState() => _IngredientLineWidgetState();
}

class _IngredientLineWidgetState extends State<_IngredientLineWidget> {
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
        text: _fmtQty(widget.line.quantity));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  String _fmtQty(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toString();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Ingredient name with autocomplete
            Autocomplete<Ingredient>(
              initialValue: TextEditingValue(text: widget.line.name),
              displayStringForOption: (i) => i.name,
              optionsBuilder: (value) {
                if (value.text.isEmpty) return const Iterable.empty();
                return widget.savedIngredients.where((i) =>
                    i.name.toLowerCase().contains(value.text.toLowerCase()));
              },
              onSelected: (ing) {
                setState(() {
                  widget.line.ingredientId = ing.id;
                  widget.line.name = ing.name;
                  widget.line.unit =
                      widget.units.contains(ing.unit) ? ing.unit : 'g';
                });
                widget.onChanged();
              },
              fieldViewBuilder: (ctx, ctrl, fn, _) {
                return TextField(
                  controller: ctrl,
                  focusNode: fn,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    widget.line.name = v;
                    if (v.isEmpty) widget.line.ingredientId = null;
                    widget.onChanged();
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Quantity
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      widget.line.quantity =
                          double.tryParse(v) ?? widget.line.quantity;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Unit dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: widget.units.contains(widget.line.unit)
                        ? widget.line.unit
                        : widget.units.first,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: widget.units
                        .map((u) =>
                            DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => widget.line.unit = v);
                        widget.onChanged();
                      }
                    },
                  ),
                ),
                if (widget.onRemove != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red, size: 20),
                    onPressed: widget.onRemove,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
