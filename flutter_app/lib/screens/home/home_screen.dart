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
          // 1. Forest Canopy Background Image with Crisp Light Gradient Overlay
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
                  stops: [0.0, 0.30, 0.65, 1.0],
                  colors: [
                    Color(0xF0FFFFFF),
                    Color(0xDCF4FAF6),
                    Color(0xF2F4FAF6),
                    Color(0xFFF4FAF6),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Ergonomic Dashboard Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Campus Status Pill Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.surfaceBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF15803D).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                            const SizedBox(width: 8),
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.surfaceBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF15803D).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.accentLime,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Headline & Subtitle
                  Text(
                    'FIELD INTELLIGENCE',
                    style: GoogleFonts.syne(
                      color: AppTheme.accentLime,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover What's\nGrowing Around You",
                    style: GoogleFonts.syne(
                      color: AppTheme.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "AI-powered plant identification & real-time conservation data for India's native flora.",
                    style: GoogleFonts.dmSans(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row Cards
                  Row(
                    children: [
                      _buildStatCard('12', 'Native Species'),
                      const SizedBox(width: 10),
                      _buildStatCard('3', 'Endangered'),
                      const SizedBox(width: 10),
                      _buildStatCard('48', 'Observations'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ergonomic Quick Action Cards
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
                          onTap: () => onNavigateTab(4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // PRIMARY ERGONOMIC CTA (Bottom Thumb Reach Zone)
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: onOpenScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentLime,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppTheme.accentLime.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.surfaceBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF15803D).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
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
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.surfaceBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF15803D).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.accentLime, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.syne(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
