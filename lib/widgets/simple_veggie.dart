import 'package:flutter/material.dart';

/// A simple decorative widget that displays a food/veggie icon with an
/// optional label, styled to match the app's colour scheme.
///
/// Used as a quick visual accent on summary cards and empty-state screens.
class SimpleVeggie extends StatelessWidget {
  /// The icon to display (defaults to a broccoli / healthy food icon).
  final IconData icon;

  /// Optional label shown below the icon.
  final String? label;

  /// Diameter of the circular background behind the icon.
  final double size;

  /// Background colour of the circle.  Falls back to
  /// [ColorScheme.primaryContainer] when null.
  final Color? backgroundColor;

  /// Foreground (icon) colour.  Falls back to
  /// [ColorScheme.onPrimaryContainer] when null.
  final Color? foregroundColor;

  const SimpleVeggie({
    super.key,
    this.icon = Icons.eco,
    this.label,
    this.size = 64,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.primaryContainer;
    final fg = foregroundColor ?? cs.onPrimaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: fg, size: size * 0.55),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
