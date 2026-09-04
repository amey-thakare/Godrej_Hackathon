import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'glass_container.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const GlassSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search native flora, regions...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 52,
      borderRadius: AppTheme.radiusXL,
      opacityColor: Colors.white,
      opacity: 0.88,
      blur: AppTheme.blurMedium,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                if (onClear != null) onClear!();
                if (onChanged != null) onChanged!('');
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
