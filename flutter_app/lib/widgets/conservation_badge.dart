import 'package:flutter/material.dart';

class ConservationBadge extends StatelessWidget {
  final String status;
  final bool isMedium;

  const ConservationBadge({
    super.key,
    required this.status,
    this.isMedium = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    Color dot;

    final lower = status.toLowerCase();

    if (lower.contains('least')) {
      bg = const Color(0x99064E3B); // emerald-900/60
      text = const Color(0xFF6EE7B7); // emerald-300
      border = const Color(0x66047857); // emerald-700/40
      dot = const Color(0xFF34D399); // emerald-400
    } else if (lower.contains('vulnerable')) {
      bg = const Color(0x9978350F); // amber-900/60
      text = const Color(0xFFFCD34D); // amber-300
      border = const Color(0x66B45309); // amber-700/40
      dot = const Color(0xFFFBBF24); // amber-400
    } else if (lower.contains('threatened')) {
      bg = const Color(0x997C2D12); // orange-900/60
      text = const Color(0xFFFDBA74); // orange-300
      border = const Color(0x66C2410C); // orange-700/40
      dot = const Color(0xFFFB923C); // orange-400
    } else {
      // Endangered / Critical
      bg = const Color(0x997F1D1D); // red-900/60
      text = const Color(0xFFFCA5A5); // red-300
      border = const Color(0x66B91C1C); // red-700/40
      dot = const Color(0xFFEF4444); // red-500
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMedium ? 12 : 9,
        vertical: isMedium ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMedium ? 6 : 5,
            height: isMedium ? 6 : 5,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: text,
              fontSize: isMedium ? 12 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
