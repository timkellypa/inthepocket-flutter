import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/table_base_override.dart';
import 'package:in_the_pocket/repository/repository_base.dart';
import 'package:in_the_pocket/repository/track_repository.dart';

class SetListRepository extends RepositoryBase<Setlist> {
  @override
  Future<List<Setlist>> fetch(
      {bool Function(Setlist)? filter,
      String? whereClause,
      String? whereParameter}) async {
    SetlistFilterBuilder setListQuery = Setlist().select();
    if (whereClause != null) {
      setListQuery =
          setListQuery.where(whereClause, parameterValue: whereParameter);
    }

    List<Setlist> setLists =
        await setListQuery.orderBy(TableBase.SORT_ORDER_COLUMN).toList();

    if (filter != null) {
      setLists = setLists.where(filter).toList();
    }

    return setLists;
  }

  @override
  Future<String> insert(Setlist item) async {
    item.init();
    item.sortOrder = await Setlist().select().toCount() + 1;
    await item.upsert();
    return item.id!;
  }

  @override
  Future<String> update(Setlist item) async {
    await item.upsert();
    return item.id!;
  }

  @override
  Future<void> delete(String id) async {
    final Setlist? setlist = await Setlist().getById(id);
    final List<SetlistTrack>? setlistTracks =
        await setlist?.getSetlistTracks()?.toList(preload: true);

    if (setlistTracks != null) {
      for (SetlistTrack setlistTrack in setlistTracks) {
        await TrackRepository().delete(setlistTrack.id!);
      }
    }
    await setlist?.delete();
  }
}
