import 'active_window_impl_stub.dart'
if (dart.library.io) 'active_window_impl_io.dart';

class ActiveWindow {
  final String appName;
  final String title;

  ActiveWindow({required this.appName, required this.title});
}

Future<ActiveWindow?> getActiveWindow() => getActiveWindowImpl();
