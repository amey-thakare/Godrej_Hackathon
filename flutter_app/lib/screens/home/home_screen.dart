import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onOpenScanner;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenScanner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. Forest Canopy Background Image with Gradient Overlay
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1693743459489-7bc63e539a73?w=800&h=1200&fit=crop&auto=format',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppTheme.darkBackground);
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.35, 0.70, 1.0],
                  colors: [
                    Color(0xCC0D1410),
                    Color(0x730D1410),
                    Color(0xD90D1410),
                    Color(0xFF0D1410),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status / Campus Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x990D1410),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accentLime.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Godrej Campus',
                              style: TextStyle(
                                color: AppTheme.accentLime,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x990D1410),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentLime.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.accentLime,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Headline & Eyebrow
                  Text(
                    'FIELD INTELLIGENCE',
                    style: GoogleFonts.syne(
                      color: AppTheme.accentLime,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover What's\nGrowing Around You",
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "AI-powered plant identification & real-time conservation data for India's native biodiversity.",
                    style: GoogleFonts.dmSans(
                      color: AppTheme.sageText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Row (12 Species, 3 Endangered, 48 Observations)
                  Row(
                    children: [
                      _buildStatCard('12', 'Native Species'),
                      const SizedBox(width: 10),
                      _buildStatCard('3', 'Endangered'),
                      const SizedBox(width: 10),
                      _buildStatCard('48', 'Observations'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Feature Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.eco_rounded,
                          title: 'Plant Catalog',
                          subtitle: 'Browse 12 species',
                          onTap: () => onNavigateTab(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Ask AI Guide',
                          subtitle: 'Gemini expert',
                          onTap: () => onNavigateTab(3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bottom Scan CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onOpenScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentLime,
                        foregroundColor: AppTheme.darkBackground,
                        elevation: 4,
                        shadowColor: AppTheme.accentLime.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scan a Plant',
                            style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1410),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌿', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xB20D1410),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.accentLime.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: GoogleFonts.syne(
                color: AppTheme.accentLime,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppTheme.sageText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xB20D1410),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accentLime.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.accentLime, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.syne(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: AppTheme.sageText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
