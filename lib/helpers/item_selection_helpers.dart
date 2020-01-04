import 'dart:collection';

import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';

class ItemSelectionHelpers {
  static List<ModelType> getItemSelectionMatches<ModelType extends ModelBase>(
      HashMap<ModelType, ItemSelection> map, int selectionType) {
    final List<ModelType> models = <ModelType>[];

    map.forEach((ModelType model, ItemSelection itemSelection) {
      if (itemSelection.selectionType & selectionType > 0) {
        models.add(model);
      }
    });

    return models;
  }
}
