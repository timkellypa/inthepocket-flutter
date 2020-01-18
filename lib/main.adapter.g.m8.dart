// GENERATED CODE - DO NOT MODIFY BY HAND
// Emitted on: 2020-01-15 22:24:45.451474

// **************************************************************************
// DatabaseProviderGenerator
// **************************************************************************

import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';

enum InitMode { developmentAlwaysReinitDb, testingMockDb, production }

class DatabaseAdapter {
  InitMode _initMode;
  static InitMode _startInitMode;
  static final DatabaseAdapter _instance = DatabaseAdapter._internal();
  static Database _db;

  /// Default initMode is production
  /// [developmentAlwaysReinitDb] then the database will be deleteted on each init
  /// [testingMockDb] then the database will be initialized as mock
  /// [production] then the database will be initialized as production
  factory DatabaseAdapter([InitMode initMode = InitMode.production]) {
    _startInitMode = initMode;
    return _instance;
  }

  DatabaseAdapter._internal() {
    if (_initMode == null) {
      _initMode = _startInitMode;
    }
  }

  InitMode get initMode => _initMode;

  Future<Database> getDb(dynamic _onCreate) async {
    if (_db != null) {
      return _db;
    }
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'm8_store_0.2.0.db');

    if (_startInitMode == InitMode.developmentAlwaysReinitDb) {
      await deleteDatabase(path);
    }

    _db = await openDatabase(path, version: 2, onCreate: _onCreate);
    return _db;
  }
}

class DatabaseProvider
    with
        SetListDatabaseProvider,
        SetListTrackDatabaseProvider,
        TempoDatabaseProvider,
        TrackDatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static Database _db;

  static DatabaseAdapter _dbBuilder;

  factory DatabaseProvider(DatabaseAdapter dbBuilder) {
    _dbBuilder = dbBuilder;
    return _instance;
  }

  DatabaseProvider._internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _dbBuilder.getDb(_onCreate);

    return _db;
  }

  void _onCreate(Database db, int newVersion) async {
    await createSetListTable(db);
    await createSetListTrackTable(db);
    await createTempoTable(db);
    await createTrackTable(db);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future deleteAll() async {
    await deleteSetListProxiesAll();
    await deleteSetListTrackProxiesAll();
    await deleteTempoProxiesAll();
    await deleteTrackProxiesAll();
  }
}
