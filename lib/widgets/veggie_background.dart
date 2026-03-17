import 'package:flutter/material.dart';

/// A decorative background widget that renders a soft gradient with subtle
/// scattered food / veggie icons.
///
/// Wrap a page body (or any child widget) with [VeggieBackground] to give it
/// the app's signature green-themed illustrated background.
///
/// Example:
/// ```dart
/// VeggieBackground(
///   child: Center(child: Text('Hello!')),
/// )
/// ```
class VeggieBackground extends StatelessWidget {
  /// Widget to render on top of the background.
  final Widget child;

  /// Primary gradient colour.  Falls back to [ColorScheme.primaryContainer].
  final Color? topColor;

  /// Secondary gradient colour.  Falls back to [ColorScheme.surface].
  final Color? bottomColor;

  /// Opacity applied to the decorative icons (0.0 – 1.0).
  final double iconOpacity;

  const VeggieBackground({
    super.key,
    required this.child,
    this.topColor,
    this.bottomColor,
    this.iconOpacity = 0.08,
  });

  static const List<_IconPlacement> _placements = [
    _IconPlacement(icon: Icons.eco, left: 0.05, top: 0.05, size: 48),
    _IconPlacement(icon: Icons.local_florist, right: 0.08, top: 0.12, size: 36),
    _IconPlacement(icon: Icons.spa, left: 0.12, top: 0.30, size: 28),
    _IconPlacement(icon: Icons.grass, right: 0.04, top: 0.40, size: 42),
    _IconPlacement(icon: Icons.eco, left: 0.06, top: 0.60, size: 32),
    _IconPlacement(icon: Icons.local_florist, right: 0.10, top: 0.70, size: 30),
    _IconPlacement(icon: Icons.spa, left: 0.20, top: 0.80, size: 40),
    _IconPlacement(icon: Icons.grass, right: 0.18, top: 0.90, size: 26),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final top = topColor ?? cs.primaryContainer;
    final bottom = bottomColor ?? cs.surface;

    return Stack(
      children: [
        // Gradient background
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, bottom],
              ),
            ),
          ),
        ),
        // Scattered decorative icons
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _placements.map((p) {
                  return Positioned(
                    left: p.left != null
                        ? constraints.maxWidth * p.left!
                        : null,
                    right: p.right != null
                        ? constraints.maxWidth * p.right!
                        : null,
                    top: constraints.maxHeight * p.top,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: Icon(
                        p.icon,
                        size: p.size,
                        color: cs.primary,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        // Foreground content
        child,
      ],
    );
  }
}

/// Internal helper that holds the position and appearance of a decorative icon.
class _IconPlacement {
  final IconData icon;
  final double? left;
  final double? right;
  final double top;
  final double size;

  const _IconPlacement({
    required this.icon,
    this.left,
    this.right,
    required this.top,
    required this.size,
  });
}
