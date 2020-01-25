// GENERATED CODE - DO NOT MODIFY THIS HEADER
// **************************************************************************
// Generator: vscode-f-orm-m8
// Version: 0.1.8
// Database: Sqlite
// Timestamp: 1573874693623
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

enum SetListType { master, event }

@DataTable('set_lists')
class SetList implements DbEntity, SortableModelBase {
  @DataColumn('id',
      metadataLevel: ColumnMetadata.primaryKey | ColumnMetadata.autoIncrement)
  @override
  int id;

  @DataColumn('guid',
      metadataLevel: ColumnMetadata.indexed | ColumnMetadata.unique)
  @override
  String guid;

  @DataColumn('description', metadataLevel: 0)
  String description;

  @DataColumn('sort_order', metadataLevel: 0)
  @override
  int sortOrder;

  @DataColumn('date', metadataLevel: 0)
  DateTime date;

  @DataColumn('location', metadataLevel: 0)
  String location;

  @DataColumn('set_list_type', metadataLevel: 0)
  int setListType;
}
