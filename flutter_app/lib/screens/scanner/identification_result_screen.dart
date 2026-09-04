import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/identification.dart';
import '../../models/plant.dart';
import '../../services/flora_dex_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/conservation_badge.dart';
import '../ar/ar_view_screen.dart';
import '../chatbot/chatbot_screen.dart';

class IdentificationResultScreen extends StatefulWidget {
  final IdentificationResult result;
  final Uint8List? capturedImageBytes;

  const IdentificationResultScreen({
    super.key,
    required this.result,
    this.capturedImageBytes,
  });

  @override
  State<IdentificationResultScreen> createState() => _IdentificationResultScreenState();
}

class _IdentificationResultScreenState extends State<IdentificationResultScreen> {
  String? _expandedKey = "description";
  UnlockResult? _unlockResult;

  @override
  void initState() {
    super.initState();
    _triggerFloraDexUnlock();
  }

  Future<void> _triggerFloraDexUnlock() async {
    final plant = widget.result.plant;
    if (plant != null && plant.id > 0) {
      final res = await FloraDexService.unlockPlant(plant.id);
      if (mounted && res.isFirstTime) {
        setState(() {
          _unlockResult = res;
        });
      }
    }
  }

  void _toggleSection(String key) {
    setState(() {
      _expandedKey = (_expandedKey == key) ? null : key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ident = widget.result.identification;
    final plant = widget.result.plant;
    final confidencePct = (ident.confidence * 100).round();

    final displayName = plant?.commonName ?? ident.commonName ?? ident.scientificName;
    final displayScientific = plant?.scientificName ?? ident.scientificName;
    final displayFamily = plant?.family ?? ident.family ?? 'Flora';
    final displayRegion = plant?.nativeRegion ?? 'Indian Subcontinent';
    final displayHabitat = plant?.habitat ?? 'Natural Ecosystems';
    final displayStatus = plant?.conservationStatus ?? 'Least Concern';
    final displayDescription = plant?.description ?? ident.description ?? ident.details ?? widget.result.message ?? 'Identified species via Gemini Vision AI.';
    final displayEcological = plant?.ecologicalImportance ?? ident.ecologicalImportance ?? 'Supports native biodiversity, pollinators, and ecosystem equilibrium.';
    final displayThreats = plant?.threats ?? 'Habitat fragmentation and invasive competitor species.';
    final displayConservation = plant?.conservationActions ?? 'Preserve native specimen trees and report geo-observations.';
    final displayFeatures = plant?.identificationFeatures ?? ident.details ?? 'Identified from captured botanical leaf and flower structures.';

    final sections = [
      {'key': 'description', 'label': 'Description', 'content': displayDescription},
      {'key': 'ecological', 'label': 'Ecological Importance', 'content': displayEcological},
      {'key': 'threats', 'label': 'Threats', 'content': displayThreats},
      {'key': 'conservation', 'label': 'How You Can Help', 'content': displayConservation},
    ];

    // Dummy fallback plant if not directly from DB
    final effectivePlant = plant ??
        Plant(
          id: 0,
          scientificName: displayScientific,
          commonName: displayName,
          family: displayFamily,
          nativeRegion: displayRegion,
          conservationStatus: displayStatus,
          ecologicalImportance: displayEcological,
          description: displayDescription,
          threats: displayThreats,
          conservationActions: displayConservation,
          habitat: displayHabitat,
          identificationFeatures: displayFeatures,
          imageUrl: plant?.imageUrl,
        );

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppTheme.darkBackground,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x990D1410),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLime,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentLime.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      '$confidencePct% Match',
                      style: GoogleFonts.syne(
                        color: const Color(0xFF0D1410),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.capturedImageBytes != null)
                        Image.memory(widget.capturedImageBytes!, fit: BoxFit.cover)
                      else if (plant?.imageUrl != null)
                        Image.network(plant!.imageUrl!, fit: BoxFit.cover)
                      else
                        Image.network(
                          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
                          fit: BoxFit.cover,
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.2, 0.98],
                            colors: [
                              Color(0x330D1410),
                              Color(0xF50D1410),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              displayScientific,
                              style: GoogleFonts.dmSans(
                                color: AppTheme.accentLime,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConservationBadge(status: displayStatus, isMedium: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detail Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flora Dex Unlock Celebration Banner
                      if (_unlockResult != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A24), Color(0xFF0F1E13)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentLime, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentLime.withValues(alpha: 0.2),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLime.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.catching_pokemon,
                                  color: AppTheme.accentLime,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text(
                                          '🎉 UNLOCKED IN FLORA DEX!',
                                          style: TextStyle(
                                            color: AppTheme.accentLime,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+${_unlockResult!.xpAwarded} XP earned for campus biodiversity collection',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_unlockResult!.newAchievements.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '🏆 Honor Earned: ${_unlockResult!.newAchievements.first.title}',
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Info chips
                      Row(
                        children: [
                          _buildInfoChip(Icons.category_outlined, 'FAMILY', displayFamily),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.public_outlined, 'REGION', displayRegion),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.forest_outlined, 'HABITAT', displayHabitat),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Accordions
                      ...sections.map((sec) {
                        final key = sec['key'] as String;
                        final label = sec['label'] as String;
                        final content = sec['content'] as String;
                        final isExpanded = _expandedKey == key;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => _toggleSection(key),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.eco, color: AppTheme.accentLime, size: 16),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: GoogleFonts.syne(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: AppTheme.sageText,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    content,
                                    style: GoogleFonts.dmSans(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // Did You Know card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x14E8A030),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x40E8A030), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Field Note / Identification Feature',
                                  style: GoogleFonts.syne(
                                    color: AppTheme.amberAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayFeatures,
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFFD4AA70),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xF20D1410),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.accentLime.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ARViewScreen(plant: effectivePlant),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentLime,
                            foregroundColor: AppTheme.darkBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'View in AR',
                            style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1410),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatbotScreen(initialPlant: effectivePlant),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.surfaceBorder),
                            backgroundColor: AppTheme.surfaceCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Ask AI Guide',
                            style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentLime,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.sageText, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: AppTheme.sageText,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
