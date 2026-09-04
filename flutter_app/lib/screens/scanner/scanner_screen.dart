import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/identification.dart';
import '../../models/plant.dart';
import '../../services/api_service.dart';
import '../../services/identification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_icon_button.dart';
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
  String _loadingText = 'Point camera at leaf or flower';
  String? _errorMessage;
  List<Plant> _recentPlants = [];
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
          ResolutionPreset.high,
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
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (_) {}
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
          _loadingText = 'Point camera at leaf or flower';
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
        _loadingText = 'Point camera at leaf or flower';
      });
    }
  }

  Future<void> _identifyBytes(Uint8List bytes, String filename) async {
    if (!mounted) return;
    setState(() {
      _loadingText = 'Examining leaf structure & AI features...';
    });

    try {
      final IdentificationResult result = await IdentificationService.identifyPlantFromBytes(
        bytes,
        filename,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingText = 'Point camera at leaf or flower';
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
        _loadingText = 'Point camera at leaf or flower';
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
          // 1. Full Screen Camera View
          Positioned.fill(
            child: _isCameraInitialized &&
                    _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Image.network(
                    'https://images.unsplash.com/photo-1700592478407-3981353caecb?w=800&h=1200&fit=crop&auto=format',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppTheme.primaryForest);
                    },
                  ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),

          // 2. Floating Liquid Glass Top Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    iconColor: AppTheme.textPrimary,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const GlassContainer(
                    borderRadius: AppTheme.radiusXL,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    opacity: 0.82,
                    blur: AppTheme.blurMedium,
                    child: Text(
                      'Native Plant Scanner',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    iconColor: _isFlashOn ? AppTheme.amberAccent : AppTheme.textPrimary,
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // 3. Calm Biological Recognition Feedback Ring (Center Viewfinder)
          Center(
            child: SizedOverflowBox(
              size: const Size(240, 240),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryForest.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.leafGreen.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Floating Glass "Plant Detected" Status Indicator
          Align(
            alignment: const Alignment(0, 0.42),
            child: GlassContainer(
              borderRadius: AppTheme.radiusXL,
              opacity: 0.88,
              blur: AppTheme.blurMedium,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentForest,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _loadingText,
                          style: const TextStyle(
                            color: AppTheme.primaryForest,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Row(
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
                        Text(
                          _loadingText,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Error Banner
          if (_errorMessage != null)
            Align(
              alignment: const Alignment(0, 0.54),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xCC7F1D1D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // 5. Floating Liquid Glass Shutter & Action Controls (Bottom Dock)
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: GlassContainer(
              borderRadius: AppTheme.radiusXL,
              opacityColor: Colors.white,
              opacity: 0.88,
              blur: AppTheme.blurLarge,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Gallery Picker
                  GlassIconButton(
                    icon: Icons.photo_library_rounded,
                    iconColor: AppTheme.primaryForest,
                    onPressed: _isLoading ? () {} : () => _pickAndIdentify(ImageSource.gallery),
                    tooltip: 'Gallery',
                  ),

                  // PRIMARY SHUTTER BUTTON
                  GestureDetector(
                    onTap: _isLoading ? null : _captureFromCamera,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryForest,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryForest.withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 3.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // Live AR Mode Button
                  GlassIconButton(
                    icon: Icons.view_in_ar_rounded,
                    iconColor: AppTheme.primaryForest,
                    onPressed: _openARMode,
                    tooltip: 'AR Mode',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
