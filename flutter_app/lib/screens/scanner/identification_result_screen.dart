import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/identification.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confidence_badge.dart';
import '../../widgets/conservation_badge.dart';
import '../ar/ar_view_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../plant_detail/plant_detail_screen.dart';

class IdentificationResultScreen extends StatelessWidget {
  final IdentificationResult result;
  final Uint8List capturedImageBytes;

  const IdentificationResultScreen({
    super.key,
    required this.result,
    required this.capturedImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final ident = result.identification;
    final plant = result.plant;
    final isLowConfidence = ident.confidence < 0.50;

    // Fallback lightweight Plant model for AR and AI Chatbot if plant is not in curated DB
    final displayPlant = plant ??
        Plant(
          id: 0,
          commonName: ident.commonName ?? 'Identified Plant',
          scientificName: ident.scientificName,
          family: 'Flora',
          nativeRegion: 'Global / Introduced',
          ecologicalImportance: 'Identified in real-time via Gemini Multimodal Vision AI.',
          conservationStatus: 'Least Concern',
          description: 'Identified species.',
          threats: 'None reported.',
          conservationActions: 'Observe and protect flora.',
          habitat: 'Gardens / Urban Landscapes',
          identificationFeatures: 'Identified via camera.',
          imageUrl: '',
          plantnetSpeciesName: ident.scientificName,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.memory(
                      capturedImageBytes,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ConfidenceBadge(confidence: ident.confidence),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                ident.commonName ?? plant?.commonName ?? 'Identified Species',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                ident.scientificName,
                style: const TextStyle(
                  color: AppTheme.accentLime,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              if (isLowConfidence || result.message != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.warningAmber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          result.message ??
                              'Identification uncertain. Try capturing a clearer image of the leaves, flowers, bark, or full plant.',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (plant != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Family: ${plant.family}',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ConservationBadge(status: plant.conservationStatus),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Native Region',
                          style: TextStyle(
                            color: AppTheme.accentLime,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          plant.nativeRegion,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ecological Importance',
                          style: TextStyle(
                            color: AppTheme.accentLime,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          plant.ecologicalImportance,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Always present AR Mode button for any identified plant
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ARViewScreen(plant: displayPlant),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLime,
                    foregroundColor: AppTheme.darkBackground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.view_in_ar, size: 22),
                  label: const Text(
                    'View in AR Mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (plant != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailScreen(plant: plant),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.surfaceBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: AppTheme.surfaceCard,
                        ),
                        icon: const Icon(Icons.info, color: AppTheme.accentLime, size: 18),
                        label: const Text(
                          'Plant Details',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        ),
                      ),
                    ),
                  if (plant != null) const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatbotScreen(
                              initialPlant: displayPlant,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: AppTheme.surfaceCard,
                      ),
                      icon: const Icon(Icons.psychology, color: AppTheme.accentLime, size: 18),
                      label: const Text(
                        'Ask AI Guide',
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh, color: AppTheme.textMuted),
                  label: const Text(
                    'Scan Another Plant',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
