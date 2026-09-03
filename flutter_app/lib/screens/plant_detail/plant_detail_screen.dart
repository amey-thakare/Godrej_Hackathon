import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../theme/app_theme.dart';
import '../../widgets/conservation_badge.dart';
import '../ar/ar_view_screen.dart';
import '../chatbot/chatbot_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    plant.imageUrl ??
                        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primaryForest,
                        child: const Icon(Icons.nature, color: AppTheme.accentLime, size: 80),
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppTheme.darkBackground],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.commonName,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plant.scientificName,
                              style: const TextStyle(
                                color: AppTheme.accentLime,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConservationBadge(status: plant.conservationStatus),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.view_in_ar, size: 20),
                          label: const Text('View in AR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatbotScreen(initialPlant: plant),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.surfaceBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppTheme.surfaceCard,
                          ),
                          icon: const Icon(Icons.psychology, color: AppTheme.accentLime, size: 20),
                          label: const Text('Ask AI Guide', style: TextStyle(color: AppTheme.textPrimary)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow('Family', plant.family, Icons.category),
                          const Divider(color: AppTheme.surfaceBorder, height: 20),
                          _buildDetailRow('Native Region', plant.nativeRegion, Icons.public),
                          const Divider(color: AppTheme.surfaceBorder, height: 20),
                          _buildDetailRow('Habitat', plant.habitat, Icons.landscape),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Overview & Description'),
                  const SizedBox(height: 8),
                  Text(
                    plant.description,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Identification Features'),
                  const SizedBox(height: 8),
                  Text(
                    plant.identificationFeatures,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Ecological Importance'),
                  const SizedBox(height: 8),
                  Text(
                    plant.ecologicalImportance,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Threats'),
                  const SizedBox(height: 8),
                  Text(
                    plant.threats,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('How You Can Help'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryForest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryForest),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.volunteer_activism, color: AppTheme.accentLime, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plant.conservationActions,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentLime, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
