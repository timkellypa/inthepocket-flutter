import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';

import '../model_card_state_base.dart';

mixin EditableModelCard<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> on ModelCardStateBase<WidgetType, ModelType> {
  @override
  Widget getLeading() {
    return InkWell(
      onTap: () {
        getBloc(context).selectItem(
          selectedItemMap,
          model,
          SelectionType.editing,
        );
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(
            Icons.edit,
            size: 26.0,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}
