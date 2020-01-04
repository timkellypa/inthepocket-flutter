import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

class SetListRepository extends RepositoryBase<SetListProxy> {
  @override
  Future<List<SetListProxy>> fetch({Function filter}) async {
    final List<SetListProxy> setLists = await dbProvider.getSetListProxiesAll();
    setLists.sort(
        (SetListProxy a, SetListProxy b) => a.sortOrder.compareTo(b.sortOrder));
    return setLists;
  }

  @override
  Future<int> insert(SetListProxy item) async {
    final int id = await dbProvider.saveSetList(item);
    item.id = id;
    item.sortOrder = id;
    return await dbProvider.updateSetList(item);
  }

  @override
  Future<int> update(SetListProxy item) => dbProvider.updateSetList(item);

  @override
  Future<int> delete(int id) => dbProvider.deleteSetList(id);
}
