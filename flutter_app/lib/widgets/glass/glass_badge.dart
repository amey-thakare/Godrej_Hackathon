import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'glass_container.dart';

class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.fontSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTheme.accentForest;
    final fgColor = textColor ?? badgeColor;

    return GlassContainer(
      borderRadius: AppTheme.radiusXL,
      opacityColor: Colors.white,
      opacity: 0.88,
      blur: AppTheme.blurSmall,
      border: Border.all(
        color: badgeColor.withValues(alpha: 0.3),
        width: 1.0,
      ),
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fgColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
