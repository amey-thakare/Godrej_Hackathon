import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';
import '../../widgets/conservation_badge.dart';
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
      {'key': 'description', 'label': 'Description', 'content': plant.description},
      {'key': 'ecological', 'label': 'Ecological Importance', 'content': plant.ecologicalImportance},
      {'key': 'threats', 'label': 'Threats', 'content': plant.threats},
      {'key': 'conservation', 'label': 'Conservation Actions', 'content': plant.conservationActions},
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image with Gradient
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        plant.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: AppTheme.primaryForest);
                        },
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
                      // Title on Image
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.commonName,
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              plant.scientificName,
                              style: GoogleFonts.dmSans(
                                color: AppTheme.accentLime,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConservationBadge(status: plant.conservationStatus, isMedium: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Chips Row
                      Row(
                        children: [
                          _buildInfoChip(Icons.category_outlined, 'FAMILY', plant.family),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.public_outlined, 'REGION', plant.nativeRegion),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.forest_outlined, 'HABITAT', plant.habitat),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Accordion Sections
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

                      // Did You Know Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x14E8A030), // rgba(232,160,48,0.08)
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
                                  'Did You Know / Identification Feature',
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
                              plant.identificationFeatures,
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
                                builder: (context) => ARViewScreen(plant: plant),
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
                                builder: (context) => ChatbotScreen(initialPlant: plant),
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
