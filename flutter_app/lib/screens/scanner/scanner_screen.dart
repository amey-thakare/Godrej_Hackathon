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
  String _loadingText = 'Point at a plant to identify';
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
      debugPrint('Camera init error (using gallery/file capture): $e');
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
        debugPrint('Direct camera capture failed, trying ImagePicker: $e');
      }
    }

    // Fallback to ImagePicker camera
    if (!mounted) return;
    _pickAndIdentify(ImageSource.camera);
  }

  Future<void> _pickAndIdentify(ImageSource source) async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _loadingText = source == ImageSource.camera ? 'Accessing Camera...' : 'Selecting Image...';
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
          _loadingText = 'Point at a plant to identify';
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
        _loadingText = 'Point at a plant to identify';
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
        _loadingText = 'Point at a plant to identify';
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
        _loadingText = 'Point at a plant to identify';
      });
    }
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
              color: const Color(0x660D1410),
            ),
          ),

          // 2. Top Bar
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
                  Text(
                    'Plant Scanner',
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x990D1410),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
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

          // 3. Animated Circular Reticle in Center
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.08);
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
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
                        // Middle ring
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
                        // Inner ring
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentLime.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Center crosshair dot
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentLime,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentLime,
                                blurRadius: 8,
                                spreadRadius: 2,
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

          // 4. Status Pill below Reticle
          Align(
            alignment: const Alignment(0, 0.42),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xB20D1410),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentLime,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                      ),
                    ),
            ),
          ),

          // 5. Error banner if any
          if (_errorMessage != null)
            Align(
              alignment: const Alignment(0, 0.53),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
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

          // 6. Bottom Sheet with Recent Scans & Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xF50D1410),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(
                  color: AppTheme.accentLime.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drawer handle
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
                    const SizedBox(height: 12),

                    Text(
                      'RECENT / QUICK SELECT',
                      style: GoogleFonts.syne(
                        color: AppTheme.sageText,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick thumbnail chips
                    if (_recentPlants.isNotEmpty)
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recentPlants.take(5).length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final plant = _recentPlants[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IdentificationResultScreen(
                                      result: IdentificationResult(
                                        success: true,
                                        identification: SpeciesIdentification(
                                          scientificName: plant.scientificName,
                                          commonName: plant.commonName,
                                          confidence: 0.95,
                                        ),
                                        plant: plant,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.accentLime.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    plant.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=200',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(color: AppTheme.primaryForest);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Action buttons (Gallery + Scan Now)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : () => _pickAndIdentify(ImageSource.gallery),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.surfaceBorder),
                                backgroundColor: AppTheme.surfaceCard,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.photo_library_outlined, color: AppTheme.accentLime, size: 20),
                              label: Text(
                                'Gallery',
                                style: GoogleFonts.syne(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _captureFromCamera,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentLime,
                                foregroundColor: AppTheme.darkBackground,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.camera_alt_rounded, size: 20, color: Color(0xFF0D1410)),
                              label: Text(
                                'Scan Now',
                                style: GoogleFonts.syne(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D1410),
                                ),
                              ),
                            ),
                          ),
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
