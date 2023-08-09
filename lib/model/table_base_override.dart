import 'package:in_the_pocket/model/model_base.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart' as sqf_entity show TableBase;
import 'package:sqfentity_gen/sqfentity_gen.dart';

/// Override TableBase to also implement ModelBase,
/// so it can be used in the same ways as models created from other providers,
/// namely sortability and unique ID generation
class TableBase extends sqf_entity.TableBase implements ModelBase {
  static const String SORT_ORDER_COLUMN = 'row__sortOrder';
  static const String ID_COLUMN = 'row__id';

  @override
  String? get id {
    return (this as dynamic).row__id as String?;
  }

  @override
  set id (String? value) {
    (this as dynamic).row__id = value;
  }

  @override
  int? get sortOrder {
    return (this as dynamic).row__sortOrder as int?;
  }

  @override
  set sortOrder (int? value) {
    (this as dynamic).row__sortOrder = value;
  }

  @override
  ConjunctionBase distinct({List<String>? columnsToSelect, bool? getIsDeleted}) {
    throw UnimplementedError('must implement distinct in child class');
  }

  @override
  void init() {
    // kind of roundabout, but need to call super through a static.
    ModelBase.build(this);
  }

  @override
  void rollbackPk() {
    throw UnimplementedError('must implement rollbackPk in child class');
  }

  @override
  ConjunctionBase select({List<String>? columnsToSelect, bool? getIsDeleted}) {
    throw UnimplementedError('must implement select in child class');
  }

  @override
  List<dynamic> toArgs() {
    throw UnimplementedError('must implement toArgs in child class');
  }

  @override
  List<dynamic> toArgsWithIds() {
    throw UnimplementedError('must implement toArgsWithIds in child class');
  }

  @override
  String toJson() {
    throw UnimplementedError('must implement toJson in child class');
  }

  @override
  Future<String> toJsonWithChilds() {
    throw UnimplementedError('must implement toJsonWithChilds in child class');
  }

  @override
  Map<String, dynamic> toMap({bool forQuery = false, bool forJson = false, bool forView = false}) {
    throw UnimplementedError('must implement toMap in child class');
  }

  @override
  Future<Map<String, dynamic>> toMapWithChildren([bool forQuery = false, bool forJson = false, bool forView = false]) {
    throw UnimplementedError('must implement toMapWithChildren in child class');
  }
}