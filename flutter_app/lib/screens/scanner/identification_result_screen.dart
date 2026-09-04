import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/identification.dart';
import '../../models/plant.dart';
import '../../services/flora_dex_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_badge.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_icon_button.dart';
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

    final sections = [
      {'key': 'description', 'label': 'Botanical Identification', 'content': displayDescription},
      {'key': 'ecological', 'label': 'Ecological Importance', 'content': displayEcological},
      {'key': 'threats', 'label': 'Habitat & Conservation Threats', 'content': displayThreats},
      {'key': 'conservation', 'label': 'Conservation Actions', 'content': displayConservation},
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Botanical Photography Header
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppTheme.darkBackground,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    iconColor: AppTheme.textPrimary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
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
                          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=1000',
                          fit: BoxFit.cover,
                        ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.2, 0.75, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.30),
                                Colors.black.withValues(alpha: 0.10),
                                AppTheme.darkBackground,
                              ],
                            ),
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
                            // Floating Glass Badges Row
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                GlassBadge(
                                  label: '$confidencePct% Match',
                                  icon: Icons.verified_rounded,
                                  color: AppTheme.accentForest,
                                ),
                                GlassBadge(
                                  label: 'Native • $displayRegion',
                                  icon: Icons.place_rounded,
                                  color: AppTheme.primaryForest,
                                ),
                                GlassBadge(
                                  label: displayStatus,
                                  icon: Icons.shield_outlined,
                                  color: AppTheme.amberAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                height: 1.12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayScientific,
                              style: const TextStyle(
                                color: AppTheme.accentForest,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detail Content Surface
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unlock celebration banner if first discovery
                      if (_unlockResult != null)
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          borderRadius: AppTheme.radiusLarge,
                          opacityColor: AppTheme.softSage,
                          opacity: 0.90,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: AppTheme.primaryForest,
                                size: 30,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'UNLOCKED IN MY FLORA DEX',
                                      style: TextStyle(
                                        color: AppTheme.primaryForest,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+${_unlockResult!.xpAwarded} XP earned for campus biodiversity notebook',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Single Unified Content Surface
                      Container(
                        decoration: AppTheme.solidCardDecoration,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Key Meta Specs Grid
                            Row(
                              children: [
                                _buildSpecColumn('FAMILY', displayFamily),
                                _buildSpecColumn('HABITAT', displayHabitat),
                                _buildSpecColumn('REGION', displayRegion),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: AppTheme.surfaceBorder, height: 1),
                            ),

                            // Unified Accordion Sections
                            ...sections.map((sec) {
                              final key = sec['key'] as String;
                              final label = sec['label'] as String;
                              final content = sec['content'] as String;
                              final isExpanded = _expandedKey == key;

                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () => _toggleSection(key),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.eco_rounded,
                                            color: AppTheme.accentForest,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              label,
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up_rounded
                                                : Icons.keyboard_arrow_down_rounded,
                                            color: AppTheme.textSecondary,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28, bottom: 12),
                                      child: Text(
                                        content,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  const Divider(color: AppTheme.surfaceBorder, height: 1),
                                ],
                              );
                            }),

                            const SizedBox(height: 16),

                            // Field Notes Card
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.mistBackground,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(color: AppTheme.surfaceBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.nature_people_rounded,
                                        color: AppTheme.primaryForest,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Field Identification Characteristics',
                                        style: TextStyle(
                                          color: AppTheme.primaryForest,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    displayFeatures,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
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
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Sticky Liquid Glass Action Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: GlassContainer(
              borderRadius: AppTheme.radiusXL,
              opacityColor: Colors.white,
              opacity: 0.90,
              blur: AppTheme.blurMedium,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'View in AR',
                      icon: Icons.view_in_ar_rounded,
                      variant: GlassButtonVariant.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ARViewScreen(plant: effectivePlant),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      label: 'Ask AI Guide',
                      icon: Icons.auto_awesome_rounded,
                      variant: GlassButtonVariant.secondary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatbotScreen(initialPlant: effectivePlant),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
