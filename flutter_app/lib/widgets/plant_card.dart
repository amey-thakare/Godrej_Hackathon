import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../theme/app_theme.dart';
import 'glass/glass_badge.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.solidCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Botanical Thumbnail Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Image.network(
                    plant.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 72,
                        height: 72,
                        color: AppTheme.softSage,
                        child: const Icon(Icons.eco_rounded, color: AppTheme.primaryForest, size: 28),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.commonName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plant.scientificName,
                        style: const TextStyle(
                          color: AppTheme.accentForest,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.softSage,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              plant.family,
                              style: const TextStyle(
                                color: AppTheme.primaryForest,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassBadge(
                            label: plant.conservationStatus,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            color: AppTheme.accentForest,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
