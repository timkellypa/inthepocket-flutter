import 'dart:async';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/setlist_repository.dart';

import 'model_bloc_base.dart';

class SetlistBloc extends ModelBlocBase<Setlist, SetListRepository> {
  SetlistBloc({this.importTargetSetlist}) : super();

  final Setlist? importTargetSetlist;

  bool firstFetch = true;

  @override
  String get listTitle {
    return 'Setlists';
  }

  @override
  Future<List<Setlist>> fetch() async {
    final List<Setlist> setlists = await getItemList();
    if (firstFetch) {
      firstFetch = false;

      for (Setlist setlist in setlists) {
        if (setlist.id == importTargetSetlist?.id) {
          selectItem(setlist, SelectionType.disabled);
        }
      }
    }

    syncList(setlists);
    return setlists;
  }

  @override
  Future<void> insert(Setlist item) async {
    await repository.insert(item);
  }

  @override
  Future<void> update(Setlist item) async {
    await repository.update(item);
  }

  @override
  Future<void> delete(Setlist item) async {
    await repository.delete(item.id!);
  }
  
  @override
  SetListRepository get repository => SetListRepository();
}
