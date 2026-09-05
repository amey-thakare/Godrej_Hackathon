import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onOpenScanner;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenScanner,
  });

  void _openARMode(BuildContext context) {
    // Navigate to the scanner screen — the scanner has a proper
    // AR-mode button that captures a photo, identifies the plant via
    // Gemini Vision, and then opens ARViewScreen with the correct plant.
    onOpenScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. Botanical Macro Photo Background with Environmental Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.52,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=1000&h=1400&fit=crop&auto=format',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppTheme.primaryForest);
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 0.85, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          AppTheme.darkBackground.withValues(alpha: 0.75),
                          AppTheme.darkBackground,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Scrollable Liquid Glass Interface
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Floating Liquid Glass Status Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassContainer(
                        borderRadius: AppTheme.radiusXL,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        opacity: 0.82,
                        blur: AppTheme.blurSmall,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.leafGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Western Ghats Region',
                              style: TextStyle(
                                color: AppTheme.primaryForest,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const GlassContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 22,
                        opacity: 0.82,
                        blur: AppTheme.blurSmall,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.primaryForest,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Hero Title & Description
                  const Text(
                    "Discover India's\nNative Flora",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      height: 1.12,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Identify, explore and understand the plants around you with field AI.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // PRIMARY LIQUID GLASS HERO CTAS (Side-by-side or dual row)
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Identify Plant',
                          icon: Icons.camera_alt_rounded,
                          height: 54,
                          variant: GlassButtonVariant.primary,
                          onPressed: onOpenScanner,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassButton(
                          label: 'View in AR',
                          icon: Icons.view_in_ar_rounded,
                          height: 54,
                          variant: GlassButtonVariant.secondary,
                          onPressed: () => _openARMode(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Secondary Floating Quick Action Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildQuickActionPill(
                          icon: Icons.view_in_ar_rounded,
                          label: 'View in AR',
                          onTap: () => _openARMode(context),
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionPill(
                          icon: Icons.auto_stories_rounded,
                          label: 'Explore Flora',
                          onTap: () => onNavigateTab(2),
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionPill(
                          icon: Icons.collections_bookmark_rounded,
                          label: 'My Discoveries',
                          onTap: () => onNavigateTab(3),
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionPill(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Ask AI Guide',
                          onTap: () => onNavigateTab(4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Solid Surface Biodiversity Overview Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.solidCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Field Intelligence Overview',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Icon(
                              Icons.north_east_rounded,
                              size: 18,
                              color: AppTheme.textSecondary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatItem('12', 'Native Species'),
                            _buildDivider(),
                            _buildStatItem('3', 'Endangered'),
                            _buildDivider(),
                            _buildStatItem('48', 'Observations'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Spacing for floating bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      opacityColor: Colors.white,
      opacity: 0.85,
      blur: AppTheme.blurMedium,
      borderRadius: AppTheme.radiusXL,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryForest),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryForest,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: AppTheme.primaryForest,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppTheme.surfaceBorder,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
