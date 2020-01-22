import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';

import '../model_card_state_base.dart';

mixin MultiSelectModelCard<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> on ModelCardStateBase<WidgetType, ModelType> {
  @override
  Widget getLeading() {
    bool isSelected = false;
    bool isDisabled = false;
    if (selectedItemMap[model.guid] != null) {
      isSelected =
          selectedItemMap[model.guid].selectionType & SelectionType.selected >
              0;
      isDisabled =
          selectedItemMap[model.guid].selectionType & SelectionType.disabled >
              0;
    }
    return InkWell(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            size: 26.0,
            color: isDisabled ? Colors.grey : Colors.purple,
          ),
        ),
      ),
    );
  }
}
