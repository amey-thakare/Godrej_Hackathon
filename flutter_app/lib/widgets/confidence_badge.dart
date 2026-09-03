import 'package:flutter/material.dart';

class ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const ConfidenceBadge({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(0);
    Color bgColor;
    Color textColor;
    String label;

    if (confidence >= 0.75) {
      bgColor = const Color(0xFF15803D).withValues(alpha: 0.25);
      textColor = const Color(0xFFA3E635);
      label = 'High ($percentage%)';
    } else if (confidence >= 0.50) {
      bgColor = const Color(0xFFB45309).withValues(alpha: 0.25);
      textColor = const Color(0xFFFBBF24);
      label = 'Moderate ($percentage%)';
    } else {
      bgColor = const Color(0xFFB91C1C).withValues(alpha: 0.25);
      textColor = const Color(0xFFF87171);
      label = 'Low ($percentage%)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
