import 'dart:io';
import 'package:flutter/services.dart';
import 'active_window.dart';

class ActiveWindowMacOS {
  static const _channel = MethodChannel("active_window_macos");

  static Future<ActiveWindow?> getActiveWindow() async {
    if (!Platform.isMacOS) return null;

    final raw = await _channel.invokeMethod<String>("getActiveWindow") ?? "";
    if (raw.isEmpty || !raw.contains("|||")) return null;

    final parts = raw.split("|||");
    return ActiveWindow(
      appName: parts[0],
      title: parts.length > 1 ? parts[1] : "",
    );
  }
}
