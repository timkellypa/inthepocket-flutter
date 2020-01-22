// GENERATED CODE - DO NOT MODIFY BY HAND
// Emitted on: 2020-01-22 00:20:53.233913

// **************************************************************************
// Generator: OrmM8GeneratorForAnnotation
// **************************************************************************

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:in_the_pocket/models/independent/tempo.dart';

class TempoProxy extends Tempo {
  TempoProxy();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['guid'] = guid;
    map['sort_order'] = sortOrder;
    map['track_id'] = trackId;
    map['bpm'] = bpm;
    map['beats_per_bar'] = beatsPerBar;
    map['beat_unit'] = beatUnit;
    map['dotted_quarter_accent'] = dottedQuarterAccent ? 1 : 0;
    map['accent_beats_per_bar'] = accentBeatsPerBar;
    map['number_of_bars'] = numberOfBars;

    return map;
  }

  TempoProxy.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.guid = map['guid'];
    this.sortOrder = map['sort_order'];
    this.trackId = map['track_id'];
    this.bpm = map['bpm'];
    this.beatsPerBar = map['beats_per_bar'];
    this.beatUnit = map['beat_unit'];
    this.dottedQuarterAccent = map['dotted_quarter_accent'] == 1 ? true : false;
    this.accentBeatsPerBar = map['accent_beats_per_bar'];
    this.numberOfBars = map['number_of_bars'];
  }
}

mixin TempoDatabaseProvider {
  Future<Database> db;
  final theTempoColumns = [
    "id",
    "guid",
    "sort_order",
    "track_id",
    "bpm",
    "beats_per_bar",
    "beat_unit",
    "dotted_quarter_accent",
    "accent_beats_per_bar",
    "number_of_bars"
  ];

  final String theTempoTableHandler = 'tempos';
  Future createTempoTable(Database db) async {
    await db.execute('''CREATE TABLE $theTempoTableHandler (
    id INTEGER  PRIMARY KEY AUTOINCREMENT,
    guid TEXT ,
    sort_order INTEGER ,
    track_id INTEGER ,
    bpm REAL ,
    beats_per_bar INTEGER ,
    beat_unit INTEGER ,
    dotted_quarter_accent INTEGER ,
    accent_beats_per_bar INTEGER ,
    number_of_bars NUMERIC ,
    UNIQUE (guid)
    )''');
    await db.execute(
        '''CREATE INDEX ix_${theTempoTableHandler}_guid ON $theTempoTableHandler (guid)''');
  }

  Future<int> saveTempo(TempoProxy instanceTempo) async {
    var dbClient = await db;

    var result =
        await dbClient.insert(theTempoTableHandler, instanceTempo.toMap());
    return result;
  }

  Future<List<TempoProxy>> getTempoProxiesAll() async {
    var dbClient = await db;
    var result = await dbClient.query(theTempoTableHandler,
        columns: theTempoColumns, where: '1');

    return result.map((e) => TempoProxy.fromMap(e)).toList();
  }

  Future<int> getTempoProxiesCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient
        .rawQuery('SELECT COUNT(*) FROM $theTempoTableHandler  WHERE 1'));
  }

  Future<TempoProxy> getTempo(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(theTempoTableHandler,
        columns: theTempoColumns, where: '1 AND id = ?', whereArgs: [id]);

    if (result.length > 0) {
      return TempoProxy.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteTempo(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(theTempoTableHandler, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> deleteTempoProxiesAll() async {
    var dbClient = await db;
    await dbClient.delete(theTempoTableHandler);
    return true;
  }

  Future<int> updateTempo(TempoProxy instanceTempo) async {
    var dbClient = await db;

    return await dbClient.update(theTempoTableHandler, instanceTempo.toMap(),
        where: "id = ?", whereArgs: [instanceTempo.id]);
  }
}
