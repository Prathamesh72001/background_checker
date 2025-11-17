import 'dart:async';
import 'dart:isolate';
import '../db/db_provider.dart';
import '../modules/usage_entry.dart';
import '../platforms/active_window.dart';

class TrackerService {
  final Duration pollInterval;
  Timer? _timer;
  String? _currentApp;
  String? _currentTitle;
  DateTime? _currentStart;
  final _controller = StreamController<UsageEntry>.broadcast();

  Stream<UsageEntry> get onSessionRecorded => _controller.stream;

  TrackerService({this.pollInterval = const Duration(seconds: 1)});

  void start() {
    // initial snapshot
    _poll();
    _timer = Timer.periodic(pollInterval, (_) => _poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    try {
      final aw = await getActiveWindow(); // platform-specific
      final app = aw?.appName ?? 'Unknown';
      final title = aw?.title ?? '';

      if (_currentApp == null) {
        _currentApp = app;
        _currentTitle = title;
        _currentStart = DateTime.now();
        return;
      }

      // if changed (app or window title), finalize previous session
      if (app != _currentApp || title != _currentTitle) {
        final end = DateTime.now();
        final durationMs = end.difference(_currentStart!).inMilliseconds;
        final entry = UsageEntry(
          appName: _currentApp!,
          windowTitle: _currentTitle ?? '',
          start: _currentStart!,
          end: end,
          durationMs: durationMs,
        );
        await DBProvider.instance.insertEntry(entry);
        _controller.add(entry);

        // start new session
        _currentApp = app;
        _currentTitle = title;
        _currentStart = DateTime.now();
      }
    } catch (e, st) {
      // ignore but you could log or surface errors
      // print('poll error: $e $st');
    }
  }
}
