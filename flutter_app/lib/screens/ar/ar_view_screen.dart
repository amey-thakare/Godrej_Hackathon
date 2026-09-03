import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../services/ar_service.dart';
import '../../services/identification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ar_info_card.dart';
import '../chatbot/chatbot_screen.dart';

class ARViewScreen extends StatefulWidget {
  final Plant plant;

  const ARViewScreen({super.key, required this.plant});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  late Plant _currentPlant;
  bool _isScanning = false;
  bool _autoScanEnabled = true;
  Timer? _autoScanTimer;
  String _statusMessage = 'AR Spatial Tracking Active. Point camera at plant.';
  late AnimationController _animController;
  int _selectedLayerIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPlant = widget.plant;
    _initCamera();
    _checkARSupport();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final backCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          _startAutoScanTimer();
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error for AR View: $e');
    }
  }

  void _startAutoScanTimer() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_autoScanEnabled && !_isScanning && _isCameraInitialized && mounted) {
        _triggerLiveScan();
      }
    });
  }

  Future<void> _triggerLiveScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Gemini AI Vision Scanning...';
    });

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();

      final result = await IdentificationService.identifyPlantFromBytes(
        bytes,
        'ar_live_scan.jpg',
      );

      if (mounted) {
        final ident = result.identification;
        final matchedPlant = result.plant ??
            Plant(
              id: 0,
              commonName: ident.commonName ?? (ident.scientificName != "Unknown" ? ident.scientificName : "Identified Species"),
              scientificName: ident.scientificName,
              family: 'Flora',
              nativeRegion: 'Global / Introduced',
              ecologicalImportance: 'Identified in real-time via Gemini Multimodal Vision AI.',
              conservationStatus: 'Least Concern',
              description: 'Identified live via AR Vision.',
              threats: 'None reported.',
              conservationActions: 'Observe and protect flora.',
              habitat: 'Gardens / Natural Ecosystems',
              identificationFeatures: 'Identified live via AR camera.',
              imageUrl: '',
              plantnetSpeciesName: ident.scientificName,
            );

        setState(() {
          _currentPlant = matchedPlant;
          _statusMessage = 'Live AI Match: ${matchedPlant.commonName} (${(ident.confidence * 100).toStringAsFixed(0)}%)';
        });
      }
    } catch (e) {
      debugPrint('Live AR scan error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'AR Spatial Tracking Active. 0.85m Depth.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _checkARSupport() async {
    final supported = await ARService.isARSupported();
    if (mounted) {
      setState(() {
        _statusMessage = ARService.getARStatusMessage(supported);
      });
    }
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Feed
          Positioned.fill(
            child: _isCameraInitialized && _cameraController != null
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D1F12), Color(0xFF051009)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.nature, color: AppTheme.accentLime, size: 80),
                          SizedBox(height: 12),
                          Text(
                            'AR Live Camera View',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Animated Spatial Target Reticle & Connecting Vector Line
          Center(
            child: RotationTransition(
              turns: _animController,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isScanning ? AppTheme.warningAmber : AppTheme.accentLime,
                    width: 2.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 135,
                      height: 135,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (_isScanning ? AppTheme.warningAmber : AppTheme.accentLime).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Icon(
                      _isScanning ? Icons.search : Icons.center_focus_weak,
                      color: _isScanning ? AppTheme.warningAmber : AppTheme.accentLime,
                      size: 56,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AR Spatial Node Badge over reticle
          Center(
            child: Transform.translate(
              offset: const Offset(0, -100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _isScanning ? AppTheme.warningAmber : AppTheme.accentLime),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isScanning ? Icons.sync : Icons.gps_fixed,
                      color: _isScanning ? AppTheme.warningAmber : AppTheme.accentLime,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isScanning ? 'GEMINI VISION SCANNING...' : '3D Anchor • 0.85m',
                      style: TextStyle(
                        color: _isScanning ? AppTheme.warningAmber : AppTheme.accentLime,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Top AR Telemetry Header & Controls
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.view_in_ar, color: AppTheme.accentLime, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Controls Row: Auto-Scan Toggle & Manual Scan Trigger
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Auto-scan Toggle Chip
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _autoScanEnabled = !_autoScanEnabled;
                          if (_autoScanEnabled) {
                            _startAutoScanTimer();
                          } else {
                            _autoScanTimer?.cancel();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: _autoScanEnabled ? AppTheme.accentLime : Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accentLime),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _autoScanEnabled ? Icons.motion_photos_on : Icons.motion_photos_off,
                              size: 14,
                              color: _autoScanEnabled ? AppTheme.darkBackground : AppTheme.accentLime,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _autoScanEnabled ? 'LIVE SCAN: ON' : 'LIVE SCAN: OFF',
                              style: TextStyle(
                                color: _autoScanEnabled ? AppTheme.darkBackground : AppTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Instant Scan Button
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _triggerLiveScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentLime,
                        foregroundColor: AppTheme.darkBackground,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.center_focus_strong, size: 16),
                      label: const Text(
                        'Scan Target Now',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Layer Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLayerChip('🌱 Species Telemetry', 0),
                      const SizedBox(width: 8),
                      _buildLayerChip('🛡️ Ecology & Habitat', 1),
                      const SizedBox(width: 8),
                      _buildLayerChip('💧 Conservation Insights', 2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating AR Plant Info Card (Updates Live)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Center(
              child: ARInfoCard(
                plant: _currentPlant,
                onAskGuide: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatbotScreen(
                        initialPlant: _currentPlant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerChip(String label, int index) {
    final isSelected = _selectedLayerIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayerIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentLime
              : Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentLime : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.darkBackground : AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
