// GENERATED CODE - DO NOT MODIFY BY HAND
// Emitted on: 2020-01-01 23:47:28.536906

// **************************************************************************
// Generator: OrmM8GeneratorForAnnotation
// **************************************************************************

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:in_the_pocket/models/independent/setlist_track.dart';

class SetListTrackProxy extends SetListTrack {
  SetListTrackProxy();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['sort_order'] = sortOrder;
    map['song_id'] = trackId;
    map['song_set_id'] = setListId;
    map['notes'] = notes;

    return map;
  }

  SetListTrackProxy.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.sortOrder = map['sort_order'];
    this.trackId = map['song_id'];
    this.setListId = map['song_set_id'];
    this.notes = map['notes'];
  }
}

mixin SetListTrackDatabaseProvider {
  Future<Database> db;
  final theSetListTrackColumns = [
    "id",
    "sort_order",
    "song_id",
    "song_set_id",
    "notes"
  ];

  final String theSetListTrackTableHandler = 'setlist_tracks';
  Future createSetListTrackTable(Database db) async {
    await db.execute('''CREATE TABLE $theSetListTrackTableHandler (
    id INTEGER  PRIMARY KEY AUTOINCREMENT,
    sort_order INTEGER ,
    song_id INTEGER ,
    song_set_id INTEGER ,
    notes TEXT 
    )''');
  }

  Future<int> saveSetListTrack(SetListTrackProxy instanceSetListTrack) async {
    var dbClient = await db;

    var result = await dbClient.insert(
        theSetListTrackTableHandler, instanceSetListTrack.toMap());
    return result;
  }

  Future<List<SetListTrackProxy>> getSetListTrackProxiesAll() async {
    var dbClient = await db;
    var result = await dbClient.query(theSetListTrackTableHandler,
        columns: theSetListTrackColumns, where: '1');

    return result.map((e) => SetListTrackProxy.fromMap(e)).toList();
  }

  Future<int> getSetListTrackProxiesCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT COUNT(*) FROM $theSetListTrackTableHandler  WHERE 1'));
  }

  Future<SetListTrackProxy> getSetListTrack(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(theSetListTrackTableHandler,
        columns: theSetListTrackColumns,
        where: '1 AND id = ?',
        whereArgs: [id]);

    if (result.length > 0) {
      return SetListTrackProxy.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteSetListTrack(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(theSetListTrackTableHandler, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> deleteSetListTrackProxiesAll() async {
    var dbClient = await db;
    await dbClient.delete(theSetListTrackTableHandler);
    return true;
  }

  Future<int> updateSetListTrack(SetListTrackProxy instanceSetListTrack) async {
    var dbClient = await db;

    return await dbClient.update(
        theSetListTrackTableHandler, instanceSetListTrack.toMap(),
        where: "id = ?", whereArgs: [instanceSetListTrack.id]);
  }
}
