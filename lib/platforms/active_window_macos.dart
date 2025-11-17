import 'dart:io';
import '../platforms/active_window.dart';

Future<ActiveWindow?> getActiveWindowMac() async {
  try {
    // AppleScript: get frontmost app name and window title (if any)
    final script = '''
      tell application "System Events"
        set frontApp to name of first application process whose frontmost is true
      end tell
      set windowTitle to ""
      try
        tell application frontApp
          set windowTitle to name of front window
        end try
      end try
      return frontApp & "|||" & windowTitle
    ''';

    final result = await Process.run('osascript', ['-e', script]);
    if (result.exitCode != 0) return null;
    final out = (result.stdout as String).trim();
    final parts = out.split('|||');
    final app = parts.isNotEmpty ? parts[0] : 'unknown';
    final title = parts.length > 1 ? parts[1] : '';
    return ActiveWindow(appName: app, title: title);
  } catch (e) {
    return null;
  }
}
