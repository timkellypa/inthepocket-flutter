import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
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
      onDismissed: (DismissDirection direction) async {
        final ModelBlocBase<ModelType, dynamic> bloc = getBloc(context);

        // update UI.
        bloc.itemList.remove(model);
        bloc.syncList(bloc.itemList);

        // delete from DB, but no need to wait.
        bloc.delete(model);
      },
      direction: _dismissDirection,
      key: ObjectKey(model),
      child: original,
    );
  }
}
