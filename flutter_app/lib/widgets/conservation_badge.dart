import 'package:flutter/material.dart';

class ConservationBadge extends StatelessWidget {
  final String status;

  const ConservationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    final lower = status.toLowerCase();

    if (lower.contains('vulnerable')) {
      color = const Color(0xFFF59E0B);
    } else if (lower.contains('endangered')) {
      color = const Color(0xFFEF4444);
    } else if (lower.contains('critical')) {
      color = const Color(0xFFDC2626);
    } else {
      color = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
