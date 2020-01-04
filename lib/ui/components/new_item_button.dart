import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

class NewItemButton<ModelType extends ModelBase> extends StatelessWidget {
  const NewItemButton({Key key, @required this.modelBloc}) : super(key: key);

  final ModelBlocBase<Object, RepositoryBase<Object>> modelBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HashMap<ModelType, ItemSelection>>(
        stream: modelBloc.selectedItems,
        initialData: HashMap<ModelType, ItemSelection>(),
        builder: (BuildContext innerContext,
            AsyncSnapshot<HashMap<ModelType, ItemSelection>>
                selectedItemMapSnapshot) {
          return Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 0),
              child: FloatingActionButton(
                elevation: 5.0,
                heroTag: 'add_item',
                onPressed: () {
                  modelBloc.selectItem(
                      selectedItemMapSnapshot.data, null, SelectionType.add);
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.indigoAccent,
                ),
              ));
        });
  }
}
