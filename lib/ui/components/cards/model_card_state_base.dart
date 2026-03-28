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

  void tapAction({bool allowMultiSelect = false}) {}

  Widget getListTile(String title) {
    const int positiveSelectionTypes =
        SelectionType.add + SelectionType.editing + SelectionType.selected;
    final bool isSelected = itemSelectionType & positiveSelectionTypes > 0;
    
    return ListTile(
      enabled: !(itemSelectionType & SelectionType.disabled > 0),
      onTap: tapAction,
      leading: getLeading(),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.5,
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
        ),
      ),
    );
  }

  Color getColor() {
    const int positiveSelectionTypes =
        SelectionType.add + SelectionType.editing + SelectionType.selected;
    return itemSelectionType & positiveSelectionTypes > 0
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.65)
        : Theme.of(context).cardColor;
  }

  ModelBlocBase<ModelType, dynamic> getBloc(BuildContext context);
}
