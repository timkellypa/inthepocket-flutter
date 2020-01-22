// GENERATED CODE - DO NOT MODIFY THIS HEADER
// **************************************************************************
// Generator: vscode-f-orm-m8
// Version: 0.1.8
// Database: Sqlite
// Timestamp: 1573874842242
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
import 'package:in_the_pocket/models/independent/sortable_model_base.dart';

@DataTable('tempos')
class Tempo implements DbEntity, SortableModelBase {
  @DataColumn('id',
      metadataLevel: ColumnMetadata.primaryKey | ColumnMetadata.autoIncrement)
  @override
  int id;

  @DataColumn('guid',
      metadataLevel: ColumnMetadata.indexed | ColumnMetadata.unique)
  @override
  String guid;

  @DataColumn('sort_order', metadataLevel: 0)
  @override
  int sortOrder;

  @DataColumn('track_id', metadataLevel: 0)
  int trackId;

  @DataColumn('bpm', metadataLevel: 0)
  double bpm;

  @DataColumn('beats_per_bar', metadataLevel: 0)
  int beatsPerBar;

  @DataColumn('beat_unit', metadataLevel: 0)
  int beatUnit;

  @DataColumn('dotted_quarter_accent', metadataLevel: 0)
  bool dottedQuarterAccent;

  @DataColumn('accent_beats_per_bar', metadataLevel: 0)
  int accentBeatsPerBar;

  @DataColumn('number_of_bars', metadataLevel: 0)
  num numberOfBars;

  @DataColumn('display_text', metadataLevel: ColumnMetadata.ignore)
  String get displayText {
    return '$bpm BPM ($beatsPerBar/$beatUnit)';
  }
}
