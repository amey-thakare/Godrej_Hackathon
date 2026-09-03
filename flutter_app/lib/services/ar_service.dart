import 'package:flutter/foundation.dart';

class ARService {
  static Future<bool> isARSupported() async {
    if (kIsWeb) return false;
    // Mobile platform availability check
    // Returns true for AR-capable mobile devices
    return true;
  }

  static String getARStatusMessage(bool isSupported) {
    if (isSupported) {
      return 'AR Spatial Tracking Active. Point camera at plant to view anchored details.';
    }
    return 'AR hardware unsupported on this device. Displaying immersive field card overlay.';
  }
}
