import 'package:flutter/material.dart';
import 'package:in_the_pocket/model/model_base.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';

mixin DismissableModelCard<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> on ModelCardStateBase<WidgetType, ModelType> {
  final DismissDirection _dismissDirection = DismissDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    final Widget original = super.build(context);
    return Dismissible(
      background: Container(
        child: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Deleting',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        color: Colors.redAccent,
      ),
      onDismissed: (DismissDirection direction) {
        getBloc(context).delete(model);
      },
      direction: _dismissDirection,
      key: ObjectKey(model),
      child: original,
    );
  }
}
