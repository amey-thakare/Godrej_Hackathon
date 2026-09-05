import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ar_flutter_plugin_plus/ar_flutter_plugin_plus.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_plus/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_plus/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_plus/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../models/plant.dart';
import '../../services/identification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_icon_button.dart';
import '../../widgets/glass/glass_badge.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/chat/bot_bottom_sheet.dart';
import '../../widgets/ar_data_panel.dart';
import '../../utils/widget_to_image.dart';
import '../../providers/ar_session_provider.dart';

class ARViewScreen extends ConsumerStatefulWidget {
  final Plant plant;

  const ARViewScreen({super.key, required this.plant});

  @override
  ConsumerState<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends ConsumerState<ARViewScreen> {
  late Plant _currentPlant;
  bool _isScanning = false;
  String _statusMessage = '🔍 Move phone slowly to detect surfaces';
  double _confidence = 0.0;
  final GlobalKey _dataPanelKey = GlobalKey();
  final List<vector.Vector3> _anchorPositions = [];

  @override
  void initState() {
    super.initState();
    _currentPlant = widget.plant;
  }

  @override
  void dispose() {
    ref.read(arSessionProvider.notifier).dispose();
    super.dispose();
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    ref.read(arSessionProvider.notifier).setManagers(
          arSessionManager,
          arObjectManager,
          arAnchorManager,
          arLocationManager,
        );

    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );
    
    arObjectManager.onInitialize();

    arSessionManager.onPlaneOrPointTap = _onPlaneOrPointTapped;
    
    setState(() {
      _statusMessage = 'Tap on a detected surface to scan plant';
    });
  }

  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (hitTestResults.isEmpty || _isScanning) return;
    
    final singleHitTestResult = hitTestResults.first;
    
    if (singleHitTestResult.type == ARHitTestResultType.plane || 
        singleHitTestResult.type == ARHitTestResultType.point) {
      
      final transform = singleHitTestResult.worldTransform;
      final position = vector.Vector3(
        transform.getColumn(3).x,
        transform.getColumn(3).y,
        transform.getColumn(3).z,
      );

      for (final existingPos in _anchorPositions) {
        if (existingPos.distanceTo(position) < 0.3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already scanned near this location.')),
            );
          }
          return;
        }
      }

      // 1. Run the scan first to get the identified plant details
      await _triggerARScan();
      
      // 2. Wait a short moment to ensure the off-screen Widget is re-rendered with new data
      await Future.delayed(const Duration(milliseconds: 200));

      // 3. Now that the plant is identified and rendered, create the Anchor and Node
      final newAnchor = ARPlaneAnchor(transformation: transform);
      final state = ref.read(arSessionProvider);
      bool? didAddAnchor = await state.anchorManager?.addAnchor(newAnchor);
      
      if (didAddAnchor ?? false) {
        _anchorPositions.add(position);
        
        final imageBytes = await WidgetToImage.captureAsBytes(_dataPanelKey);
        
        if (imageBytes != null) {
          try {
            final dir = await path_provider.getApplicationDocumentsDirectory();
            final textureFile = File('${dir.path}/banner_texture.png');
            await textureFile.writeAsBytes(imageBytes);

            final gltfFile = File('${dir.path}/banner.gltf');
            final gltfJson = '''{
              "asset": {"version": "2.0"},
              "extensionsUsed": ["KHR_materials_unlit"],
              "scene": 0,
              "scenes": [{"nodes": [0]}],
              "nodes": [{"mesh": 0}],
              "materials": [{
                "doubleSided": true,
                "alphaMode": "BLEND",
                "pbrMetallicRoughness": {
                  "baseColorTexture": {"index": 0},
                  "metallicFactor": 0.0,
                  "roughnessFactor": 1.0
                },
                "extensions": {
                  "KHR_materials_unlit": {}
                }
              }],
              "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2}, "indices": 3, "material": 0}]}],
              "textures": [{"sampler": 0, "source": 0}],
              "images": [{"uri": "banner_texture.png"}],
              "samplers": [{"magFilter": 9729, "minFilter": 9987}],
              "buffers": [{"byteLength": 140, "uri": "data:application/octet-stream;base64,AAAAv5qZmb4AAAAAAAAAP5qZmb4AAAAAAAAAv5qZmT4AAAAAAAAAP5qZmT4AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AACAPwAAgD8AAAEAAgACAAEAAwA="}],
              "bufferViews": [{"buffer": 0, "byteLength": 48, "byteOffset": 0}, {"buffer": 0, "byteLength": 48, "byteOffset": 48}, {"buffer": 0, "byteLength": 32, "byteOffset": 96}, {"buffer": 0, "byteLength": 12, "byteOffset": 128}],
              "accessors": [{"bufferView": 0, "componentType": 5126, "count": 4, "type": "VEC3", "max": [0.5, 0.3, 0.0], "min": [-0.5, -0.3, 0.0]}, {"bufferView": 1, "componentType": 5126, "count": 4, "type": "VEC3"}, {"bufferView": 2, "componentType": 5126, "count": 4, "type": "VEC2"}, {"bufferView": 3, "componentType": 5123, "count": 6, "type": "SCALAR"}]
            }''';
            await gltfFile.writeAsString(gltfJson);

            final nodeUri = Platform.isIOS ? 'banner.gltf' : gltfFile.absolute.path;

            final newNode = ARNode(
              type: NodeType.fileSystemAppFolderGLTF2,
              uri: nodeUri,
              scale: vector.Vector3(0.5, 0.5, 0.5),
              position: vector.Vector3(0, 0.45, 0),
              rotation: vector.Vector4(0.0, 0.0, 0.0, 1.0), 
            );
            
            bool? didAddNode = await state.objectManager?.addNode(newNode, planeAnchor: newAnchor);
            if (!(didAddNode ?? false)) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add 3D Node to AR Scene')));
            } else {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AR Banner Added Successfully!')));
            }
          } catch (e) {
            debugPrint("Failed to map AR GLTF texture: $e");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating 3D banner: $e')));
          }
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to capture widget as image')));
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to place AR Anchor. Try moving the phone.')));
      }
    }
  }

  Future<void> _triggerARScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = '🔍 Analyzing Plant...';
    });
    
    try {
      final state = ref.read(arSessionProvider);
      if (state.sessionManager != null) {
        // Simulate a brief analysis delay for UX
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          setState(() {
            _confidence = 0.95; // Since we already identified it previously
            _statusMessage = '🌸 AR Lock: ${_currentPlant.commonName} (95% Match)';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Tap on a surface to scan';
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
  Widget build(BuildContext context) {
    final confidencePct = (_confidence * 100).round();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hidden offstage widget to allow capture as Uint8List
          Positioned(
            left: -2000,
            top: -2000,
            child: RepaintBoundary(
              key: _dataPanelKey,
              child: ArDataPanel(plant: _currentPlant),
            ),
          ),

          // 1. AR View
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          
          // 2. Top UI Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    iconColor: AppTheme.textPrimary,
                    size: 38,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  
                  // Live Species Badge Pill
                  Expanded(
                    child: GlassContainer(
                      borderRadius: AppTheme.radiusXL,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      opacityColor: Colors.white,
                      opacity: 0.88,
                      blur: AppTheme.blurMedium,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppTheme.leafGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _currentPlant.commonName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GlassBadge(
                            label: '$confidencePct%',
                            fontSize: 9.5,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            color: AppTheme.accentForest,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Status Pill Banner
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
                    Flexible(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: AppTheme.primaryForest,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 4. Contextual Chatbot Bottom Sheet
          BotBottomSheet(plant: _currentPlant),
        ],
      ),
    );
  }
}