// ignore_for_file: unused_import, always_specify_types

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart' hide TableBase;

import 'table_base_override.dart';

part 'setlistdb.g.dart';

// BEGIN setlistdb.db MODEL

// BEGIN TABLES

const tableSetlist = SqfEntityTable(
    tableName: 'Setlist',
    primaryKeyName: 'row__id',
    primaryKeyType: PrimaryKeyType.text,
    fields: [
      SqfEntityField('description', DbType.text),
      SqfEntityField('row__sortOrder', DbType.integer),
      SqfEntityField('date', DbType.datetime),
      SqfEntityField('location', DbType.text),
      SqfEntityField('setlistType', DbType.integer),
    ]);

const tableTrack = SqfEntityTable(
  tableName: 'Track',
    primaryKeyName: 'row__id',
    primaryKeyType: PrimaryKeyType.text,
    fields: [
      SqfEntityField('title', DbType.text),
      SqfEntityField('notes', DbType.text),

      // unused, only for model base abstraction
      SqfEntityField('row__sortOrder', DbType.integer, defaultValue: 1),
      SqfEntityField('spotifyId', DbType.text),
      SqfEntityField('spotifyAudioFeatures', DbType.text),
      SqfEntityField('countOutBars', DbType.text),

    ]);

const tableSetlistTrack = SqfEntityTable(
    tableName: 'SetlistTrack',
    primaryKeyName: 'row__id',
    primaryKeyType: PrimaryKeyType.text,
    fields: [
      SqfEntityField('row__sortOrder', DbType.integer),
      SqfEntityField('notes', DbType.text),
      SqfEntityFieldRelationship(
          parentTable: tableSetlist,
          deleteRule: DeleteRule.NO_ACTION,
          fieldName: 'setlistId',
          isPrimaryKeyField: false),
      SqfEntityField('setlistType', DbType.integer),
      SqfEntityFieldRelationship(
        parentTable: tableTrack,
        deleteRule: DeleteRule.NO_ACTION,
        fieldName: 'trackId',
        isPrimaryKeyField: false),
    ]);

const tableTempo = SqfEntityTable(
    tableName: 'Tempo',
    primaryKeyName: 'row__id',
    primaryKeyType: PrimaryKeyType.text,
    fields: [
      SqfEntityField('row__sortOrder', DbType.integer),
      SqfEntityField('bpm', DbType.real),
      SqfEntityField('beatsPerBar', DbType.integer, defaultValue: 4),
      SqfEntityField('beatUnit', DbType.integer, defaultValue: 4),
      SqfEntityField('dottedQuarterAccent', DbType.bool, defaultValue: false),
      SqfEntityField('accentBeatsPerBar', DbType.integer, defaultValue: 1),
      SqfEntityField('numberOfBars', DbType.real, defaultValue: 1000),
      SqfEntityFieldRelationship(
        parentTable: tableTrack,
        deleteRule: DeleteRule.NO_ACTION,
        fieldName: 'trackId',
        isPrimaryKeyField: false),
    ]);

// END TABLES

// BEGIN DATABASE MODEL
@SqfEntityBuilder(setlistdb)
const setlistdb = SqfEntityModel(
    modelName: 'setlistdb',
    databaseName: 'setlistdb_v1.0.0+1.db',
    databaseTables: [
      tableSetlist,
      tableSetlistTrack,
      tableTrack,
      tableTempo
    ]
);
// END setlistdb.db MODEL