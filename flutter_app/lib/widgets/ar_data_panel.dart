import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';

class ArDataPanel extends StatelessWidget {
  final Plant plant;

  const ArDataPanel({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340, // Fixed size for consistent AR capture
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFA050505), // Ultra high contrast black for outdoor AR
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentForest, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentForest.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant.commonName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            plant.scientificName,
            style: const TextStyle(
              color: AppTheme.accentForest,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white30, height: 32, thickness: 1),
          _buildInfoRow(Icons.account_tree_rounded, 'Family', plant.family),
          _buildInfoRow(Icons.public_rounded, 'Region', plant.nativeRegion),
          _buildInfoRow(Icons.eco_rounded, 'Role', plant.ecologicalImportance),
          _buildInfoRow(Icons.security_rounded, 'Status', plant.conservationStatus),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.leafGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
