// GENERATED CODE - DO NOT MODIFY THIS HEADER
// **************************************************************************
// Generator: vscode-f-orm-m8
// Version: 0.1.8
// Database: Sqlite
// Timestamp: 1573874784680
// **************************************************************************
//
// WARNING: If you alter the lines above, on future updates
//          the extension will skip this file
//
// USER CODE - FROM THIS LINE YOU ARE FREE TO MODIFY THE CONTENT
//
// The model respect f-orm-m8 framework annotations system
// More info on: https://github.com/matei-tm/f-orm-m8
//
// You are free and also responsible to add your own fields
//   and annotate according to f-orm-m8
//
// If you changed this file you must
//   re-run the extension
//   f-orm-m8: Generate Sqlite Fixture
//   from the command pallette

import 'package:f_orm_m8/f_orm_m8.dart';

@DataTable('tracks')
class Track implements DbEntity {
  @DataColumn('id',
      metadataLevel: ColumnMetadata.primaryKey | ColumnMetadata.autoIncrement)
  @override
  int id;

  @DataColumn('title', metadataLevel: 0)
  String title;

  @DataColumn('spotifyId', metadataLevel: 0)
  String spotifyId;

  @DataColumn('spotifyAudioFeatures', metadataLevel: 0)
  String spotifyAudioFeatures;
}
