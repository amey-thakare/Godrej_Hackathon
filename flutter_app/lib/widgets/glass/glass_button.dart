import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'glass_container.dart';

enum GlassButtonVariant { primary, secondary, outline }

class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final GlassButtonVariant variant;
  final double? width;
  final double height;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.width,
    this.height = 52.0,
    this.isLoading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgOpacityColor;
    double opacity;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case GlassButtonVariant.primary:
        bgOpacityColor = AppTheme.primaryForest;
        opacity = 0.92;
        textColor = Colors.white;
        border = Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.0,
        );
        break;
      case GlassButtonVariant.secondary:
        bgOpacityColor = Colors.white;
        opacity = 0.88;
        textColor = AppTheme.primaryForest;
        border = Border.all(
          color: AppTheme.surfaceBorder,
          width: 1.0,
        );
        break;
      case GlassButtonVariant.outline:
        bgOpacityColor = AppTheme.mistBackground;
        opacity = 0.70;
        textColor = AppTheme.primaryForest;
        border = Border.all(
          color: AppTheme.accentForest.withValues(alpha: 0.4),
          width: 1.0,
        );
        break;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: GlassContainer(
          width: widget.width,
          height: widget.height,
          borderRadius: AppTheme.radiusXL,
          opacityColor: bgOpacityColor,
          opacity: opacity,
          border: border,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
                const SizedBox(width: 6),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, color: textColor, size: 18),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
