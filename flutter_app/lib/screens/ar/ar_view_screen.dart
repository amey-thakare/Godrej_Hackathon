import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../services/identification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_badge.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_icon_button.dart';
import '../chatbot/chatbot_screen.dart';

class ARViewScreen extends StatefulWidget {
  final Plant plant;

  const ARViewScreen({super.key, required this.plant});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  late Plant _currentPlant;
  bool _isScanning = false;
  bool _autoScanEnabled = true;
  Timer? _autoScanTimer;
  String _statusMessage = '🟢 Live AR Scanner Active • Align Flower';
  double _confidence = 0.95;
  String _activeLayer = 'Species Info';
  bool _cardOpen = true;

  late AnimationController _pulseController;
  final List<String> _layers = ['Species Info', 'Ecological Role', 'Field Notes'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPlant = widget.plant;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty && mounted) {
        final backCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        final controller = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        _cameraController = controller;
        await controller.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          _startLiveScanTimer();
        }
      }
    } catch (e) {
      debugPrint('AR camera init error: $e');
    }
  }

  void _startLiveScanTimer() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_autoScanEnabled && !_isScanning && _isCameraInitialized && mounted) {
        _triggerLiveFlowerScan();
      }
    });
  }

  Future<void> _triggerLiveFlowerScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = '🔍 Analyzing Flower & Leaf Live...';
    });

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();

      final result = await IdentificationService.identifyPlantFromBytes(
        bytes,
        'ar_live_flower.jpg',
      );

      if (mounted) {
        final ident = result.identification;
        final matchedPlant = result.plant ??
            Plant(
              id: 0,
              commonName: ident.commonName ?? (ident.scientificName != "Unknown" ? ident.scientificName : "Identified Flower"),
              scientificName: ident.scientificName,
              family: ident.family ?? 'Flora',
              nativeRegion: 'Indian Subcontinent',
              ecologicalImportance: ident.ecologicalImportance ?? 'Keystone species identified live via AR Vision.',
              conservationStatus: 'Least Concern',
              description: ident.description ?? 'Identified live via AR Botanical Vision.',
              threats: 'Habitat loss.',
              conservationActions: 'Protect native pollinators.',
              habitat: 'Natural Ecosystems',
              identificationFeatures: ident.details ?? 'Identified live via AR camera reticle.',
              imageUrl: '',
            );

        setState(() {
          _currentPlant = matchedPlant;
          _confidence = ident.confidence;
          _statusMessage = '🌸 Identified: ${matchedPlant.commonName} (${(ident.confidence * 100).toStringAsFixed(0)}% Match)';
        });
      }
    } catch (e) {
      debugPrint('Live AR scan error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '🟢 Live AR Scanner Active • Align Flower';
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoScanTimer?.cancel();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  String _getLayerContent() {
    switch (_activeLayer) {
      case 'Ecological Role':
        return '🐝 ${_currentPlant.ecologicalImportance}\n\nHabitat: ${_currentPlant.habitat}';
      case 'Field Notes':
        return '🌿 ${_currentPlant.identificationFeatures}\n\nThreats: ${_currentPlant.threats}';
      case 'Species Info':
      default:
        return 'Family: ${_currentPlant.family} · Region: ${_currentPlant.nativeRegion}\n\n${_currentPlant.description}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct = (_confidence * 100).round();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Viewport
          Positioned.fill(
            child: _isCameraInitialized &&
                    _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Image.network(
                    _currentPlant.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
                    fit: BoxFit.cover,
                  ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),

          // 2. AR Grid Painter Background
          Positioned.fill(
            child: CustomPaint(
              painter: _ARGridPainter(),
            ),
          ),

          // 3. Top Floating Liquid Glass Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    iconColor: AppTheme.textPrimary,
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Live Species Badge Pill
                  GlassContainer(
                    borderRadius: AppTheme.radiusXL,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    opacityColor: Colors.white,
                    opacity: 0.88,
                    blur: AppTheme.blurMedium,
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
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Text(
                            _currentPlant.commonName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GlassBadge(
                          label: '$confidencePct%',
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppTheme.accentForest,
                        ),
                      ],
                    ),
                  ),

                  // Auto Scan Live Switch Pill
                  GlassContainer(
                    borderRadius: AppTheme.radiusXL,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    opacityColor: Colors.white,
                    opacity: 0.88,
                    blur: AppTheme.blurMedium,
                    onTap: () {
                      setState(() {
                        _autoScanEnabled = !_autoScanEnabled;
                      });
                      if (_autoScanEnabled) _startLiveScanTimer();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Live AR',
                          style: TextStyle(
                            color: AppTheme.primaryForest,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 28,
                          height: 16,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _autoScanEnabled ? AppTheme.accentForest : AppTheme.surfaceBorder,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: _autoScanEnabled ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Live Status Pill Banner below Header
          Positioned(
            top: 84,
            left: 20,
            right: 20,
            child: Center(
              child: GlassContainer(
                borderRadius: AppTheme.radiusXL,
                opacityColor: Colors.white,
                opacity: 0.90,
                blur: AppTheme.blurMedium,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isScanning) ...[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accentForest,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        color: AppTheme.primaryForest,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Animated Spatial AR Target Reticle in Center
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.08);
                return Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: _LiveARReticlePainter(isScanning: _isScanning),
                  ),
                );
              },
            ),
          ),

          // 6. Bottom Floating Liquid Glass Layer Switcher & AR Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Layer Selector Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _layers.map((layer) {
                      final isSelected = _activeLayer == layer;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: GlassContainer(
                          opacityColor: isSelected ? AppTheme.primaryForest : Colors.white,
                          opacity: isSelected ? 0.92 : 0.85,
                          blur: AppTheme.blurSmall,
                          borderRadius: AppTheme.radiusXL,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          onTap: () {
                            setState(() {
                              _activeLayer = layer;
                            });
                          },
                          child: Text(
                            layer,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryForest,
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Floating Liquid Glass Bottom Card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: GlassContainer(
                    borderRadius: AppTheme.radiusXL,
                    opacityColor: Colors.white,
                    opacity: 0.92,
                    blur: AppTheme.blurLarge,
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentPlant.commonName,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentPlant.scientificName,
                                      style: const TextStyle(
                                        color: AppTheme.accentForest,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GlassIconButton(
                                icon: _cardOpen
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                size: 36,
                                iconSize: 20,
                                onPressed: () {
                                  setState(() {
                                    _cardOpen = !_cardOpen;
                                  });
                                },
                              ),
                            ],
                          ),

                          if (_cardOpen) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.mistBackground,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(color: AppTheme.surfaceBorder),
                              ),
                              child: Text(
                                _getLayerContent(),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GlassButton(
                                    label: 'Scan Flower Live',
                                    icon: Icons.camera_alt_rounded,
                                    height: 46,
                                    variant: GlassButtonVariant.primary,
                                    isLoading: _isScanning,
                                    onPressed: _triggerLiveFlowerScan,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GlassButton(
                                    label: 'Ask AI Guide',
                                    icon: Icons.auto_awesome_rounded,
                                    height: 46,
                                    variant: GlassButtonVariant.secondary,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatbotScreen(initialPlant: _currentPlant),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Live AR Hexagonal Reticle Painter
class _LiveARReticlePainter extends CustomPainter {
  final bool isScanning;

  _LiveARReticlePainter({required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = isScanning ? AppTheme.accentForest : Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isScanning ? 2.5 : 1.8;

    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final nodePaint = Paint()
      ..color = AppTheme.leafGreen
      ..style = PaintingStyle.fill;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.0, nodePaint);
    }

    canvas.drawCircle(center, 5, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _LiveARReticlePainter oldDelegate) {
    return oldDelegate.isScanning != isScanning;
  }
}

// AR Grid lines painter
class _ARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.leafGreen.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
