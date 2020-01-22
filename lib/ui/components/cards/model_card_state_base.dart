import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';

abstract class ModelCardStateBase<WidgetType extends StatefulWidget,
    ModelType extends ModelBase> extends State<WidgetType> {
  ModelType get model;
  HashMap<String, ItemSelection> get selectedItemMap;

  int get itemSelectionType {
    int returnVal = selectedItemMap[model.guid]?.selectionType;
    returnVal ??= 0;
    return returnVal;
  }

  Widget getLeading() {
    return null;
  }

  Function getTapAction() {
    return null;
  }

  Widget getListTile(String title) {
    return ListTile(
      enabled: !(itemSelectionType & SelectionType.disabled > 0),
      onTap: getTapAction(),
      leading: getLeading(),
      title: Text(
        title,
        style: TextStyle(
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
