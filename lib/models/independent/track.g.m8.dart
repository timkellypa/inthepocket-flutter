// GENERATED CODE - DO NOT MODIFY BY HAND
// Emitted on: 2020-01-15 22:24:45.451474

// **************************************************************************
// Generator: OrmM8GeneratorForAnnotation
// **************************************************************************

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:in_the_pocket/models/independent/track.dart';

class TrackProxy extends Track {
  TrackProxy();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['spotifyId'] = spotifyId;
    map['spotifyAudioFeatures'] = spotifyAudioFeatures;

    return map;
  }

  TrackProxy.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.spotifyId = map['spotifyId'];
    this.spotifyAudioFeatures = map['spotifyAudioFeatures'];
  }
}

mixin TrackDatabaseProvider {
  Future<Database> db;
  final theTrackColumns = ["id", "title", "spotifyId", "spotifyAudioFeatures"];

  final String theTrackTableHandler = 'tracks';
  Future createTrackTable(Database db) async {
    await db.execute('''CREATE TABLE $theTrackTableHandler (
    id INTEGER  PRIMARY KEY AUTOINCREMENT,
    title TEXT ,
    spotifyId TEXT ,
    spotifyAudioFeatures TEXT 
    )''');
  }

  Future<int> saveTrack(TrackProxy instanceTrack) async {
    var dbClient = await db;

    var result =
        await dbClient.insert(theTrackTableHandler, instanceTrack.toMap());
    return result;
  }

  Future<List<TrackProxy>> getTrackProxiesAll() async {
    var dbClient = await db;
    var result = await dbClient.query(theTrackTableHandler,
        columns: theTrackColumns, where: '1');

    return result.map((e) => TrackProxy.fromMap(e)).toList();
  }

  Future<int> getTrackProxiesCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient
        .rawQuery('SELECT COUNT(*) FROM $theTrackTableHandler  WHERE 1'));
  }

  Future<TrackProxy> getTrack(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(theTrackTableHandler,
        columns: theTrackColumns, where: '1 AND id = ?', whereArgs: [id]);

    if (result.length > 0) {
      return TrackProxy.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteTrack(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(theTrackTableHandler, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> deleteTrackProxiesAll() async {
    var dbClient = await db;
    await dbClient.delete(theTrackTableHandler);
    return true;
  }

  Future<int> updateTrack(TrackProxy instanceTrack) async {
    var dbClient = await db;

    return await dbClient.update(theTrackTableHandler, instanceTrack.toMap(),
        where: "id = ?", whereArgs: [instanceTrack.id]);
  }
}
