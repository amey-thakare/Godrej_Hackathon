import 'package:flutter/material.dart';
import '../../models/flora_dex_entry.dart';
import '../../services/flora_dex_service.dart';
import '../../theme/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final list = await FloraDexService.getAchievements();
    if (mounted) {
      setState(() {
        _achievements = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalXpFromBadges = _achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.xpReward);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Achievements Shelf',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF131D17),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.accentLime, size: 16),
                const SizedBox(width: 5),
                Text(
                  '+$totalXpFromBadges XP',
                  style: const TextStyle(
                    color: AppTheme.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentLime))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // Top Trophy Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2E1E), Color(0xFF0D1811)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Icon(
                          Icons.military_tech_rounded,
                          color: Color(0xFFF59E0B),
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$unlockedCount of ${_achievements.length} Badges Unlocked',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _achievements.isEmpty
                                    ? 0.0
                                    : unlockedCount / _achievements.length,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentLime,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Complete field discovery milestones to earn botanical honors.',
                              style: TextStyle(color: AppTheme.sageText, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'HONOR BADGES',
                  style: TextStyle(
                    color: AppTheme.sageText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Grid of 6 Badges
                ..._achievements.map((ach) => _buildAchievementCard(ach)),

                const SizedBox(height: 24),

                // XP Scoring Reference Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D17),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'XP & REWARD RULES',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildXpRow('Common Species Scan', '+10 XP', const Color(0xFF22C55E)),
                      _buildXpRow('Uncommon Species Scan', '+25 XP', const Color(0xFF3B82F6)),
                      _buildXpRow('Rare Species Scan', '+60 XP', const Color(0xFFA855F7)),
                      _buildXpRow('Legendary Species Scan', '+150 XP', const Color(0xFFF59E0B)),
                      _buildXpRow('First-Ever Discovery Bonus', '+20 XP', AppTheme.accentLime),
                      _buildXpRow('Milestone Achievement', '+50–200 XP', const Color(0xFFE0EAD0)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAchievementCard(Achievement ach) {
    final isEarned = ach.isUnlocked;
    final color = isEarned ? ach.accentColor : Colors.white24;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned ? const Color(0xFF131D17) : const Color(0xFF0C120F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEarned ? color.withValues(alpha: 0.4) : Colors.white10,
          width: isEarned ? 1.5 : 1.0,
        ),
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Badge Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isEarned ? color.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isEarned ? color : Colors.white12,
                width: 2,
              ),
            ),
            child: Icon(
              ach.icon,
              color: isEarned ? color : Colors.white24,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ach.title,
                      style: TextStyle(
                        color: isEarned ? Colors.white : Colors.white54,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isEarned
                            ? color.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isEarned ? color : Colors.white12),
                      ),
                      child: Text(
                        '+${ach.xpReward} XP',
                        style: TextStyle(
                          color: isEarned ? color : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ach.description,
                  style: const TextStyle(
                    color: AppTheme.sageText,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                if (isEarned && ach.unlockedAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Earned: ${ach.unlockedAt}',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ] else if (!isEarned) ...[
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: Colors.white30, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Locked',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpRow(String label, String points, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          Text(
            points,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
