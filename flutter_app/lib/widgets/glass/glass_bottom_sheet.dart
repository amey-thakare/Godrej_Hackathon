import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 32),
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? height,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => GlassBottomSheet(
        height: height,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryForest.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.blurLarge,
            sigmaY: AppTheme.blurLarge,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Apple-style Drag Handle
                Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
