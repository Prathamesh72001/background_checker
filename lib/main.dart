import 'dart:async';
import 'package:desktop_time_tracker/services/tracker_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db/db_provider.dart';
import 'modules/usage_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBProvider.instance.init(); // initialize sqlite
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TrackerService _tracker = TrackerService();
  List<UsageEntry> _recent = [];
  StreamSubscription<UsageEntry>? _sub;

  @override
  void initState() {
    super.initState();
    _tracker.start(); // start polling
    _loadRecent();
    // Listen for session completions (optional)
    _sub = _tracker.onSessionRecorded.listen((entry) {
      setState(() => _recent.insert(0, entry));
    });
  }

  Future<void> _loadRecent() async {
    final entries = await DBProvider.instance.getRecentEntries(limit: 50);
    setState(() => _recent = entries.reversed.toList());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tracker.stop();
    super.dispose();
  }

  Widget _buildEntryTile(UsageEntry e) {
    final start = DateFormat('yyyy-MM-dd HH:mm:ss').format(e.start);
    final dur = Duration(milliseconds: e.durationMs);
    String durStr() {
      if (dur.inHours > 0) return "${dur.inHours}h ${dur.inMinutes.remainder(60)}m";
      if (dur.inMinutes > 0) return "${dur.inMinutes}m ${dur.inSeconds.remainder(60)}s";
      return "${dur.inSeconds}s";
    }

    return ListTile(
      title: Text("${e.appName}"),
      subtitle: Text("${e.windowTitle}\n$start — ${durStr()}"),
      isThreeLine: true,
      trailing: Text(durStr()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Time Tracker',
      home: Scaffold(
        appBar: AppBar(title: Text('Time Tracker')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Recent sessions', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recent.length,
                itemBuilder: (_, i) => _buildEntryTile(_recent[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
