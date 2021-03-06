// GENERATED CODE - DO NOT MODIFY BY HAND
// Emitted on: 2020-01-25 00:01:00.167331

// **************************************************************************
// Generator: OrmM8GeneratorForAnnotation
// **************************************************************************

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:in_the_pocket/models/independent/setlist.dart';

class SetListProxy extends SetList {
  SetListProxy();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['guid'] = guid;
    map['description'] = description;
    map['sort_order'] = sortOrder;
    map['date'] = date.millisecondsSinceEpoch;
    map['location'] = location;
    map['set_list_type'] = setListType;

    return map;
  }

  SetListProxy.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.guid = map['guid'];
    this.description = map['description'];
    this.sortOrder = map['sort_order'];
    this.date = DateTime.fromMillisecondsSinceEpoch(map['date']);
    this.location = map['location'];
    this.setListType = map['set_list_type'];
  }
}

mixin SetListDatabaseProvider {
  Future<Database> db;
  final theSetListColumns = [
    "id",
    "guid",
    "description",
    "sort_order",
    "date",
    "location",
    "set_list_type"
  ];

  final String theSetListTableHandler = 'set_lists';
  Future createSetListTable(Database db) async {
    await db.execute('''CREATE TABLE $theSetListTableHandler (
    id INTEGER  PRIMARY KEY AUTOINCREMENT,
    guid TEXT ,
    description TEXT ,
    sort_order INTEGER ,
    date INTEGER ,
    location TEXT ,
    set_list_type INTEGER ,
    UNIQUE (guid)
    )''');
    await db.execute(
        '''CREATE INDEX ix_${theSetListTableHandler}_guid ON $theSetListTableHandler (guid)''');
  }

  Future<int> saveSetList(SetListProxy instanceSetList) async {
    var dbClient = await db;

    var result =
        await dbClient.insert(theSetListTableHandler, instanceSetList.toMap());
    return result;
  }

  Future<List<SetListProxy>> getSetListProxiesAll() async {
    var dbClient = await db;
    var result = await dbClient.query(theSetListTableHandler,
        columns: theSetListColumns, where: '1');

    return result.map((e) => SetListProxy.fromMap(e)).toList();
  }

  Future<int> getSetListProxiesCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient
        .rawQuery('SELECT COUNT(*) FROM $theSetListTableHandler  WHERE 1'));
  }

  Future<SetListProxy> getSetList(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(theSetListTableHandler,
        columns: theSetListColumns, where: '1 AND id = ?', whereArgs: [id]);

    if (result.length > 0) {
      return SetListProxy.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteSetList(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(theSetListTableHandler, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> deleteSetListProxiesAll() async {
    var dbClient = await db;
    await dbClient.delete(theSetListTableHandler);
    return true;
  }

  Future<int> updateSetList(SetListProxy instanceSetList) async {
    var dbClient = await db;

    return await dbClient.update(
        theSetListTableHandler, instanceSetList.toMap(),
        where: "id = ?", whereArgs: [instanceSetList.id]);
  }
}
