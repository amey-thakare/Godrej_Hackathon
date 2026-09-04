import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_badge.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_icon_button.dart';
import '../ar/ar_view_screen.dart';
import '../chatbot/chatbot_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  String? _expandedKey = "description";

  void _toggleSection(String key) {
    setState(() {
      _expandedKey = (_expandedKey == key) ? null : key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    final sections = [
      {'key': 'description', 'label': 'Botanical Description', 'content': plant.description},
      {'key': 'ecological', 'label': 'Ecological Importance', 'content': plant.ecologicalImportance},
      {'key': 'threats', 'label': 'Ecological Threats', 'content': plant.threats},
      {'key': 'conservation', 'label': 'Conservation Actions', 'content': plant.conservationActions},
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image Header
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
                      Image.network(
                        plant.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=1000',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: AppTheme.primaryForest);
                        },
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
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                GlassBadge(
                                  label: 'Native • ${plant.nativeRegion}',
                                  icon: Icons.place_rounded,
                                  color: AppTheme.primaryForest,
                                ),
                                GlassBadge(
                                  label: plant.conservationStatus,
                                  icon: Icons.shield_outlined,
                                  color: AppTheme.amberAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              plant.commonName,
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
                              plant.scientificName,
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
                  child: Container(
                    decoration: AppTheme.solidCardDecoration,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildSpecColumn('FAMILY', plant.family),
                            _buildSpecColumn('HABITAT', plant.habitat),
                            _buildSpecColumn('REGION', plant.nativeRegion),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: AppTheme.surfaceBorder, height: 1),
                        ),

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
                                plant.identificationFeatures,
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
                ),
              ),
            ],
          ),

          // Floating Action Bar
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
                            builder: (context) => ARViewScreen(plant: plant),
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
                            builder: (context) => ChatbotScreen(initialPlant: plant),
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
