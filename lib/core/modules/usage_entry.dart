class UsageEntry {
  final int? id;
  final String appName;
  final String windowTitle;
  final DateTime start;
  final DateTime end;
  final int durationMs;

  UsageEntry({
    this.id,
    required this.appName,
    required this.windowTitle,
    required this.start,
    required this.end,
    required this.durationMs,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'appName': appName,
      'windowTitle': windowTitle,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'durationMs': durationMs,
    };
  }

  static UsageEntry fromMap(Map<String, Object?> m) {
    return UsageEntry(
      id: m['id'] as int?,
      appName: m['appName'] as String,
      windowTitle: m['windowTitle'] as String,
      start: DateTime.fromMillisecondsSinceEpoch(m['start'] as int),
      end: DateTime.fromMillisecondsSinceEpoch(m['end'] as int),
      durationMs: m['durationMs'] as int,
    );
  }
}
