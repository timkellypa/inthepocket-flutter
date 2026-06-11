import 'dart:async';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/setlist_repository.dart';

import 'model_bloc_base.dart';

class SetlistBloc extends ModelBlocBase<Setlist, SetListRepository> {
  SetlistBloc({this.importTargetSetlist}) : super();

  final Setlist? importTargetSetlist;

  @override
  String get listTitle {
    return 'Setlists';
  }

  @override
  Future<Setlist> buildNewItem() async {
    final Setlist item = Setlist().init() as Setlist;
    item.sortOrder = await Setlist().select().toCount() + 1;
    return item;
  }

  @override
  Future<List<Setlist>> fetch() async {
    final List<Setlist> setlists = await getItemList();

    for (Setlist setlist in setlists) {
      if (setlist.id == importTargetSetlist?.id) {
        selectItem(setlist, SelectionType.disabled,
            allowMultiSelect: true,
            allowSelectionToggle: false,
            verifyItemExists: false);
      }
    }

    syncList(setlists);
    return setlists;
  }

  @override
  Future<void> upsert(Setlist item) async {
    await repository.upsert(item);
    fetch();
  }

  @override
  Future<void> delete(Setlist item) async {
    await repository.delete(item.id!);
  }

  @override
  SetListRepository get repository => SetListRepository();
}
