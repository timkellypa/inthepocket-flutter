import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';

import '../model_card_state_base.dart';

mixin SelectableModelCard<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> on ModelCardStateBase<WidgetType, ModelType> {
  @override
  Function getTapAction() {
    return () {
      bool isSelected = false;
      if (selectedItemMap[model] != null) {
        isSelected =
            selectedItemMap[model].selectionType & SelectionType.selected > 0;
      }

      if (!isSelected) {
        getBloc(context).selectItem(
          selectedItemMap,
          model,
          SelectionType.selected,
        );
      } else {
        getBloc(context).unSelectItem(
          selectedItemMap,
          model,
          SelectionType.selected,
        );
      }
    };
  }
}
