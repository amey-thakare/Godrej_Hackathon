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
      campusHint: 'Central quadrangle ancient banyan grove & heritage plaza',
      ecologicalFunFact:
          'A single mature banyan canopy can shelter more than 100 bird, mammal, and insect species with year-round fig crops.',
      bloomSeason: 'Year-round fig fruiting cycles',
    ),
    2: FloraDexPlantMeta(
      plantId: 2,
      rarity: RarityTier.common,
      campusHint: 'Campus boundary green belts & perimeter bio-fences',
      ecologicalFunFact:
          'Azadirachtin in neem leaves deters over 200 insect pest species while acting as a natural organic soil revitalizer.',
      bloomSeason: 'Spring (March – May)',
    ),
    3: FloraDexPlantMeta(
      plantId: 3,
      rarity: RarityTier.uncommon,
      campusHint: 'Retention ponds & bio-swales near water corridors',
      ecologicalFunFact:
          'Its deep purple berries provide vital monsoon carbohydrates and electrolytes for wild birds and fruit bats.',
      bloomSeason: 'Pre-monsoon (March – June)',
    ),
    4: FloraDexPlantMeta(
      plantId: 4,
      rarity: RarityTier.common,
      campusHint: 'Eastern heritage plaza & wildlife stepping corridors',
      ecologicalFunFact:
          'Releases significant oxygen even during the night via Crassulacean Acid Metabolism (CAM).',
      bloomSeason: 'Variable spring fig production',
    ),
    5: FloraDexPlantMeta(
      plantId: 5,
      rarity: RarityTier.uncommon,
      campusHint: 'Dry deciduous woodland ridge & rock garden perimeter',
      ecologicalFunFact:
          'Its remarkable crocodile-like bark can store clean drinkable water during harsh parched summer droughts.',
      bloomSeason: 'April – May blooms, fruits in winter',
    ),
    6: FloraDexPlantMeta(
      plantId: 6,
      rarity: RarityTier.legendary,
      campusHint: 'Shaded Western Ghats arboretum micro-climate',
      ecologicalFunFact:
          'A sacred rainforest understory jewel of the Western Ghats; critically threatened by destructive wild bark harvesting.',
      bloomSeason: 'February – April (Fragrant orange-red clusters)',
    ),
    7: FloraDexPlantMeta(
      plantId: 7,
      rarity: RarityTier.rare,
      campusHint: 'Forest border conservation belt & southern tree line',
      ecologicalFunFact:
          'Its nocturnal sweet flowers fall before dawn and are eagerly harvested by Asian palm civets and fruit bats.',
      bloomSeason: 'March – April (Night-blooming sweet blossoms)',
    ),
    8: FloraDexPlantMeta(
      plantId: 8,
      rarity: RarityTier.uncommon,
      campusHint: 'Medicinal nursery garden & sunny south terrace',
      ecologicalFunFact:
          'Its trifoliate leaves naturally absorb atmospheric pollutants and heavy particulate compounds from urban air.',
      bloomSeason: 'April – June (Aromatic pale green flowers)',
    ),
    9: FloraDexPlantMeta(
      plantId: 9,
      rarity: RarityTier.legendary,
      campusHint: 'Protected biodiversity sanctuary growing close to host trees',
      ecologicalFunFact:
          'A hemi-parasitic heritage tree whose root haustoria draw essential minerals from surrounding native host trees.',
      bloomSeason: 'Summer to monsoon (Small purplish flowers)',
    ),
    10: FloraDexPlantMeta(
      plantId: 10,
      rarity: RarityTier.rare,
      campusHint: 'North hill slope & open campus meadow canopy',
      ecologicalFunFact:
          'Known as "Palash", its blaze of scarlet flowers signals spring and feeds hundreds of parakeets and sunbirds.',
      bloomSeason: 'February – March (Spectacular fiery orange blaze)',
    ),
    11: FloraDexPlantMeta(
      plantId: 11,
      rarity: RarityTier.common,
      campusHint: 'Bioretention swales & roadside rain gardens',
      ecologicalFunFact:
          'A pioneer legume that fixes atmospheric nitrogen, restoring fertile organic matter into degraded soils.',
      bloomSeason: 'April – June (Fragrant pinkish-white blossoms)',
    ),
    12: FloraDexPlantMeta(
      plantId: 12,
      rarity: RarityTier.uncommon,
      campusHint: 'Perimeter walkway & exterior campus boundary',
      ecologicalFunFact:
          'Features characteristic 7-whorled leaves and autumn nocturnal blooms that attract hawk moths.',
      bloomSeason: 'October – November (Intense nocturnal fragrance)',
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
