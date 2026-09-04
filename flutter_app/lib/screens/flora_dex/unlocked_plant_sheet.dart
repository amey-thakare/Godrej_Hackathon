import 'package:flutter/material.dart';
import '../../models/flora_dex_entry.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';
import '../plant_detail/plant_detail_screen.dart';

class UnlockedPlantSheet extends StatelessWidget {
  final Plant plant;
  final FloraDexPlantMeta meta;
  final String discoveryDate;
  final VoidCallback? onAskAi;

  const UnlockedPlantSheet({
    super.key,
    required this.plant,
    required this.meta,
    required this.discoveryDate,
    this.onAskAi,
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
      child: SingleChildScrollView(
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
            const SizedBox(height: 18),

            // Plant Specimen Image with Rarity Frame
            Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF131D17),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: rarity.color.withValues(alpha: 0.5),
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                        ? Image.network(
                            plant.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.eco_rounded, size: 64, color: AppTheme.sageText),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.eco_rounded, size: 64, color: AppTheme.sageText),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0D1410),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: rarity.color),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(rarity.icon, size: 14, color: rarity.color),
                            const SizedBox(width: 5),
                            Text(
                              rarity.label.toUpperCase(),
                              style: TextStyle(
                                color: rarity.color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0D1410),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          '+${rarity.baseXP} XP',
                          style: const TextStyle(
                            color: AppTheme.accentLime,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 14,
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'First Discovered: $discoveryDate',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Names & Family
            Text(
              plant.commonName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              plant.scientificName,
              style: const TextStyle(
                color: AppTheme.accentLime,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // Botanical Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('Family', plant.family, Icons.account_tree_outlined),
                _buildTag('IUCN', plant.conservationStatus, Icons.shield_outlined),
                _buildTag('Region', plant.nativeRegion, Icons.place_outlined),
              ],
            ),

            const SizedBox(height: 18),

            // Flavor Text / Ecological Fun Fact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D17),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: rarity.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: rarity.color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'ECOLOGICAL FUN FACT',
                        style: TextStyle(
                          color: rarity.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.ecologicalFunFact,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Earned Badges Showcase
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1813),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Badges Earned From This Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rarity == RarityTier.legendary
                              ? '🏆 Legendary Hunter  •  🌟 Native Explorer'
                              : rarity == RarityTier.rare
                                  ? '🔮 Rare Finder  •  🌟 Native Explorer'
                                  : '🌿 First Scan  •  🌟 Native Explorer',
                          style: const TextStyle(
                            color: AppTheme.sageText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlantDetailScreen(plant: plant),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text('Field Guide'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentLime,
                      side: const BorderSide(color: AppTheme.accentLime),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onAskAi != null) onAskAi!();
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Ask AI Guide'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentLime,
                      foregroundColor: AppTheme.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF131D17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.sageText),
          const SizedBox(width: 4),
          Text(
            '$title: $val',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
