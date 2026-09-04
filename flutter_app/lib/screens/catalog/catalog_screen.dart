import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_search_bar.dart';
import '../../widgets/plant_card.dart';
import '../plant_detail/plant_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Plant> _plants = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";

  final List<String> _filters = [
    "All",
    "Western Ghats",
    "Medicinal",
    "Keystone Trees",
    "Endangered",
  ];

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plants = await ApiService.getPlants(query: query);
      setState(() {
        _plants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  List<Plant> get _filteredPlants {
    return _plants.where((p) {
      bool matchFilter = true;
      if (_selectedFilter == "Endangered") {
        matchFilter = p.conservationStatus.toLowerCase().contains("endangered") ||
            p.conservationStatus.toLowerCase().contains("vulnerable");
      } else if (_selectedFilter == "Keystone Trees") {
        matchFilter = p.commonName.toLowerCase().contains("tree") ||
            p.description.toLowerCase().contains("tree") ||
            p.habitat.toLowerCase().contains("forest");
      } else if (_selectedFilter == "Medicinal") {
        matchFilter = p.description.toLowerCase().contains("medicinal") ||
            p.ecologicalImportance.toLowerCase().contains("medicinal") ||
            p.commonName.toLowerCase().contains("neem");
      } else if (_selectedFilter == "Western Ghats") {
        matchFilter = p.nativeRegion.toLowerCase().contains("ghats") ||
            p.nativeRegion.toLowerCase().contains("india") ||
            p.nativeRegion.toLowerCase().contains("maharashtra");
      }

      final query = _searchController.text.toLowerCase().trim();
      final matchSearch = query.isEmpty ||
          p.commonName.toLowerCase().contains(query) ||
          p.scientificName.toLowerCase().contains(query) ||
          p.family.toLowerCase().contains(query);

      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPlants;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Apple Headline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Native Flora',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Indian flora & ecosystem keystone species',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  GlassContainer(
                    borderRadius: AppTheme.radiusXL,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    opacityColor: Colors.white,
                    opacity: 0.88,
                    blur: AppTheme.blurSmall,
                    onTap: () => _fetchCatalog(query: _searchController.text),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded, color: AppTheme.primaryForest, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Sync',
                          style: TextStyle(
                            color: AppTheme.primaryForest,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Floating Liquid Glass Search Bar
              GlassSearchBar(
                controller: _searchController,
                hintText: 'Search native species, scientific name, region...',
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 12),

              // Floating Liquid Glass Filter Pills Row
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return GlassContainer(
                      opacityColor: isSelected ? AppTheme.primaryForest : Colors.white,
                      opacity: isSelected ? 0.92 : 0.85,
                      blur: AppTheme.blurSmall,
                      borderRadius: AppTheme.radiusXL,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryForest
                            : AppTheme.surfaceBorder,
                        width: 1.0,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryForest,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Plant Species Feed
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentForest),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 44),
                                const SizedBox(height: 10),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: () => _fetchCatalog(),
                                  child: const Text('Retry Connection'),
                                ),
                              ],
                            ),
                          )
                        : filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'No native species match your search filter.',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 90),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final plant = filtered[index];
                                  return PlantCard(
                                    plant: plant,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlantDetailScreen(plant: plant),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
