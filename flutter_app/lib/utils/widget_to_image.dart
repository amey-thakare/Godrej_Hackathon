import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetToImage {
  static Future<ui.Image?> capture(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary = 
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: 3.0);
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  static Future<Uint8List?> captureAsBytes(GlobalKey key) async {
    final image = await capture(key);
    if (image == null) return null;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
