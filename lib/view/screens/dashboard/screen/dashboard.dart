import 'dart:async';

import 'package:desktop_time_tracker/constants/colors.dart';
import 'package:desktop_time_tracker/constants/strings.dart';
import 'package:desktop_time_tracker/view/common%20widgets/text_widget.dart';
import 'package:desktop_time_tracker/view/screens/dashboard/widget/session_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/db_provider.dart';
import '../../../../core/modules/usage_entry.dart';
import '../../../../core/services/tracker_service.dart';

class DashboardView extends StatefulWidget {
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
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
    entries.sort((a, b) => a.start.isBefore(b.start)?1:0,);
    setState(() => _recent = entries.toList());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tracker.stop();
    super.dispose();
  }

  // Widget _buildEntryTile(UsageEntry e) {
  //   final start = DateFormat('yyyy-MM-dd HH:mm:ss').format(e.start);
  //   final dur = Duration(milliseconds: e.durationMs);
  //   String durStr() {
  //     if (dur.inHours > 0) return "${dur.inHours}h ${dur.inMinutes.remainder(60)}m";
  //     if (dur.inMinutes > 0) return "${dur.inMinutes}m ${dur.inSeconds.remainder(60)}s";
  //     return "${dur.inSeconds}s";
  //   }
  //
  //   return ListTile(
  //     title: Text("${e.appName}"),
  //     subtitle: Text("${e.windowTitle}\n$start — ${durStr()}"),
  //     isThreeLine: true,
  //     trailing: Text(durStr()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CommonTextWidget(text: Strings.app_name, fontWeight: FontWeight.bold, textSize: 25, textColor: AppColors.secondaryColor,),backgroundColor: AppColors.textColor,),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CommonTextWidget(text: Strings.recent_sessions.toUpperCase(), textSize: 50,),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recent.length,
              itemBuilder: (_, i) => SessionTile(softwareName: _recent[i].appName,endTime: _recent[i].end,startTime: _recent[i].start,windowTitle: _recent[i].windowTitle,),
            ),
          ),
        ],
      ),
    );
  }
}