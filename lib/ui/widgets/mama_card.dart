// ============================================
// MamaCare KE - Custom Card & Container Widgets
// ============================================
// Consistent, warm, and highly polished surface
// components embodying the maternal brand identity.
// ============================================

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MamaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final double borderRadius;
  final double elevation;

  const MamaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MamaCareSpacing.md),
    this.margin,
    this.onTap,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius = MamaCareSpacing.radiusLg,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? MamaCareColors.cardBackground) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: MamaCareColors.divider.withValues(alpha: 0.6), width: 1),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
