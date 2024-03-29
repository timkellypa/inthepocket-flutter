import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/model_base.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

class NewItemButton<ModelType extends ModelBase> extends StatelessWidget {
  const NewItemButton({Key? key, required this.modelBloc}) : super(key: key);

  final ModelBlocBase<ModelBase, RepositoryBase<ModelBase>> modelBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HashMap<String, ItemSelection>>(
        stream: modelBloc.selectedItems,
        initialData: HashMap<String, ItemSelection>(),
        builder: (BuildContext innerContext,
            AsyncSnapshot<HashMap<String, ItemSelection>>
                selectedItemMapSnapshot) {
          return Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 0),
              child: FloatingActionButton(
                elevation: 5.0,
                heroTag: 'add_item',
                onPressed: () {
                  modelBloc.selectItem(null, SelectionType.add);
                },
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.indigoAccent,
                ),
              ));
        });
  }
}
