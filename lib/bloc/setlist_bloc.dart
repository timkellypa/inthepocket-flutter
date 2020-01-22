import 'dart:async';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/repository/setlist_repository.dart';

import 'model_bloc_base.dart';

class SetListBloc extends ModelBlocBase<SetListProxy, SetListRepository> {
  SetListBloc({this.importTargetSetList}) : super();

  final SetListProxy importTargetSetList;

  bool firstFetch = true;

  @override
  SetListRepository get repository {
    return SetListRepository();
  }

  @override
  String get listTitle {
    return 'Setlists';
  }

  @override
  Future<List<SetListProxy>> fetch() async {
    final List<SetListProxy> setLists = await getItemList();
    if (importTargetSetList != null && firstFetch) {
      firstFetch = false;

      for (SetListProxy setList in setLists) {
        if (setList.id == importTargetSetList.id) {
          selectItem(setList, SelectionType.disabled);
        }
      }
    }

    listController.sink.add(setLists);
    return setLists;
  }

  @override
  Future<void> insert(SetListProxy item) async {
    await repository.insert(item);
    fetch();
  }

  @override
  Future<void> update(SetListProxy item) async {
    await repository.update(item);
    fetch();
  }

  @override
  Future<void> delete(SetListProxy item) async {
    await repository.delete(item.id);
    fetch();
  }
}
