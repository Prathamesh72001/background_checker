import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

import '../modules/usage_entry.dart';

class DBProvider {
  DBProvider._privateConstructor();
  static final DBProvider instance = DBProvider._privateConstructor();

  late DatabaseFactory _dbFactory;
  late Database _db;

  Future<void> init() async {
    sqfliteFfiInit();
    _dbFactory = databaseFactoryFfi;
    final dbPath = join(Directory.current.path, 'usage_tracker.db');
    _db = await _dbFactory.openDatabase(dbPath, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usage (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            appName TEXT,
            windowTitle TEXT,
            start INTEGER,
            end INTEGER,
            durationMs INTEGER
          )
        ''');
      },
    ));
  }

  Future<int> insertEntry(UsageEntry e) async {
    return await _db.insert('usage', e.toMap());
  }

  Future<List<UsageEntry>> getRecentEntries({int limit = 100}) async {
    final res = await _db.query('usage', orderBy: 'start DESC', limit: limit);
    return res.map((r) => UsageEntry.fromMap(r)).toList();
  }
}
