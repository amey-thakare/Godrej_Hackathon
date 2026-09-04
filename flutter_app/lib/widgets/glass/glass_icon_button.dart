import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'glass_container.dart';

class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? opacityColor;
  final double opacity;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48.0,
    this.iconSize = 22.0,
    this.iconColor,
    this.opacityColor,
    this.opacity = 0.82,
    this.tooltip,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ?? AppTheme.primaryForest;
    final effectiveBgColor = widget.opacityColor ?? Colors.white;

    Widget button = AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: GlassContainer(
          width: widget.size,
          height: widget.size,
          borderRadius: widget.size / 2,
          opacityColor: effectiveBgColor,
          opacity: widget.opacity,
          blur: AppTheme.blurMedium,
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: effectiveIconColor,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
