import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/plant.dart';
import '../../services/identification_service.dart';
import '../../theme/app_theme.dart';

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
  bool _autoScanEnabled = false;
  Timer? _autoScanTimer;
  String _statusMessage = 'AR Spatial Tracking Active';
  String _activeLayer = 'Species Info';
  bool _cardOpen = true;

  late AnimationController _pulseController;
  final List<String> _layers = ['Species Info', 'Threats', 'Fun Facts'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPlant = widget.plant;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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
          ResolutionPreset.medium,
          enableAudio: false,
        );
        _cameraController = controller;
        await controller.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          _startAutoScanTimer();
        }
      }
    } catch (e) {
      debugPrint('AR camera init error: $e');
    }
  }

  void _startAutoScanTimer() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
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
      _statusMessage = 'AI Vision Identifying Species...';
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
              nativeRegion: 'Indian Subcontinent',
              ecologicalImportance: 'Identified in real-time via AI Vision.',
              conservationStatus: 'Least Concern',
              description: 'Identified live via AR Vision.',
              threats: 'None reported.',
              conservationActions: 'Observe and protect flora.',
              habitat: 'Natural Ecosystems',
              identificationFeatures: 'Identified live via AR camera.',
              imageUrl: '',
            );

        setState(() {
          _currentPlant = matchedPlant;
          _statusMessage = 'Identified: ${matchedPlant.commonName} (${(ident.confidence * 100).toStringAsFixed(0)}%)';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.accentLime, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recognized: ${matchedPlant.commonName} (${(ident.confidence * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E3A27),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Live AR scan error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'AR Spatial Tracking Active · 0.85m Depth';
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
      case 'Threats':
        return '⚠️ ${_currentPlant.threats}\n\nHabitat: ${_currentPlant.habitat}';
      case 'Fun Facts':
        return '🌿 ${_currentPlant.ecologicalImportance}\n\n✨ ${_currentPlant.identificationFeatures}';
      case 'Species Info':
      default:
        return '${_currentPlant.family} · ${_currentPlant.nativeRegion}\n\n${_currentPlant.description}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Feed or Backdrop
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
              color: const Color(0x660D1410),
            ),
          ),

          // 2. AR Grid Pattern Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _ARGridPainter(),
            ),
          ),

          // 3. Top Status Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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

                  // Plant pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xB20D1410),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _currentPlant.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=100',
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 16, color: AppTheme.accentLime),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Text(
                            _currentPlant.commonName,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '95%',
                          style: TextStyle(
                            color: AppTheme.accentLime,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Auto toggle switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xB20D1410),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Auto', style: TextStyle(color: AppTheme.sageText, fontSize: 11)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _autoScanEnabled = !_autoScanEnabled;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 18,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _autoScanEnabled ? AppTheme.accentLime : const Color(0xFF2D4A2D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: _autoScanEnabled ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
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

          // 4. Status message pill
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xCC0D1410),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.25)),
                ),
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.dmSans(
                    color: AppTheme.accentLime,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 5. Hexagonal AR Spatial Reticle in Center
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.06);
                return Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _HexReticlePainter(),
                  ),
                );
              },
            ),
          ),

          // 6. Bottom Layer Controls & Expandable Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Layer pills row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _layers.map((layer) {
                    final isSelected = _activeLayer == layer;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _activeLayer = layer;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentLime : const Color(0xCC0D1410),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentLime : AppTheme.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            layer,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0D1410) : AppTheme.sageText,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Info card bottom sheet
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xF50D1410),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(
                      color: AppTheme.accentLime.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.sageText.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        InkWell(
                          onTap: () {
                            setState(() {
                              _cardOpen = !_cardOpen;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentPlant.commonName,
                                    style: GoogleFonts.syne(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _currentPlant.scientificName,
                                    style: GoogleFonts.dmSans(
                                      color: AppTheme.sageText,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _cardOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                color: AppTheme.sageText,
                              ),
                            ],
                          ),
                        ),

                        if (_cardOpen) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x800D1410),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Text(
                              _getLayerContent(),
                              style: GoogleFonts.dmSans(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 7. Floating Camera Scan FAB
          Positioned(
            bottom: _cardOpen ? 170 : 80,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppTheme.accentLime,
              foregroundColor: const Color(0xFF0D1410),
              elevation: 4,
              onPressed: _triggerLiveScan,
              child: const Icon(Icons.camera_alt_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// AR Hexagonal Reticle Painter
class _HexReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = AppTheme.accentLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

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

    // Draw corner circular nodes
    final nodePaint = Paint()
      ..color = AppTheme.accentLime
      ..style = PaintingStyle.fill;

    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, nodePaint);
    }

    // Center glow dot
    canvas.drawCircle(center, 4, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// AR Grid lines painter
class _ARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentLime.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
