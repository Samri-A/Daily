import 'package:flutter/services.dart';

class WidgetUpdater {
  static const MethodChannel _channel = MethodChannel('com.example.myhabit/widget');

  static Future<void> refresh() async {
    try {
      await _channel.invokeMethod('refreshWidget');
    } catch (_) {
    }
  }
}
