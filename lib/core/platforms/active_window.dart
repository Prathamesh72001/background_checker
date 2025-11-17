import 'active_window_impl_stub.dart'
if (dart.library.io) 'active_window_impl_io.dart';

class ActiveWindow {
  final String appName;
  final String title;
  final String? url; // <-- NEW

  ActiveWindow({required this.appName, required this.title, this.url});
}

Future<ActiveWindow?> getActiveWindow() => getActiveWindowImpl();
