import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<Ingredient> _ingredients = [];
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _ingredients = IngredientService.getAllIngredients();
    });
  }

  List<Ingredient> get _filtered {
    if (_searchQuery.isEmpty) return _ingredients;
    final q = _searchQuery.toLowerCase();
    return _ingredients.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _showAddEditDialog([Ingredient? existing]) async {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final calCtrl =
        TextEditingController(text: existing?.caloriesPerUnit.toString() ?? '');
    final proteinCtrl =
        TextEditingController(text: existing?.proteinPerUnit.toString() ?? '0');
    String unit = existing?.unit ?? 'g';

    const units = [
      'g', 'oz', 'cup', 'cups', 'tbsp', 'tsp', 'ml', 'large',
      'medium', 'small', 'scoop', 'piece', 'slice', 'clove', 'other'
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Ingredient' : 'Edit Ingredient'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: calCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Calories per unit *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: proteinCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Protein per unit (g) — optional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => unit = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final cal = double.tryParse(calCtrl.text.trim());
                  if (name.isEmpty || cal == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please enter a name and valid calorie amount')),
                    );
                    return;
                  }
                  final protein =
                      double.tryParse(proteinCtrl.text.trim()) ?? 0;
                  final ingredient = Ingredient(
                    id: existing?.id ?? const Uuid().v4(),
                    name: name,
                    caloriesPerUnit: cal,
                    unit: unit,
                    proteinPerUnit: protein,
                  );
                  await IngredientService.saveIngredient(ingredient);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _refresh();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _delete(Ingredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ingredient?'),
        content: Text('Delete "${ingredient.name}"?'),
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
      await IngredientService.deleteIngredient(ingredient.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayed = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Ingredient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search ingredients…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: _ingredients.isEmpty
                ? const Center(
                    child: Text(
                      'No ingredients yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : displayed.isEmpty
                    ? const Center(
                        child: Text(
                          'No ingredients match your search.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final ing = displayed[i];
                          return ListTile(
                            title: Text(ing.name),
                            subtitle: Text(
                                '${ing.caloriesPerUnit.toStringAsFixed(0)} cal / ${ing.unit}'
                                '${ing.proteinPerUnit > 0 ? '  •  ${ing.proteinPerUnit.toStringAsFixed(1)}g protein' : ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showAddEditDialog(ing),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  onPressed: () => _delete(ing),
                                ),
                              ],
                            ),
                          );
                        },
            ),
          ),
        ],
      ),
    );
  }
}
