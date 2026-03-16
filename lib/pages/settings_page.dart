import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _calorieController;
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = SettingsService.getSettings();
    _calorieController =
        TextEditingController(text: _settings.dailyCalorieLimit.toString());
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = int.tryParse(_calorieController.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid calorie limit')),
      );
      return;
    }
    _settings.dailyCalorieLimit = value;
    await SettingsService.saveSettings(_settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Calorie Limit',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Current limit: ${_settings.dailyCalorieLimit} calories/day',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.secondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Calorie Limit',
                hintText: 'e.g. 1050',
                border: OutlineInputBorder(),
                suffixText: 'cal',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
