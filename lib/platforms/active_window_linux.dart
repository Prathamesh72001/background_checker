import 'dart:io';
import '../platforms/active_window.dart';

Future<ActiveWindow?> getActiveWindowLinux() async {
  try {
    // requires xdotool installed on Linux
    final proc1 = await Process.run('xdotool', ['getactivewindow', 'getwindowname']);
    if (proc1.exitCode != 0) {
      // fallback: try wmctrl
      final proc2 = await Process.run('xdotool', ['getactivewindow']);
      if (proc2.exitCode != 0) return null;
      final winId = (proc2.stdout as String).trim();
      final proc3 = await Process.run('xdotool', ['getwindowname', winId]);
      if (proc3.exitCode != 0) return null;
      final title = (proc3.stdout as String).trim();
      return ActiveWindow(appName: 'unknown', title: title);
    } else {
      final title = (proc1.stdout as String).trim();
      // get PID of active window
      final procPid = await Process.run('xdotool', ['getactivewindow', 'getwindowpid']);
      String app = 'unknown';
      if (procPid.exitCode == 0) {
        final pid = (procPid.stdout as String).trim();
        // try read /proc/<pid>/comm
        try {
          final comm = File('/proc/$pid/comm');
          if (await comm.exists()) {
            app = (await comm.readAsString()).trim();
          }
        } catch (_) {}
      }
      return ActiveWindow(appName: app, title: title);
    }
  } catch (e) {
    return null;
  }
}
