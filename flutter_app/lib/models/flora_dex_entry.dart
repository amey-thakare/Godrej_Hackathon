import 'package:flutter/material.dart';

enum RarityTier {
  common,
  uncommon,
  rare,
  legendary,
}

extension RarityTierExtension on RarityTier {
  String get label {
    switch (this) {
      case RarityTier.common:
        return 'Common';
      case RarityTier.uncommon:
        return 'Uncommon';
      case RarityTier.rare:
        return 'Rare';
      case RarityTier.legendary:
        return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case RarityTier.common:
        return const Color(0xFF22C55E); // Emerald Green
      case RarityTier.uncommon:
        return const Color(0xFF3B82F6); // Electric Blue
      case RarityTier.rare:
        return const Color(0xFFA855F7); // Mystic Purple
      case RarityTier.legendary:
        return const Color(0xFFF59E0B); // Amber / Radiant Gold
    }
  }

  Color get glowColor {
    switch (this) {
      case RarityTier.common:
        return const Color(0x3322C55E);
      case RarityTier.uncommon:
        return const Color(0x333B82F6);
      case RarityTier.rare:
        return const Color(0x44A855F7);
      case RarityTier.legendary:
        return const Color(0x66F59E0B);
    }
  }

  int get baseXP {
    switch (this) {
      case RarityTier.common:
        return 10;
      case RarityTier.uncommon:
        return 25;
      case RarityTier.rare:
        return 60;
      case RarityTier.legendary:
        return 150;
    }
  }

  IconData get icon {
    switch (this) {
      case RarityTier.common:
        return Icons.eco_rounded;
      case RarityTier.uncommon:
        return Icons.water_drop_rounded;
      case RarityTier.rare:
        return Icons.auto_awesome_rounded;
      case RarityTier.legendary:
        return Icons.workspace_premium_rounded;
    }
  }
}

class FloraDexPlantMeta {
  final int plantId;
  final RarityTier rarity;
  final String campusHint;
  final String ecologicalFunFact;
  final String bloomSeason;

  const FloraDexPlantMeta({
    required this.plantId,
    required this.rarity,
    required this.campusHint,
    required this.ecologicalFunFact,
    required this.bloomSeason,
  });

  static const Map<int, FloraDexPlantMeta> catalogMeta = {
    1: FloraDexPlantMeta(
      plantId: 1,
      rarity: RarityTier.common,
      campusHint: 'Campus perimeter bio-fences, sun-drenched archways & stone pergolas',
      ecologicalFunFact:
          'Its dense, thorny entanglement creates safe shelter for small garden birds away from urban predators.',
      bloomSeason: 'Year-round in warm climates (Peak Nov – May)',
    ),
    2: FloraDexPlantMeta(
      plantId: 2,
      rarity: RarityTier.uncommon,
      campusHint: 'Campus retention pond bank & stream side green belts',
      ecologicalFunFact:
          'Can produce 35% more oxygen and sequester up to 12 tonnes of CO2 per hectare annually compared to many timber trees.',
      bloomSeason: 'Infrequent monocarpic multi-decade flowering',
    ),
    3: FloraDexPlantMeta(
      plantId: 3,
      rarity: RarityTier.common,
      campusHint: 'Sunny central courtyard borders & pollinator observation patches',
      ecologicalFunFact:
          'Its nectar-rich tubular blossoms are custom-shaped for long-tongued native bees and nectar-feeding sunbirds.',
      bloomSeason: 'Almost year-round (Peak post-monsoon to spring)',
    ),
    4: FloraDexPlantMeta(
      plantId: 4,
      rarity: RarityTier.uncommon,
      campusHint: 'Botanical greenhouse conservatory & student seasonal flower beds',
      ecologicalFunFact:
          'Provides crucial late-season nectar when most other flowering perennials have ceased blooming for the winter.',
      bloomSeason: 'Autumn to mid-winter (October – January)',
    ),
    5: FloraDexPlantMeta(
      plantId: 5,
      rarity: RarityTier.uncommon,
      campusHint: 'Agricultural demonstration plots & open pollinator meadow',
      ecologicalFunFact:
          'Young flower heads track the sun across the sky daily; mature dried seed heads feed dozens of wild bird species.',
      bloomSeason: 'Summer to post-monsoon (June – October)',
    ),
    6: FloraDexPlantMeta(
      plantId: 6,
      rarity: RarityTier.rare,
      campusHint: 'Grand campus ceremonial entrance avenue & administration concourse',
      ecologicalFunFact:
          'The lofty crownshaft acts as high-rise nesting platforms for urban bats and cavity-nesting parakeets.',
      bloomSeason: 'Summer flowering with autumn dark purple fruit clusters',
    ),
    7: FloraDexPlantMeta(
      plantId: 7,
      rarity: RarityTier.common,
      campusHint: 'Shaded courtyard understory beds & indoor botanical atrium',
      ecologicalFunFact:
          'Broad colorful leaves act as micro-umbrellas, creating shaded, humid soil microhabitats for beneficial insects.',
      bloomSeason: 'Late winter to spring (Terminal panicles of tiny flowers)',
    ),
    8: FloraDexPlantMeta(
      plantId: 8,
      rarity: RarityTier.uncommon,
      campusHint: 'Pathway structural hedges & medicinal garden perimeter',
      ecologicalFunFact:
          'Its sweet nocturnal fragrance intensifies after sunset specifically to attract night-flying pollinating hawk moths.',
      bloomSeason: 'Year-round (Peak during warm, humid months)',
    ),
    9: FloraDexPlantMeta(
      plantId: 9,
      rarity: RarityTier.legendary,
      campusHint: 'Central heritage lawn & ancient campus quadrangle',
      ecologicalFunFact:
          'Its colossal canopy can spread over 60 meters wide, fixing atmospheric nitrogen while significantly cooling ground temperatures.',
      bloomSeason: 'March – May & post-monsoon (Puffball pink-and-white blooms)',
    ),
    10: FloraDexPlantMeta(
      plantId: 10,
      rarity: RarityTier.rare,
      campusHint: 'South botanical slope border & multi-layered canopy edge',
      ecologicalFunFact:
          'Mature multi-stem clusters form an interwoven root matrix that locks slope topsoil during torrential rains.',
      bloomSeason: 'Spring flushes with persistent architectural foliage',
    ),
    11: FloraDexPlantMeta(
      plantId: 11,
      rarity: RarityTier.rare,
      campusHint: 'Rock garden perimeter & arid succulent terrace',
      ecologicalFunFact:
          'Its thick aerial prop roots anchor into steep rocky terrain, acting as natural windbreaks and drought-resistant soil anchors.',
      bloomSeason: 'Variable tropical flowering; celebrated for variegated evergreen spirals',
    ),
  };

  static FloraDexPlantMeta getMeta(int plantId) {
    return catalogMeta[plantId] ??
        FloraDexPlantMeta(
          plantId: plantId,
          rarity: RarityTier.common,
          campusHint: 'Campus nature trail & botanical garden',
          ecologicalFunFact:
              'Contributes to local ecosystem biodiversity and urban carbon sequestration.',
          bloomSeason: 'Seasonal native blooming',
        );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final int xpReward;
  final bool isUnlocked;
  final String? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.xpReward,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    String? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      accentColor: accentColor,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
