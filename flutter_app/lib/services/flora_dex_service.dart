import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flora_dex_entry.dart';

class UnlockResult {
  final bool isFirstTime;
  final int plantId;
  final int xpAwarded;
  final List<Achievement> newAchievements;

  const UnlockResult({
    required this.isFirstTime,
    required this.plantId,
    required this.xpAwarded,
    required this.newAchievements,
  });
}

class FloraDexService {
  static const String _unlockedIdsKey = 'floradex_unlocked_ids';
  static const String _discoveryDatesKey = 'floradex_discovery_dates';
  static const String _totalXpKey = 'floradex_total_xp';
  static const String _achievementsKey = 'floradex_achievements';
  static const String _firstScanBonusAwardedKey = 'floradex_first_scan_bonus_awarded';

  // Base list of system achievements
  static const List<Achievement> baseAchievements = [
    Achievement(
      id: 'first_scan',
      title: 'First Scan',
      description: 'Discover and identify your first plant species on campus.',
      icon: Icons.camera_alt_rounded,
      accentColor: Color(0xFF22C55E),
      xpReward: 50,
      isUnlocked: false,
    ),
    Achievement(
      id: 'rare_finder',
      title: 'Rare Finder',
      description: 'Find and unlock your first Rare plant species (Royal Palm, Ti Tall, or Screw Pine).',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFFA855F7),
      xpReward: 50,
      isUnlocked: false,
    ),
    Achievement(
      id: 'legendary_hunter',
      title: 'Legendary Hunter',
      description: 'Locate and document the Legendary heritage Rain Tree (Samanea saman).',
      icon: Icons.workspace_premium_rounded,
      accentColor: Color(0xFFF59E0B),
      xpReward: 100,
      isUnlocked: false,
    ),
    Achievement(
      id: 'family_collector',
      title: 'Family Collector',
      description: 'Collect all species belonging to a botanical family (Asteraceae or Asparagaceae).',
      icon: Icons.account_tree_rounded,
      accentColor: Color(0xFF3B82F6),
      xpReward: 75,
      isUnlocked: false,
    ),
    Achievement(
      id: 'campus_streak',
      title: 'Field Explorer',
      description: 'Scan and document campus flora across multiple field observation days.',
      icon: Icons.local_fire_department_rounded,
      accentColor: Color(0xFFEF4444),
      xpReward: 50,
      isUnlocked: false,
    ),
    Achievement(
      id: 'full_set',
      title: 'Grand Botanist',
      description: 'Discover and complete the entire 11-species campus flora catalog.',
      icon: Icons.military_tech_rounded,
      accentColor: Color(0xFF10B981),
      xpReward: 200,
      isUnlocked: false,
    ),
  ];

  // Initialize with initial demo discovered species (Bougainvillea) on very first launch
  static Future<void> initDefaultDemoIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_unlockedIdsKey)) {
      // Seed Bougainvillea (id 1) as discovered
      final initialIds = ['1'];
      final initialDates = {'1': 'Sep 5, 2026 • 09:30 AM'};
      final initialAchievements = {'first_scan': 'Sep 5, 2026 • 09:30 AM'};

      await prefs.setStringList(_unlockedIdsKey, initialIds);
      await prefs.setString(_discoveryDatesKey, jsonEncode(initialDates));
      await prefs.setString(_achievementsKey, jsonEncode(initialAchievements));
      await prefs.setInt(_totalXpKey, 80); // 10 base + 20 first scan + 50 achievement
      await prefs.setBool(_firstScanBonusAwardedKey, true);
    }
  }

  // Get set of all discovered plant IDs
  static Future<Set<int>> getUnlockedIds() async {
    await initDefaultDemoIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_unlockedIdsKey) ?? [];
    return list.map((idStr) => int.tryParse(idStr) ?? 0).where((id) => id > 0).toSet();
  }

  // Check if a specific plant is discovered
  static Future<bool> isDiscovered(int plantId) async {
    final unlocked = await getUnlockedIds();
    return unlocked.contains(plantId);
  }

  // Get discovery date formatted string
  static Future<String?> getDiscoveryDate(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawDates = prefs.getString(_discoveryDatesKey);
    if (rawDates != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(rawDates);
        return map[plantId.toString()] as String?;
      } catch (_) {}
    }
    return null;
  }

  // Get total XP accumulated
  static Future<int> getTotalXp() async {
    await initDefaultDemoIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXpKey) ?? 0;
  }

  // Get list of achievements with earned state
  static Future<List<Achievement>> getAchievements() async {
    await initDefaultDemoIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_achievementsKey);
    Map<String, dynamic> earnedMap = {};
    if (raw != null) {
      try {
        earnedMap = jsonDecode(raw);
      } catch (_) {}
    }

    return baseAchievements.map((ach) {
      final earnedDate = earnedMap[ach.id] as String?;
      return ach.copyWith(
        isUnlocked: earnedDate != null,
        unlockedAt: earnedDate,
      );
    }).toList();
  }

  // Main unlock plant workflow when scanned
  static Future<UnlockResult> unlockPlant(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedSet = await getUnlockedIds();

    if (unlockedSet.contains(plantId)) {
      return UnlockResult(
        isFirstTime: false,
        plantId: plantId,
        xpAwarded: 0,
        newAchievements: [],
      );
    }

    // 1. Calculate XP
    final meta = FloraDexPlantMeta.getMeta(plantId);
    int scanXp = meta.rarity.baseXP;

    // Check first-ever scan bonus (+20 XP)
    final bool firstBonusAwarded = prefs.getBool(_firstScanBonusAwardedKey) ?? false;
    if (!firstBonusAwarded) {
      scanXp += 20;
      await prefs.setBool(_firstScanBonusAwardedKey, true);
    }

    // 2. Persist new unlocked ID & date
    unlockedSet.add(plantId);
    await prefs.setStringList(
      _unlockedIdsKey,
      unlockedSet.map((e) => e.toString()).toList(),
    );

    final now = DateTime.now();
    final dateStr =
        '${_monthName(now.month)} ${now.day}, ${now.year} • ${_formatTime(now)}';

    Map<String, dynamic> datesMap = {};
    final rawDates = prefs.getString(_discoveryDatesKey);
    if (rawDates != null) {
      try {
        datesMap = jsonDecode(rawDates);
      } catch (_) {}
    }
    datesMap[plantId.toString()] = dateStr;
    await prefs.setString(_discoveryDatesKey, jsonEncode(datesMap));

    // 3. Evaluate Achievements
    Map<String, dynamic> earnedAchievements = {};
    final rawAch = prefs.getString(_achievementsKey);
    if (rawAch != null) {
      try {
        earnedAchievements = jsonDecode(rawAch);
      } catch (_) {}
    }

    final List<Achievement> newlyEarned = [];

    void awardAchievement(String achId) {
      if (!earnedAchievements.containsKey(achId)) {
        earnedAchievements[achId] = dateStr;
        final base = baseAchievements.firstWhere((a) => a.id == achId);
        scanXp += base.xpReward;
        newlyEarned.add(base.copyWith(isUnlocked: true, unlockedAt: dateStr));
      }
    }

    // A. First Scan
    awardAchievement('first_scan');

    // B. Rare Finder
    if (meta.rarity == RarityTier.rare) {
      awardAchievement('rare_finder');
    }

    // C. Legendary Hunter
    if (meta.rarity == RarityTier.legendary) {
      awardAchievement('legendary_hunter');
    }

    // D. Family Collector (Asteraceae: 4 & 5; Asparagaceae: 7 & 10)
    final hasAsteraceae = unlockedSet.contains(4) && unlockedSet.contains(5);
    final hasAsparagaceae = unlockedSet.contains(7) && unlockedSet.contains(10);
    if (hasAsteraceae || hasAsparagaceae) {
      awardAchievement('family_collector');
    }

    // E. Full Set
    if (unlockedSet.length >= 11) {
      awardAchievement('full_set');
    }

    // Save updated achievements
    await prefs.setString(_achievementsKey, jsonEncode(earnedAchievements));

    // Update total XP
    final currentTotalXp = prefs.getInt(_totalXpKey) ?? 0;
    final updatedXp = currentTotalXp + scanXp;
    await prefs.setInt(_totalXpKey, updatedXp);

    return UnlockResult(
      isFirstTime: true,
      plantId: plantId,
      xpAwarded: scanXp,
      newAchievements: newlyEarned,
    );
  }

  // Reset progress for clean demo/testing
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedIdsKey);
    await prefs.remove(_discoveryDatesKey);
    await prefs.remove(_totalXpKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_firstScanBonusAwardedKey);
    await initDefaultDemoIfEmpty();
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Jan';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
