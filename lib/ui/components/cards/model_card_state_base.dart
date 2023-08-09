import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/model_base.dart';

abstract class ModelCardStateBase<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> extends State<WidgetType> {
  ModelType get model;
  HashMap<String, ItemSelection> get selectedItemMap;

  int get itemSelectionType {
    final int returnVal = selectedItemMap[model.id]?.selectionType ?? 0;
    return returnVal;
  }

  Widget? getLeading() {
    return null;
  }

  void tapAction() {

  }

  Widget getListTile(String title) {
    return ListTile(
      enabled: !(itemSelectionType & SelectionType.disabled > 0),
      onTap: tapAction,
      leading: getLeading(),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16.5,
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Color getColor() {
    const int positiveSelectionTypes =
        SelectionType.add + SelectionType.editing + SelectionType.selected;
    return itemSelectionType & positiveSelectionTypes > 0
        ? Colors.blueAccent
        : Colors.white;
  }

  ModelBlocBase<ModelType, dynamic> getBloc(BuildContext context);
}
