import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';

import '../loading.dart';

typedef CardCreator<T, ModelType> = T Function(
    ModelType item, HashMap<ModelType, ItemSelection> selectedItemMap);

abstract class ModelListBase<ModelType extends ModelBase,
    CardType extends Widget> extends StatelessWidget {
  const ModelListBase(this.creator, {this.excludeIds = const <int>[]});

  final CardCreator<CardType, ModelType> creator;

  final List<int> excludeIds;

  @override
  Widget build(BuildContext context) {
    final ModelBlocBase<dynamic, dynamic> modelBloc = getBloc(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
      child: Container(
        //This is where the magic starts
        child: StreamBuilder<List<ModelType>>(
          stream: modelBloc.items,
          builder:
              (BuildContext context, AsyncSnapshot<List<ModelType>> itemList) {
            return StreamBuilder<HashMap<ModelType, ItemSelection>>(
              stream: modelBloc.selectedItems,
              initialData: HashMap<ModelType, ItemSelection>(),
              builder: (
                BuildContext innerContext,
                AsyncSnapshot<HashMap<ModelType, ItemSelection>>
                    selectedItemMap,
              ) =>
                  getCardWidgets(
                modelBloc,
                itemList,
                selectedItemMap,
              ),
            );
          },
        ),
      ),
    );
  }

  String get addItemText;

  CardType createCard(
      ModelType item, HashMap<ModelType, ItemSelection> selectedItemMap) {
    return creator(item, selectedItemMap);
  }

  ModelBlocBase<dynamic, dynamic> getBloc(BuildContext context);

  Widget getCardWidgets(
    ModelBlocBase<dynamic, dynamic> modelBloc,
    AsyncSnapshot<List<ModelType>> itemListStream,
    AsyncSnapshot<HashMap<ModelType, ItemSelection>> selectedItemMap,
  ) {
    /*Since most of our operations are asynchronous
    at initial state of the operation there will be no stream
    so we need to handle it if this was the case
    by showing users a processing/loading indicator*/
    if (itemListStream.hasData) {
      /*Also handles whenever there's stream
      but returned returned 0 records of SetList from DB.
      If that the case show user that you have empty SetLists
      */

      itemListStream.data.removeWhere((ModelBase item) {
        return excludeIds.contains(item.id);
      });

      if (itemListStream.data.isNotEmpty) {
        return ReorderableListView(
          header: Text(modelBloc.listTitle),
          children: itemListStream.data
              .map<CardType>(
                (ModelType item) => createCard(
                  item,
                  selectedItemMap.data,
                ),
              )
              .toList(),
          onReorder: (int fromIndex, int toIndex) async {
            final int iterator = toIndex > fromIndex ? -1 : 1;

            toIndex = iterator == -1 ? toIndex - 1 : toIndex;

            final int mobileSortOrder = itemListStream.data[toIndex].sortOrder;

            int i = toIndex;

            while (i != fromIndex) {
              // set each item's order index to the next one in the direction we are going.
              itemListStream.data[i].sortOrder =
                  itemListStream.data[i + iterator].sortOrder;
              await modelBloc.update(itemListStream.data[i]);
              i += iterator;
            }

            itemListStream.data[fromIndex].sortOrder = mobileSortOrder;
            await modelBloc.update(itemListStream.data[fromIndex]);
          },
        );
      } else {
        return Container(
            child: Center(
          child: Container(
            child: Text(
              addItemText,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
            ),
          ),
        ));
      }
    } else {
      return Center(
        child: Loading(),
      );
    }
  }
}
