import 'package:flutter/material.dart';
import '../../models/flora_dex_entry.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';

class LockedPlantSheet extends StatelessWidget {
  final Plant plant;
  final FloraDexPlantMeta meta;
  final VoidCallback onGoScan;

  const LockedPlantSheet({
    super.key,
    required this.plant,
    required this.meta,
    required this.onGoScan,
  });

  @override
  Widget build(BuildContext context) {
    final rarity = meta.rarity;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1410),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33A8E63D), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mystery Silhouette Image Card
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xFF080C0A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: rarity.color.withValues(alpha: 0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: rarity.glowColor,
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0, 0, 0, 0, 0, // Red
                            0, 0, 0, 0, 0, // Green
                            0, 0, 0, 0, 0, // Blue
                            0, 0, 0, 0.88, 0, // Alpha
                          ]),
                          child: Image.network(
                            plant.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.forest_rounded, size: 72, color: Colors.black54),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.forest_rounded, size: 72, color: Colors.black54),
                        ),
                ),

                // Glowing Lock Badge Overlay
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0D1410),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rarity.color,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: rarity.color.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: rarity.color,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Title & Teaser Rarity
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: rarity.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rarity.color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(rarity.icon, size: 14, color: rarity.color),
                    const SizedBox(width: 5),
                    Text(
                      '${rarity.label.toUpperCase()} SPECIMEN',
                      style: TextStyle(
                        color: rarity.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${rarity.baseXP} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text(
            '???',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Undiscovered Campus Species',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.sageText,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 22),

          // Field Discovery Hints
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131D17),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.explore_rounded, color: AppTheme.accentLime, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'FIELD DISCOVERY HINTS',
                      style: TextStyle(
                        color: AppTheme.accentLime,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📍 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                          children: [
                            const TextSpan(
                              text: 'Found near: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            TextSpan(text: meta.campusHint),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌸 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                          children: [
                            const TextSpan(
                              text: 'Phenology: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            TextSpan(text: meta.bloomSeason),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CTA: Go Scan →
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onGoScan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentLime,
              foregroundColor: AppTheme.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.center_focus_strong_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  'Go Scan Specimen →',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
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
