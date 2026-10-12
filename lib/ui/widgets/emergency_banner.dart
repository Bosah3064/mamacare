// ============================================
// MamaCare KE - Emergency Banner Widget
// ============================================
// Visible, accessible, 1-tap emergency access
// banner for expectant mothers in distress.
// ============================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class EmergencyBanner extends StatelessWidget {
  final VoidCallback? onMoreInfoPressed;
  final bool isSwahili;

  const EmergencyBanner({
    super.key,
    this.onMoreInfoPressed,
    this.isSwahili = true,
  });

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:1199');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MamaCareSpacing.md, vertical: MamaCareSpacing.xs),
      padding: const EdgeInsets.all(MamaCareSpacing.md),
      decoration: BoxDecoration(
        color: MamaCareColors.errorSurface,
        borderRadius: BorderRadius.circular(MamaCareSpacing.radiusLg),
        border: Border.all(color: MamaCareColors.error.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MamaCareColors.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: MamaCareSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSwahili ? 'Dharura ya Uzazi? (Emergency)' : 'Maternal Emergency?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: MamaCareColors.error,
                  ),
                ),
                Text(
                  isSwahili
                      ? 'Piga 1199 (Msalaba Mwekundu) bila malipo'
                      : 'Call 1199 (Kenya Red Cross) Toll-Free',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _callEmergency,
            style: ElevatedButton.styleFrom(
              backgroundColor: MamaCareColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, size: 16),
                const SizedBox(width: 4),
                Text(
                  isSwahili ? 'Piga 1199' : 'Call 1199',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
