import '../platforms/active_window.dart';
import 'active_window_windows.dart' as win;
import 'active_window_macos.dart' as mac;
import 'active_window_linux.dart' as lin;
import 'dart:io';

Future<ActiveWindow?> getActiveWindowImpl() async {
  if (Platform.isWindows) return win.getActiveWindowWindows();
  if (Platform.isMacOS) return mac.getActiveWindowMac();
  if (Platform.isLinux) return lin.getActiveWindowLinux();
  return null;
}
