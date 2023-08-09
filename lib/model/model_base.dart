import 'package:uuid/uuid.dart';

/// All base models will have a GUID ID and a sort order.
class ModelBase {
  String? id;
  int? sortOrder;

  void init () {
    ModelBase.build(this);
  }

  static void build (ModelBase modelBase) {
    modelBase.id ??= const Uuid().v4();
  }
}
