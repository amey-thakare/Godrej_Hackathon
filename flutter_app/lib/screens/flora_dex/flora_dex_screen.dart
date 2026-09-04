import 'package:flutter/material.dart';
import '../../models/flora_dex_entry.dart';
import '../../models/plant.dart';
import '../../services/api_service.dart';
import '../../services/flora_dex_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_container.dart';
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
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentForest))
            : RefreshIndicator(
                color: AppTheme.accentForest,
                backgroundColor: Colors.white,
                onRefresh: _loadFloraDexData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Discoveries',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getRankTitle(_totalXp),
                                  style: const TextStyle(
                                    color: AppTheme.accentForest,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            GlassContainer(
                              borderRadius: AppTheme.radiusXL,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              opacityColor: Colors.white,
                              opacity: 0.88,
                              blur: AppTheme.blurSmall,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AchievementsScreen(),
                                  ),
                                );
                                _loadFloraDexData();
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.military_tech_rounded, color: AppTheme.amberAccent, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Badges',
                                    style: TextStyle(
                                      color: AppTheme.primaryForest,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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
                        decoration: AppTheme.solidCardDecoration,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.softSage,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.collections_bookmark_rounded,
                                        color: AppTheme.primaryForest,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Field Notebook Progress',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '$discoveredCount / $totalCount species identified',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.softSage,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.bolt_rounded, color: AppTheme.accentForest, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$_totalXp XP',
                                        style: const TextStyle(
                                          color: AppTheme.primaryForest,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
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
                                backgroundColor: AppTheme.surfaceBorder,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentForest),
                                minHeight: 8,
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
                            _buildFilterPill('All', null),
                            _buildFilterPill('Legendary', RarityTier.legendary.color),
                            _buildFilterPill('Rare', RarityTier.rare.color),
                            _buildFilterPill('Uncommon', RarityTier.uncommon.color),
                            _buildFilterPill('Common', RarityTier.common.color),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 2-Column Grid of Plant Notebook Cards
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

  Widget _buildFilterPill(String label, Color? tierColor) {
    final isSelected = _selectedFilter == label;
    final color = tierColor ?? AppTheme.primaryForest;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GlassContainer(
        opacityColor: isSelected ? color : Colors.white,
        opacity: isSelected ? 0.92 : 0.85,
        blur: AppTheme.blurSmall,
        borderRadius: AppTheme.radiusXL,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryForest,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

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
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        decoration: AppTheme.solidCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                            child: Icon(Icons.eco_rounded, size: 40, color: AppTheme.accentForest),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.eco_rounded, size: 40, color: AppTheme.accentForest),
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: rarity.color),
                      ),
                      child: Text(
                        rarity.label.toUpperCase(),
                        style: TextStyle(
                          color: rarity.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                        color: AppTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.scientificName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.accentForest,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plant.family,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                        Text(
                          '+${rarity.baseXP} XP',
                          style: TextStyle(
                            color: rarity.color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
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
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.mistBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.35, 0,
                          ]),
                          child: Image.network(
                            plant.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceBorder),
                          ),
                        )
                      : Container(color: AppTheme.surfaceBorder),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded, color: AppTheme.textMuted, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Undiscovered',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.commonName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tap hint',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                        Text(
                          '+${rarity.baseXP} XP',
                          style: TextStyle(
                            color: rarity.color.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
