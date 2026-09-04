import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/identification.dart';
import '../../models/plant.dart';
import '../../services/api_service.dart';
import '../../services/identification_service.dart';
import '../../theme/app_theme.dart';
import '../ar/ar_view_screen.dart';
import 'identification_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  String _loadingText = 'Align plant within reticle & tap capture';
  String? _errorMessage;
  List<Plant> _recentPlants = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _initCamera();
    _loadRecentPlants();
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
        }
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _loadRecentPlants() async {
    try {
      final plants = await ApiService.getPlants();
      if (mounted) {
        setState(() {
          _recentPlants = plants;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (!mounted) return;
    if (_isCameraInitialized && _cameraController != null && !_cameraController!.value.isTakingPicture) {
      try {
        setState(() {
          _isLoading = true;
          _loadingText = 'Capturing frame...';
          _errorMessage = null;
        });

        final xFile = await _cameraController!.takePicture();
        if (!mounted) return;
        final bytes = await xFile.readAsBytes();
        if (!mounted) return;
        await _identifyBytes(bytes, xFile.name);
        return;
      } catch (e) {
        debugPrint('Direct camera capture error: $e');
      }
    }

    _pickAndIdentify(ImageSource.camera);
  }

  Future<void> _pickAndIdentify(ImageSource source) async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _loadingText = source == ImageSource.camera ? 'Accessing Camera...' : 'Opening Gallery...';
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (!mounted) return;
      if (image == null) {
        setState(() {
          _isLoading = false;
          _loadingText = 'Align plant within reticle & tap capture';
        });
        return;
      }

      final Uint8List bytes = await image.readAsBytes();
      if (!mounted) return;
      await _identifyBytes(bytes, image.name);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _loadingText = 'Align plant within reticle & tap capture';
      });
    }
  }

  Future<void> _identifyBytes(Uint8List bytes, String filename) async {
    if (!mounted) return;
    setState(() {
      _loadingText = 'Analyzing via Gemini AI Vision...';
    });

    try {
      final IdentificationResult result = await IdentificationService.identifyPlantFromBytes(
        bytes,
        filename,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingText = 'Align plant within reticle & tap capture';
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentificationResultScreen(
            result: result,
            capturedImageBytes: bytes,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _loadingText = 'Align plant within reticle & tap capture';
      });
    }
  }

  void _openARMode() {
    final fallbackPlant = _recentPlants.isNotEmpty
        ? _recentPlants.first
        : Plant(
            id: 1,
            scientificName: 'Nelumbo nucifera',
            commonName: 'Lotus',
            family: 'Nelumbonaceae',
            nativeRegion: 'Pan-India',
            conservationStatus: 'Least Concern',
            ecologicalImportance: 'Sacred aquatic keystone plant supporting freshwater wetland ecosystems.',
            description: 'National flower of India.',
            threats: 'Pollution.',
            conservationActions: 'Protect wetlands.',
            habitat: 'Ponds and lakes.',
            identificationFeatures: 'Pink flowers, peltate leaves.',
            imageUrl: '',
            plantnetSpeciesName: 'Nelumbo nucifera',
          );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARViewScreen(plant: fallbackPlant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Viewfinder or Fallback Backdrop
          Positioned.fill(
            child: _isCameraInitialized &&
                    _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Image.network(
                    'https://images.unsplash.com/photo-1700592478407-3981353caecb?w=600&h=900&fit=crop&auto=format',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppTheme.darkBackground);
                    },
                  ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0x55070E09),
            ),
          ),

          // 2. Top Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xB2070E09),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Plant Scanner',
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xB2070E09),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentLime,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Gemini AI',
                          style: TextStyle(
                            color: AppTheme.accentLime,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Animated Reticle in Center
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.07);
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentLime.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 175,
                          height: 175,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentLime.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentLime.withValues(alpha: 0.75),
                              width: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentLime,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentLime,
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Status Banner below Reticle
          Align(
            alignment: const Alignment(0, 0.38),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xD9070E09),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentLime,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _loadingText,
                          style: GoogleFonts.dmSans(
                            color: AppTheme.accentLime,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _loadingText,
                      style: GoogleFonts.dmSans(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),

          // 5. Error banner if any
          if (_errorMessage != null)
            Align(
              alignment: const Alignment(0, 0.50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xCC7F1D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x80EF4444)),
                ),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),

          // 6. ERGONOMIC BOTTOM CONTROL DOCK (Natural Thumb Reach Zone)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: const Color(0xF2070E09),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: AppTheme.accentLime.withValues(alpha: 0.18),
                  width: 1.2,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drawer pill handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.sageText.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ergonomic Shutter Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Gallery Button (Left Thumb Access)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : () => _pickAndIdentify(ImageSource.gallery),
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC132A1C),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppTheme.accentLime.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.photo_library_outlined,
                                    color: AppTheme.accentLime,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gallery',
                              style: GoogleFonts.dmSans(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // 2. PRIMARY SHUTTER BUTTON (Center - Primary Ergonomic Action)
                        GestureDetector(
                          onTap: _isLoading ? null : _captureFromCamera,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accentLime,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentLime.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  spreadRadius: 3,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 3,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF070E09),
                                size: 36,
                              ),
                            ),
                          ),
                        ),

                        // 3. Live AR Mode Button (Right Thumb Access)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _openARMode,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC132A1C),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppTheme.accentLime.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.view_in_ar_rounded,
                                    color: AppTheme.accentLime,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'AR Mode',
                              style: GoogleFonts.dmSans(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
