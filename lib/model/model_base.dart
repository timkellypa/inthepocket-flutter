import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// All base models will have a GUID ID and a sort order.
class ModelBase {
  String? id;
  int? sortOrder;
  GlobalKey get cardKey {
    _cardKey ??= GlobalKey();
    return _cardKey!;
  }

  GlobalKey? _cardKey;

  void init() {
    ModelBase.build(this);
  }

  static void build(ModelBase modelBase) {
    modelBase.id ??= const Uuid().v4();
  }
}
