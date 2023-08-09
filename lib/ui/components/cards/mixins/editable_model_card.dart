import 'package:flutter/material.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/model_base.dart';

import '../model_card_state_base.dart';

mixin EditableModelCard<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> on ModelCardStateBase<WidgetType, ModelType> {
  @override
  Widget getLeading() {
    return InkWell(
      onTap: () {
        getBloc(context).selectItem(
          model,
          SelectionType.editing,
        );
      },
      child: Container(
        child: const Padding(
          padding: EdgeInsets.all(15.0),
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
