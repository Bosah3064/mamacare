// ============================================
// MamaCare KE - Brand Logo & Emblem Component
// ============================================

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MamaCareLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const MamaCareLogo({
    super.key,
    this.size = 36,
    this.showText = true,
    this.isDark = false,
  });

  /// App icon badge with squircle styling
  factory MamaCareLogo.appIcon({double size = 64}) {
    return MamaCareLogo(size: size, showText: false);
  }

  /// Horizontal Brand Logo (Emblem + Typography)
  factory MamaCareLogo.full({double size = 38}) {
    return MamaCareLogo(size: size, showText: true);
  }

  @override
  Widget build(BuildContext context) {
    final emblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: MamaCareColors.primary.withValues(alpha: 0.18),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/images/logo_emblem.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: MamaCareColors.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.favorite_rounded,
              color: MamaCareColors.primary,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );

    if (!showText) return emblem;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(width: size * 0.28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MamaCare KE',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: size * 0.48,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : MamaCareColors.textPrimary,
              ),
            ),
            Text(
              'Your pregnancy companion',
              style: TextStyle(
                fontSize: (size * 0.26).clamp(9.0, 12.0),
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : MamaCareColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Standalone Full Banner Logo
class MamaCareBannerLogo extends StatelessWidget {
  final double height;
  final BoxFit fit;

  const MamaCareBannerLogo({
    super.key,
    this.height = 70,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const MamaCareLogo(size: 44, showText: true),
    );
  }
}
