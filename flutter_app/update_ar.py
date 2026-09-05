import re

with open("/Users/ameythakare/Godrej_Hackathon/flutter_app/lib/screens/ar/ar_view_screen.dart.bak", "r") as f:
    content = f.read()

# Replace Offstage with Positioned
content = content.replace('''          Offstage(
            child: Align(
              alignment: Alignment.center,
              child: RepaintBoundary(
                key: _dataPanelKey,
                child: ArDataPanel(plant: _currentPlant),
              ),
            ),
          ),''', '''          Positioned(
            left: -2000,
            top: -2000,
            child: RepaintBoundary(
              key: _dataPanelKey,
              child: ArDataPanel(plant: _currentPlant),
            ),
          ),''')

# Replace _onPlaneOrPointTapped block
new_on_tap = '''  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
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
            final gltfJson = \'\'\'{
              "asset": {"version": "2.0"},
              "scene": 0,
              "scenes": [{"nodes": [0]}],
              "nodes": [{"mesh": 0}],
              "materials": [{"doubleSided": true, "pbrMetallicRoughness": {"baseColorTexture": {"index": 0}, "metallicFactor": 0.0, "roughnessFactor": 1.0}}],
              "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2}, "indices": 3, "material": 0}]}],
              "textures": [{"sampler": 0, "source": 0}],
              "images": [{"uri": "banner_texture.png"}],
              "samplers": [{"magFilter": 9729, "minFilter": 9987}],
              "buffers": [{"byteLength": 140, "uri": "data:application/octet-stream;base64,AAAAvwAAAL8AAAAAAAAAPwAAAL8AAAAAAAAAvwAAAD8AAAAAAAAAPwAAAD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAgD8AAIA/AACAPwAAAAAAAAAAAACAPwAAAAAAAAEAAgACAAEAAwA="}],
              "bufferViews": [{"buffer": 0, "byteLength": 48, "byteOffset": 0}, {"buffer": 0, "byteLength": 48, "byteOffset": 48}, {"buffer": 0, "byteLength": 32, "byteOffset": 96}, {"buffer": 0, "byteLength": 12, "byteOffset": 128}],
              "accessors": [{"bufferView": 0, "componentType": 5126, "count": 4, "type": "VEC3", "max": [0.5, 0.5, 0.0], "min": [-0.5, -0.5, 0.0]}, {"bufferView": 1, "componentType": 5126, "count": 4, "type": "VEC3"}, {"bufferView": 2, "componentType": 5126, "count": 4, "type": "VEC2"}, {"bufferView": 3, "componentType": 5123, "count": 6, "type": "SCALAR"}]
            }\'\'\';
            await gltfFile.writeAsString(gltfJson);

            final nodeUri = Platform.isIOS ? 'banner.gltf' : gltfFile.absolute.path;

            final newNode = ARNode(
              type: NodeType.fileSystemAppFolderGLTF2,
              uri: nodeUri,
              scale: vector.Vector3(0.4, 0.4, 0.4),
              position: vector.Vector3(0, 0.2, 0),
              rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0), 
            );
            
            await state.objectManager?.addNode(newNode, planeAnchor: newAnchor);
          } catch (e) {
            debugPrint("Failed to map AR GLTF texture: $e");
          }
        }
      }
    }
  }'''

# Extract the old onPlaneOrPointTapped
start_idx = content.find('  Future<void> _onPlaneOrPointTapped')
end_idx = content.find('  Future<void> _triggerARScan()')

content = content[:start_idx] + new_on_tap + '\n\n' + content[end_idx:]

with open("/Users/ameythakare/Godrej_Hackathon/flutter_app/lib/screens/ar/ar_view_screen.dart", "w") as f:
    f.write(content)
