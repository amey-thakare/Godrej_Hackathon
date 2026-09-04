import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blur;
  final Color opacityColor;
  final double opacity;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppTheme.radiusLarge,
    this.blur = AppTheme.blurMedium,
    this.opacityColor = Colors.white,
    this.opacity = 0.78,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        Border.all(
          color: opacityColor == Colors.white
              ? Colors.white.withValues(alpha: 0.5)
              : AppTheme.primaryForest.withValues(alpha: 0.2),
          width: 1.0,
        );

    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: AppTheme.primaryForest.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ];

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: opacityColor.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: effectiveBorder,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
