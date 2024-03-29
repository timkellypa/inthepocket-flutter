import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/model_base.dart';

import '../model_card_state_base.dart';

mixin SelectableModelCard<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> on ModelCardStateBase<WidgetType, ModelType> {
  @override
  void tapAction({bool allowMultiSelect = false}) {
    getBloc(context).selectItem(
      model,
      SelectionType.selected,
      allowMultiSelect: allowMultiSelect
    );
  }
}
