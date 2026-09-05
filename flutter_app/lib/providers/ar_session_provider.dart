import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';

class ARSessionState {
  final ARSessionManager? sessionManager;
  final ARObjectManager? objectManager;
  final ARAnchorManager? anchorManager;
  final ARLocationManager? locationManager;
  final bool isInitialized;
  final String? errorMessage;

  ARSessionState({
    this.sessionManager,
    this.objectManager,
    this.anchorManager,
    this.locationManager,
    this.isInitialized = false,
    this.errorMessage,
  });

  ARSessionState copyWith({
    ARSessionManager? sessionManager,
    ARObjectManager? objectManager,
    ARAnchorManager? anchorManager,
    ARLocationManager? locationManager,
    bool? isInitialized,
    String? errorMessage,
  }) {
    return ARSessionState(
      sessionManager: sessionManager ?? this.sessionManager,
      objectManager: objectManager ?? this.objectManager,
      anchorManager: anchorManager ?? this.anchorManager,
      locationManager: locationManager ?? this.locationManager,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ARSessionNotifier extends StateNotifier<ARSessionState> {
  ARSessionNotifier() : super(ARSessionState());

  void setManagers(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    state = state.copyWith(
      sessionManager: sessionManager,
      objectManager: objectManager,
      anchorManager: anchorManager,
      locationManager: locationManager,
      isInitialized: true,
      errorMessage: null,
    );
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  @override
  void dispose() {
    state.sessionManager?.dispose();
    super.dispose();
  }
}

final arSessionProvider =
    StateNotifierProvider<ARSessionNotifier, ARSessionState>((ref) {
  return ARSessionNotifier();
});
