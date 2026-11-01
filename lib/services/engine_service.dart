import 'package:flutter/services.dart';

class EngineService {
  static const _ch = MethodChannel('com.asasain.poll/engine');

  static Future<bool> checkOverlayPermission() async {
    try {
      return await _ch.invokeMethod('checkOverlayPermission') ?? false;
    } catch (_) { return false; }
  }

  static Future<void> requestOverlayPermission() async {
    await _ch.invokeMethod('requestOverlayPermission');
  }

  // Launch 8BP di sandbox + aktifkan cheat sesuai config
  static Future<bool> startEngine({
    bool esp = false,
    bool autoPlay = false,
    bool autoQueue = false,
    double accuracy = 0.85,
  }) async {
    try {
      return await _ch.invokeMethod('startEngine', {
        'esp': esp,
        'autoPlay': autoPlay,
        'autoQueue': autoQueue,
        'accuracy': accuracy,
      }) ?? false;
    } catch (_) { return false; }
  }

  static Future<bool> stopEngine() async {
    try {
      return await _ch.invokeMethod('stopEngine') ?? false;
    } catch (_) { return false; }
  }

  static Future<Map<String, dynamic>> getEngineStatus() async {
    try {
      final result = await _ch.invokeMethod('getEngineStatus');
      return Map<String, dynamic>.from(result ?? {});
    } catch (_) {
      return {'ready': false, 'active': false, 'nativeLoaded': false};
    }
  }
}
