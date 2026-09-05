import 'dart:convert';

void main() {
  final jsonStr = '''{
    "asset": {"version": "2.0"},
    "scene": 0,
    "scenes": [{"nodes": [0]}],
    "nodes": [{"mesh": 0}],
    "materials": [{"doubleSided": true, "pbrMetallicRoughness": {"baseColorTexture": {"index": 0}, "metallicFactor": 0.0, "roughnessFactor": 1.0}}],
    "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2}, "indices": 3, "material": 0}]}],
    "textures": [{"sampler": 0, "source": 0}],
    "images": [{"uri": "texture.png"}],
    "samplers": [{"magFilter": 9729, "minFilter": 9987}],
    "buffers": [{"byteLength": 140, "uri": "data:application/octet-stream;base64,AAAAvwAAAL8AAAAAAAAAPwAAAL8AAAAAAAAAvwAAAD8AAAAAAAAAPwAAAD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAgD8AAIA/AACAPwAAAAAAAAAAAACAPwAAAAAAAAEAAgACAAEAAwA="}],
    "bufferViews": [{"buffer": 0, "byteLength": 48, "byteOffset": 0}, {"buffer": 0, "byteLength": 48, "byteOffset": 48}, {"buffer": 0, "byteLength": 32, "byteOffset": 96}, {"buffer": 0, "byteLength": 12, "byteOffset": 128}],
    "accessors": [{"bufferView": 0, "componentType": 5126, "count": 4, "type": "VEC3", "max": [0.5, 0.5, 0.0], "min": [-0.5, -0.5, 0.0]}, {"bufferView": 1, "componentType": 5126, "count": 4, "type": "VEC3"}, {"bufferView": 2, "componentType": 5126, "count": 4, "type": "VEC2"}, {"bufferView": 3, "componentType": 5123, "count": 6, "type": "SCALAR"}]
  }''';
  print(jsonDecode(jsonStr) != null ? 'Valid JSON' : 'Invalid');
}
