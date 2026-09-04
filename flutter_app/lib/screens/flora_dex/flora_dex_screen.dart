import 'package:flutter/material.dart';
import '../../models/flora_dex_entry.dart';
import '../../models/plant.dart';
import '../../services/api_service.dart';
import '../../services/flora_dex_service.dart';
import '../../theme/app_theme.dart';
import 'achievements_screen.dart';
import 'locked_plant_sheet.dart';
import 'unlocked_plant_sheet.dart';

class FloraDexScreen extends StatefulWidget {
  final VoidCallback onGoScan;
  final VoidCallback? onOpenChatbot;

  const FloraDexScreen({
    super.key,
    required this.onGoScan,
    this.onOpenChatbot,
  });

  @override
  State<FloraDexScreen> createState() => _FloraDexScreenState();
}

class _FloraDexScreenState extends State<FloraDexScreen> {
  List<Plant> _plants = [];
  Set<int> _unlockedIds = {};
  int _totalXp = 0;
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadFloraDexData();
  }

  Future<void> _loadFloraDexData() async {
    try {
      final plants = await ApiService.getPlants();
      final unlocked = await FloraDexService.getUnlockedIds();
      final xp = await FloraDexService.getTotalXp();

      if (mounted) {
        setState(() {
          _plants = plants;
          _unlockedIds = unlocked;
          _totalXp = xp;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRankTitle(int xp) {
    if (xp >= 500) return 'Grand Botanist';
    if (xp >= 250) return 'Campus Guardian';
    if (xp >= 100) return 'Field Naturalist';
    return 'Novice Observer';
  }

  List<Plant> _getFilteredAndSortedPlants() {
    var list = List<Plant>.from(_plants);

    // Sort by rarity: Legendary (0) -> Rare (1) -> Uncommon (2) -> Common (3)
    list.sort((a, b) {
      final metaA = FloraDexPlantMeta.getMeta(a.id);
      final metaB = FloraDexPlantMeta.getMeta(b.id);
      final tierCompare = metaB.rarity.index.compareTo(metaA.rarity.index);
      if (tierCompare != 0) return tierCompare;
      return a.id.compareTo(b.id);
    });

    if (_selectedFilter != 'All') {
      list = list.where((p) {
        final meta = FloraDexPlantMeta.getMeta(p.id);
        return meta.rarity.label.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlants = _getFilteredAndSortedPlants();
    final discoveredCount = _plants.where((p) => _unlockedIds.contains(p.id)).length;
    final totalCount = _plants.length;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentLime))
            : RefreshIndicator(
                color: AppTheme.accentLime,
                backgroundColor: const Color(0xFF131D17),
                onRefresh: _loadFloraDexData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Bar with Trophy Link
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.catching_pokemon, color: AppTheme.accentLime, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'FLORA DEX',
                                      style: TextStyle(
                                        color: AppTheme.accentLime,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getRankTitle(_totalXp),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Achievements Shelf CTA Button
                            InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AchievementsScreen(),
                                  ),
                                );
                                _loadFloraDexData();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131D17),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B), size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Badges',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Progress Banner Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B2E1E), Color(0xFF0F1A13)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentLime.withValues(alpha: 0.08),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentLime.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.eco_rounded,
                                        color: AppTheme.accentLime,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Campus Discoveries',
                                          style: TextStyle(color: AppTheme.sageText, fontSize: 11),
                                        ),
                                        Text(
                                          '$discoveredCount / $totalCount species discovered',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // XP Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF22C55E)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.bolt_rounded, color: Color(0xFF22C55E), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$_totalXp XP',
                                        style: const TextStyle(
                                          color: Color(0xFF22C55E),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: totalCount == 0 ? 0.0 : (discoveredCount / totalCount),
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentLime),
                                minHeight: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter Chips Bar
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildFilterChip('All', null),
                            _buildFilterChip('Legendary', RarityTier.legendary.color),
                            _buildFilterChip('Rare', RarityTier.rare.color),
                            _buildFilterChip('Uncommon', RarityTier.uncommon.color),
                            _buildFilterChip('Common', RarityTier.common.color),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 2-Column Grid of Plant Cards
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final plant = filteredPlants[index];
                            final isUnlocked = _unlockedIds.contains(plant.id);
                            final meta = FloraDexPlantMeta.getMeta(plant.id);

                            return isUnlocked
                                ? _buildUnlockedCard(plant, meta)
                                : _buildLockedCard(plant, meta);
                          },
                          childCount: filteredPlants.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color? tierColor) {
    final isSelected = _selectedFilter == label;
    final color = tierColor ?? AppTheme.accentLime;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        backgroundColor: const Color(0xFF131D17),
        selectedColor: color,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : Colors.white12,
            width: 1,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  // Card for Unlocked Species
  Widget _buildUnlockedCard(Plant plant, FloraDexPlantMeta meta) {
    final rarity = meta.rarity;

    return InkWell(
      onTap: () async {
        final date = await FloraDexService.getDiscoveryDate(plant.id) ?? 'Discovered';
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => UnlockedPlantSheet(
            plant: plant,
            meta: meta,
            discoveryDate: date,
            onAskAi: widget.onOpenChatbot,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131D17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: rarity.color.withValues(alpha: 0.5),
            width: rarity == RarityTier.legendary ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: rarity.glowColor,
              blurRadius: rarity == RarityTier.legendary ? 16 : 8,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image with Rarity Badge
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                      ? Image.network(
                          plant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.eco_rounded, size: 40, color: AppTheme.sageText),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.eco_rounded, size: 40, color: AppTheme.sageText),
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xDD0D1410),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: rarity.color),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(rarity.icon, size: 10, color: rarity.color),
                          const SizedBox(width: 3),
                          Text(
                            rarity.label.toUpperCase(),
                            style: TextStyle(
                              color: rarity.color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xDD0D1410),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF22C55E),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plant.commonName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.scientificName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.sageText,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plant.family,
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        Text(
                          '+${rarity.baseXP} XP',
                          style: TextStyle(
                            color: rarity.color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card for Locked Species (Silhouette)
  Widget _buildLockedCard(Plant plant, FloraDexPlantMeta meta) {
    final rarity = meta.rarity;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => LockedPlantSheet(
            plant: plant,
            meta: meta,
            onGoScan: widget.onGoScan,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F0D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: rarity.color.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Silhouette Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0,
                            0, 0, 0, 0.90, 0,
                          ]),
                          child: Image.network(
                            plant.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.black),
                          ),
                        )
                      : Container(color: Colors.black),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xEE0D1410),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: rarity.color.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        rarity.label.toUpperCase(),
                        style: TextStyle(
                          color: rarity.color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: rarity.color.withValues(alpha: 0.6)),
                      ),
                      child: Icon(Icons.lock_rounded, color: rarity.color, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '???',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Undiscovered Specimen',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tap for hint',
                          style: TextStyle(color: AppTheme.sageText, fontSize: 10),
                        ),
                        Text(
                          '+${rarity.baseXP} XP',
                          style: TextStyle(
                            color: rarity.color.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
